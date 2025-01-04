/datum/mind
	var/quiet_round = FALSE //Won't be picked as target in most cases
	var/accent_name = null // The name of the accent this guy has. NULL implies no accent

/datum/mind/proc/handle_speech(datum/source, mob/speech_args)
	var/static/list/accents_name2regexes // Key is the name of the accent, value is a length-2 list of lists.
	//The first list contains all the regexes marked as being word or phrase replacements. They are replaced first.
	//The second list contains all other regexes and are handled last.
	if(!(accent_name in GLOB.accents_name2file))
		return
	
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/list/phrase2replace = GLOB.accents_name2regexes[accent_name][1] // key is regex, value is replacement
		var/list/word2replace = GLOB.accents_name2regexes[accent_name][2] // key is plaintext word, value is replacement
		var/list/regex2replace = GLOB.accents_name2regexes[accent_name][3] // key is regex, value is replacement
		// First the phrases
		for(var/x in phrase2replace) //Linear time relative to number of phrases
			var/regex/R = x
			var/replace = phrase2replace[x]
			if(islist(replace))
				replace = pick(replace)
			message = R.Replace(message,replace)
		// Then the words
		var/list/words = splittext(message," ")
		for(var/i=1;i <= words.len; ++i)// Linear time relative to number of words spoken by player (times log(number of accent words) because BYOND doesn't use hashtables for some ungodly reason)
			var/word = words[i]
			var/rep = word2replace[lowertext(word)]
			if(!rep)
				continue
			if(islist(rep))
				rep = pick(rep)
			words[i] = set_case(rep,get_case(word))
		message = jointext(words," ")
		// Then the general regexes
		for(var/z in regex2replace) //Linear time relative to number of generic regexe
			var/regex/R = z
			var/replace = regex2replace[z]
			if(islist(replace))
				replace = pick(replace)
			message = R.Replace(message,replace)
	speech_args[SPEECH_MESSAGE] = message
