# URL Status Checker
A simple shell script to check the status of the URLs mentioned in the files.

# Features
- Parallel processing of URLs for faster execution
- Categorizes URLs into three groups: successful, redirected, and failed
- Provides a summary with counts for each category

# Usage
1. Create a  file with one URL per line.
2. Run the script with the filename as an argument:

```bash
./health-checker.sh urls.txt
```

# Notes

- URLs returning 2xx status codes are considered successful.
- URLs returning 3xx status codes are considered redirected.
- All other status codes (including connection failures) are considered failed.
