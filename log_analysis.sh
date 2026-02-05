#!/bin/bash

DEFAULT_LOG="/home/test_task/log_analysis/nginx.log"

# log file based
case "$1" in
    --top|--strings|--status)
        LOG_FILE="${3:-$DEFAULT_LOG}"
        ;;
    *)
        LOG_FILE="${1:-$DEFAULT_LOG}"
        CSV_FILE="${2:-nginx_parsed.csv}"
        ;;
esac

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Git
    git_push_csv() {
    local FILE="$1"
    if [ -f "$FILE" ]; then
        git add "$FILE"
        git commit -m "Update $FILE $(date '+%Y-%m-%d %H:%M:%S')" --allow-empty
        git push
    fi
    }
case "$1" in

    --top)
        N="$2"
        # Extract IPs, count unique, sort by frequency, get top N
        awk '/^[0-9]+\./{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n $N | awk '{print $2","$1}' > "top_$N.csv"
        echo "Top $N IPs saved to top_$N.csv"
        git_push_csv "top_$N.csv"
        ;;

    --status)
        CODE="$2"
        # Filter log entries by status code
        awk -v c="$2" '/^[0-9]+\./ && $9==c' "$LOG_FILE" > "status_$CODE.csv"
        echo "Status $CODE saved to status_$CODE.csv"
        git_push_csv "status_$CODE.csv"
        ;;

    --strings)
        # Show last N log lines - newest entries first
        tail -n "$2" "$LOG_FILE" > "last_strings_$2.csv"
        echo "Last $2 strings saved"
        git_push_csv "last_strings_$2.csv"
        ;;

    *)
        # Parse nginx log to CSV with basic fields
        CSV_FILE="${2:-nginx_parsed.csv}"
        echo "ip,date,protocol,url,status" > "$CSV_FILE"

        awk '{
            match($0,/^([0-9.]+) - - \[([^\]]+)\] "([A-Z]+) ([^"]+) [^"]*" ([0-9]+)/,a);
            if(a[1]!="") print a[1]","a[2]","a[3]","a[4]","a[5]
        }' "$LOG_FILE" >> "$CSV_FILE"

        echo "Parsed log saved to $CSV_FILE"
        git_push_csv "$CSV_FILE"
        ;;
esac

