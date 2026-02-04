#!/bin/bash

DEFAULT_LOG="/home/test_task/log_analysis/nginx.log"

# Recognition log
case "$1" in
    --top)
        LOG_FILE="${2:-$DEFAULT_LOG}"
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
        awk '/^[0-9]+\./{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n $N | awk 'BEGIN{print "IP,Count"}{print $2","$1}' > "top_$N.csv"
        echo "Top $N IPs saved to top_$N.csv"
        ;;
    *)
        awk 'BEGIN{print "IP,date,method,url,code,size,referer,ua"}
        /^[0-9]+\./{
            print $1","$4","$5","$6","$9","$10","$11
        }' "$LOG_FILE" > "$CSV_FILE"
        echo "CSV created: $CSV_FILE"
        ;;
esac
