import sys
if len(sys.argv) < 2 or sys.argv[1][-4:] != ".dme":
    print("No suitable .dme file provided")
    sys.exit(1)

f = open(sys.argv[1])

hasbegun = False
oldline = ""
newline = ""
iswrong = 0
line = 1

for newline in f:
    line = line + 1
    newline = newline.lower()
    if hasbegun:
        if "// end_include" in newline:
            hasbegun = False
        else:
            if newline > oldline or oldline == "":
                oldline = newline
                continue
            else:
                oldsplit = oldline.split("\\")
                newsplit = newline.split("\\")
                if len(oldsplit) != len(newsplit):
                    length = len(oldsplit)-1 if len(oldsplit) < len(newsplit) else len(newsplit)-1
                    for x in range(length):
                        if(oldsplit[x] > newsplit[x]):
                            print("::error file=" + sys.argv[1] + ",line=" + str(line) + "::This line is out of alphabetical order")
                            iswrong += 1
                            break
                    oldline = newline
                    continue

    else:
        if "// begin_include" in newline:
            hasbegun = True
if iswrong > 0:
    print("There are " + str(iswrong) + " lines out of place, please organize the .DME alphabetically.")
f.close()
sys.exit(iswrong)


