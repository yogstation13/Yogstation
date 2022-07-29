/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 SECONDS //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, span_notice("You use [src] to deactivate [H]."))
			qdel(H)
		else
			if(!is_blocked_turf(T, TRUE)) //can't put hard light on a tile that has dense stuff
				if(holocreator_busy)
					to_chat(user, span_notice("[src] is busy creating a hard light barrier."))
					return
				if(signs.len < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(signs.len >= max_signs)
							return
						if(is_blocked_turf(T, TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					to_chat(user, span_notice("You create \a [H] with [src]."))
				else
					to_chat(user, span_notice("[src] is projecting at max capacity!"))

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		to_chat(user, span_notice("You clear all active hard light barriers."))

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	creation_time = 2 SECONDS
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates hard light security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 3 SECONDS
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates hard light engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 3 SECONDS
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates hard light barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0 SECONDS
	max_signs = 3

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE hard light barriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	creation_time = 3 SECONDS
	max_signs = 3

/obj/item/holosign_creator/firstaid
	name = "medical holobed projector"
	desc = "A holographic projector that creates first aid holobeds that slows the metabolism of those laying on it and provides a sterile enviroment for surgery."
	icon_state = "signmaker_firstaid"
	holosign_type = /obj/structure/holobed
	creation_time = 1 SECONDS
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 1.5 SECONDS
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = FALSE

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, span_notice("You clear all active hard light barriers, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 0.5 SECONDS
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = FALSE
			return
		else if(R.emagged && !shock)
			to_chat(user, span_warning("You clear all active hard light barriers, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 3 SECONDS
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = TRUE
			return
		else
			if(signs.len)
				for(var/H in signs)
					qdel(H)
				to_chat(user, span_notice("You clear all active hard light barriers."))
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		to_chat(user, span_notice("You clear all active hard light barriers."))

/obj/item/holosign_creator/multi
	name = "multiple holosign projector"  //Fork from this to make multiple barriers
	var/list/holodesigns = list()

/obj/item/holosign_creator/multi/attack_self(mob/user)
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		to_chat(user, span_notice("You clear all active hard light barriers."))
	else
		holosign_type = next_list_item(holosign_type, holodesigns)
		to_chat(user, span_notice("You switch to [holosign_type]"))

/obj/item/holosign_creator/multi/CE
	name = "CE holofan projector"
	desc = "A holographic projector that creates hard light barriers that prevent changes in atmosphere conditions or engineering barriers."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	max_signs = 5
	holodesigns = list(/obj/structure/holosign/barrier/atmos, /obj/structure/holosign/barrier/engineering)
