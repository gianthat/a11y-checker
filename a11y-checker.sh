#!/bin/bash

# Default output format
OUTPUT_FORMAT="html"

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
  local domain="$1"
  local base_domain=$(get_base_domain "$domain")
  local sanitized_domain=${domain//\//_}
  local base_dir="scans/${base_domain}"
  local report_dir="$base_dir"

  # Create base directory for the domain
  mkdir -p "$base_dir"

  # Create report directory for subpages
  if [[ $domain == *"/"* ]]; then
    local subpage=${sanitized_domain#*\/}
    subpage=${subpage%%/*}
    report_dir="$base_dir/$subpage"
    mkdir -p "$report_dir"
  fi

  local log_file="logs/achecker-log-${sanitized_domain}-$CURRENT_DATETIME.txt"
  npx achecker --outputFormat "$OUTPUT_FORMAT" --outputFolder "$report_dir" "$domain" >"$log_file" 2>&1

  local report_file="$report_dir/${sanitized_domain}.${OUTPUT_FORMAT}"
  if [ -f "$report_file" ]; then
    echo "Report generated for $domain: $report_file"
  else
    echo "No report generated for $domain"
  fi
}

# Check for required command: achecker
if ! command_exists achecker; then
  echo "Error: This script requires 'achecker'. Please install it first."
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
mkdir -p logs scans

# Current date and time for filename
CURRENT_DATETIME=$(date "+%Y%m%d-%H%M%S")

# Split the domain argument into an array
IFS=',' read -ra DOMAINS <<< "$1"

# Process each domain
for DOMAIN in "${DOMAINS[@]}"; do
  process_domain "$DOMAIN"
done
