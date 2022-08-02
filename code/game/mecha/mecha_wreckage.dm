///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/structure/mecha_wreckage
	name = "exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Repairable, given some work."
	icon = 'icons/mecha/mecha.dmi'
	density = TRUE
	anchored = FALSE
	opacity = 0
	var/state = MECHA_WRECK_CUT
	var/orig_mecha
	var/can_be_reconstructed = TRUE
	var/hint // Examine hint
	var/list/equipment = list() // Equipment that the mech retains
	// Total repair will take 80/40/27/20 seconds depending on capacitor tier. Roboticists repair 20% faster, so 64/32/21/16 seconds instead.
	var/repair_efficiency = 0 // Capacitor tier
	var/obj/item/stock_parts/cell/cell ///Keeps track of the mech's cell
	var/obj/item/stock_parts/scanning_module/scanmod ///Keeps track of the mech's scanning module
	var/mob/living/silicon/ai/AI //AIs to be salvaged

/obj/structure/mecha_wreckage/examine(mob/user)
	. = ..()
	switch(repair_efficiency)
		if(0)
			. += span_danger("There was no capacitor to save this poor mecha from its doomed fate!")
		if(1)
			. += span_danger("The weak capacitor did what little it could in preventing total destruction of this mecha. It is barely recoverable.")
		if(2)
			. += span_danger("The capacitor barely held the parts together upon its destruction. Repair will be difficult.")
		if(3)
			. += span_danger("The capacitor did well in preventing too much damage. Repair will be manageable.")
		if(4)
			. += span_danger("The capacitor did such a good job in preserving the chassis that you could almost call it functional. But it isn't. Repair should be easy though.")
	if(hint)
		. += hint

/obj/structure/mecha_wreckage/Initialize(mapload, mob/living/silicon/ai/AI_pilot)
	. = ..()
	
	if(!AI_pilot) //Type-checking for this is already done in mecha/Destroy()
		return

	AI = AI_pilot
	AI.apply_damage(150, BURN) //Give the AI a bit of damage from the "shock" of being suddenly shut down
	AI.death() //The damage is not enough to kill the AI, but to be 'corrupted files' in need of repair.
	AI.forceMove(src) //Put the dead AI inside the wreckage for recovery
	add_overlay(mutable_appearance('icons/obj/projectiles.dmi', "green_laser")) //Overlay for the recovery beacon
	AI.controlled_mech = null
	AI.remote_control = null

/obj/structure/mecha_wreckage/examine(mob/user)
	. = ..()
	if(AI)
		. += span_notice("The AI recovery beacon is active.")

/obj/structure/mecha_wreckage/attackby(obj/item/I, mob/user, params)
	if(!can_be_reconstructed)
		return ..()
	
	switch(state)
		if(MECHA_WRECK_CUT)
			if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
				user.visible_message(span_notice("[user] begins to weld together \the [src]'s broken parts..."),
										span_notice("You begin welding together \the [src]'s broken parts..."))
				if(I.use_tool(src, user, 200/repair_efficiency, amount = 5, volume = 100, robo_check = TRUE))
					state = MECHA_WRECK_DENTED
					hint = span_notice("The chassis has suffered major damage and will require the dents to be smoothed out with a <b>welder</b>.")
					to_chat(user, span_notice("The parts are loosely reattached, but are dented wildly out of place."))
				return
		if(MECHA_WRECK_DENTED)
			if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
				user.visible_message(span_notice("[user] welds out the many, many dents in \the [src]'s chassis..."),
										span_notice("You weld out the many, many dents in \the [src]'s chassis..."))
				if(I.use_tool(src, user, 200/repair_efficiency, amount = 5, volume = 100, robo_check = TRUE))
					state = MECHA_WRECK_LOOSE
					hint = span_notice("The mecha wouldn't make it two steps before falling apart. The bolts must be tightened with a <b>wrench</b>.")
					to_chat(user, span_notice("The chassis has been repaired, but the bolts are incredibly loose and need to be tightened."))
				return
		if(MECHA_WRECK_LOOSE)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message(span_notice("[user] slowly tightens the bolts of \the [src]..."),
										span_notice("You slowly tighten the bolts of \the [src]..."))
				if(I.use_tool(src, user, 180/repair_efficiency, volume = 50, robo_check = TRUE))
					state = MECHA_WRECK_UNWIRED
					hint = span_notice("The mech is nearly ready, but the <b>wiring</b> has been fried and needs repair.")
					to_chat(user, span_notice("The bolts are tightened and the mecha is looking as good as new, but the wiring was fried in the destruction and needs repair."))
				return
		if(MECHA_WRECK_UNWIRED)
			if(istype(I, /obj/item/stack/cable_coil) && I.tool_start_check(user, amount=5))
				user.visible_message(span_notice("[user] starts repairing the wiring on \the [src]..."),
										span_notice("You start repairing the wiring on \the [src]..."))
				if(I.use_tool(src, user, 120/repair_efficiency, amount = 5, volume = 50, robo_check = TRUE))
					create_mech()
					to_chat(user, span_notice("The mecha has been fully repaired."))
				return
	return ..()

