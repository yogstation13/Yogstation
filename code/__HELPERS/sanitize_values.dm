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
	if(List && List.len)
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

/proc/sanitize_hexcolor(color, desired_format= DEFAULT_HEX_COLOR_LEN, include_crunch = TRUE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

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
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				char = lowertext(char)
				. += char
			else
				break
		switch(format_input_ratio)
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	if(length_char(.) == desired_format)
		return crunch + .
	switch(format_input_ratio) //add or remove alpha channel depending on desired format.
		if("3:8", "3:4", "6:4")
			return copytext(., 1, desired_format+1)
		if("4:6", "4:3", "8:3")
			return . + ((desired_format == 4) ? "f" : "ff")
		else //not a supported hex color format.
			return default ? default : crunch + repeat_string(desired_format, "0")

/proc/sanitize_ooccolor(color)
	if(length(color) != length_char(color))
		CRASH("Invalid characters in color '[color]'")
	var/list/HSL = rgb2hsl(hex2num(copytext(color, 2, 4)), hex2num(copytext(color, 4, 6)), hex2num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"
