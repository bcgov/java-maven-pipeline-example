#!/usr/bin/env bash

RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" -X 'GET' \
  https://broker.io.nrs.gov.bc.ca/v1/health/token-check \
  -H 'accept: */*' \
  -H 'Authorization: Bearer '"$BROKER_JWT"'' \
  )

if [ "$RESPONSE_CODE" -eq 401 ]; then
  echo "Unauthorized (401)"
  exit 1
elif [ "$RESPONSE_CODE" -eq 403 ]; then
  echo "Invalid JWT: Block list has match"
  exit 1
else
  echo "Response code: $RESPONSE_CODE"
fi