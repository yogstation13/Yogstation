/obj/item/organ/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/cyberimp/leg/Initialize()
	. = ..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	SetSlotFromZone()
	items_list = contents.Copy()

/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg configuration. You can use a screwdriver to reassemble it.")

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg."))
	update_icon()

/obj/item/organ/cyberimp/leg/Remove(mob/living/carbon/M, special = 0)
	..()

/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("[src] is hit by EMP!"))
		// give the owner an idea about why his implant is glitching

// /obj/item/organ/cyberimp/leg/maglock
// 	name = "integrated maglock implant"
// 	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contains all necessary tools."
// 	var/active = FALSE
// 	actions_types = list(/datum/action/item_action/organ_action/toggle)

// /obj/item/organ/cyberimp/leg/maglock/l
// 	zone = BODY_ZONE_L_LEG

// /obj/item/organ/cyberimp/leg/maglock/Destroy()
// 	if(active)
// 		ui_action_click()
// 	..()

// /obj/item/organ/cyberimp/leg/maglock/ui_action_click()
// 	active = !active
// 	to_chat(owner, span_notice("You [active ? "enable" : "disable"] your mag-pulse traction system implant."))
// 	if(active)
// 		ADD_TRAIT(owner, TRAIT_NOSLIPWATER, "maglock_implant")
// 		owner.add_movespeed_modifier("maglock_implant", update=TRUE, priority=100, multiplicative_slowdown=2, blacklisted_movetypes=(FLYING|FLOATING))
// 	else
// 		REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, "maglock_implant")
// 		owner.remove_movespeed_modifier("maglock_implant")

/obj/item/organ/cyberimp/leg/galosh
	name = "antislip implant"
	desc = "An implant that uses sensors and motors to detect when you are slipping and attempt to prevent it. It probably won't help if the floor is too slippery."

/obj/item/organ/cyberimp/leg/galosh/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/galosh/Insert()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOSLIPWATER, "Antislip_implant")

/obj/item/organ/cyberimp/leg/galosh/Remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, "Antislip_implant")
	. = ..()

/obj/item/organ/cyberimp/leg/noslip
	name = "advanced antislip implant"
	desc = "An implant that uses advanced sensors and motors to detect when you are slipping and attempt to prevent it."
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/leg/noslip/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/noslip/Insert()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOSLIPALL, "Noslip_implant")

/obj/item/organ/cyberimp/leg/noslip/Remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(owner, TRAIT_NOSLIPALL, "Noslip_implant")
	. = ..()
