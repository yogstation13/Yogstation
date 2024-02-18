/proc/key_name_params(whom, include_link = null, include_name = 1, anchor_params = null, datum/admin_help/T = null)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = GLOB.directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = FALSE

	if(key)
		//if(include_link)
			//. += "<a href='?priv_msg=[T ? "ticket;ticket=\ref[T]" : ckey][anchor_params ? ";[anchor_params]" : ""]'>"

		if(C && C.holder && C.holder.fakekey && !include_name)
			. += "Administrator"
		else
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

/proc/generate_admin_info(msg, key)
	//explode the input msg into a list

	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in GLOB.mob_list)
		if(!M.mind && !M.client)
			continue

		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/list/jobs = list()
	var/list/job_count = list()
	for(var/datum/mind/M in SSticker.minds)
		var/T = lowertext(M.assigned_role)
		jobs[T] = M.current
		job_count[T]++ //count how many of this job was found so we only show link for singular jobs

	var/ai_found = FALSE
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = TRUE
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(!found)
						var/T = lowertext(original_word)
						if(T == "cap") T = "captain"
						if(T == "hop") T = "head of personnel"
						if(T == "cmo") T = "chief medical officer"
						if(T == "ce")  T = "chief engineer"
						if(T == "hos") T = "head of security"
						if(T == "rd")  T = "research director"
						if(T == "qm")  T = "quartermaster"
						if(job_count[T] == 1) //skip jobs with multiple results
							found = jobs[T]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = TRUE
							msg += "<b>[original_word]</b> (<a href='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(found)]'>?</a>)"
							continue
			msg += "[original_word] "
	return msg

/proc/get_fancy_key(mob/user)
	if(ismob(user))
		var/mob/temp = user
		return temp.key
	else if(istype(user, /client))
		var/client/temp = user
		return temp.key
	else if(istype(user, /datum/mind))
		var/datum/mind/temp = user
		return temp.key

	return "* Unknown *"

// Like get_turf, but if inside a bluespace locker it returns the turf the bluespace locker is on
// possibly could be adapted for other stuff, i dunno
/proc/get_turf_global(atom/A, recursion_limit = 5)
	var/turf/T = get_turf(A)
	if(!T)
		return
	if(recursion_limit <= 0)
		return T
	if(T.loc)
		var/area/R = T.loc
		if(R.global_turf_object)
			return get_turf_global(R.global_turf_object, recursion_limit - 1)
	return T

/proc/js_keycode_to_byond(key_in)
	key_in = text2num(key_in)
	switch(key_in)
		if(65 to 90, 48 to 57) // letters and numbers
			return ascii2text(key_in)
		if(17)
			return "Ctrl"
		if(18)
			return "Alt"
		if(16)
			return "Shift"
		if(37)
			return "West"
		if(38)
			return "North"
		if(39)
			return "East"
		if(40)
			return "South"
		if(45)
			return "Insert"
		if(46)
			return "Delete"
		if(36)
			return "Northwest"
		if(35)
			return "Southwest"
		if(33)
			return "Northeast"
		if(34)
			return "Southeast"
		if(112 to 123)
			return "F[key_in-111]"
		if(96 to 105)
			return "Numpad[key_in-96]"
		if(188)
			return ","
		if(190)
			return "."
		if(189)
			return "-"

#define UPPER 0
#define LOWER 1
#define CAPITAL 2
/proc/get_case(txt) // Returns the case of the text given
	if(txt == uppertext(txt))
		return UPPER
	if(txt == lowertext(txt))
		return LOWER
	if(txt[1] == uppertext(txt[1]))
		return CAPITAL
	
	return UPPER // We're assuming at this point that the text is a weird mixed-case. Most likely the intended case was UPPER.
/proc/set_case(txt,case) // Modifies the case of txt to be case input
	switch(case)
		if(UPPER)
			return uppertext(txt)
		if(LOWER)
			return lowertext(txt)
		if(CAPITAL)
			return uppertext(txt[1]) + copytext(lowertext(txt),2)
#undef UPPER
#undef LOWER
#undef CAPITAL
