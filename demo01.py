#!/usr/bin/python3
# put your demo script here
# get all prime numbers between 2 and 1000,  then get the sum of these prime numbers.


L = []

for i in range(2, 1001):
    prime_flag = 1
    if i == 2:
        L.append(i)
        continue
    else:
        for n in range(2, i):
            if i % n == 0:
                prime_flag = 0
                break
            else:
                continue
    
    if prime_flag == 1:
        L.append(i)



sum = 0
for i in range(len(L)):
    sum = sum + L[i]

print("sum of all prime numbers between 2 and 1000 is %d" % sum)
