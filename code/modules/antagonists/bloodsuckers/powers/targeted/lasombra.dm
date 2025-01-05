/datum/action/cooldown/bloodsucker/targeted/lasombra
	name = "Shadow Control"
	desc = "Submit shadows to your bidding, making darkness much scarier than before."
	background_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	active_background_icon_state = "lasombra_power_on"
	base_background_icon_state = "lasombra_power_off"
	button_icon_state = "power_shadow"
	power_explanation = "Shadow Control:\n\
		Shadow Control allows you to do different things based on level:\n\
		Level 1 - Click lights to instantly break them;\n\
		Level 2 - Click a person near darkness to shut off any lights they have.\n\
		Level 3 - Click doors to bolt them down for a while, scales with level;\n\
		Level 4 - Click tiles to make a temporary fence on them that blocks movement, scales with level."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY
	purchase_flags = LASOMBRA_CAN_BUY
	bloodcost = 20
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bloodsucker/targeted/lasombra/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/machinery/light) || isopenturf(target_atom)

/datum/action/cooldown/bloodsucker/targeted/lasombra/CheckCanTarget(atom/target_atom)
	. = ..()
	if(isopenturf(target_atom))
		if(level_current < 4)
			owner.balloon_alert(owner, "you need [4 - level_current] more levels!")
			return FALSE
		return TRUE
	if(istype(target_atom, /obj/machinery/door))
		if(level_current < 3)
			owner.balloon_alert(owner, "you need [3 - level_current] more levels!")
			return FALSE
		return TRUE
	if(isliving(target_atom))
		if(level_current < 2)
			owner.balloon_alert(owner, "you need 1 more level!")
			return FALSE
		return TRUE
	if(istype(target_atom, /obj/machinery/light))
		return TRUE
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/lasombra/FireTargetedPower(atom/target_atom)
	. = ..()
	if(istype(target_atom, /obj/machinery/light))
		for(var/obj/machinery/light/light_bulbs in range(5, target_atom)) //break nearby lights
			light_bulbs.on = TRUE
			light_bulbs.break_light_tube()

	if(isliving(target_atom))
		var/mob/living/L = target_atom
		if(isethereal(L))
			L.emp_act(EMP_LIGHT)
		for(var/obj/item/O in L.get_all_contents())
			if(O.light_range && O.light_power)
				disintegrate(O)
			if(L.pulling && L.pulling.light_range && isitem(L.pulling))
				disintegrate(L.pulling)

	if(istype(target_atom, /obj/machinery/door))
		var/obj/structure/window/shadow/full/friend = new /obj/structure/window/shadow(get_turf(target_atom))
		QDEL_IN(friend, (2 + level_current) SECONDS)
		target_atom.visible_message(span_warning("Shadows leap at the door, blocking it!"))

	if(isopenturf(target_atom))
		var/set_direction = get_dir(owner, target_atom)
		var/obj/structure/window/shadow/friend = new /obj/structure/window/shadow(get_turf(target_atom))
		friend.dir = set_direction
		QDEL_IN(friend, (3 + level_current) SECONDS)
		target_atom.visible_message(span_warning("Shadows harden into a translucent wall, blocking passage!"))
	
/datum/action/cooldown/bloodsucker/targeted/lasombra/proc/disintegrate(obj/item/O)
	if(istype(O, /obj/item/pda))
		var/obj/item/pda/PDA = O
		PDA.set_light_on(FALSE)
		PDA.update_appearance(UPDATE_ICON)
		O.visible_message(span_danger("The light in [PDA] shorts out!"))
	else
		O.visible_message(span_danger("[O] is disintegrated by [src]!"))
		O.burn()
	playsound(src, 'sound/items/welder.ogg', 50, 1)
	
/obj/structure/window/shadow
	name = "shadow barrier"
	desc = "Basic shadow fence meant to stop idiots like you from passing."
	icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	icon_state = "shadowfence"
	can_be_unanchored = FALSE

/obj/structure/window/shadow/can_be_rotated()
	return FALSE

/obj/structure/window/shadow/full
	name = "shadow barrier" //original
	desc = "Not a window."
	icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	icon_state = "shadowlock"
	fulltile = TRUE
