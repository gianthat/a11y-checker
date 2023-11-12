#!/bin/bash

# Default output format
OUTPUT_FORMAT="html"
# Navigation timeout in seconds (10 seconds)
NAVIGATION_TIMEOUT=15

# Function to check if required command exists
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# Function to extract and sanitize base domain for directory naming
get_base_domain() {
  local url="$1"
  url=${url#https://}
  url=${url#http://}
  url=${url#www.}
  echo $url | awk -F/ '{print $1}' | awk -F. '{print $(NF-1)"."$NF}'
}

# Function to process each domain
process_domain() {
  local original_domain="$1"
  local domain=${original_domain#https://}
  domain=${domain#http://}
  domain=${domain#www.}
  local base_domain=$(get_base_domain "$domain")
  local sanitized_domain=${domain//\//_}
  local base_dir="scans/$CURRENT_DATETIME/${base_domain}"
  local report_dir="$base_dir"

  mkdir -p "$report_dir"

  local temp_url_file="temp_url-$CURRENT_DATETIME.txt"
  echo "https://$domain" > "$temp_url_file"

  local log_file="logs/achecker-log-${sanitized_domain}-$CURRENT_DATETIME.txt"
  echo "👀 Scanning $original_domain..."

  # Start achecker with timeout
  timeout $NAVIGATION_TIMEOUT npx achecker --policies "WCAG_2_1" --outputFormat "$OUTPUT_FORMAT" --outputFolder "$report_dir" "$temp_url_file" >"$log_file" 2>&1
  exit_status=$?

  # Check exit status for timeout
  if [ $exit_status -eq 124 ]; then
    echo "😴 Error: Navigation timeout exceeded for $original_domain. Check $original_domain in the browser."
  fi

  # Check if a report was generated
  if compgen -G "${report_dir}/*" > /dev/null; then
    echo "✅ Report generated for $original_domain!"
  else
    echo "❌ No report generated for $original_domain."
  fi

  # Clean up temporary URL file
  rm "$temp_url_file"
}

# Check for required command: achecker and timeout
if ! command_exists achecker || ! command_exists timeout; then
  echo "⚠️ This script requires 'achecker' and 'timeout'. Please install them first."
  exit 1
fi

# Parse options
while getopts "f:" opt; do
  case $opt in
    f) OUTPUT_FORMAT="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

shift $((OPTIND-1))

# Check if domains are provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-f format] domain1[,domain2,...]"
  exit 1
fi

# Create necessary directories
mkdir -p logs

# Current date and time for filename
CURRENT_DATETIME=$(date "+%Y%m%d-%H%M%S")
mkdir -p "scans/$CURRENT_DATETIME"

# Split the domain argument into an array
IFS=',' read -ra DOMAINS <<< "$1"

# Process each domain
for DOMAIN in "${DOMAINS[@]}"; do
  process_domain "$DOMAIN"
done
