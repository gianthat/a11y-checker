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

# Check for required command: achecker
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if ! command_exists achecker; then
  echo "Error: This script requires 'achecker'. Please install it first."
  exit 1
fi

# Check if domains are provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-f format] domain1[,domain2,...]"
  exit 1
fi

# Create logs and scans directories if they don't exist
mkdir -p logs scans

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

# Function to extract and sanitize base domain for directory naming
get_base_domain() {
  local url="$1"
  local domain

  # Replace trailing slash with an underscore if present
  url=${url%/}
  url=${url//\//_}

  # Extract the domain from a URL if necessary
  if [[ $url =~ ^https?://([^/]+) ]]; then
    domain=${BASH_REMATCH[1]}
  else
    domain=$url
  fi

  # Remove 'www.' if present
  domain=${domain#www.}

  # Extract the base domain
  echo $domain | awk -F. '{print $(NF-1)"."$NF}'
}

# Process each domain
for DOMAIN in "${DOMAINS[@]}"; do
  BASE_DOMAIN=$(get_base_domain "$DOMAIN")

  if [ -z "$BASE_DOMAIN" ]; then
    echo "Error extracting base domain for $DOMAIN"
    continue
  fi

  # Directory name based on base domain
  BASE_DIR="scans/${BASE_DOMAIN}-$CURRENT_DATETIME"
  mkdir -p "$BASE_DIR"

  # Subdirectory for subpages
  SUBPAGE_DIR=$(echo $DOMAIN | sed 's/^https:\/\/[^\/]*\///; s/[\/:]/_/g')
  if [ "$SUBPAGE_DIR" != "" ]; then
    mkdir -p "$BASE_DIR/$SUBPAGE_DIR"
    REPORT_DIR="$BASE_DIR/$SUBPAGE_DIR"
  else
    REPORT_DIR="$BASE_DIR"
  fi

  # Run achecker for the domain
  LOG_FILE="logs/achecker-log-$(echo $BASE_DOMAIN | awk -F/ '{print $1}')-$CURRENT_DATETIME.txt"
  npx achecker --outputFormat "$OUTPUT_FORMAT" --outputFolder "$REPORT_DIR" "$URL_FILE" >"$LOG_FILE" 2>&1

  # Rename the report file
  if [ -f "$REPORT_DIR/${DOMAIN}.${OUTPUT_FORMAT}" ]; then
    mv "$REPORT_DIR/${DOMAIN}.${OUTPUT_FORMAT}" "$REPORT_DIR/${DOMAIN//\//_}.${OUTPUT_FORMAT}"
    echo "Report generated for $DOMAIN: $REPORT_DIR/${DOMAIN//\//_}.${OUTPUT_FORMAT}"
  else
    echo "No report generated for $DOMAIN"
  fi
done

# Clean up the URL file
rm "$URL_FILE"