/obj/structure/mecha_wreckage/proc/create_mech()
	if(!orig_mecha)
		return
	
	var/obj/mecha/M = new orig_mecha(loc)
	QDEL_NULL(M.cell)
	QDEL_NULL(M.scanmod)
	QDEL_NULL(M.capacitor)
	
	if(cell)
		cell.forceMove(M)
	if(scanmod)
		scanmod.forceMove(M)
	
	M.CheckParts(M.contents)

	qdel(src)
	QDEL_NULL(scanmod)
	QDEL_NULL(cell)
	

/obj/structure/mecha_wreckage/transfer_ai(interaction, mob/user, mob/living/silicon/ai/ai_unused, obj/item/aicard/card) //ai_unused is unused but having it is better than having  it be null or _ for readability
	if(!..())
		return

 //Proc called on the wreck by the AI card.
	if(interaction == AI_TRANS_TO_CARD) //AIs can only be transferred in one direction, from the wreck to the card.
		if(!AI) //No AI in the wreck
			to_chat(user, span_warning("No AI backups found."))
			return
		cut_overlays() //Remove the recovery beacon overlay
		AI.forceMove(card) //Move the dead AI to the card.
		card.AI = AI
		if(AI.client) //AI player is still in the dead AI and is connected
			to_chat(AI, "The remains of your file system have been recovered on a mobile storage device.")
		else //Give the AI a heads-up that it is probably going to get fixed.
			AI.notify_ghost_cloning("You have been recovered from the wreckage!", source = card)
		to_chat(user, "[span_boldnotice("Backup files recovered")]: [AI.name] ([rand(1000,9999)].exe) salvaged from [name] and stored within local memory.")

	else
		return ..()


/obj/structure/mecha_wreckage/gygax
	name = "\improper Gygax wreckage"
	icon_state = "gygax-broken"
	orig_mecha = /obj/mecha/combat/gygax

/obj/structure/mecha_wreckage/gygax/dark
	name = "\improper Dark Gygax wreckage"
	icon_state = "darkgygax-broken"
	orig_mecha = /obj/mecha/combat/gygax/dark

/obj/structure/mecha_wreckage/marauder
	name = "\improper Marauder wreckage"
	icon_state = "marauder-broken"
	orig_mecha = /obj/mecha/combat/marauder

/obj/structure/mecha_wreckage/mauler
	name = "\improper Mauler wreckage"
	icon_state = "mauler-broken"
	desc = "The Syndicate won't be very happy about this..."
	orig_mecha = /obj/mecha/combat/marauder/mauler

/obj/structure/mecha_wreckage/seraph
	name = "\improper Seraph wreckage"
	icon_state = "seraph-broken"
	orig_mecha = /obj/mecha/combat/marauder/seraph

/obj/structure/mecha_wreckage/reticence
	name = "\improper Reticence wreckage"
	icon_state = "reticence-broken"
	color = "#87878715"
	desc = "..."
	orig_mecha = /obj/mecha/combat/reticence

/obj/structure/mecha_wreckage/ripley
	name = "\improper Ripley wreckage"
	icon_state = "ripley-broken"
	orig_mecha = /obj/mecha/working/ripley

/obj/structure/mecha_wreckage/ripley/mkii
	name = "\improper Ripley MK-II wreckage"
	icon_state = "ripleymkii-broken"
	orig_mecha = /obj/mecha/working/ripley/mkii

/obj/structure/mecha_wreckage/ripley/firefighter
	name = "\improper Firefighter wreckage"
	icon_state = "firefighter-broken"
	orig_mecha = /obj/mecha/working/ripley/firefighter

/obj/structure/mecha_wreckage/ripley/deathripley
	name = "\improper Death-Ripley wreckage"
	icon_state = "deathripley-broken"
	orig_mecha = /obj/mecha/working/ripley/deathripley

/obj/structure/mecha_wreckage/honker
	name = "\improper H.O.N.K wreckage"
	icon_state = "honker-broken"
	desc = "All is right in the universe."
	orig_mecha = /obj/mecha/combat/honker

/obj/structure/mecha_wreckage/durand
	name = "\improper Durand wreckage"
	icon_state = "durand-broken"
	orig_mecha = /obj/mecha/combat/durand

/obj/structure/mecha_wreckage/phazon
	name = "\improper Phazon wreckage"
	icon_state = "phazon-broken"
	orig_mecha = /obj/mecha/combat/phazon

/obj/structure/mecha_wreckage/odysseus
	name = "\improper Odysseus wreckage"
	icon_state = "odysseus-broken"
	orig_mecha = /obj/mecha/medical/odysseus
