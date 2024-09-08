import os
import re
import sys

define_regex = re.compile(r"(\s+)?#define\s?([A-Z0-9_]+)\(?(.+)\)?")

def green(text):
	return "\033[32m" + str(text) + "\033[0m"

def red(text):
	return "\033[31m" + str(text) + "\033[0m"

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

def get_defines(defines_file: str) -> list[str]:
	defines_to_search_for = []
	scannable_lines = []
	with open(defines_file, 'r') as file:
		reading = False

		for line in file:
			line = line.strip()

			if line == "// BEGIN TRAIT DEFINES":
				reading = True
				continue
			elif line == "// END TRAIT DEFINES":
				break
			elif not reading:
				continue

			scannable_lines.append(line)
	for potential_define in scannable_lines:
		match = define_regex.match(potential_define)
		if not match:
			continue
		defines_to_search_for.append(match.group(2))
	return defines_to_search_for

globalvars_file = "code/_globalvars/traits/_traits.dm"

def post_error(file, name):
	if on_github:
		print(f"::error file={file},title=Define Sanity::{name} is defined in {file} but not added to {globalvars_file}!")
	else:
		print(red(f"- Failure: {name} is defined in {file} but not added to {globalvars_file}!"))

if not os.path.isfile(globalvars_file):
	print(red(f"Could not find the globalvars file '{globalvars_file}'!"))
	sys.exit(1)

def run_check_with_file(defines_file: str, min_defines: int = 450):
	how_to_fix_message = f"Please ensure that all traits in the {defines_file} file are added in the {globalvars_file} file."
	if not os.path.isfile(defines_file):
		print(red(f"Could not find the defines file '{defines_file}'!"))
		sys.exit(1)

	defines_to_search_for = get_defines(defines_file)
	missing_defines = []
	number_of_defines = len(defines_to_search_for)

	if number_of_defines == 0:
		print(red("No defines found! This is likely an error."))
		sys.exit(1)

	if number_of_defines <= min_defines:
		print(red(f"Only found {number_of_defines} defines! Something has likely gone wrong as the number of global traits should not be this low."))
		sys.exit(1)

	with open(globalvars_file, "r") as file:
		globalvars_file_contents = file.read()
		for define_name in defines_to_search_for:
			searchable_string = "\"" + define_name + "\" = " + define_name
			if not re.search(searchable_string, globalvars_file_contents):
				missing_defines.append(define_name)

	if len(missing_defines):
		for missing_define in missing_defines:
			post_error(defines_file, missing_define)

		print(red(how_to_fix_message))
		sys.exit(1)

	else:
		print(green(f"All traits were found in both files! (found {number_of_defines} defines)"))

run_check_with_file("code/__DEFINES/traits/declarations.dm")
run_check_with_file("code/__DEFINES/traits/monkestation/declarations.dm", min_defines=25)
