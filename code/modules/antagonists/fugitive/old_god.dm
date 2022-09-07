
/mob/camera/yalp_elor
	name = "Yalp Elor"
	real_name = "Yalp Elor"
	desc = "An old, dying god. Its power has been severely sapped ever since it has lost its standing in the world."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "yalp_elor"
	invisibility = INVISIBILITY_OBSERVER
	var/lastWarning = 0
	var/datum/action/innate/yalp_transmit/transmit
	var/datum/action/innate/yalp_transport/transport
	var/datum/action/cooldown/yalp_heal/heal
	var/hunters_release_time // Yogs -- making Login() dialogue make more sense

/mob/camera/yalp_elor/Initialize()
	. = ..()
	transmit = new
	transport = new
	heal = new
	transmit.Grant(src)
	transport.Grant(src)
	heal.Grant(src)
	START_PROCESSING(SSobj, src)
	hunters_release_time = world.time + 10 MINUTES // Yogs -- making Login() dialogue make more sense

/mob/camera/yalp_elor/Destroy() // Yogs -- fixes duplicated Destroy() proc
	QDEL_NULL(transmit)
	QDEL_NULL(transport)
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/camera/yalp_elor/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

/mob/camera/yalp_elor/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/camera/yalp_elor/Login() // Yogs -- better Login() dialogue
	..()
	to_chat(src,span_boldnotice("You are [name], the old god!"))
	to_chat(src,span_notice("You must protect your followers from Nanotrasen!"))
	to_chat(src,span_notice("Only your followers can hear you, and you can speak to send messages to all of them, wherever they are. <i>You can also locally whisper to anyone.</i>"))
	var/passed_time = hunters_release_time - world.time
	if(passed_time > 0)
		to_chat(src, span_warning("Nanotrasen will reach you and your followers in about [DisplayTimeText(passed_time)]. Make sure they are ready when the time is up."))
//yogs end

/mob/camera/yalp_elor/Move(NewLoc, direct)
	if(!NewLoc)
		return
	var/OldLoc = loc
	var/turf/T = get_turf(NewLoc)
	if(locate(/obj/effect/blessing, T))
		if((world.time - lastWarning) >= 30)
			lastWarning = world.time
			to_chat(src, span_warning("This turf is consecrated and can't be crossed!"))
		return
	if(istype(get_area(T), /area/chapel))
		if((world.time - lastWarning) >= 30)
			lastWarning = world.time
			to_chat(src, span_warning("The Chapel is hallowed ground under a much, MUCH stronger deity, and can't be accessed!"))
		return
	forceMove(T)
	Moved(OldLoc, direct)

/mob/camera/yalp_elor/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	src.log_talk(message, LOG_SAY, tag="fugitive god")
	message = span_boldnotice("<b>[name]:</b> \"[capitalize(message)]\"")
	for(var/mob/V in GLOB.player_list)
		if(V.mind.has_antag_datum(/datum/antagonist/fugitive))
			to_chat(V, "[message]")
		else if(isobserver(V))
			to_chat(V, "[FOLLOW_LINK(V, src)] [message]")

/mob/camera/yalp_elor/process() // Yogs -- fixing oldgod race conditions
	for(var/V in GLOB.mob_living_list)
		var/mob/living/L = V
		if (!L.ckey) // never had a client (logic stolen from how game_mode.dm does these kinda checks)
			continue  
		if(L.stat == DEAD) // Seems like a paranoid check to do against GLOB.mob_living_list but, whatever.
			continue
		//Note that the above counts "living fugitives which are unfortunately AFK" as valid for this loss-condition check.
		var/datum/antagonist/fugitive/fug = isfugitive(L)
		if(!fug)
			continue
		if(!fug.is_captured) // Found a living fugitive!!
			return
	//otherwise, eat shit and commit qdel()
	to_chat(src, span_userdanger("All of your followers are gone. That means you cease to exist."))
	playsound_local(get_turf(src), 'sound/machines/clockcult/ark_rattle.ogg', 100, FALSE, pressure_affected = FALSE)
	qdel(src)
