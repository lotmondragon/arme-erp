#!/usr/bin/env bash
# PostToolUse hook: after Claude writes/edits a .cs file under backend/src or
# backend/tests, build the nearest project so compile errors surface
# immediately instead of at the next `dotnet test`/CI run. Best-effort: never
# blocks the agent, even if dotnet isn't available or the build fails.
set -u

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)"

[ -z "$file_path" ] && exit 0
case "$file_path" in
  *.cs) ;;
  *) exit 0 ;;
esac
case "$file_path" in
  */backend/src/*|*/backend/tests/*) ;;
  *) exit 0 ;;
esac

command -v dotnet >/dev/null 2>&1 || exit 0

dir="$(dirname "$file_path")"
proj=""
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  found="$(find "$dir" -maxdepth 1 -name '*.csproj' 2>/dev/null | head -1)"
  if [ -n "$found" ]; then
    proj="$found"
    break
  fi
  dir="$(dirname "$dir")"
done

[ -z "$proj" ] && exit 0

output="$(cd "$(dirname "$proj")" && dotnet build --nologo -v quiet 2>&1)"
status=$?

if [ $status -ne 0 ]; then
  short="$(printf '%s' "$output" | grep -E 'error ' | head -10)"
  [ -z "$short" ] && short="$(printf '%s' "$output" | tail -20)"
  msg="$(printf 'dotnet build failed for %s:\n%s' "$(basename "$proj")" "$short")"
  jq -n --arg msg "$msg" '{systemMessage: $msg}'
fi

exit 0
