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
	if(mob && !isdead(mob))
		var/mob/M = mob
		
		var/time = input(src, "How long do you expect to be gone?") as anything in list("5 minutes","10 minutes","15 minutes","30 minutes","Whole round","Unknown")
		
		if(!time)
			return
		
		var/text // The text that this guy will broadcast as best he can in IC channels.
		var/alert_admins = FALSE
		var/list/channels = list() // What channels to broadcast their IC message on
		if(isdrone(M))// :altoids:
			text = borgtext[time]
			channels = list(".b")
		else if(issilicon(M))
			alert_admins = TRUE
			text = borgtext[time]
			channels = list(".o",".c")
		else if(ishuman(M))
			text = humantext[time]
			channels = list(".h")
			if(M.job)
				text += " This is the [M.job] signing off for now."
				if(M.job in GLOB.command_positions)
					alert_admins = TRUE
					channels += ".c"
		else // This guy is some strange sorta mob
			alert_admins = (alert("Should admins know about you going AFK?","AFK Verb Notice","Yes","No") == "Yes")
		
		//The actual loop where the mob speaks in IC
		for(var/i in channels)
			var/channel = channels[i]
			M.say("[channel] [text]")
		
		//Now we try to do the OOC bits, if necessary
		if(alert_admins)
			var/reason = stripped_input(src, "Do you have time to give a reason? If so, please give it:")
			adminhelp("I need to go AFK as '[M.job]' for duration of '[time]' [reason ? " with the reason: '[reason]'" : ""]")
		else
			to_chat(src, "<span class='danger'>Admins will not be specifically alerted, because you are not in a critical station role.</span>")
	else
		to_chat(src, "<span class='boldnotice'>It is not necessary to report being AFK if you are not in the game.</span>")