//yogs end

/datum/action/innate/yalp_transmit
	name = "Divine Oration"
	desc = "Transmits a message to the target."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_spell"
	button_icon_state = "god_transmit"

/datum/action/innate/yalp_transmit/Trigger()
	var/list/possible_targets = list()
	for(var/mob/living/M in range(7, owner))
		if(istype(M))
			possible_targets += M
	if(!possible_targets.len)
		to_chat(owner, span_warning("Nobody in range to talk to!"))
		return FALSE

	var/mob/living/target
	if(possible_targets.len == 1)
		target = possible_targets[1]
	else
		target = input("Who do you wish to transmit to?", "Targeting") as null|mob in possible_targets

	var/input = stripped_input(owner, "What do you wish to tell [target]?", null, "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	if(isnotpretty(input)) // Yogs -- Pretty filter
		to_chat(owner,span_warning("That's not a very nice thing to tell [target.p_them()]."))
		var/log_message = "[key_name(owner)] just tripped a pretty filter: '[input]'."
		message_admins(log_message)
		log_say(log_message)
		return FALSE // yogs end

	transmit(owner, target, input)
	return TRUE

/datum/action/innate/yalp_transmit/proc/transmit(mob/user, mob/living/target, message)
	if(!message)
		return
	log_directed_talk(user, target, message, LOG_SAY, "[name]")
	to_chat(user, "[span_boldnotice("You transmit to [target]:")] [span_notice("[message]")]")
	to_chat(target, "[span_boldnotice("You hear something behind you talking...")] [span_notice("[message]")]")
	for(var/ded in GLOB.dead_mob_list)
		if(!isobserver(ded))
			continue
		var/follow_rev = FOLLOW_LINK(ded, user)
		var/follow_whispee = FOLLOW_LINK(ded, target)
		to_chat(ded, "[follow_rev] [span_boldnotice("[user] [name]:")] [span_notice("\"[message]\" to")] [follow_whispee] [span_name("[target]")]")

/datum/action/innate/yalp_transport
	name = "Guidance"
	desc = "Transports you to a follower."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_spell"
	button_icon_state = "god_transport"

/datum/action/innate/yalp_transport/Trigger()
	var/list/faithful = list()
	var/mob/living/target
	for(var/mob/V in GLOB.player_list)
		var/datum/antagonist/fugitive/fug = isfugitive(V)
		if(!fug || !iscarbon(V))
			continue
		if(fug.is_captured)
			continue
		faithful += V
	if(!faithful.len)
		to_chat(owner, span_warning("You have nobody to jump to!"))
		return FALSE
	if(faithful.len == 1)
		target = faithful[1]
	else
		target = input("Which of your followers do you wish to jump to?", "Targeting") as null|mob in faithful

	var/turf/T = get_turf(target)
	if(target && T)
		owner.forceMove(T)
		return TRUE
	to_chat(owner, span_warning("Something horrible just happened to your target!"))
	return FALSE


/datum/action/cooldown/yalp_heal
	name = "Purification"
	desc = "Heals all followers a bit."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_spell"
	button_icon_state = "god_heal"
	cooldown_time = 600

/datum/action/cooldown/yalp_heal/Trigger()
	var/list/faithful = list()
	var/heal_amount = 20
	for(var/mob/V in GLOB.player_list)
		if(!isfugitive(V) ||  V == owner)
			continue
		faithful += V
	if(!faithful.len)
		to_chat(owner, "There are no followers left to heal!")
		return
	for(var/mob/living/A in faithful)
		A.adjustBruteLoss(-heal_amount, TRUE, TRUE) //heal
		A.adjustFireLoss(-heal_amount, TRUE, TRUE)
		A.adjustOxyLoss(-heal_amount, TRUE, TRUE)
		A.adjustToxLoss(-heal_amount, TRUE, TRUE)
		to_chat(A, "You have been healed by the great Yalp Elor!")
	to_chat(owner, "You have healed your followers!")
	StartCooldown()
