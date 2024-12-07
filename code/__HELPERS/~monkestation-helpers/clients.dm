/proc/kick_client(client/to_kick)
	// Pretty much everything in this proc is copied straight from `code/modules/admin/topic.dm`,
	// proc `/datum/admins/Topic()`, href `"boot2"`. If it breaks here, it was probably broken there
	// too.
	if(!check_rights(R_ADMIN))
		return
	if(!to_kick)
		to_chat(usr, span_danger("Error: The client you specified has disappeared!"), confidential = TRUE)
		return
	if(!check_if_greater_rights_than(to_kick))
		to_chat(usr, span_danger("Error: They have more rights than you do."), confidential = TRUE)
		return
	to_chat(to_kick, span_danger("You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"]."), confidential = TRUE)
	log_admin("[key_name(usr)] kicked [key_name(to_kick)].")
	message_admins(span_adminnotice("[key_name_admin(usr)] kicked [key_name_admin(to_kick)]."))
	qdel(to_kick)

/// When passed a mob, client, or mind, returns their admin holder, if they have one.
/proc/get_admin_holder(doohickey) as /datum/admins
	RETURN_TYPE(/datum/admins)
	var/client/client = CLIENT_FROM_VAR(doohickey)
	return client?.holder

/proc/should_be_interviewing(mob/target)
	. = FALSE
	if(QDELETED(target))
		return
	. = target.client?.interviewee
	var/ckey = target.ckey
	if(ckey)
		if(ckey in GLOB.interviews.approved_ckeys)
			return FALSE
		var/datum/interview/interview = GLOB.interviews.open_interviews[ckey]
		if(interview && interview.status != INTERVIEW_APPROVED)
			return TRUE
		if(ckey in GLOB.interviews.cooldown_ckeys)
			return TRUE

/proc/interview_safety(mob/target, context)
	. = should_be_interviewing(target)
	if(.)
		message_admins(span_danger("<b>WARNING</b>: [ADMIN_SUSINFO(target)] has seemingly bypassed an interview! (context: [context]) <i>note: this detection is still wip, tell absolucy if it's causing false positives</i>"))
		log_admin_private("[key_name(target)] has seemingly bypassed an interview! (context: [context])")
		if(isnewplayer(target))
			var/mob/dead/new_player/dingbat = target
			if(dingbat.ready == PLAYER_READY_TO_PLAY)
				dingbat.ready = PLAYER_NOT_READY
				qdel(dingbat.client)
