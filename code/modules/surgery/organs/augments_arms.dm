/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/cyberimp/arm/Initialize(mapload)
	. = ..()
	if(ispath(holder))
		holder = new holder(src)

	update_appearance(UPDATE_ICON)
	SetSlotFromZone()

	var/item_types = items_list.Copy()
	QDEL_NULL(items_list)
	items_list = list()
	for(var/item_type in item_types)
		items_list.Add(new item_type(src))

/obj/item/organ/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			stack_trace("Invalid zone for [type]")
			return FALSE
	return TRUE

/obj/item/organ/cyberimp/arm/update_icon(updates=ALL)
	. = ..()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	. = ..()
	. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.")

/obj/item/organ/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else if(zone == BODY_ZONE_L_ARM)
		zone = BODY_ZONE_R_ARM
	if(SetSlotFromZone())
		I.play_tool_sound(src)
		update_appearance(UPDATE_ICON)
		to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	else
		to_chat(user, span_warning("[src] cannot be modified!"))

/obj/item/organ/cyberimp/arm/Remove(mob/living/carbon/M, special = 0)
	Retract()
	..()

/obj/item/organ/cyberimp/arm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(1.5 * severity) && owner)
		to_chat(owner, span_warning("[src] is hit by EMP!"))
		// give the owner an idea about why his implant is glitching
		Retract()

