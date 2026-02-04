#!/bin/bash

# Usage:
# ./log_analysis.sh [log_path] [csv_name]          # Full CSV
# ./log_analysis.sh --top N [log_path]             # Only top N IPs

DEFAULT_LOG="/home/test_task/log_analysis/nginx.log"
LOG_FILE="${1:-$DEFAULT_LOG}"
CSV_FILE="${2:-nginx_parsed.csv}"
TOP_MODE=0

# Check --top mode
if [ "$1" = "--top" ]; then
    TOP_COUNT="$2"
    LOG_FILE="${3:-$DEFAULT_LOG}"
    TOP_MODE=1
    shift 2
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# MODE 1: Only TOP IPs
if [ $TOP_MODE -eq 1 ]; then
    TOP_FILE="top_ips_${TOP_COUNT}.csv"
    awk '/^[0-9]+\./ {print $1}' "$LOG_FILE" | \
    sort | uniq -c | sort -nr | head -n "$TOP_COUNT" | \
    awk 'BEGIN {print "IP,Requests"} {print $2 "," $1}' > "$TOP_FILE"
    echo "Top $TOP_COUNT IPs → $TOP_FILE"
fi

# MODE 2: Full CSV (default)
if [ $TOP_MODE -eq 0 ]; then
    awk '
    BEGIN { print "IP,Date,Method,URL,HTTP_Code,Size,Referer,User_Agent" }
    /^[0-9]+\./ {
        ip=$1; date=$4; method=$5; url=$6; code=$9; size=$10; referer=$11
        ua=""; for(i=12;i<=NF;i++) ua=ua (ua?" ":"") $i
        gsub(/[\[\]"]/, "", date method url referer ua)
        print ip "," date "," method "," url "," code "," size "," referer "," ua
    }' "$LOG_FILE" > "$CSV_FILE"
    echo "Full CSV → $CSV_FILE"
fi

# COMMIT
if git diff --quiet --exit-code; then
    echo "ℹ️ No changes to commit"
else
    git add .
    if [ $TOP_MODE -eq 1 ]; then
        git commit -m "Top $TOP_COUNT IPs analysis - $(date '+%H:%M')"
    else
        git commit -m "Full nginx log → CSV ($(wc -l < "$CSV_FILE") rows) - $(date '+%H:%M')"
    fi
    git push origin main 2>/dev/null || echo "Pushed locally"
fi

echo "Done!"

