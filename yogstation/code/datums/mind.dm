/datum/mind
	var/quiet_round = FALSE //Won't be picked as target in most cases
	var/accent_name = null // The name of the accent this guy has. NULL implies no accent


/datum/mind/proc/vampire_hook()
	var/text = "vampire"
	if(SSticker.mode.config_tag == "vampire")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(is_vampire(current))
		text += "<b>VAMPIRE</b> | <a href='?src=\ref[src];vampire=clear'>human</a> | <a href='?src=\ref[src];vampire=full'>full-power</a>"
	else
		text += "<a href='?src=\ref[src];vampire=vampire'>vampire</a> | <b>HUMAN</b> | <a href='?src=\ref[src];vampire=full'>full-power</a>"
	if(current && current.client && (ROLE_VAMPIRE in current.client.prefs.be_special))
		text += " | Enabled in Prefs"
	else
		text += " | Disabled in Prefs"
	return text

/datum/mind/proc/vampire_href(href, mob/M)
	switch(href)
		if("clear")
			remove_vampire(current)
			message_admins("[key_name_admin(usr)] has de-vampired [current].")
			log_admin("[key_name(usr)] has de-vampired [current].")
		if("vampire")
			if(!is_vampire(current))
				message_admins("[key_name_admin(usr)] has vampired [current].")
				log_admin("[key_name(usr)] has vampired [current].")
				add_vampire(current)
			else
				to_chat(usr, "<span class='warning'>[current] is already a vampire!</span>")
		if("full")
			message_admins("[key_name_admin(usr)] has full-vampired [current].")
			log_admin("[key_name(usr)] has full-vampired [current].")
			if(!is_vampire(current))
				add_vampire(current)
				var/datum/antagonist/vampire/V = has_antag_datum(ANTAG_DATUM_VAMPIRE)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()
			else
				var/datum/antagonist/vampire/V = has_antag_datum(ANTAG_DATUM_VAMPIRE)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()

/datum/mind/proc/handle_speech(datum/source, mob/speech_args)
	var/static/list/accents_name2regexes // Key is the name of the accent, value is a length-2 list of lists.
	//The first list contains all the regexes marked as being word or phrase replacements. They are replaced first.
	//The second list contains all other regexes and are handled last.
	if(!accent_name)
		return
	if(!accents_name2regexes)
		accents_name2regexes = list()
		var/list/accent_names = assoc_list_strip_value(GLOB.accents_name2file)
		var/regex/is_phrase = regex(@"\\b[\w \.,;'\?!]+\\b","i")
		var/regex/is_word = regex(@"\\b[\w\.,;'\?!]+\\b","i") // Should be very similar to the above regex, except it doesn't capture on spaces and so only hits plaintext words
		for(var/accent in accent_names)
			var/list/accent_lists = list(list(), list(), list())
			var/list/accent_regex2replace = strings(GLOB.accents_name2file[accent_name], accent_name, directory = "strings/accents") // Key is regex, value is replacement
			for(var/reg in accent_regex2replace)
				if(findtext(reg,is_word)) // If a word
					reg = replacetext(reg,@"\b","") // Remove the \b, because we'll be treating this as a straight thing to replace
					accent_lists[2][reg] =	accent_regex2replace[reg] // These numerical indices mark their priority
				else if(findtext(reg,is_phrase)) // If a phrase
					accent_lists[1][regex(reg,"gi")] = accent_regex2replace[reg]
				else
					accent_lists[3][regex(reg,"gi")] = accent_regex2replace[reg]
			accents_name2regexes[accent] = accent_lists

	
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/list/phrase2replace = accents_name2regexes[accent_name][1] // key is regex, value is replacement
		var/list/word2replace = accents_name2regexes[accent_name][2] // key is plaintext word, value is replacement
		var/list/regex2replace = accents_name2regexes[accent_name][3] // key is regex, value is replacement
		// First the phrases
		for(var/x in phrase2replace) //Linear time relative to number of phrases
			var/regex/R = x
			var/replace = phrase2replace[x]
			if(islist(replace))
				replace = pick(replace)
			message = R.Replace(message,replace)
		// Then the words
		var/list/words = splittext(message," ") 
		for(var/i in words) // Linear time relative to number of words spoken by player (times log(number of accent words) because BYOND doesn't use hashtables for some ungodly reason)
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
