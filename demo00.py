#!/usr/bin/python3
# put your demo script here
# get the total stopping time of n(n >= 2 and n <= 20), collatz conjecture.


L = []
for i in range(2, 20):
    L.append(i)


R = []
for i in range(len(L)):
    n = 0
    x = L[i]
    while x != 1:
        n = n+ 1
        if x%2 == 0:
            x = int(x / 2)
        else:
            x=3 * x + 1
    R.append(n)


for i in range(len(R)):
    print(R[i])
