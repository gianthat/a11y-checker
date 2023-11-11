#!/bin/bash

# Default output format
OUTPUT_FORMAT="html"

# Check for output format flag
while getopts "f:" opt; do
  case $opt in
    f) OUTPUT_FORMAT="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Remove processed options from arguments
shift $((OPTIND-1))

# Script to run IBM Equal Access Accessibility Checker (achecker) on given domains

# Function to check if a command exists
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# Check for required command: wkhtmltopdf and achecker
if ! command_exists achecker; then
  echo "Error: This script requires 'achecker'. Please install it first."
  exit 1
fi

# Check if domains are provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-f format] domain1[,domain2,...]"
  exit 1
fi

# Split the domain argument into an array
IFS=',' read -ra DOMAINS <<< "$1"

# Current date and time for filename
CURRENT_DATETIME=$(date "+%Y%m%d-%H%M%S")

# Create a temporary file to store URLs
URL_FILE="urls-$CURRENT_DATETIME.txt"
touch "$URL_FILE"

# Write each domain to the file, prepending with https:// if necessary
for DOMAIN in "${DOMAINS[@]}"; do
  if [[ ! $DOMAIN =~ ^https?:// ]]; then
    DOMAIN="https://$DOMAIN"
  fi
  echo "$DOMAIN" >> "$URL_FILE"
done

# Run IBM Equal Access Accessibility Checker and capture output
LOG_FILE="achecker-log-$CURRENT_DATETIME.txt"
npx achecker --outputFormat "$OUTPUT_FORMAT" --outputFolder "." "$URL_FILE" >"$LOG_FILE" 2>&1

# Report generation and renaming
for DOMAIN in "${DOMAINS[@]}"; do
  if [ -f "${DOMAIN}.${OUTPUT_FORMAT}" ]; then
    echo "Report generated for $DOMAIN: a11y-check-${DOMAIN}-$CURRENT_DATETIME.${OUTPUT_FORMAT}"
  else
    echo "No report generated for $DOMAIN"
  fi
done

# Clean up the URL file
rm "$URL_FILE"
