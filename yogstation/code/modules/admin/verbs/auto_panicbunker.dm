/client/proc/autopanicbunker()
	set name = "Toggle/Set Automatic Panic Bunker"
	set category = "Server"
	set desc = "Allows you to toggle the Automatic Panic Bunker, and set its required player count."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!check_rights(R_ADMIN,1))
		return
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, "<span class='adminnotice'>The Database is not enabled!</span>")
		return
	
	var/response = input("Would you like to toggle the automatic panic bunker, or set its required player count?") as anything in list("Toggle","Set Player Count")
	
	if(!response)
		return
	
	if(response == "Toggle")
		var/newflag = !CONFIG_GET(flag/autopanicbunker)
		CONFIG_SET(flag/autopanicbunker,newflag)
		log_admin("[key_name(src)] has [newflag ? "enabled" : "disabled"] the automatic panic bunker.")
		message_admins("[key_name(src)] has <font color='red'>[newflag ? "enabled" : "disabled"]</font> the automatic panic bunker.")
		if(!newflag) // If we're turning it off
			GLOB.autobunker_enabled = FALSE
	else if(response == "Set Player Count")
		response = input("What would you like to set the required player count to?") as num
		if(!response || !isnum(response))
			return
		CONFIG_SET(number/autopanic_players,response)
		log_admin("[key_name(src)] has set the automatic panic bunker to activate at [response] living players.")
		message_admins("[key_name(src)] has set the automatic panic bunker to activate at [response] living players.")