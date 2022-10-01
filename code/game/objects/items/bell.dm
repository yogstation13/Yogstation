/obj/item/deskbell
	name = "desk bell"
	desc = "ding. ding."
	icon = 'icons/obj/bell.dmi'
	icon_state = "bell"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	attack_verb = list("rang")
	hitsound = 'sound/items/bell.ogg'
	materials = list(/datum/material/iron = 2000)
	anchored = FALSE
	var/ring_delay = 2 SECONDS
	var/normal_sound = 'sound/items/bell.ogg'
	var/agressive_sound = 'sound/items/bell_many.ogg'
	var/obj/item/assembly/assembly

/obj/item/deskbell/Initialize()
	. = ..()
	if(ispath(assembly))
		assembly = new assembly(src)

/obj/item/deskbell/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_unfasten_wrench(user, I, 0 SECONDS))
		return TRUE

/obj/item/deskbell/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!assembly)
		to_chat(user, span_warning("[src] doesn't have a device inside!"))
		return TRUE
	I.play_tool_sound(src)
	to_chat(user, span_notice("You remove [assembly] from [src]."))
	user.put_in_hands(assembly)
	assembly = null
	return TRUE
	

/obj/item/deskbell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/assembly))
		if(assembly)
			to_chat(user, span_warning("[src] already has a device inside!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		assembly = I
		return

	attack_hand(user)
	..()

/obj/item/deskbell/attack_self(mob/living/carbon/user)
	return attack_hand(user)

/obj/item/deskbell/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/deskbell/attack_animal(mob/user)
	return attack_hand(user)

/obj/item/deskbell/attack_hand(mob/user)
	ring(user.a_intent == INTENT_HARM)
	add_fingerprint(user)
	return

/obj/item/deskbell/proc/ring(aggressive)
	if(TIMER_COOLDOWN_CHECK(src, "ring"))
		return
	TIMER_COOLDOWN_START(src, "ring", ring_delay)
	flick("[icon_state]-push", src)
	if(aggressive)
		playsound(src, agressive_sound, 25)
	else
		playsound(src, normal_sound, 25)

	if(assembly)
		assembly.pulsed()
	return TRUE

/obj/item/deskbell/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated() || !Adjacent(M))
		return

	if(anchored)
		to_chat(M, span_notice("[src] is currently anchored."))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)

/obj/item/deskbell/preset
	desc = "A bell hooked up to an automated announcement system that alerts the department of your request."
	anchored = TRUE
	assembly = /obj/item/assembly/radio/bell

// Command
/obj/item/deskbell/preset/hop
	name = "\improper Head of Personnel's desk bell"
	assembly = /obj/item/assembly/radio/bell/hop

// Sec
/obj/item/deskbell/preset/sec
	name = "security desk bell"
	assembly = /obj/item/assembly/radio/bell/sec

/obj/item/deskbell/preset/warden
	name = "brig control desk bell"
	assembly = /obj/item/assembly/radio/bell/warden

/obj/item/deskbell/preset/armory
	name = "armory desk bell"
	assembly = /obj/item/assembly/radio/bell/armory

// Engi
/obj/item/deskbell/preset/engi
	name = "engineering desk bell"
	assembly = /obj/item/assembly/radio/bell/engi

/obj/item/deskbell/preset/atmos
	name = "atmospherics desk bell"
	assembly = /obj/item/assembly/radio/bell/atmos

// Sci
/obj/item/deskbell/preset/sci
	name = "science desk bell"
	assembly = /obj/item/assembly/radio/bell/sci

/obj/item/deskbell/preset/robotics
	name = "robotics desk bell"
	assembly = /obj/item/assembly/radio/bell/robotics

/obj/item/deskbell/preset/xenobio
	name = "xenobiology desk bell"
	assembly = /obj/item/assembly/radio/bell/xenobio

// Med
/obj/item/deskbell/preset/med
	name = "medbay desk bell"
	assembly = /obj/item/assembly/radio/bell/med

/obj/item/deskbell/preset/chemistry
	name = "chemistry desk bell"
	assembly = /obj/item/assembly/radio/bell/chemistry

/obj/item/deskbell/preset/genetics
	name = "genetics desk bell"
	assembly = /obj/item/assembly/radio/bell/genetics

/obj/item/deskbell/preset/paramedic
	name = "paramedic desk bell"
	assembly = /obj/item/assembly/radio/bell/paramedic

// Supply
/obj/item/deskbell/preset/supply
	name = "cargo desk bell"
	assembly = /obj/item/assembly/radio/bell/supply

/obj/item/deskbell/preset/delivery
	name = "delivery desk bell"
	assembly = /obj/item/assembly/radio/bell/delivery

// Service
/obj/item/deskbell/preset/kitchen
	name = "kitchen bell"
	assembly = /obj/item/assembly/radio/bell/kitchen

/obj/item/deskbell/preset/bar
	name = "bar bell"
	assembly = /obj/item/assembly/radio/bell/bar

/obj/item/deskbell/preset/hydroponics
	name = "hydroponics desk bell"
	assembly = /obj/item/assembly/radio/bell/hydroponics

/obj/item/deskbell/preset/library
	name = "library desk bell"
	assembly = /obj/item/assembly/radio/bell/library

/// Buttons
/obj/item/deskbell/button
	name = "button"
	desc = "A button that can have devices inserted inside."
	icon_state = "buttonred"
	materials = list(/datum/material/plastic = 2000)
	normal_sound = 'sound/machines/click.ogg'
	agressive_sound = 'sound/machines/click.ogg'

/obj/item/deskbell/button/blue
	icon_state = "buttonblue"

/obj/item/deskbell/button/meeting
	name = "meeting request button"
	desc = "A button that alerts command staff that a meeting is taking place."
	assembly = /obj/item/assembly/radio/bell/meeting

/obj/item/deskbell/button/sec_meeting
	name = "meeting request button"
	desc = "A button that alerts security staff that a meeting is taking place."
	assembly = /obj/item/assembly/radio/bell/sec_meeting
