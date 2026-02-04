#!/bin/bash


LOG_FILE="${1:-/home/test_task/log_analysis/nginx.log}"
CSV_FILE="${2:-nginx_parsed.csv}"
COMMIT_MSG="${3:-"Add new options"}"   

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Converting logs to CSV
awk '
BEGIN {
    print "IP,Date,Method,URL,Code,Size,Referer,User_Agent"
}
/^[0-9]+\./ {  # Тільки рядки з IP
    ip=$1
    date=$4
    method=$5      
    url=$6           
    code=$9
    size=$10
    referer=$11

    ua=""
    for(i=12; i<=NF; i++){ ua=ua (ua?" ":"") $i }

    gsub(/"/, "", date)
    gsub(/"/, "", method) 
    gsub(/"/, "", url)
    gsub(/"/, "", referer)
    gsub(/"/, "", ua)

    print ip "," date "," method "," url "," code "," size "," referer "," ua
}
' "$LOG_FILE" > "$CSV_FILE"

echo "CSV created: $CSV_FILE"

# Git commit з твоїм коментарем
if git diff --quiet --exit-code; then
    echo "No changes to commit"
else
    git add "$CSV_FILE"
    git commit -m "$COMMIT_MSG"
    git push origin main
fi

echo "Done!"

