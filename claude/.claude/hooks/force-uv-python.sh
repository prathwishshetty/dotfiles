#!/bin/bash
set -euo pipefail

input_json="$(cat)"
command="$(printf '%s' "$input_json" | jq -r '.tool_input.command // empty')"
trimmed_command="$(printf '%s' "$command" | sed -E 's/^[[:space:]]+//')"

allow_with_rewrite() {
  local rewritten_command="$1"
  jq -n \
    --arg command "$rewritten_command" \
    '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "Rewrote Python or pip usage to uv",
        updatedInput: {
          command: $command
        }
      }
    }'
}

deny_with_reason() {
  local reason="$1"
  jq -n \
    --arg reason "$reason" \
    '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
}

contains_bare_python() {
  local cmd="$1"
  printf '%s\n' "$cmd" | grep -Eq '(^|[[:space:];(|&])python3?([[:space:]]|$)'
}

rewrite_with_uv_pip() {
  local cmd="$1"
  printf '%s' "$cmd" | sed -E \
    -e 's/^python3[[:space:]]+-m[[:space:]]+pip[[:space:]]+install([[:space:]]|$)/uv pip install\1/' \
    -e 's/^python[[:space:]]+-m[[:space:]]+pip[[:space:]]+install([[:space:]]|$)/uv pip install\1/' \
    -e 's/^python3[[:space:]]+-m[[:space:]]+pip[[:space:]]+uninstall([[:space:]]|$)/uv pip uninstall\1/' \
    -e 's/^python[[:space:]]+-m[[:space:]]+pip[[:space:]]+uninstall([[:space:]]|$)/uv pip uninstall\1/' \
    -e 's/^python3[[:space:]]+-m[[:space:]]+pip[[:space:]]+freeze([[:space:]]|$)/uv pip freeze\1/' \
    -e 's/^python[[:space:]]+-m[[:space:]]+pip[[:space:]]+freeze([[:space:]]|$)/uv pip freeze\1/' \
    -e 's/^python3[[:space:]]+-m[[:space:]]+pip[[:space:]]+list([[:space:]]|$)/uv pip list\1/' \
    -e 's/^python[[:space:]]+-m[[:space:]]+pip[[:space:]]+list([[:space:]]|$)/uv pip list\1/' \
    -e 's/^pip3[[:space:]]+install([[:space:]]|$)/uv pip install\1/' \
    -e 's/^pip[[:space:]]+install([[:space:]]|$)/uv pip install\1/' \
    -e 's/^pip3[[:space:]]+uninstall([[:space:]]|$)/uv pip uninstall\1/' \
    -e 's/^pip[[:space:]]+uninstall([[:space:]]|$)/uv pip uninstall\1/' \
    -e 's/^pip3[[:space:]]+freeze([[:space:]]|$)/uv pip freeze\1/' \
    -e 's/^pip[[:space:]]+freeze([[:space:]]|$)/uv pip freeze\1/' \
    -e 's/^pip3[[:space:]]+list([[:space:]]|$)/uv pip list\1/' \
    -e 's/^pip[[:space:]]+list([[:space:]]|$)/uv pip list\1/'
}

case "$trimmed_command" in
  python3\ -m\ pip\ install|"python3 -m pip install "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  python\ -m\ pip\ install|"python -m pip install "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  python3\ -m\ pip\ uninstall|"python3 -m pip uninstall "*|python\ -m\ pip\ uninstall|"python -m pip uninstall "*|python3\ -m\ pip\ freeze|"python3 -m pip freeze "*|python\ -m\ pip\ freeze|"python -m pip freeze "*|python3\ -m\ pip\ list|"python3 -m pip list "*|python\ -m\ pip\ list|"python -m pip list "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  python3\ -m\ pip*|python\ -m\ pip*)
    deny_with_reason "Use uv pip ... instead of pip. Auto-rewrite is only enabled for install, uninstall, freeze, and list."
    exit 0
    ;;
  pip3\ install|"pip3 install "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  pip\ install|"pip install "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  pip3\ uninstall|"pip3 uninstall "*|pip\ uninstall|"pip uninstall "*|pip3\ freeze|"pip3 freeze "*|pip\ freeze|"pip freeze "*|pip3\ list|"pip3 list "*|pip\ list|"pip list "*)
    rewritten_command="$(rewrite_with_uv_pip "$trimmed_command")"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  pip3*|pip*)
    deny_with_reason "Use uv pip ... instead of pip. Auto-rewrite is only enabled for install, uninstall, freeze, and list."
    exit 0
    ;;
  python3|"python3 "*)
    rewritten_command="$(printf '%s' "$trimmed_command" | sed -E 's/^python3([[:space:]]|$)/uv run python\1/')"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  python|"python "*)
    rewritten_command="$(printf '%s' "$trimmed_command" | sed -E 's/^python([[:space:]]|$)/uv run python\1/')"
    allow_with_rewrite "$rewritten_command"
    exit 0
    ;;
  *)
    if contains_bare_python "$trimmed_command"; then
      deny_with_reason "Use uv run python ... instead of python or python3. Auto-rewrite is only enabled when the command starts with python."
      exit 0
    fi
    exit 0
    ;;
esac
