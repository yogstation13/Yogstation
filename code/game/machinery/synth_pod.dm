// SUIT STORAGE UNIT /////////////////
/obj/machinery/synth_pod
	name = "synthetic storage unit"
	desc = "An industrial unit made to store inactive synthetic units for long durations."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "close"
	density = TRUE
	max_integrity = 500
	circuit = /obj/item/circuitboard/machine/synth_pod

	var/mob/living/carbon/human/stored
								// if you add more storage slots, update cook() to clear their radiation too.

	state_open = FALSE
	panel_open = FALSE

/obj/machinery/synth_pod/Initialize(mapload)
	. = ..()
	update_icon()
	if(mapload)
		var/mob/living/carbon/human/S = new(src)
		S.set_species(/datum/species/wy_synth)
		stored = S
		var/datum/outfit/job/synthetic/SO = new()
		SO.equip(S)

/obj/machinery/synth_pod/update_icon()
	cut_overlays()

	if(stored)
		add_overlay("uvhuman")
	else 
		add_overlay("open")

/obj/machinery/synth_pod/process()
	if(!stored)
		return
	if(!is_synth(stored))
		return
	var/datum/species/wy_synth/S = stored.dna.species
	S.charge = clamp(S.charge + 10, PRETERNIS_LEVEL_NONE, PRETERNIS_LEVEL_FULL)


/obj/machinery/synth_pod/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(user) || user.stat || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	if(stored)
		to_chat(user, span_warning("This unit is already full."))
	var/mob/living/target = A

	if(!is_synth(target))
		to_chat(user, span_warning("This machine only accepts synthetics."))
		return

	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_mob(user, target, 3 SECONDS))
		if(stored)
			return
		if(target == user)
			user.visible_message(span_warning("[user] slips into [src] and closes the door behind [user.p_them()]!"), "<span class=notice'>You slip into [src]'s comfy space and shut its door.</span>")
		else
			target.visible_message("<span class='warning'>[user] pushes [target] into [src] and shuts its door!<span>", span_userdanger("[user] shoves you into [src] and shuts the door!"))
		close_machine(target)
		stored = target
		update_icon()


/obj/machinery/synth_pod/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W))
		return
	return ..()



/obj/machinery/synth_pod/attackby(obj/item/I, mob/user, params)
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "panel", "close", I))
			return
		if(default_deconstruction_crowbar(I))
			return

	return ..()

/obj/machinery/synth_pod/attack_ai(mob/user)
	. = ..()
	if(!isAI(user))
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.dashboard.has_completed_project(/datum/ai_project/synth_control))
		to_chat(user, span_warning("You do not have the required program to interface with this machine."))
		return
	if(!stored)
		to_chat(user, span_warning("There is no synthetic unit stored in this machine."))
		return
	if(AI.deploy_to_synth_pod(src))
		open_machine()
		var/datum/species/wy_synth/S = stored.dna.species
		S.assume_control(AI, stored)
		stored = null
		update_icon()

