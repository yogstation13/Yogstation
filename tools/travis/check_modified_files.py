from git import Repo
import sys
index = Repo().index
errors = 0
for i in index.diff(None):
    print("::error file=" + i.b_path + ",line=1::This file has been modified by the git checkout. Probable cause is using the wrong line endings!")
    errors += 1
sys.exit(errors)
