#!/usr/bin/python3
# put your demo script here
# Prompt usrs to input three numbers, firstly check if these three numbers can form a Pythagorean triple.If yes, print area.
# Otherwise check if these three nubmers can form a triangle,if yes, print perimeter.

import sys

L = []
for i in sys.stdin:
    L.append(int(i))

L = sorted(L)


a=L[0]
b=L[1]
c=L[2]

if a ** 2 + b ** 2 == c ** 2:
    s = (a * b) / 2
    print("Pythagorean triples! area is %d" % s)

else:
    if a + b > c:
        p = a+b+c
        print("Triangle, the Perimeter is %d" % p)
    else:
        print("No triangle")