/obj/item/organ/cyberimp/arm/proc/Retract()
	if(!holder || (holder in src))
		return FALSE

	UnregisterSignal(holder, COMSIG_ITEM_PREDROPPED)

	if(!syndicate_implant)
		owner.visible_message(span_notice("[owner] retracts [holder] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
			span_notice("[holder] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
			span_italics("You hear a short mechanical noise."))
		playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		to_chat(owner, span_notice("[holder] silently snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))

	if(istype(holder, /obj/item/assembly/flash/armimplant))
		var/obj/item/assembly/flash/F = holder
		F.set_light(0)

	owner.transferItemToLoc(holder, src, TRUE)
	holder = null
	return TRUE

/obj/item/organ/cyberimp/arm/proc/on_drop(datum/source, mob/user)
	Retract()

/obj/item/organ/cyberimp/arm/proc/Extend(obj/item/item)
	if(!(item in src))
		stack_trace("[item.type] is not in [type] and cannot be extended!")
		return FALSE

	holder = item
	RegisterSignal(holder, COMSIG_ITEM_PREDROPPED, PROC_REF(on_drop))
	ADD_TRAIT(holder, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.materials = null

	if(istype(holder, /obj/item/assembly/flash/armimplant))
		var/obj/item/assembly/flash/F = holder
		F.set_light(7)

	var/obj/item/arm_item = owner.get_active_held_item()

	if(arm_item)
		if(!owner.dropItemToGround(arm_item))
			to_chat(owner, span_warning("Your [arm_item] interferes with [src]!"))
			return FALSE
		else
			to_chat(owner, span_notice("You drop [arm_item] to activate [src]!"))

	var/result
	switch(zone)
		if(BODY_ZONE_R_ARM)
			result = owner.put_in_r_hand(holder)
		if(BODY_ZONE_L_ARM)
			result = owner.put_in_l_hand(holder)
		else
			result = owner.put_in_hands(holder)
	if(!result)
		to_chat(owner, span_warning("Your [name] fails to activate!"))
		return FALSE

	// Activate the hand that now holds our item.
	owner.swap_hand(result)//... or the 1st hand if the index gets lost somehow

	if(!syndicate_implant)
		owner.visible_message(span_notice("[owner] extends [holder] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
			span_notice("You extend [holder] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
			span_italics("You hear a short mechanical noise."))
		playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		to_chat(owner, span_notice("You silently extend [holder] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	
	return TRUE

/obj/item/organ/cyberimp/arm/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!holder && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(!holder || (holder in src))
		holder = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/obj/item/I in items_list)
				choice_list[I] = image(I)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !holder && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()


/obj/item/organ/cyberimp/arm/gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(3 * severity) && owner && (organ_flags & ORGAN_FAILING))
		Retract()
		owner.visible_message(span_danger("A loud bang comes from [owner]\'s [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!"))
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		to_chat(owner, span_userdanger("You feel an explosion erupt inside your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!"))
		owner.adjust_fire_stacks(20)
		owner.ignite_mob()
		owner.adjustFireLoss(25)
		organ_flags |= ORGAN_FAILING


/obj/item/organ/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	items_list = list(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/cyberimp/arm/gun/laser/l
	zone = BODY_ZONE_L_ARM


/obj/item/organ/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	items_list = list(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/cyberimp/arm/gun/taser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contains all necessary tools."
	items_list = list(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)

/obj/item/organ/cyberimp/arm/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset/on_drop(datum/source, mob/user)
	ui_action_click()

/obj/item/organ/cyberimp/arm/toolset/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		to_chat(usr, span_notice("You unlock [src]'s integrated knife!"))
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return TRUE
	return FALSE

/obj/item/organ/cyberimp/arm/toolset/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!holder && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	var/list/choice_list = list()
	for(var/obj/item/I in items_list)
		choice_list[I] = image(I)
	choice_list["Retract"] = image(icon = 'icons/mob/landmarks.dmi', icon_state = "x")
	var/choice = show_radial_menu(owner, owner, choice_list)
	if(!choice)
		return
	Retract()
	if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && (choice in contents))
		// This monster sanity check is a nice example of how bad input is.
		Extend(choice)

/obj/item/organ/cyberimp/arm/toolset/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	items_list = list(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/surgicaldrill/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment)

/obj/item/organ/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	items_list = list(/obj/item/melee/transforming/energy/blade/hardlight)

/obj/item/organ/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	items_list = list(/obj/item/gun/medbeam)


/obj/item/organ/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	items_list = list(/obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/flash/Initialize(mapload)
	. = ..()
	if(locate(/obj/item/assembly/flash/armimplant) in items_list)
		var/obj/item/assembly/flash/armimplant/F = locate(/obj/item/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	items_list = list(/obj/item/borg/stun)

/obj/item/organ/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	items_list = list(/obj/item/melee/transforming/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/combat/Initialize(mapload)
	. = ..()
	if(locate(/obj/item/assembly/flash/armimplant) in items_list)
		var/obj/item/assembly/flash/armimplant/F = locate(/obj/item/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/syndie_mantis
	name = "G.O.R.L.E.X. mantis blade implant"
	desc = "Modernized mantis blades designed and coined by Tiger operatives. Energy actuators makes the blade a much deadlier weapon."
	items_list = list(/obj/item/mantis/blade/syndicate)
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/arm/syndie_hammer
	name = "Vxtvul Hammer implant"
	desc = "A folded Vxtvul Hammer designed to be incorporated into preterni chassis. Surgery can permit it to fit in other organic bodies."
	items_list = list(/obj/item/melee/vxtvulhammer)
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/arm/nt_mantis
	name = "H.E.P.H.A.E.S.T.U.S. mantis blade implants"
	desc = "Retractable arm-blade implants to get you out of a pinch. Wielding two will let you double-attack."
	items_list = list(/obj/item/mantis/blade/NT)

/obj/item/organ/cyberimp/arm/nt_mantis/left
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	items_list = list(/obj/item/apc_powercord)
	slot = ORGAN_SLOT_STOMACH_AID //so ipcs don't get shafted for nothing
	compatible_biotypes = MOB_ROBOTIC
	zone = BODY_ZONE_CHEST

/obj/item/organ/cyberimp/arm/power_cord/SetSlotFromZone() // don't swap the zone
	return FALSE

/obj/item/organ/cyberimp/arm/flash/rev
	name = "revolutionary brainwashing implant"
	desc = "An integrated flash projector used alongside syndicate subliminal messaging training to convert loyal crew into violent syndicate activists."
	items_list = list(/obj/item/assembly/flash/armimplant/rev)
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/arm/stechkin_implant
	name = "Stechkin implant"
	desc = "A modified version of the Stechkin pistol placed inside of the forearm to allow for easy concealment."
	items_list = list(/obj/item/gun/ballistic/automatic/pistol/implant)
	syndicate_implant = TRUE
