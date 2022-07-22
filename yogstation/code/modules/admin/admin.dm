/client/proc/YogsPPoptions(mob/M) // why is this client and not /datum/admins? noone knows, in PP src == client, instead of holder. wtf. - I'm confused too man
	var/body = "<br>"
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];makementor=[M.ckey]'>Make mentor</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];wikimentor=[M.ckey]'>Make Wiki mentor</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];removementor=[M.ckey]'>Remove mentor</A>"
	return body

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc = "can you even see verb descriptions anywhere?"
	set name = "Toggle LOOC"

	toggle_looc()
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] toggled LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle LOOC", "[GLOB.looc_allowed ? "Enabled" : "Disabled"]"))

/datum/admins/proc/toggleloocdead()
	set category = "Server"
	set desc = "seriously, why do we even bother"
	set name = "Toggle Dead LOOC"

	toggle_dlooc()
	log_admin("[key_name(usr)] toggled Dead LOOC.")
	message_admins("[key_name_admin(usr)] toggled Dead LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead LOOC", "[GLOB.dlooc_allowed ? "Enabled" : "Disabled"]"))

/datum/admins/output_ai_laws() // Proc override
	if(!GLOB.silicon_mobs.len)
		to_chat(usr, span_adminnotice("No silicons located.") , confidential=TRUE)
		return
	to_chat_immediate(usr,span_admin("Silicon Laws:"))
	for(var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/S = i
		var/msg = span_adminnotice("[key_name(S,usr)] laws:")
		var/do_show_laws = TRUE
		if(isAI(S))
			msg = span_adminnotice("<font color='tomato'>AI</font> [key_name(S,usr)] laws:")
		else if(isAIShell(S)) // done separately from cyborgs since it's a bit of a snowflake case
			var/mob/living/silicon/robot/R = S
			do_show_laws = FALSE
			if(R.connected_ai)
				msg = span_adminnotice("<font color='tomato'>AI SHELL</font> [key_name(S,usr)] laws are synced with [R.connected_ai].")
			else if(S.ckey) // wtf??
				msg = span_adminnotice("<font color='tomato'>AI SHELL</font> [key_name(S,usr)] is not properly connected to the AI that controls it. Laws:")
				do_show_laws = TRUE
			else
				msg = span_adminnotice("<font color='tomato'>AI SHELL</font> [S] is empty.")
		else if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			if(R.connected_ai)
				if(R.lawupdate)
					msg = span_adminnotice("<font color='tomato'>CYBORG</font> [key_name(S,usr)] laws are synced with [R.connected_ai].")
					do_show_laws = FALSE
				else
					msg = span_adminnotice("<font color='tomato'>CYBORG</font> [key_name(S,usr)] is <font color='tomato'>desynced</font> but enslaved to [R.connected_ai], with following laws:")
			else
				msg = span_adminnotice("<font color='tomato'>CYBORG</font> [key_name(S,usr)] is <font color='white'>independent</font> with following laws:")
		else if (ispAI(S))
			msg = span_adminnotice("<font color='tomato'>pAI</font> [key_name(S, usr)] laws:")
		to_chat_immediate(usr,msg, confidential=TRUE) // Say the first message
		if(do_show_laws) // now the laws
			if(!S.laws)
				to_chat_immediate(usr,span_adminnotice("Silicon has no laws datum. Probably a bug?"), confidential=TRUE)
				continue
			var/list/printable_laws = S.laws.get_law_list(include_zeroth = TRUE)
			if(!printable_laws.len)
				to_chat_immediate(usr,span_warning("Lawset has no laws."), confidential=TRUE)
				continue
			for(var/law in printable_laws)
				to_chat_immediate(usr,span_notice(law), confidential=TRUE) // We use to_chat_immediate to make sure that no batching takes place between identical lawsets.
