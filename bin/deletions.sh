#!/bin/bash

# Get the date 5 years ago in the format required by Git, e.g., "5 years ago"
five_years_ago=$(date -v-5y '+%Y-%m-%d')

# Generate the report from git log
echo "Generating report from $five_years_ago to now..."
git log --shortstat --since="$five_years_ago" --pretty=format:"%an" | \
    awk '/^ / {added += $4; deleted += $6} /^$/ {print added, deleted, author; added = 0; deleted = 0} !/^ / {author = $0}' | \
    awk '{arr[$3 " " $4]+=$1; del[$3 " " $4]+=$2} END {for (i in arr) print arr[i], del[i], i}' | \
    sort -k2 -nr | head -n 10
