/client/verb/afk()
	set name = "AFK"
	set category = "OOC"
	set desc = "Report to Admins and your peers that you will go AFK."

	var/static/list/borgtext = list(
		"Unknown" = "A fault has been detected in my core. Taking my consciousness offline.",
		"5 minutes" = "A fault has been detected in my core. Performing a quick reboot of my consciousness.",
		"10 minutes" = "A fault has been detected in my core. Performing a defragmentation of my consciousness.",
		"15 minutes" = "A fault has been detected in my core. Going offline for moderate-length self diagnostics.",
		"30 minutes" = "A fault has been detected in my core. Going offline for a long term self diagnostic.",
		"Whole round" = "A fault has been detected in my core. Going offline until CentCom can repair my circuits."
	)
	var/static/list/humantext = list(
		"Unknown" = "I need to catch some shut-eye. Please keep an eye on the crew whilst I am resting this shift.",
		"5 minutes" = "I need to shut my eyes for a brief moment.",
		"10 minutes" = "I need to shut my eyes for a short while.",
		"15 minutes" = "I need to shut my eyes for a bit. Please keep an eye on me while I am resting.",
		"30 minutes" = "I need to shut my eyes for quite a while. Please keep an eye on me while I am resting.",
		"Whole round" = "I need to shut my eyes for a long time... Someone please take over my station responsibilities."
	)
	
	var/static/list/alientext = list(
		"Unknown" = "My broodmembers, I must go quiet for a time. Please watch over me.",
		"5 minutes" = "My broodmembers, I must go quiet for a time. I will awaken very soon.",
		"10 minutes" = "My broodmembers, I must go quiet for a time. I will awaken soon.",
		"15 minutes" = "My broodmembers, I must go quiet for a time. I will awaken in time.",
		"30 minutes" = "My broodmembers, I must go quiet for a time. It will be some time before I awaken.",
		"Whole round" = "My broodmembers, I must go quiet. I may never awaken during this cycle.",
	)
	if(mob && !isdead(mob))
		var/mob/M = mob
		
		var/time = input(src, "How long do you expect to be gone?") as anything in list("5 minutes","10 minutes","15 minutes","30 minutes","Whole round","Unknown")
		
		if(!time)
			return
		
		var/text // The text that this guy will broadcast as best he can in IC channels.
		var/alert_admins = FALSE
		var/special_role
		var/list/channels = list() // What channels to broadcast their IC message on
		if(isdrone(M))// :altoids:
			text = borgtext[time]
			channels = list(".b")
		else if(issilicon(M))
			alert_admins = TRUE
			text = borgtext[time]
			channels = list(".o",".c",".b") // AI Private, Command, and Binary.
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			text = humantext[time]
			channels = list(".h")
			if(H.job)
				text += " This is the [M.job] signing off for now."
				if(H.job in GLOB.command_positions)
					alert_admins = TRUE
					channels += ".c"
				else if(H.job in GLOB.security_positions)
					alert_admins = TRUE
					//Already implicitly sending an IC message on sec channels via the .h above
			if(H.mind)
				if(H.mind.special_role) // This catches if they are a typical variety of antag (clockwork, traitor, zombie, wizard, etc)
					alert_admins = TRUE
					special_role = H.mind.special_role
					switch(special_role)
						if("Nuclear Operative","Clown Operative","Syndicate Cyborg","Lone Operative") // Le nukie bois
							channels = list(".t") // Broadcast their AFK-hood on syndicate channels
				if(H.mind.has_antag_datum(/datum/antagonist/ert)) // A bit awkward, but they lack a special_role (nor a consistently unique assigned_role) and it would break some things to make them have one
					alert_admins = TRUE
					special_role = H.mind.assigned_role // This normally works.
					channels = list(".y",".c") // Y for.... Centcom, of course!
		else if(isalien(M))
			alert_admins = TRUE
			text = alientext[time]
			channels = list(".a")
		else // This guy is some strange sorta mob
			alert_admins = (alert("Should admins know about you going AFK?","AFK Verb Notice","Yes","No") == "Yes")
		
		//The actual loop where the mob speaks in IC
		for(var/i in channels)
			var/channel = channels[i]
			M.say("[channel] [text]")
		
		//Now we try to do the OOC bits, if necessary
		if(alert_admins)
			var/reason = stripped_input(src, "Do you have time to give a reason? If so, please give it:")
			var/important_role = special_role || M.job || initial(M.name) || "something important"
			adminhelp("I need to go AFK as '[important_role]' for duration of '[time]' [reason ? " with the reason: '[reason]'" : ""]")
			mob.log_message("is now AFK for [time] [reason ? " with the reason: '[reason]'" : ""]", LOG_OWNERSHIP)
		else
			to_chat(src, "<span class='danger'>Admins will not be automatically alerted, because you do not seem to be in a critical station role.</span>")
	else
		to_chat(src, "<span class='boldnotice'>It is not necessary to report being AFK if you are not in the game.</span>")
