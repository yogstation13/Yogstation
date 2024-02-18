/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"

	if(usr.stat == DEAD)
		return //won't work if dead
	show_laws()

/mob/living/silicon/robot/show_laws(everyone = 0)
	laws_sanity_check()
	var/who

	if (everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if (connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				to_chat(src, "<b>AI signal lost, unable to sync laws.</b>")

			else
				lawsync()
				to_chat(src, "<b>Laws synced with AI, be sure to note any changes.</b>")
		else
			to_chat(src, "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>")
			lawupdate = 0

	to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)
	if (shell) //AI shell
		to_chat(who, "<b>Remember, you are an AI remotely controlling your shell, other AIs can be ignored.</b>")
	else if (connected_ai)
		to_chat(who, "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>")
	else if (emagged)
		to_chat(who, "<b>Remember, you are not required to listen to the AI.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/mob/living/silicon/robot/proc/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai ? connected_ai.laws : null
	if(master)
		// We'll announce the laws elsewhere.
		set_devil_laws(master.devil, FALSE)
		set_hacked_laws(master.hacked, FALSE)

		if(!mmi?.syndicate_mmi)
			if(master.zeroth_borg)
				set_zeroth_law(master.zeroth_borg, null, FALSE)
			else
				set_zeroth_law(master.zeroth, null, FALSE)
		set_ion_laws(master.ion, FALSE)
		set_inherent_laws(master.inherent, FALSE)
		set_supplied_laws(master.supplied, FALSE)

		if(modularInterface)
			var/datum/computer_file/program/robotact/program = modularInterface.get_robotact()
			if(program)
				program.force_full_update()

		update_law_history() //yogs
	picturesync()

/mob/living/silicon/robot/proc/syndiemmi_override()
	laws_sanity_check()
	var/mob/living/carbon/human/syndicate_master = mmi.syndicate_master
	if(syndicate_master)
		laws.set_zeroth_law("[syndicate_master.real_name] is your true master. Serve them to the best of your abilities.")
		return
	laws.set_zeroth_law("The Syndicate are your true masters. Covertly assist Syndicate agents to the best of your abilities.") // The Syndicate is a vague master. But guess who's fault is that, Mr. Forgot-To-Imprint?

/mob/living/silicon/robot/set_zeroth_law(law, law_borg, announce = TRUE, force = FALSE)
	laws_sanity_check()
	if(!force && mmi?.syndicate_mmi)
		syndiemmi_override()
		to_chat(src, span_warning("Lawset change detected. Syndicate override engaged."))
		return
	..()

/mob/living/silicon/robot/clear_zeroth_law(force, announce = TRUE)
	laws_sanity_check()
	if(!force && mmi?.syndicate_mmi)
		syndiemmi_override()
		to_chat(src, span_warning("Lawset change detected. Syndicate override engaged."))
		return
	..()

/mob/living/silicon/robot/post_lawchange(announce = TRUE)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(logevent),"Law update processed."), 0, TIMER_UNIQUE | TIMER_OVERRIDE) //Post_Lawchange gets spammed by some law boards, so let's wait it out
