#!/bin/bash

# Simple Server Stats Script

echo "==================================="
echo "SERVER PERFORMANCE STATISTICS"
echo "==================================="
echo ""

# 1. Total CPU Usage
echo "CPU USAGE:"
top -bn1 | grep "Cpu(s)" | awk '{print "Total CPU Usage: " 100 - $8 "%"}'
echo ""

# 2. Memory Usage
echo "MEMORY USAGE:"
free -m | awk 'NR==2{printf "Total: %sMB\nUsed: %sMB\nFree: %sMB\nUsage: %.2f%%\n", $2, $3, $4, $3*100/$2}'
echo ""

# 3. Disk Usage
echo "DISK USAGE:"
df -h / | awk 'NR==2{printf "Total: %s\nUsed: %s\nFree: %s\nUsage: %s\n", $2, $3, $4, $5}'
echo ""

# 4. Top 5 Processes by CPU
echo "TOP 5 PROCESSES BY CPU:"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-10s %5s %10s\n", $11, $3"%", $2}'
echo ""

# 5. Top 5 Processes by Memory
echo "TOP 5 PROCESSES BY MEMORY:"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-10s %5s %10s\n", $11, $4"%", $2}'
