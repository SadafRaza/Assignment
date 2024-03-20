#!/bin/bash

## Assuming the file NC_000913.faa is in the same directory

a=$(grep "^>" NC_000913.faa | wc -l) ##counting the number of sequences
b=$(grep -v "^>" NC_000913.faa | awk '{ total += length($0) } END { print total }')  ##counting the total number of amino acids
average_length=$((b / a))
echo "Average length of protein in E. coli MG1655 strain: $average_length"
