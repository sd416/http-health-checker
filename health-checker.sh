#!/bin/bash

# Temporary files for storing results
temp_success=$(mktemp)
temp_fail=$(mktemp)
temp_redirect=$(mktemp)

# Function to check a single URL
check_url() {
    url="$1"
    response=$(curl -o /dev/null -s -w "%{http_code}" -m 10 "$url")
    if [ "$response" -ge 200 ] && [ "$response" -lt 300 ]; then
        echo "$url: OK ($response)"
        echo "$url: OK ($response)" >> "$temp_success"
    elif [ "$response" -ge 300 ] && [ "$response" -lt 400 ]; then
        echo "$url: REDIRECT ($response)"
        echo "$url: REDIRECT ($response)" >> "$temp_redirect"
    else
        echo "$url: FAIL ($response)"
        echo "$url: FAIL ($response)" >> "$temp_fail"
    fi
}

# Check if a file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_with_urls>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File not found!"
    exit 1
fi

# Set maximum number of parallel processes
MAX_PROCS=10

# Read URLs from file and check each one
while IFS= read -r url || [ -n "$url" ]; do
    if [ -n "$url" ]; then
        # Run check_url in background
        check_url "$url" &

        # Limit the number of parallel processes
        while [ $(jobs -p | wc -l) -ge $MAX_PROCS ]; do
            sleep 0.1
        done
    fi
done < "$1"

# Wait for all background processes to finish
wait

# Print results
echo -e "\n--- RESULTS ---"
echo "Successful URLs:"
cat "$temp_success"
echo -e "\nRedirected URLs:"
cat "$temp_redirect"
echo -e "\nFailed URLs:"
cat "$temp_fail"
echo -e "\nTotal Successful: $(wc -l < "$temp_success")"
echo "Total Redirected: $(wc -l < "$temp_redirect")"
echo "Total Failed: $(wc -l < "$temp_fail")"

# Clean up temporary files
rm "$temp_success" "$temp_fail" "$temp_redirect"
