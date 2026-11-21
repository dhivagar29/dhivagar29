#!/usr/bin/env bash
# Local mirror of .github/workflows/readme-validation.yml so the same checks
# that gate CI can be run before pushing.
set -euo pipefail

README="README.md"
STATUS=0

echo "== Check README exists and is non-empty =="
if [ ! -f "$README" ]; then
  echo "ERROR: $README not found"
  exit 1
fi
FILE_SIZE=$(stat -c%s "$README")
if [ "$FILE_SIZE" -eq 0 ]; then
  echo "ERROR: $README is empty"
  exit 1
fi
echo "OK: $README found (${FILE_SIZE} bytes)"

echo
echo "== Validate HTML <div> tags are balanced =="
OPEN_DIVS=$(grep -oi '<div' "$README" | wc -l)
CLOSE_DIVS=$(grep -oi '</div>' "$README" | wc -l)
if [ "$OPEN_DIVS" -ne "$CLOSE_DIVS" ]; then
  echo "ERROR: Unbalanced <div> tags: ${OPEN_DIVS} opening vs ${CLOSE_DIVS} closing"
  STATUS=1
else
  echo "OK: HTML div tags are balanced (${OPEN_DIVS} pairs)"
fi

echo
echo "== Check README file size (warn > 50 KB) =="
MAX_SIZE=51200
if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
  echo "WARNING: $README is large (${FILE_SIZE} bytes). Consider optimizing for faster loading."
else
  echo "OK: README size is ${FILE_SIZE} bytes (under ${MAX_SIZE})"
fi

echo
if [ "$STATUS" -ne 0 ]; then
  echo "README validation FAILED"
else
  echo "README validation passed"
fi
exit "$STATUS"
