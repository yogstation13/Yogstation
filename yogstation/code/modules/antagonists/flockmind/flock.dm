GLOBAL_VAR(flock)

/datum/team/flock
	name = "flock"
	member_name = "flock member"
	var/stored_resources = 0
	var/mob/camera/flocktrace/flockmind/overmind 
	var/compute = 0

/datum/team/flock/New(starting_members)
	. = ..()
	if(!GLOB.flock)
		GLOB.flock = src
	else
		qdel(src)

/proc/ping_flock(message, mob/user, ghosts = TRUE)
	if(user)
		user.log_talk(message, LOG_SAY)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	var/message_a = user.say_quote(message)
	var/rendered = span_swarmer("\[Flock Communication\][user ? " [user]" : ""] [message_a]")

	for(var/mob/M in GLOB.mob_list)
		if(isflockdrone(M) || isflocktrace(M))
			to_chat(M, rendered)
		if(isobserver(M) && ghosts)
			if(user)
				var/link = FOLLOW_LINK(M, user)
				to_chat(M, "[link] [rendered]")
			else
				to_chat(M, "[rendered]")

/proc/get_flock_team(list/members)
	if(GLOB.flock)
		return GLOB.flock
	else
		var/datum/team/flock/F = new(members)
		return F