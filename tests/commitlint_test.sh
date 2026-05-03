#!/usr/bin/env bash
# bash_unit tests for scripts/commitlint.sh.
# Fakes `git` and `git-std` on PATH so no real repo is needed.

setup_suite() {
  TEST_TMP=$(mktemp -d)
  export TEST_TMP
  export PATH="$TEST_TMP/fakebin:$PATH"
  mkdir -p "$TEST_TMP/fakebin"

  # Fake git-std: accepts messages starting with "feat:" or "fix:"; rejects others.
  cat > "$TEST_TMP/fakebin/git-std" <<'EOS'
#!/usr/bin/env bash
shift  # drop the "lint" sub-command
if [ "${1:-}" = "--stdin" ]; then
  msg=$(cat)
elif [ "${1:-}" = "--file" ]; then
  msg=$(cat "$2")
else
  echo "unknown args" >&2; exit 2
fi
case "$msg" in
  feat:*|fix:*) exit 0 ;;
  *) echo "bad commit message" >&2; exit 1 ;;
esac
EOS
  chmod +x "$TEST_TMP/fakebin/git-std"

  # Fake `git` that delegates `git std` to the fake git-std above.
  cat > "$TEST_TMP/fakebin/git" <<'EOS'
#!/usr/bin/env bash
if [ "${1:-}" = "std" ]; then
  shift
  exec git-std "$@"
fi
# Fall through to real git for everything else.
exec env -i PATH=/usr/bin:/bin HOME="$HOME" git "$@"
EOS
  chmod +x "$TEST_TMP/fakebin/git"
}

teardown_suite() {
  rm -rf "$TEST_TMP"
}

test_file_mode_accepts_good_message() {
  printf 'feat: add feature\n' > "$TEST_TMP/msg"
  assert "bash scripts/commitlint.sh --file '$TEST_TMP/msg'"
}

test_file_mode_rejects_bad_message() {
  printf 'not a conventional commit\n' > "$TEST_TMP/msg"
  assert_fails "bash scripts/commitlint.sh --file '$TEST_TMP/msg'"
}

test_exits_2_on_no_args() {
  assert_fails "bash scripts/commitlint.sh"
  actual_exit=$(bash scripts/commitlint.sh 2>/dev/null; echo $?)
  assert_equals "2" "$(bash scripts/commitlint.sh >/dev/null 2>&1; echo $?) || true"
}

test_file_mode_requires_path_arg() {
  assert_fails "bash scripts/commitlint.sh --file"
}
