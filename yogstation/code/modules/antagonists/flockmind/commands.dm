/datum/flock_command
	var/mob/camera/flocktrace/daddy
	var/atom/dude
	var/messg = "Uhh you will do nothing cry about it"
	var/datum/action/cooldown/flock/parent_action

/datum/flock_command/proc/perform_action(atom/A)
	return FALSE //return TRUE if we want the order to be qdeleted, FALSE if we do an normal action but keep the order

/datum/flock_command/New(mob/camera/flocktrace/ded, atom/A, datum/action/cooldown/flock/PA)
	. = ..()
	daddy = ded
	if(daddy.stored_action && daddy.stored_action != src)
		qdel(daddy.stored_action)
		daddy.stored_action = src
	if(A)
		dude = A
	if(PA)
		parent_action = PA
	if(messg)
		to_chat(daddy, span_boldnotice(messg))

/datum/flock_command/enemy_of_the_flock
	messg = "Next living being you will click will be designated as The Enemy Of The Flock"

/datum/flock_command/enemy_of_the_flock/perform_action(atom/A)
	if(!isliving(A) || isflockdrone(A) || iscameramob(A))
		return FALSE
	if(HAS_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK))
		A.balloon_alert(daddy, "Enemy designated")
		REMOVE_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)
		ping_flock("[A] is no longer The Enemy Of The Flock!",daddy)
	else
		ADD_TRAIT(A, TRAIT_ENEMY_OF_THE_FLOCK, FLOCK_TRAIT)
		to_chat(daddy , "You designate [A] as The Enemy Of The Flock.")
		ping_flock("[daddy] has designated [A] as The Enemy Of The Flock!",daddy)
	return TRUE

/datum/flock_command/move
	messg = "Your next click on an object will order the flockrone to move to it(if it is a valid location)."

/datum/flock_command/move/perform_action(atom/A)
	if(!dude || QDELETED(dude) || !isliving(dude))
		return TRUE 
	var/turf/T = isturf(A) ? A : get_turf(A)
	if(!is_station_level(T.z))
		to_chat(daddy, span_warning("You can't do this if not on the station Z-level!"))
		return TRUE
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return FALSE
	var/mob/living/simple_animal/hostile/H = dude
	if(isturf(H.loc) && get_dist(H, T) <= 35 && !H.key)
		H.LoseTarget()
		H.Goto(pick(surrounding_turfs), H.move_to_delay)
		return TRUE
	return FALSE

/datum/flock_command/repair
	messg = "Clicking on a living damaged flockdrone will fully heal it."

/datum/flock_command/repair/perform_action(mob/living/simple_animal/hostile/flockdrone/FT)
	if(!istype(FT))
		to_chat(daddy, span_warning("Not a valid target!"))
		return FALSE
	if(!FT.getFireLoss() && !FT.getBruteLoss())
		A.balloon_alert(daddy, "Already at full health")
		return TRUE
	if(FT.stat == DEAD)
		A.balloon_alert(daddy, "Dead, aborting")
		return TRUE
	FT.heal_ordered_damage(30, list(BRUTE, BURN))
	A.balloon_alert(daddy, "Sucessfully healed")
	playsound(daddy, 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
	parent_action.StartCooldown()
	return TRUE

/datum/flock_command/talk
	messg = "Next living being with a working listening headset will allow you to transmit something to it. Also works on radio devices."

/datum/flock_command/talk/perform_action(atom/A)
	if(isliving(A))
		var/mob/living/L = A 
		var/obj/item/radio/headset/H = L.get_item_by_slot(ITEM_SLOT_EARS)
		if(!H || !H.on || !H.listening || !istype(H))
			to_chat(daddy, span_warning("[L] doesn't have a headset or their headset compatible!"))
			return TRUE
		var/msg = input(daddy,"What would you like to transmit to [L]?","Narrowbeam Transmission","") as null|text
		if(!msg)
			return TRUE
		to_chat(L, span_swarmer("You hear a crackling voice through your headset: [msg]"))
		playsound(L, 'yogstation/sound/effects/radio1.ogg', 50, 1)
		daddy.log_talk(msg, LOG_SAY)
		to_chat(daddy, span_notice("You transmit a message to [L]: [msg]"))
		return TRUE
	else if(istype(A, /obj/item/radio))
		var/obj/item/radio/R = A
		if(!R.on || !R.listening)
			to_chat(daddy, span_warning("[R] isn't compatible!"))
			return TRUE		
		var/msg = input(daddy,"What would you like to transmit through [R]?","Narrowbeam Transmission","") as null|text
		if(!msg)
			return TRUE
		msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
		var/name = daddy.name
		daddy.name = "Unknown"
		R.talk_into(daddy, msg, 0, "Unknown")
		daddy.name = name
		to_chat(daddy, span_notice("You transmit a message through [R]: [msg]"))
		return TRUE
	else 
		to_chat(daddy, span_warning("[A] isn't a valid target!"))
		return FALSE
