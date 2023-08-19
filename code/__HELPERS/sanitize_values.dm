//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_float(number, min=0, max=1, accuracy=1, default=0)
	if(isnum(number))
		number = round(number, accuracy)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_islist(value, default)
	if(islist(value) && length(value))
		return value
	if(default)
		return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)
		return value
	if(default)
		return default
	if(List?.len)
		return pick(List)



//more specialised stuff
/proc/sanitize_gender(gender,neuter=0,plural=1, default="male")
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default

/**
  * Sanitize_Hexcolor takes in a color in hexcode as a string, be it shorthand hex as 3 characters, or full-sized 6 digit hex, with or without a leading #
  * you can pass it a full hexcode with leading #, such as "#FFFFFF", and with the default arguments you will get exactly that color back, because it accounts for
  * leading # signs and ignores them, then later in the function will either readd one, or won't depending on what you want.
  * 
  * Full hexcolors will just be validated, shorthand hex of 3 characters can be cleanly converted up to full hex with a leading # no problem.
  * 
  * With default arguments:
  * * "FFF" -> "#FFFFFF"
  * * "#FFFFFF" -> "#FFFFFF"
  * 
  * converting down to short, with or without the # is doable by setting the desired format to the length you want and specifying the crunch to true for adding a # or false to not
  */
/proc/sanitize_hexcolor(color, desired_format = DEFAULT_HEX_COLOR_LEN, include_crunch = TRUE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	//start checks for a leading "#", and if there is it skips past it before doing the color logic.
	//this means you can pass something like "#FFFFFF" into sanitize_hexcolor without arguments, and it will automatically cut the leading #, and readd it at the end
	//there is no risk of accidentally creating a malformed color like ##FFFFFF
	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// Used for conversion between RGBA hex formats.
	var/format_input_ratio = "[desired_format]:[length_char(color)-(start-1)]"

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		i += length(char)
		switch(text2ascii(char))
			if(48 to 57) //numbers 0 to 9
				. += char
			if(97 to 102) //letters a to f
				. += char
			if(65 to 70) //letters A to F
				char = lowertext(char)
				. += char
			else
				break
		switch(format_input_ratio) 
		//if you're trying to convert up from short hex (3 characters) to a full hex 6, that's what these switch statements are doing, adding and removing to meet the desired format
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	if(length_char(.) == desired_format)
		return crunch + .
	switch(format_input_ratio) //add or remove alpha channel depending on desired format.
		if("3:8", "3:4", "6:4")
			return crunch + copytext(., 1, desired_format+1)
		if("4:6", "4:3", "8:3")
			return crunch + . + ((desired_format == 4) ? "f" : "ff")
		else //not a supported hex color format.
			return default ? default : crunch + repeat_string(desired_format, "0")

/proc/sanitize_color(color)
	if(length(color) != length_char(color))
		CRASH("Invalid characters in color '[color]'")
	var/list/HSL = rgb2hsl(hex2num(copytext(color, 2, 4)), hex2num(copytext(color, 4, 6)), hex2num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"
