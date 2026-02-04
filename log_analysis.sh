#!/bin/bash

DEFAULT_LOG="/home/test_task/log_analysis/nginx.log"

# log file based
case "$1" in
    --top|--strings|--lines)
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

case "$1" in
    --top)
        N="$2"
# Extract IPs, count unique, sort by frequency, get top N
        awk '/^[0-9]+\./{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n $N | awk '{print $2","$1}' > "top_$N.csv"
        echo "Top $N IPs saved to top_$N.csv"
        ;;
    --status)
        CODE="$2"
# Filter log entries bystatus code
	awk -v c="$2" '/^[0-9]+\./ && $9==c' "$LOG_FILE" > "status_$CODE.csv"
        echo "Status $CODE saved to status_$CODE.csv"
        ;;
	--strings)
 # Show last N log lines - newest entries first
	tail -n "$2" "$LOG_FILE" > "last_strings_$2.csv"
        echo "Last $2 strings saved"
        ;;
    *)
 # Parse nginx log to CSV
        awk 'BEGIN{print "IP,date,method,url,code,size,referer,ua"}
        /^[0-9]+\./{
            print $1","$4","$5","$6","$9","$10","$11
        }' "$LOG_FILE" > "$CSV_FILE"
        echo "CSV created: $CSV_FILE"
        ;;
esac

