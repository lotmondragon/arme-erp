#!/usr/bin/env bash
# PostToolUse hook: after Claude writes/edits a .ts/.html/.scss file under
# frontend/, run Prettier (using the config already in frontend/package.json)
# so formatting stays consistent without a separate manual step. Best-effort:
# never blocks the agent, even if npx/prettier aren't available.
set -u

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)"

[ -z "$file_path" ] && exit 0
case "$file_path" in
  *.ts|*.html|*.scss) ;;
  *) exit 0 ;;
esac
case "$file_path" in
  */frontend/*) ;;
  *) exit 0 ;;
esac

frontend_dir="$(printf '%s' "$file_path" | sed -E 's#(.*/frontend)/.*#\1#')"
[ -d "$frontend_dir" ] || exit 0
command -v npx >/dev/null 2>&1 || exit 0

(cd "$frontend_dir" && npx --no-install prettier --write "$file_path") >/dev/null 2>&1

exit 0
