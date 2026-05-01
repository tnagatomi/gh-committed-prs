#!/usr/bin/env bats

setup() {
  export TEST_TMPDIR="$BATS_TEST_TMPDIR/fakebin"
  mkdir -p "$TEST_TMPDIR"
  export PATH="$TEST_TMPDIR:$PATH"
  export GH_CALL_LOG="$BATS_TEST_TMPDIR/gh.log"
  export GIT_CALL_LOG="$BATS_TEST_TMPDIR/git.log"

  cat > "$TEST_TMPDIR/git" <<'STUB'
#!/usr/bin/env bash
{ printf 'git'; printf ' %q' "$@"; printf '\n'; } >> "$GIT_CALL_LOG"
case "$1 $2 $3" in
  'config --get user.email')
    echo 'default@example.com'
    ;;
  'log --merges --since=2024-01-01')
    echo 'base feature'
    ;;
  'log -1 --no-merges')
    echo 'abc123'
    ;;
  *)
    exit 1
    ;;
esac
STUB

  cat > "$TEST_TMPDIR/gh" <<'STUB'
#!/usr/bin/env bash
{ printf 'gh'; printf ' %q' "$@"; printf '\n'; } >> "$GH_CALL_LOG"
if [ "$1 $2 $3" = 'repo view --json' ]; then
  echo 'main'
elif [ "$1 $2 $3" = 'pr list --state' ]; then
  echo '[{"number":1,"title":"Example","url":"https://example.test/pr/1","mergedAt":"2024-01-02T03:04:05Z"}]'
else
  exit 1
fi
STUB

  cat > "$TEST_TMPDIR/jq" <<'STUB'
#!/usr/bin/env bash
cat >/dev/null
printf 'NUMBER\tTITLE\tURL\tMERGED AT\n#1\tExample\thttps://example.test/pr/1\t2024-01-02 03:04\n'
STUB

  cat > "$TEST_TMPDIR/column" <<'STUB'
#!/usr/bin/env bash
cat
STUB

  chmod +x "$TEST_TMPDIR/git" "$TEST_TMPDIR/gh" "$TEST_TMPDIR/jq" "$TEST_TMPDIR/column"
}

@test "shows help and exits 2 when no flags are provided" {
  run ./gh-committed-prs

  [ "$status" -eq 2 ]
  [[ "$output" == *"USAGE"* ]]
  [[ "$output" == *"gh committed-prs [flags]"* ]]
}

@test "requires --from" {
  run ./gh-committed-prs --author alice@example.com

  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: --from option is required"* ]]
}

@test "validates date format" {
  run ./gh-committed-prs --from 2024/01/01 --to 2024-01-31

  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: --from date must be in YYYY-MM-DD format"* ]]
}

@test "passes parsed author, dates, and excluded head to git and gh" {
  run ./gh-committed-prs --author alice@example.com --from 2024-01-01 --to 2024-01-31 --exclude-head develop

  [ "$status" -eq 0 ]
  [[ "$output" == *"Collecting commits"* ]]
  [[ "$output" == *"Listing pull requests"* ]]
  [[ "$output" == *"#1"* ]]
  grep -q -- '--author=alice@example.com' "$GIT_CALL_LOG"
  grep -q -- '--until=2024-01-31' "$GIT_CALL_LOG"
  grep -q -- '-head:develop abc123' "$GH_CALL_LOG"
}
