#!/bin/bash

# Nginx Log Analyzer
# Author: DevOps Team
# Description: Analyzes nginx access logs for common patterns

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if log file is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No log file provided${NC}"
    echo "Usage: $0 <path-to-nginx-log-file>"
    exit 1
fi

LOG_FILE=$1

# Verify file exists
if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: File '$LOG_FILE' not found${NC}"
    exit 1
fi

echo -e "${GREEN}=== Nginx Log Analysis ===${NC}"
echo -e "Analyzing: ${BLUE}$LOG_FILE${NC}"
echo ""

# Function to print section headers
print_header() {
    echo -e "${YELLOW}$1${NC}"
    echo "----------------------------------------"
}

# 1. TOP 5 IP ADDRESSES
# Logic: Extract first field (IP), sort, count duplicates, sort numerically, get top 5
print_header "Top 5 IP addresses with the most requests:"
awk '{print $1}' "$LOG_FILE" | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -5 | \
    awk '{printf "%s - %d requests\n", $2, $1}'
echo ""

# 2. TOP 5 REQUESTED PATHS
# Logic: Extract the path from the request field (between quotes)
# The request format is: "METHOD /path HTTP/version"
print_header "Top 5 most requested paths:"
awk '{print $7}' "$LOG_FILE" | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -5 | \
    awk '{printf "%s - %d requests\n", $2, $1}'
echo ""

# 3. TOP 5 RESPONSE STATUS CODES
# Logic: Extract status code field (9th field in standard nginx log)
print_header "Top 5 response status codes:"
awk '{print $9}' "$LOG_FILE" | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -5 | \
    awk '{printf "%s - %d requests\n", $2, $1}'
echo ""

# 4. TOP 5 USER AGENTS
# Logic: User agent is typically between the last set of quotes
# We need to extract everything from the last quote pair
print_header "Top 5 user agents:"
awk -F\" '{print $6}' "$LOG_FILE" | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -5 | \
    awk '{count=$1; $1=""; printf "%s - %d requests\n", substr($0,2), count}'
echo ""

echo -e "${GREEN}=== Analysis Complete ===${NC}"
