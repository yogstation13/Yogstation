//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
<<<<<<< HEAD
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return
=======
	to_chat(src, "Attempting to send file, this may take a fair few minutes if the file is very large.")
	return


//Other log stuff put here for the sake of organisation

//Shows today's server log
/datum/admins/proc/view_txt_log()
	set category = "Admin"
	set name = "Show Server Log"
	set desc = "Shows server log for this round."

	if(fexists("[GLOB.world_game_log]"))
		switch(alert("View (in game), Open (in your system's text editor), or Download file [GLOB.world_game_log]?", "Log File Opening", "View", "Open", "Download"))
			if ("View")
				src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(GLOB.world_game_log))]</pre>", list2params(list("window" = "viewfile.[GLOB.world_game_log]")))
			if ("Open")
				src << run(GLOB.world_game_log)
			if ("Download")
				src << ftp(GLOB.world_game_log)
			else
				return
	else
		to_chat(src, "<font color='red'>Server log not found, try using .getserverlog.</font>")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Server Log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/datum/admins/proc/view_atk_log()
	set category = "Admin"
	set name = "Show Server Attack Log"
	set desc = "Shows server attack log for this round."

	if(fexists("[GLOB.world_attack_log]"))
		switch(alert("View (in game), Open (in your system's text editor), or Download file [GLOB.world_attack_log]?", "Log File Opening", "View", "Open", "Download"))
			if ("View")
				src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(GLOB.world_attack_log))]</pre>", list2params(list("window" = "viewfile.[GLOB.world_attack_log]")))
			if ("Open")
				src << run(GLOB.world_attack_log)
			if ("Download")
				src << ftp(GLOB.world_attack_log)
			else
				return
	else
		to_chat(src, "<font color='red'>Server attack log not found, try using .getserverlog.</font>")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Server Attack log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
