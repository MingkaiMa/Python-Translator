#!/usr/bin/python3

x=5
while x <= 10 and x >= 0:print(x); x = x+2
if not x > 400: print("oh")

y=123
if y<1 or y >= 100: print("up")

if y == 123:print('y 123')
while y != 0: y=y-1;

z=12
while z>1: z= z * 3;break
print(z)

n=2
print(n<<2)
print(n>>2)

a=60
b=30
c=0
c = a &b
print(c)

c = a | b
print("value of c is: ", c)

c=a ^  b
print(c)

##for ~ operator, because perl has a different number representation,  I cannot handle with that.
