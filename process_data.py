import glob
import time

#from utils.sgf_reader import sgf_reader

file_paths = []

path = "data/aya_self_play"

for i in range(19, 20):
    if i < 10:
        mypath = path + "/0" + str(i)
    else:
        mypath = path + "/" + str(i)

    file_paths += glob.glob(mypath + "/*.sgf")

t = time.time()

letters = []

for path in file_paths[0:10]:
    file = open(path, mode='r')

    lines = file.readlines()

    for i, line in enumerate(lines):

        if i == 0:
            outcome = line.split("RE[")[1].split("]")[0][0]
            print(outcome)

        if i!=0 and line!=" ":
            loc = line[3:5]
            try: loc = [loc[0], loc[1]]
            except: pass
            for m in loc:
                if m not in letters:
                    letters.append(m)
            print(loc)

print(letters)
