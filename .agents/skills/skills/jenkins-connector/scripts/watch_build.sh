#!/bin/bash
# .agent/skills/jenkins-connector/scripts/watch_build.sh
# Monitors a Jenkins build.
# Supports both Multibranch Pipeline and Simple Parameterized Pipeline.
# Exit Codes:
# 0 = Success (Green)
# 1 = Build Failure (Red -> Test/Lint issues)
# 2 = System Error (Infra/Timeout/Network -> Do not attempt to fix code)

# Parse optional flags
ONLY_NEW=false
QUEUE_ID=""
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --only-new) ONLY_NEW=true ;;
        --queue-id) ;; # value handled below
        *) POSITIONAL+=("$arg") ;;
    esac
done

# Handle --queue-id value (need to re-parse to get the value after the flag)
ARGS=("$@")
for i in "${!ARGS[@]}"; do
    if [ "${ARGS[$i]}" = "--queue-id" ]; then
        QUEUE_ID="${ARGS[$((i+1))]}"
        # Remove from positional
        POSITIONAL=()
        for j in "${!ARGS[@]}"; do
            [[ "$j" == "$i" || "$j" == "$((i+1))" ]] && continue
            case "${ARGS[$j]}" in
                --only-new) ;;
                *) POSITIONAL+=("${ARGS[$j]}") ;;
            esac
        done
        break
    fi
done

if [ -n "$QUEUE_ID" ]; then
    # --queue-id mode: branch is optional
    if [ "${#POSITIONAL[@]}" -lt 1 ]; then
        echo "Usage: $0 <JobName> --queue-id <ID>"
        exit 2
    fi
    JOB_NAME="${POSITIONAL[0]}"
    BRANCH_NAME="${POSITIONAL[1]:-}"
else
    if [ "${#POSITIONAL[@]}" -lt 2 ]; then
        echo "Usage: $0 <JobName> <BranchName> [--only-new]"
        echo "       $0 <JobName> --queue-id <ID>"
        exit 2
    fi
    JOB_NAME="${POSITIONAL[0]}"
    BRANCH_NAME="${POSITIONAL[1]}"
fi

TIMEOUT_MINUTES=25
MAX_RETRIES=5 # For network glitches

JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
    echo "Error: JENKINS_USER and JENKINS_TOKEN must be set."
    exit 2
fi

# Timestamps
START_TIME=$(date +%s)
END_TIME=$((START_TIME + (TIMEOUT_MINUTES * 60)))
if [ "$ONLY_NEW" == "true" ]; then
    WATCH_START=$((START_TIME * 1000)) # epoch millis — builds older than this are ignored
    echo "🔒 --only-new: only builds started after $(date -d @$START_TIME '+%H:%M:%S') will be accepted."
fi

# ─── Queue ID Resolution ───
# If --queue-id is provided, poll the queue API until we get a build number
if [ -n "$QUEUE_ID" ]; then
    echo "🔗 Resolving queue item #$QUEUE_ID to build number..."
    QUEUE_RETRIES=0
    QUEUE_MAX_WAIT=120 # 2 minutes max waiting in queue
    QUEUE_START=$(date +%s)

    while true; do
        QUEUE_ELAPSED=$(( $(date +%s) - QUEUE_START ))
        if [ "$QUEUE_ELAPSED" -ge "$QUEUE_MAX_WAIT" ]; then
            echo "❌ Timeout waiting for queue item #$QUEUE_ID to start (${QUEUE_MAX_WAIT}s)."
            exit 2
        fi

        QUEUE_RESPONSE=$(curl -s --max-time 10 -u "$JENKINS_USER:$JENKINS_TOKEN" \
            "${JENKINS_URL}/queue/item/${QUEUE_ID}/api/json" 2>/dev/null)

        if [ -z "$QUEUE_RESPONSE" ]; then
            echo "⏳ Queue API returned empty response. Retrying..."
            sleep 3
            continue
        fi

        # Check if cancelled
        CANCELLED=$(echo "$QUEUE_RESPONSE" | jq -r '.cancelled // false' 2>/dev/null)
        if [ "$CANCELLED" = "true" ]; then
            echo "❌ Queue item #$QUEUE_ID was cancelled."
            exit 2
        fi

        # Check if build started (executable.number is set)
        RESOLVED_BUILD=$(echo "$QUEUE_RESPONSE" | jq -r '.executable.number // empty' 2>/dev/null)
        if [ -n "$RESOLVED_BUILD" ]; then
            echo "✅ Queue item #$QUEUE_ID → Build #$RESOLVED_BUILD"

            # If no branch was provided, extract it from the queue item parameters
            if [ -z "$BRANCH_NAME" ]; then
                BRANCH_NAME=$(echo "$QUEUE_RESPONSE" | jq -r \
                    '[.actions[]?.parameters? // [] | .[]? | select(.name == "CHECKOUT") | .value] | first // empty' 2>/dev/null)
                [ -z "$BRANCH_NAME" ] && BRANCH_NAME="unknown"
                echo "   Branch: $BRANCH_NAME"
            fi
            break
        fi

        # Still waiting in queue
        WHY=$(echo "$QUEUE_RESPONSE" | jq -r '.why // empty' 2>/dev/null)
        echo -ne "\r⏳ Queue item #$QUEUE_ID waiting... ${WHY:+(${WHY})} [${QUEUE_ELAPSED}s]   "
        sleep 3
    done
