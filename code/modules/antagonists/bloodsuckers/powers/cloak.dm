/datum/action/cooldown/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Cloak of Darkness<:\n\
		Activate this Power in the shadows and you will slowly turn nearly invisible.\n\
		While using Cloak of Darkness, attempting to run will crush you.\n\
		Additionally, while Cloak is active, you are completely invisible to the AI.\n\
		Higher levels will increase how invisible you are."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 5
	constant_bloodcost = 0.2
	cooldown_time = 5 SECONDS
	ascended_power = /datum/action/cooldown/bloodsucker/cloak/shadow
	var/was_running
	var/runbound = TRUE

/// Must have nobody around to see the cloak
/datum/action/cooldown/bloodsucker/cloak/CanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/watchers in viewers(9, owner) - owner)
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/ActivatePower()
	. = ..()
	var/mob/living/user = owner
	was_running = (user.m_intent == MOVE_INTENT_RUN)
	if(runbound)
		if(was_running)
			user.toggle_move_intent()
	user.digitalinvis = 1
	user.digitalcamo = 1
	user.balloon_alert(user, "cloak turned on.")

/datum/action/cooldown/bloodsucker/cloak/process()
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

/datum/action/cooldown/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your Cloak of Darkness fell off due to you falling unconscious!"))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/DeactivatePower()
	. = ..()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)
	user.digitalinvis = 0
	user.digitalcamo = 0
	if(runbound)
		if(was_running && user.m_intent == MOVE_INTENT_WALK)
			user.toggle_move_intent()
	user.balloon_alert(user, "cloak turned off.")

/datum/action/cooldown/bloodsucker/cloak/shadow
	name = "Cloak of Shadows"
	desc = "Empowered to the abyss, fortitude will now grant you a shadow armor, making your grip harder to escape and reduce projectile damage while in darkness."
	background_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	active_background_icon_state = "lasombra_power_on"
	base_background_icon_state = "lasombra_power_off"
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_state"
	additional_text = "Additionally allows you to run during cloak and gain a physical cloak while in darkness."
	purchase_flags = LASOMBRA_CAN_BUY
	constant_bloodcost = 0.3
	runbound = FALSE
	ascended_power = null

/obj/item/clothing/neck/yogs/sith_cloak/cloak
	name = "cloak of shadows"
	desc = "Fancy stuff."
	icon = 'icons/obj/vamp_obj.dmi'
	mob_overlay_icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "cloak"
	item_state = "cloak"
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

/datum/action/cooldown/bloodsucker/cloak/shadow/ActivatePower()
	. = ..()
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(light_amount <= LIGHTING_TILE_IS_DARK)
		if(!owner.get_item_by_slot(ITEM_SLOT_NECK))
			owner.equip_to_slot_or_del( new /obj/item/clothing/neck/yogs/sith_cloak/cloak(null), ITEM_SLOT_NECK)

/datum/action/cooldown/bloodsucker/cloak/shadow/DeactivatePower()
	. = ..()
	var/obj/item/I = owner.get_item_by_slot(ITEM_SLOT_NECK)
	if(istype(I, /obj/item/clothing/neck/yogs/sith_cloak/cloak))
		qdel(I)
