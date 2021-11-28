import os
# Used for counting type defenitions
resultlist = {}
# Get Every File ending with *.dm
result = [os.path.join(dp, f) for dp, dn, filenames in os.walk('.') for f in filenames if os.path.splitext(f)[1] == '.dm']

# Start opening these DM Files
for path in result:
    # UTF-8 Encoding is using in byond now
    try:
        with open(path, encoding="utf-8") as file:
            for line in file:
                formatted_line = ''.join([word for word in line if (word.isalnum() or '/')]).strip('\t').strip('\n')
                if "/" in formatted_line and not "//" in formatted_line and not "/*" in formatted_line:
                    # Have to really make sure this is a type defenition
                    if "=" in formatted_line or "," in formatted_line or (")" in formatted_line or "(" in formatted_line) and not "proc" in formatted_line:
                        continue
                    # Check if the type defenition is valid and not a var
                    for filter in ["/datum", "/atom", "/obj", "/turf", "/mob", "/area"]:
                        if(formatted_line.startswith(filter)):
                            resultlist.setdefault(formatted_line, 0)
                            resultlist[formatted_line] += 1
    except Exception as error:
        print(f"{path} : {error}")

for key in resultlist.keys():
    if resultlist[key] > 1:
        if "techweb" in key: # Techwebs have a duplicate defenition for positioning
            continue
        print(key)
