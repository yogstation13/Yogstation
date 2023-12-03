GLOBAL_LIST_EMPTY(pretty_filter_items)
GLOBAL_LIST_EMPTY(minor_filter_items)
GLOBAL_LIST_EMPTY(tts_filter_items)

#define PRETTY_FILTER "pretty"
#define MINOR_FILTER "minor"
#define TTS_FILTER "tts"
GLOBAL_LIST_INIT(pretty_filters, list(
	PRETTY_FILTER = pretty_filter_items,
	MINOR_FILTER = minor_filter_items,
	TTS_FILTER = tts_filter_items,
	))
GLOBAL_PROTECT(pretty_filters)

// Append pretty filter items from file to a list
/proc/setup_pretty_filters()
	var/list/filter_lines = world.file2list("config/pretty_filter.txt")

	for(var/line in filter_lines)
		add_pretty_filter_line(line, PRETTY_FILTER)

	filter_lines = world.file2list("config/minor_filter.txt")
	for(var/line in filter_lines)
		add_pretty_filter_line(line, MINOR_FILTER)

	filter_lines = world.file2list("config/tts_filter.txt")
	for(var/line in filter_lines)
		add_pretty_filter_line(line, TTS_FILTER)

// Add a filter pair
/proc/add_pretty_filter_line(line, filter_type)
	if(findtextEx(line,"#",1,2) || length(line) == 0)
		return
	if(!filter_type)
		return

	//Split the line at every "="
	var/list/parts = splittext(line, "=")
	if(!parts.len)
		return FALSE

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return FALSE

	//replacement follows the first "="
	var/replacement = ""
	if(parts.len >= 2)
		var/index = 2
		for(index = 2; index <= parts.len; index++)
			replacement += parts[index]
			if(index < parts.len)
				replacement += "="

	if(!replacement)
		return FALSE

	pretty_filters[filter_type]?.Add(line)

// List all filters that have been loaded
/client/proc/list_pretty_filters()
	set category = "Server"
	set name = "Pretty Filters - List"

	to_chat(usr, "<font size='3'><b>Pretty filters list</b></font>", confidential=TRUE)
	for(var/line in GLOB.pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		to_chat(usr, "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>", confidential=TRUE)
	to_chat(usr, "<font size='3'><b>End of list</b></font>", confidential=TRUE)

//Filter out and replace unwanted words, prettify sentences
/proc/pretty_filter(text, list/filter = GLOB.pretty_filter_items)
	for(var/line in filter)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		var/regex/R = new(pattern, "ig")
		text = R.Replace(text, replacement)

	return text

/proc/isnotpretty(text) // A simpler version of pretty_filter(), where all it returns is whether it had to replace something or not.
	//Useful for the "You fumble your words..." business.
	for(var/line in GLOB.pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/regex/R = new(pattern, "ig")
		if(R.Find(text)) //If found
			return TRUE // Yes, it isn't pretty.
	return FALSE // No, it is pretty.

//Filter out and replace unwanted but not important words, like WTF or LOL
/proc/minor_filter(text)
	text = text + " " //necessary since some words like "lol" have words like lollard, which means we need to only trigger if there's a space after it, which won't happen at the end of the sentence
	return pretty_filter(text, GLOB.minor_filter_items)

//Filter mispronunciations with phonetic versions i.e. ipc -> eye pee see
/proc/tts_filter(text)
	text = text + " "
	return pretty_filter(text, GLOB.tts_filter_items)
