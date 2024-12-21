text = open('go.txt').readlines()
y=0
coords=[]
for line in text:
    for x in range(len(line)):
        if line[x]=='@':
            coords.extend([x,y])
    y=y+1
print(coords)