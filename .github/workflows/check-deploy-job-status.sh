#!/bin/bash
set -e

# Use the timestamp from the previous step
GH_TASK_START="${GH_TASK_START}"
echo "Current GitHub task start: $GH_TASK_START"
sleep 30

# Configuration
POLL_INTERVAL=10
MAX_SUBMISSION_WAIT=6   # 30s initial sleep + (6 × 10s) = 90s (1.5 minutes total)
MAX_COMPLETION_WAIT=30  # 30s initial sleep + (30 × 10s) = 330s (5.5 minutes total)

TRIGGER_ID=$(echo -n "${SERVICE_NAME} ${TRIGGER_UUID}" | jq -sRr @uri)

QUERY_URL="${BROKER_URL}/v1/intention/search?where=%7B%22event.trigger.id%22%3A%22${TRIGGER_ID}%22%7D&offset=0&limit=1"

# Wait for Jenkins to report to the broker (max 1.5 minutes)
for ((i=1; i<=MAX_SUBMISSION_WAIT; i++)); do
  RESPONSE=$(curl -s -X 'POST' \
    "$QUERY_URL" \
    -H 'accept: application/json' \
    -H 'Authorization: Bearer '"${BROKER_JWT}"'' \
    -d '')

  DATA_LENGTH=$(echo "$RESPONSE" | jq '.data | length')

  if [[ -z "$RESPONSE" || "$RESPONSE" == "null" || "$DATA_LENGTH" -eq 0 ]]; then
    if [ $i -eq $MAX_SUBMISSION_WAIT ]; then
      TOTAL_WAIT=$((30 + MAX_SUBMISSION_WAIT*POLL_INTERVAL))
      echo "::error title=Jenkins Not Responding::Jenkins job did not report to broker after ${TOTAL_WAIT} seconds (1.5 minutes)."
      echo "Error: Jenkins job did not report to broker after ${TOTAL_WAIT} seconds."
      exit 1
    fi
    echo "Waiting for Jenkins job to report to broker..."
    sleep $POLL_INTERVAL
    continue
  fi
  break
done

echo "::notice::Jenkins job successfully reported to broker"

# Wait for the Jenkins deployment job to complete (max 5.5 minutes)
for ((i=1; i<=MAX_COMPLETION_WAIT; i++)); do
  RESPONSE=$(curl -s -X 'POST' \
    "$QUERY_URL" \
    -H 'accept: application/json' \
    -H 'Authorization: Bearer '"${BROKER_JWT}"'' \
    -d '')
  CLOSED=$(echo "$RESPONSE" | jq -r '.data[0].closed // false')
  if [[ "$CLOSED" == "true" ]]; then
    echo "::notice::Deployment job completed"
    echo "Deployment job is closed."
    break
  fi
  if [ $i -eq $MAX_COMPLETION_WAIT ]; then
    TOTAL_WAIT=$((30 + MAX_COMPLETION_WAIT*POLL_INTERVAL))
    echo "::warning title=Job Timeout::Deployment job did not complete within ${TOTAL_WAIT} seconds (5.5 minutes)."
    echo "::notice::The job is still running in Jenkins. Please check the Jenkins URL to verify completion status."
    echo "Warning: Deployment job could not complete within ${TOTAL_WAIT} seconds."
    echo "The deployment job is still running. Check the deployment job URL for status."
    exit 0
  fi
  echo "Deployment job still running... waiting ${POLL_INTERVAL}s"
  sleep $POLL_INTERVAL
done

# Extract and display the event URL
EVENT_URL=$(echo "$RESPONSE" | jq -r '.data[0].event.url // empty')
if [[ -n "$EVENT_URL" ]]; then
  echo "Event URL: $EVENT_URL"
  echo "event_url=$EVENT_URL" >> $GITHUB_OUTPUT
else
  echo "Event URL not found in response."
fi

# Check the outcome
STATUS=$(echo "$RESPONSE" | jq -r '.data[0].transaction.outcome // empty')
echo "status=$STATUS" >> $GITHUB_OUTPUT
if [[ "$STATUS" != "success" ]]; then
  echo "::error title=Deployment Failed::Deployment outcome is not success: $STATUS"
  echo "Deployment outcome is not success: $STATUS"
  exit 1
fi

echo "::notice title=Deployment Success::Deployment completed successfully"
