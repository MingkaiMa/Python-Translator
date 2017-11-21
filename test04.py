#!/usr/bin/python3
import sys

list = ['a', 'z', 'd', 'c']
list.append('g')
a = list[3]
print(a)


x = list.pop(2)
print(x)

size = len(list)
print(size)

print(len("abc"))

size1 = len([1,2,3,'sdf'])

print(size1)

T = sorted(list)
print(T[0])

print("%d co" % 1)
print("%d countries, %d states, %d cities." % (1,6,48))

a = len(T)
print(a)

dic = {}

dic[1] = 2;
dic['ha'] = 'p';
print(dic['ha'])


