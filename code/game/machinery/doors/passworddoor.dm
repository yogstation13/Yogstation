/obj/machinery/door/password
	name = "door"
	desc = "This door only opens when provided a password."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	var/password = "Swordfish"
	var/interaction_activated = TRUE //use the door to enter the password
	var/voice_activated = FALSE //Say the password nearby to open the door.

/obj/machinery/door/password/voice
	voice_activated = TRUE

/obj/machinery/door/password/floppy_disk
	desc = "This door only opens when provided with a decrypted floppy drive."
	var/id

/obj/machinery/door/password/floppy_disk/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/disk/puzzle))
		var/obj/item/disk/puzzle/P = I
		if(P.id == id)
			if(P.decrypted)
				open()
				to_chat(user, span_notice("You insert [P]."))
				qdel(P)
			else
				to_chat(user, span_warning("This disk doesn't seem to have been decrypted!"))
		else
			to_chat(user, span_warning("This disk doesn't belong to this door!"))

/obj/machinery/door/password/floppy_disk/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/password/button_puzzle
	desc = "This door has no obvious way to be opened."
	var/id

/obj/machinery/door/password/button_puzzle/Initialize(mapload)
	. = ..()
	for(var/datum/button_puzzle_holder/H in GLOB.button_puzzles)
		if(H.id == id)
			H.doors += src
	var/datum/button_puzzle_holder/H = new()
	H.id = id
	H.doors += src
	GLOB.button_puzzles += H

/obj/machinery/door/password/button_puzzle/attackby(obj/item/I, mob/user, params)
	. = ..()
	to_chat(user, span_warning("You're not sure how to open this door! Maybe look around?"))

/obj/machinery/door/password/button_puzzle/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/password/Initialize(mapload)
	. = ..()
	if(voice_activated)
		flags_1 |= HEAR_1

/obj/machinery/door/password/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(!density || !voice_activated || radio_freq)
		return
	if(!ishuman(speaker))
		return
	if(findtext(raw_message,password))
		open()

/obj/machinery/door/password/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/password/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return
	if(density)
		if(ask_for_pass(user))
			open()
		else
			do_animate("deny")

/obj/machinery/door/password/update_icon_state()
	. = ..()
	if(density)
		icon_state = "closed"
	else
		icon_state = "open"

/obj/machinery/door/password/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("deny")
			//Deny animation would be nice to have.
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)

/obj/machinery/door/password/proc/ask_for_pass(mob/user)
	var/guess = stripped_input(user,"Enter the password:", "Password", "")
	if(guess == password)
		return TRUE
	return FALSE

/obj/machinery/door/password/emp_act(severity)
	return

/obj/machinery/door/password/ex_act(severity, target)
	return
