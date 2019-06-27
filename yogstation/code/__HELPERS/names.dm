/proc/gorilla_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.gorilla_names_male)] [pick(GLOB.last_names)]"
	else
		return "[pick(GLOB.gorilla_names_female)] [pick(GLOB.last_names)]"
