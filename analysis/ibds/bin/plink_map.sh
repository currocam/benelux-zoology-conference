#!/bin/env bash
# Read chromosome names from stdin and process them
while IFS= read -r chrom; do
    # Skip empty lines
    [[ -z "$chrom" ]] && continue

    # Print formatted lines to stdout
    # This only works for 25cM/Mb!!!
    echo -e "$chrom\trs\t0\t1"
    echo -e "$chrom\trs\t25\t100000"
done
