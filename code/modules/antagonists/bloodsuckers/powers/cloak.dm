/datum/action/cooldown/spell/toggle/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye."

	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon_state = "power_cloak"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	// power_explanation = "Cloak of Darkness<:\n\
	// 	Activate this Power in the shadows and you will slowly turn nearly invisible.\n\
	// 	While using Cloak of Darkness, attempting to run will crush you.\n\
	// 	Additionally, while Cloak is active, you are completely invisible to the AI.\n\
	// 	Higher levels will increase how invisible you are."

	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	resource_costs = list(ANTAG_RESOURCE_BLOODSUCKER = 5)
	maintain_costs = list(ANTAG_RESOURCE_BLOODSUCKER = 0.2)
	cooldown_time = 5 SECONDS
	var/was_running
	var/runbound = TRUE

/// Must have nobody around to see the cloak
/datum/action/cooldown/spell/toggle/cloak/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/watchers in viewers(9, owner) - owner)
		if(feedback)
			owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/toggle/cloak/process()
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/user = owner
	animate(user, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)
	// Prevents running while on Cloak of Darkness
	if(runbound)
		if(user.m_intent != MOVE_INTENT_WALK)
			owner.balloon_alert(owner, "you attempt to run, crushing yourself.")
			user.toggle_move_intent()
			user.adjustBruteLoss(rand(5,15))

/datum/action/cooldown/spell/toggle/cloak/Enable()
	. = ..()
	var/mob/living/user = owner
	was_running = (user.m_intent == MOVE_INTENT_RUN)
	if(runbound)
		if(was_running)
			user.toggle_move_intent()
	user.digitalinvis = 1
	user.digitalcamo = 1
	user.balloon_alert(user, "cloak turned on.")

/datum/action/cooldown/spell/toggle/cloak/Disable()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)
	user.digitalinvis = 0
	user.digitalcamo = 0
	if(runbound)
		if(was_running && user.m_intent == MOVE_INTENT_WALK)
			user.toggle_move_intent()
	user.balloon_alert(user, "cloak turned off.")

/datum/action/cooldown/spell/toggle/cloak/shadow
	name = "Cloak of Shadows"
	desc = "Empowered to the abyss, fortitude will now grant you a shadow armor, making your grip harder to escape and reduce projectile damage while in darkness."
	background_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	active_background_icon_state = "lasombra_power_on"
	base_background_icon_state = "lasombra_power_off"
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_state"
	additional_text = "Additionally allows you to run during cloak and gain a physical cloak while in darkness."
	purchase_flags = LASOMBRA_CAN_BUY
	runbound = FALSE

/datum/action/cooldown/spell/toggle/cloak/shadow/Enable()
	. = ..()
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(light_amount <= LIGHTING_TILE_IS_DARK)
		if(!owner.get_item_by_slot(ITEM_SLOT_NECK))
			owner.equip_to_slot_or_del( new /obj/item/clothing/neck/yogs/sith_cloak/cloak(null), ITEM_SLOT_NECK)

/datum/action/cooldown/spell/toggle/cloak/shadow/Disable()
	. = ..()
	var/obj/item/I = owner.get_item_by_slot(ITEM_SLOT_NECK)
	if(istype(I, /obj/item/clothing/neck/yogs/sith_cloak/cloak))
		qdel(I)

/obj/item/clothing/neck/yogs/sith_cloak/cloak
	name = "cloak of shadows"
	desc = "Fancy stuff."
	armor = list(MELEE = 0, BULLET = 0, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 10, ACID = 100) //good if you haven nothing

/obj/item/clothing/neck/yogs/sith_cloak/cloak/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/neck/yogs/sith_cloak/cloak/process()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > LIGHTING_TILE_IS_DARK)
		qdel(src)
		STOP_PROCESSING(SSobj, src)
		src.visible_message(span_warning("The cape desintegrates as the light contacts it's surface!"))

