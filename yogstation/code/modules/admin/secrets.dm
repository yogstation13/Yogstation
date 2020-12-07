/datum/admins/proc/YogMentorLogs()
	var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>Mentor Log<HR></B>"
	for(var/l in GLOB.mentorlog)
		dat += "<li>[l]</li>"

	if(!GLOB.mentorlog.len)
		dat += "No mentors have done anything this round!"
	dat += "</BODY></HTML>"
	usr << browse(dat, "window=mentor_log")
