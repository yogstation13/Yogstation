
# Colon Locater and Reporter, by RemieRichards V1.0 - 25/10/15

# Locates the byond operator ":", which is largely frowned upon due to the fact it ignores any type safety.
# This tool produces a .txt of "filenames line,line?,line totalcolons" (where line? represents a colon in a ternary operation) from all
# .dm files in the /code directory of an SS13 codebase, but can work on any Byond project if you modify scan_dir and real_dir
# the .txt take's todays date in reverse order and adds -colon_operator_log to the end, eg: "2015/10/25-colon_operator_log.txt"

import string
import sys
import os
from datetime import date


#Climbs up from /tools/ColonCatcher and along to ../code
scan_dir = "code" #used later to truncate log file paths
real_dir = os.path.abspath(scan_dir)
print(real_dir)

usedvars = {}

#Scan a directory, scanning any dm files it finds
def colon_scan_dir(scan_dir):
    if os.path.exists(scan_dir):
        if os.path.isdir(scan_dir):

            output_str = ""

            files_scanned = 0
            files_with_colons = 0
            for root, dirs, files in os.walk(scan_dir):
                for f in files:
                    scan_result = scan_dm_file(os.path.join(root, f))
                    files_scanned += 1
                    if scan_result:
                        output_str += scan_result+"\n"
                        files_with_colons += 1
            output_str += str(files_with_colons) + "/" + str(files_scanned) + " files have colons in them"

            todays_file = str(date.today())+"-colon_operator_log.txt"
            output_file = open(todays_file, "w") #w so it overrides existing files for today, there should only really be one file per day
            output_file.write(output_str)



#Scan one file, returning a string as a "report" or if there are no colons, False
def scan_dm_file(_file):
    
    global usedvars
    if not _file.endswith(".dm"):
        return False
    with open(_file, "r", encoding="utf8") as dm_file:
        for line in dm_file:
            if("var" in line):
                if not "for" in line:
                    split = line.split('=')
                    variable = split[0].replace("\t", "").split("/")[-1]
                    usedvars.setdefault(variable, 0)
                    usedvars[variable] += 1

    #print(usedvars)

        
colon_scan_dir(real_dir)

for variable in usedvars:
    if(usedvars[variable]) == 1:
        print(f"Unused: {variable}")
print("Done!")
