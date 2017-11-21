#!/usr/bin/python3
# put your demo script here
# A number is perfect if it's equal to the sum of its divisors, itself excluded. Prompt user to input a number n(n > 2), get
# all perfect number between 2 and n.

import sys

sys.stdout.write("Input an interger: ")
n = int(sys.stdin.readline())

L = []
for i in range(2, n+1):
    L.append(i)

R = []
for i in range(len(L)):
    x = L[i]
    sum = 0
    for j in range(1, x):
        if(x % j == 0):
            sum = sum + j
    if sum == x:
        R.append(x)

print("Perfect numbers are: ")
for i in range(len(R)):
    print(R[i])
