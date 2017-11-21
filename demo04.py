#!/usr/bin/python3
# put your demo script here
# Input strings, store them into array, get the longest string.

import sys

lines = sys.stdin.readlines()

max_len = 0

for i in range(len(lines)):
    if len(lines[i]) > max_len:
        max_len = len(lines[i])

sys.stdout.write("Longest strings are: \n")
for i in range(len(lines)):
    if len(lines[i]) == max_len:
        print(lines[i])
