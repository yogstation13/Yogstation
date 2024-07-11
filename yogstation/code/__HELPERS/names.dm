/proc/gorilla_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.gorilla_names_male)] [pick(GLOB.last_names)]"
	else
		return "[pick(GLOB.gorilla_names_female)] [pick(GLOB.last_names)]"

/proc/vox_name()
	var/sounds = rand(2,8)
	var/vox_name = ""
	for(var/sound in 1 to sounds)
		vox_name += pick("ti","hi","ki","ya","ta","ha","ka","yi","chi","cha","kah")
	return vox_name
