/client/verb/afk()
	set name = "AFK"
	set category = "OOC"
	set desc = "Report to Admins and your peers that you will go AFK."

	if(mob)
		var/mob/M = mob

		if(!M || !M.job)
			to_chat(src, "<p class='info-bar emboldened'>You do not appear to have a job, so reporting being AFK is not necessary.</p>")
		else
			var/time = input(src, "How long do you expect to be gone?") as anything in list("5 minutes","10 minutes","15 minutes","30 minutes","Whole round","Unknown")

			if(!time)
				return

			var/reason = stripped_input(src, "Do you have time to give a reason? If so, please give it:")

			var/text
			if(issilicon(M))
				text = "A fault has been detected in my core. Taking my consciousness offline."
				if(time == "5 minutes")
					text = "A fault has been detected in my core. Performing a quick reboot of my consciousness."
				else if(time == "10 minutes")
					text = "A fault has been detected in my core. Performing a defragmentation of my consciousness."
				else if(time == "15 minutes")
					text = "A fault has been detected in my core. Going offline for moderate-length self diagnostics."
				else if(time == "30 minutes")
					text = "A fault has been detected in my core. Going offline for a long term self diagnostic."
				else if(time == "Whole round")
					text = "A fault has been detected in my core. Going offline until CentCom can repair my circuits."
			else
				text = "I need to catch some shut-eye. Please keep an eye on the crew whilst I am resting this shift."
				if(time == "5 minutes")
					text = "I need to shut my eyes for a brief moment."
				else if(time == "10 minutes")
					text = "I need to shut my eyes for a short while."
				else if(time == "15 minutes")
					text = "I need to shut my eyes for a short while. Please keep an eye on the crew whilst I am resting."
				else if(time == "30 minutes")
					text = "I need to shut my eyes for quite a while. Please keep an eye on the crew whilst I am resting."
				else if(time == "Whole round")
					text = "I need to shut my eyes for a long time... Someone please take over my station responsibilities."

			var/alert_admins = FALSE
			if(M.job == "AI" || istype(M, /mob/living/silicon))
				alert_admins = TRUE
				M.say(".c [text] This is the [M.job] signing off for now.")
				M.say(".o [text] This is the [M.job] signing off for now.")
			else if(M.job == "Captain" || M.job == "Head of Personnel" || M.job == "Head of Security" || M.job == "Chief Engineer" || M.job == "Research Director" || M.job == "Chief Medical Officer")
				alert_admins = TRUE
				M.say(".h [text] This is the [M.job] signing off for now.")
			else
				M.say(".h [text] This is the [M.job] signing off for now.")

			if(alert_admins)
				adminhelp("I need to go AFK as '[M.job]' for duration of '[time]' [reason ? " with the reason: '[reason]'" : ""]")
			else
				to_chat(src, "<p class='info-bar emboldened'>Admins will not be specifically alerted, because you are not in a critical station role.</p>")
	else
		to_chat(src, "<p class='info-bar emboldened'>It is not necessary to report being AFK if you are not in the game.</p>")