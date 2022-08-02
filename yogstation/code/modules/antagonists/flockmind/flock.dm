GLOBAL_VAR(flock)

/datum/team/flock
	name = "flock"
	member_name = "flock member"
	var/stored_resources = 0
	var/mob/camera/flocktrace/flockmind/overmind 
	var/list/computing_datums = list()

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

/datum/team/flock/proc/add_computing_datum(datum/computer)
	computing_datums += computer

/datum/team/flock/proc/remove_computing_datum(datum/computer)
	computing_datums -= computer

/datum/team/flock/proc/get_compute(unused = TRUE) //Gets the number of compute. Set unused to FALSE if you want to get total amount of compute, not only usable.
	var/total = 0
	for(var/datum/component/flock_compute/FC in computing_datums)
		if(!istype(FC))
			continue
		if(!unused && FC.compute_amount < 0)
			continue
		if(QDELETED(FC) || QDELETED(FC.parent))
			continue
		if(ismob(FC.parent))
			var/mob/M = FC.parent
			if(M.stat == DEAD && FC.requires_alive == TRUE)
				continue
		total += FC.compute_amount
	return total