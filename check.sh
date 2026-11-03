#!/bin/bash

exit_code=0

# Verify each of the 4 testcases
for i in 1 2 3 4; do
    tc_dir="Testcase$i"
    diff_dir="Testcase${i}Diff"
    passed=1
    has_diff=0

    # Inspect all pairs
    for file1 in "$tc_dir"/*.1.txt; do
        [ -f "$file1" ] || continue
        file2="${file1%.1.txt}.2.txt"
        [ -f "$file2" ] || continue

        base=$(basename "$file1")
        name="${base%.1.txt}"
        diff_file="$diff_dir/${name}Diff.txt"

        # Check if the pair differs
        if ! cmp -s "$file1" "$file2"; then
            has_diff=1
            # Diff file must exist
            if [ ! -f "$diff_file" ]; then
                passed=0
            # Diff contents must match starting from line 3
            elif ! cmp -s <(tail -n +3 "$diff_file") <(diff -u "$file1" "$file2" | tail -n +3); then
                passed=0
            fi
        else
            # Identical pairs must NOT have a diff file
            if [ -f "$diff_file" ]; then
                passed=0
            fi
        fi
    done

    # Check directory existence rules
    if [ "$has_diff" -eq 1 ] && [ ! -d "$diff_dir" ]; then
        passed=0
    elif [ "$has_diff" -eq 0 ] && [ -d "$diff_dir" ]; then
        passed=0
    fi

    # Output exact status format to stdout
    if [ "$passed" -eq 1 ]; then
        echo "Testcase$i: PASS"
    else
        echo "Testcase$i: FAIL"
        exit_code=1
    fi
done

exit "$exit_code"