fi

# ─── Initialize variables ───
LAST_BUILD_NUMBER=""
LOCKED_BUILD=""
RETRY_COUNT=0
STAGE_LINES_PRINTED=0

# If queue ID resolved a build, pre-lock onto it
if [ -n "$QUEUE_ID" ] && [ -n "$RESOLVED_BUILD" ]; then
    LOCKED_BUILD="$RESOLVED_BUILD"
    BUILD_API_URL="$JENKINS_URL/job/$JOB_NAME/$RESOLVED_BUILD/api/json"
    echo "🔒 Locked on build #$RESOLVED_BUILD via queue ID"
else
    # Detect Mode (standard path)
    if [[ "$JOB_NAME" == *"/"* ]]; then
        echo "🔍 Detected Multibranch path in JobName."
    else
        echo "🔍 Detected Simple Parameterized Pipeline: $JOB_NAME"
    fi
    BUILD_API_URL="$JENKINS_URL/job/$JOB_NAME/lastBuild/api/json"
fi

echo "Monitoring $JOB_NAME for branch $BRANCH_NAME..."
echo "TIMEOUT: $TIMEOUT_MINUTES minutes (Auto-abort at $(date -d @$END_TIME '+%H:%M:%S'))"

# --- Stage Feedback via wfapi ---
render_stages() {
  local BUILD_NUMBER="$1"
  local IS_FINAL="${2:-false}" # "true" when build is done (final render)
  local WFAPI_URL="$JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER/wfapi/describe"
  local WF_RESPONSE
  WF_RESPONSE=$(curl -s --max-time 5 -u "$JENKINS_USER:$JENKINS_TOKEN" "$WFAPI_URL" 2>/dev/null)

  if [ -z "$WF_RESPONSE" ]; then
      return 1
  fi

  # Parse stages using jq
  local PARSED
  PARSED=$(echo "$WF_RESPONSE" | jq -r '.stages[]? | "\(.name)\t\(.status)\t\(.durationMillis // 0)"' 2>/dev/null)

  if [ -z "$PARSED" ]; then
      return 1
  fi

  # Build stage lines into an array
  local -a LINES=()
  while IFS=$'\t' read -r name status duration_ms; do
      local icon duration_str

      # Format duration
      if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ]; then
          local secs=$((duration_ms / 1000))
          if [ "$secs" -ge 60 ]; then
              duration_str="$((secs / 60))m$((secs % 60))s"
          else
              duration_str="${secs}s"
          fi
      else
          duration_str="..."
      fi

      # Pick icon
      case "$status" in
          SUCCESS)           icon="✅" ;;
          FAILED|ABORTED)    icon="❌" ;;
          IN_PROGRESS)       icon="🔄" ;;
          NOT_EXECUTED)      icon="⏭️" ; duration_str="skipped" ;;
          *)                 icon="⏳" ;;
      esac

      LINES+=("  $icon $name ($duration_str)")
  done <<< "$PARSED"

  local TOTAL_LINES=$(( ${#LINES[@]} + 1 )) # +1 for header line

  # Move cursor up to overwrite previous stage output
  if [ "$STAGE_LINES_PRINTED" -gt 0 ]; then
      echo -ne "\033[${STAGE_LINES_PRINTED}A"
  fi

  # Print header + stages (each line clears to end to remove leftover chars)
  echo -e "\033[K🏗️  Build #$BUILD_NUMBER — Pipeline Stages:"
  for line in "${LINES[@]}"; do
      echo -e "\033[K$line"
  done

  STAGE_LINES_PRINTED=$TOTAL_LINES

  return 0
}

# --- Main Loop ---
while true; do
  CURRENT_TIME=$(date +%s)
  if [ "$CURRENT_TIME" -ge "$END_TIME" ]; then
      echo "❌ Error: Timeout reached ($TIMEOUT_MINUTES min). Build is taking too long."
      exit 2
  fi

  # Fetch with HTTP Code validation
  RESPONSE_FULL=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "$JENKINS_USER:$JENKINS_TOKEN" "$BUILD_API_URL")
  HTTP_CODE=$(echo "$RESPONSE_FULL" | grep "HTTP_CODE" | awk -F: '{print $2}')
  RESPONSE=$(echo "$RESPONSE_FULL" | sed 's/HTTP_CODE:.*//')

  # Handle HTTP Errors
  if [ "$HTTP_CODE" -ne 200 ]; then
      echo "⚠️  Jenkins API Error: HTTP $HTTP_CODE"
      RETRY_COUNT=$((RETRY_COUNT + 1))

      if [ "$RETRY_COUNT" -gt "$MAX_RETRIES" ]; then
          echo "❌ Critical Error: Jenkins is unreachable (HTTP $HTTP_CODE) after $MAX_RETRIES attempts."
          echo "Response Body: $RESPONSE"
          exit 2
      fi

      sleep 10
      continue
  fi

  # Reset retry count on success
  RETRY_COUNT=0

  if [ -z "$RESPONSE" ]; then
      echo "⏳ Empty response from Jenkins. Waiting..."
      sleep 10
      continue
  fi

  # Extract Build Info
  BUILDING=$(echo "$RESPONSE" | grep -o '"building":\s*true' | head -n 1)
  RESULT=$(echo "$RESPONSE" | grep -o '"result":\s*"[^"]*"' | cut -d'"' -f4)
  NUMBER=$(echo "$RESPONSE" | grep -o '"number":\s*[0-9]*' | head -n 1 | cut -d':' -f2 | tr -d ' ')
  if [ "$ONLY_NEW" == "true" ]; then
      BUILD_TIMESTAMP=$(echo "$RESPONSE" | grep -o '"timestamp":\s*[0-9]*' | head -n 1 | cut -d':' -f2 | tr -d ' ')
  fi

  if [ -z "$NUMBER" ]; then
      echo "⏳ No build history found. Waiting..."
      sleep 10
      continue
  fi

  # Check Parameters (Simple branch matching)
  if echo "$RESPONSE" | grep -q "$BRANCH_NAME"; then
      MATCH="true"
  else
      MATCH="false"
  fi

  # New build detected
  if [ "$NUMBER" != "$LAST_BUILD_NUMBER" ]; then
      if [ "$MATCH" == "true" ]; then
           if [ -z "$LOCKED_BUILD" ]; then
               # --only-new: ignore builds that started BEFORE watch_build.sh was invoked
               if [ "$ONLY_NEW" == "true" ] && [ -n "$BUILD_TIMESTAMP" ] && [ "$BUILD_TIMESTAMP" -lt "$WATCH_START" ]; then
                   echo "⚠️  Build #$NUMBER matches branch but is stale (started $(( (WATCH_START - BUILD_TIMESTAMP) / 1000 ))s before watch). Waiting for newer build..."
               else
                   # First valid match — lock onto this build (Sticky Build)
                   LOCKED_BUILD="$NUMBER"
                   BUILD_API_URL="$JENKINS_URL/job/$JOB_NAME/$NUMBER/api/json"
                   echo "✅ Found matching build #$NUMBER for branch $BRANCH_NAME (locked)"
               fi
          else
              echo "⚠️  Newer build #$NUMBER detected, but staying locked on #$LOCKED_BUILD"
          fi
      else
          if [ -z "$LOCKED_BUILD" ]; then
              echo "⚠️  Build #$NUMBER found, but does not match branch '$BRANCH_NAME'. Waiting..."
          fi
      fi
      LAST_BUILD_NUMBER="$NUMBER"
      if [ "$NUMBER" == "$LOCKED_BUILD" ]; then
          STAGE_LINES_PRINTED=0 # Reset stage tracking only for our locked build
      fi
  fi

  # Report status (only for locked build or multibranch)
  if [[ "$JOB_NAME" == *"/"* ]] || [ "$NUMBER" == "$LOCKED_BUILD" ]; then
      if [ -n "$BUILDING" ]; then
          ELAPSED=$((CURRENT_TIME - START_TIME))
          # Progressive stage-level feedback (overwrites in-place)
          if ! render_stages "$NUMBER"; then
              echo -ne "\r🏗️  Build #$NUMBER is running... [Elapsed: ${ELAPSED}s]   "
          fi
      else
          # Final render — show completed stages
          render_stages "$NUMBER" 2>/dev/null
          echo ""

          echo "🏁 Build #$NUMBER finished."
          echo "📊 Result: $RESULT"

          if [ "$RESULT" == "SUCCESS" ]; then
              exit 0
          elif [ "$RESULT" == "ABORTED" ]; then
               echo "⚠️  Build was ABORTED."
               exit 2 # Treat aborted as infra/human intervention, not code fail
          else
              echo "❌ Build FAILED."
              exit 1 # Code failure
          fi
      fi
  fi

  sleep 10
done
