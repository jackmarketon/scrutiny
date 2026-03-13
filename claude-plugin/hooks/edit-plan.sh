#!/bin/bash
# Launch Tauri plan editor for Claude Code

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(readlink -f "$BASH_SOURCE")")")}"
PLAN_DIR="/tmp/claude-plans"
mkdir -p "$PLAN_DIR"

# Read plan from stdin (JSON payload)
PLAN_JSON=$(cat)

# Extract plan content
PLAN_ID=$(echo "$PLAN_JSON" | jq -r '.id // ("plan-" + (now | tostring))' 2>/dev/null || echo "plan-$(date +%s)")
PLAN_CONTENT=$(echo "$PLAN_JSON" | jq -r '.plan_text // .content // .message // ""' 2>/dev/null || echo "$PLAN_JSON")

# Create plan file
PLAN_FILE="$PLAN_DIR/${PLAN_ID}.md"
echo "$PLAN_CONTENT" > "$PLAN_FILE"

# Launch Tauri app (blocking)
# Assumes the app is built and available in the plugin directory
TAURI_APP="$PLUGIN_ROOT/../target/release/scrutiny"

if [ ! -f "$TAURI_APP" ]; then
    echo "ERROR: Tauri app not found at: $TAURI_APP" >&2
    echo "Build it first with: cd scrutiny && npm run tauri:build" >&2
    exit 1
fi

# Launch with plan path
"$TAURI_APP" "$PLAN_FILE" &
APP_PID=$!

# Wait for app to close
wait $APP_PID

# Check for feedback
FEEDBACK_FILE="${PLAN_FILE}.feedback.json"
if [ -f "$FEEDBACK_FILE" ]; then
    # Send feedback to Claude
    cat "$FEEDBACK_FILE" | jq '{
        type: "plan_feedback",
        comments: .comments,
        diff: .diff,
        edited_plan: .edited_plan,
        message: "User reviewed the plan and provided feedback."
    }'
    
    # Cleanup
    rm -f "$FEEDBACK_FILE"
else
    # No feedback - user cancelled
    echo '{"type": "plan_cancelled", "message": "User cancelled plan review"}'
fi

exit 0
