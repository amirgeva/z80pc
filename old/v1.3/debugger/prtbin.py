

def f(a):
    a = [int(i, 16) for i in a]
    a = [str(bin(i))[2:] for i in a]
    a = ['0' * (8 - len(s)) + s for s in a]
    print(a)

def c():
    f('03 03 ef e3 03 03 43 e3 cb c3 7b 17 b7 43 4b eb bb 03 03 63 ff 03 fb 03'.split())
    f('06 06 ef e6 03 07 47 e6 cf c7 7f 17 b6 47 4f ef be 06 06 67 ff 06 ff 06'.split())


a=list(range(3,65))
s=' '.join([str(s) for s in a])
print(s)