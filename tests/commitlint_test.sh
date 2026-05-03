#!/usr/bin/env bash
# bash_unit tests for scripts/commitlint.sh.
# Fakes `git` and `git-std` on PATH so no real repo or git-std install is needed.

setup_suite() {
  TEST_TMP=$(mktemp -d)
  export TEST_TMP
  export PATH="$TEST_TMP/fakebin:$PATH"
  mkdir -p "$TEST_TMP/fakebin"

  # Fake git-std:
  #   lint --file <path>  -> accept if message starts with "feat:" or "fix:"
  #   lint --range <range> -> accept if range is non-empty string
  cat > "$TEST_TMP/fakebin/git-std" <<'EOS'
#!/usr/bin/env bash
if [ "${1:-}" != "lint" ]; then
  echo "unexpected git-std command: $*" >&2; exit 2
fi
shift  # drop "lint"
case "${1:-}" in
  --file)
    msg=$(cat "$2")
    case "$msg" in
      feat:*|fix:*) exit 0 ;;
      *) echo "bad commit message" >&2; exit 1 ;;
    esac
    ;;
  --range)
    [ -n "${2:-}" ] && exit 0
    echo "empty range" >&2; exit 1
    ;;
  *)
    echo "unknown lint mode: $*" >&2; exit 2
    ;;
esac
EOS
  chmod +x "$TEST_TMP/fakebin/git-std"

  # Fake git: delegates `git std` to the fake git-std above.
  cat > "$TEST_TMP/fakebin/git" <<'EOS'
#!/usr/bin/env bash
if [ "${1:-}" = "std" ]; then
  shift
  exec git-std "$@"
fi
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

test_range_mode_passes_non_empty_range() {
  assert "bash scripts/commitlint.sh 'main..HEAD'"
}

test_exits_2_on_no_args() {
  if bash scripts/commitlint.sh >/dev/null 2>&1; then
    exit_code=0
  else
    exit_code=$?
  fi
  assert_equals "2" "$exit_code"
}

test_file_mode_requires_path_arg() {
  assert_fails "bash scripts/commitlint.sh --file"
}
