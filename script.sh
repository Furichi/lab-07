#!/bin/bash

# Remove any old Testcase#Diff folders before running
rm -rf Testcase*Diff

# Loop through each testcase directory
for dir in Testcase*/; do
    dir="${dir%/}"
    diff_dir="${dir}Diff"

    # Match each .1.txt file in the folder
    for file1 in "$dir"/*.1.txt; do
        [ -f "$file1" ] || continue
        file2="${file1%.1.txt}.2.txt"
        [ -f "$file2" ] || continue

        # Run diff -u with .1 file first and .2 file second
        # diff exits with code 1 if files differ
        if ! diff -u "$file1" "$file2" > /dev/null 2>&1; then
            mkdir -p "$diff_dir"

            base=$(basename "$file1")
            name="${base%.1.txt}"
            diff_file="$diff_dir/${name}Diff.txt"

            diff -u "$file1" "$file2" > "$diff_file"
        fi
    done
done
