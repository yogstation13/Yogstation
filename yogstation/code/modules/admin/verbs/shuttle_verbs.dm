/datum/admin_delay
	var/name = "Delay by Admins"
	var/desc = "An admin has delayed the shuttle!"

/client/proc/delay_shuttle()
	set name = "Delay Shuttle"
	set desc = "Toggles admin delay of the shuttle."
	set category = "Admin"
	var/static/datum/admin_delay/delay = new
	
	if(SSshuttle.hostileEnvironments.len)
		if(delay in SSshuttle.hostileEnvironments)
			if(alert("Would you like to disable the admin-induced shuttle delay?","Shuttle Delay","Yes","No") == "Yes")
				SSshuttle.clearHostileEnvironment(delay)
				log_admin("[key_name(usr)] has removed the admin-induced delay on the shuttle launching.")
				message_admins("[key_name(usr)] has removed the admin-induced delay on the shuttle launching.")
		else
			to_chat(usr,"<span class='warning'>The shuttle is already delayed by something else!</span>", confidential=TRUE)
		return
	
	if(alert("Are you sure you want to delay the shuttle from launching?","Shuttle Delay","Yes","No") != "Yes")
		return
	
	SSshuttle.registerHostileEnvironment(delay)
	log_admin("[key_name(usr)] has delayed the shuttle from launching.")
	message_admins("[key_name(usr)] has delayed the shuttle from launching.")