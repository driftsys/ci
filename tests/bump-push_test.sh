#!/usr/bin/env bash
# bash_unit tests for scripts/bump-push.sh.
# Fakes `git` and `git-std` on PATH.

setup_suite() {
  TEST_TMP=$(mktemp -d)
  export TEST_TMP
  export PATH="$TEST_TMP/fakebin:$PATH"
  mkdir -p "$TEST_TMP/fakebin"
  BUMP_CALLS=0
  PUSH_CALLS=0
  export BUMP_CALLS PUSH_CALLS

  # Fake git-std that records bump calls.
  cat > "$TEST_TMP/fakebin/git-std" <<'EOS'
#!/usr/bin/env bash
if [ "${1:-}" = "bump" ]; then
  echo "bumped" > "$TEST_TMP/bump-called"
  exit 0
fi
echo "unexpected git-std args: $*" >&2
exit 1
EOS
  chmod +x "$TEST_TMP/fakebin/git-std"

  # Fake git: delegates std to git-std, records push calls.
  cat > "$TEST_TMP/fakebin/git" <<'EOS'
#!/usr/bin/env bash
case "${1:-}" in
  std) shift; exec git-std "$@" ;;
  push) echo "pushed" > "$TEST_TMP/push-called"; exit 0 ;;
  *) echo "unexpected git args: $*" >&2; exit 1 ;;
esac
EOS
  chmod +x "$TEST_TMP/fakebin/git"
}

teardown_suite() {
  rm -rf "$TEST_TMP"
}

setup() {
  rm -f "$TEST_TMP/bump-called" "$TEST_TMP/push-called"
}

test_dry_run_skips_push() {
  DRY_RUN=1 bash scripts/bump-push.sh
  assert "[ -f '$TEST_TMP/bump-called' ]"
  assert_fails "[ -f '$TEST_TMP/push-called' ]"
}

test_normal_run_bumps_and_pushes() {
  DRY_RUN=0 REMOTE=origin bash scripts/bump-push.sh
  assert "[ -f '$TEST_TMP/bump-called' ]"
  assert "[ -f '$TEST_TMP/push-called' ]"
}
