# Log analysis tool 
This repository contains a small Bash script called log_analysis.sh that I wrote to work with Nginx access logs.
The goal of the script is to take a standard Nginx access log and make it easier to analyze by converting it into CSV and providing a few simple command-line options.

# Script features
- CSV conversion — converts raw Nginx access logs into a clean, table-friendly CSV format.
- Top IP addresses — finds the N most active client IPs based on request count.
- Status code filtering — extracts requests with a specific HTTP status code (for example, 200 or 404).
- Latest log entries — quickly exports the most recent lines from the log file.
- Git integration — automatically creates a git commit and pushes generated reports to the repository.

# How to use it?
Make the script executable:
```
chmod +x log_analysis.sh
```
Run the script with the default options:
```
./log_analysis.sh
```
This will parse the Nginx access log and generate nginx_parsed.csv.

Get top N IP addresses:
```
./log_analysis.sh --top N
```
Filter by HTTP status code:
```
./log_analysis.sh --status N
```
Export last N log entries:
```
./log_analysis.sh --strings N
```

After each analysis, the script doesn’t just save the CSV file. It also automatically creates a git commit and pushes it to the repository. 
This way, your reports are always stored in Git history with the current date and time.

Thank you!💜



