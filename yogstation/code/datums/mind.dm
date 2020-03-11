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
		var/regex/metaregex = regex(@"\\b[\w \.,;'\?!]\\b","i")
		for(var/accent in accent_names)
			var/list/accent_lists = list(list(), list())
			var/list/accent_regex2replace = strings(GLOB.accents_name2file[accent_name], accent_name, directory = "strings/accents") // Key is regex, value is replacement
			for(var/reg in accent_regex2replace)
				if(findtext(reg,metaregex)) // If a Word regex
					accent_lists[1] += list(list(regex(reg,"gi"),accent_regex2replace[reg]))
				else
					accent_lists[2] += list(list(regex(reg,"gi"),accent_regex2replace[reg]))
			accents_name2regexes[accent] = accent_lists

	
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		for(var/i in 1 to 2)
			var/list/accent_regex2replace = accents_name2regexes[accent_name]
			for(var/x in accent_regex2replace)
				var/regex/R = x
				message = R.Replace(message,accent_regex2replace[x])
	speech_args[SPEECH_MESSAGE] = message
