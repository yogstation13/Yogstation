/datum/action/cooldown/bloodsucker/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Fortitude:\n\
		Activating Fortitude will provide pierce, stun and dismember immunity.\n\
		You will additionally gain resistance to Brute and Stamina damge, scaling with level.\n\
		While using Fortitude, attempting to run will crush you.\n\
		At level 4, you gain complete stun immunity.\n\
		Higher levels will increase Brute and Stamina resistance."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 30
	cooldown_time = 8 SECONDS
	constant_bloodcost = 0.2
	ascended_power = /datum/action/cooldown/bloodsucker/fortitude/shadow
	var/was_running
	var/fortitude_resist // So we can raise and lower your brute resist based on what your level_current WAS.

/datum/action/cooldown/bloodsucker/fortitude/ActivatePower()
	. = ..()
	owner.balloon_alert(owner, "fortitude turned on.")
	to_chat(owner, span_notice("Your flesh, skin, and muscles become as steel."))
	// Traits & Effects
	owner.add_traits(list(TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_PUSHIMMUNE), BLOODSUCKER_TRAIT)
	if(level_current >= 2)
		ADD_TRAIT(owner, TRAIT_STUNIMMUNE, BLOODSUCKER_TRAIT) // They'll get stun resistance + this, who cares.
	var/mob/living/carbon/human/bloodsucker_user = owner
	if(IS_BLOODSUCKER(owner) || IS_VASSAL(owner))
		fortitude_resist = max(0.3, 0.7 - level_current * 0.1)
		bloodsucker_user.physiology.brute_mod *= fortitude_resist
		bloodsucker_user.physiology.stamina_mod *= fortitude_resist
	if(IS_MONSTERHUNTER(owner))
		bloodsucker_user.physiology.brute_mod *= 0.4
		bloodsucker_user.physiology.burn_mod *= 0.4
		ADD_TRAIT(owner, TRAIT_STUNIMMUNE, BLOODSUCKER_TRAIT)

	was_running = (owner.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		bloodsucker_user.toggle_move_intent()

/datum/action/cooldown/bloodsucker/fortitude/process()
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/carbon/user = owner
	/// Prevents running while on Fortitude
	if(user.m_intent != MOVE_INTENT_WALK)
		user.toggle_move_intent()
		user.balloon_alert(user, "you attempt to run, crushing yourself.")
		user.adjustBruteLoss(rand(5,15))
	/// We don't want people using fortitude being able to use vehicles
	if(user.buckled && istype(user.buckled, /obj/vehicle))
		user.buckled.unbuckle_mob(src, force=TRUE)

/datum/action/cooldown/bloodsucker/fortitude/DeactivatePower()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/bloodsucker_user = owner
	if(IS_BLOODSUCKER(owner) || IS_VASSAL(owner))
		bloodsucker_user.physiology.brute_mod /= fortitude_resist
		if(!HAS_TRAIT_FROM(bloodsucker_user, TRAIT_STUNIMMUNE, BLOODSUCKER_TRAIT))
			bloodsucker_user.physiology.stamina_mod /= fortitude_resist
	if(IS_MONSTERHUNTER(owner))
		bloodsucker_user.physiology.brute_mod /= 0.4
		bloodsucker_user.physiology.burn_mod /= 0.4
	// Remove Traits & Effects
	owner.remove_traits(list(TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE), BLOODSUCKER_TRAIT)

	if(was_running && bloodsucker_user.m_intent == MOVE_INTENT_WALK)
		bloodsucker_user.toggle_move_intent()
	owner.balloon_alert(owner, "fortitude turned off.")
	return ..()

/// Monster Hunter version
/datum/action/cooldown/bloodsucker/fortitude/hunter
	name = "Flow"
	desc = "Use the arts to Flow, giving shove and stun immunity, as well as brute, burn, dismember and pierce resistance. You cannot run while this is active."
	purchase_flags = HUNTER_CAN_BUY

/datum/action/cooldown/bloodsucker/fortitude/shadow
	name = "Shadow Armor"
	desc = "Empowered to the abyss, fortitude will now grant you a shadow armor, making your grip harder to escape and reduce projectile damage while in darkness."
	background_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	active_background_icon_state = "lasombra_power_on"
	base_background_icon_state = "lasombra_power_off"
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_armor"
	additional_text = "Additionally gives you extra damage while fortitude'd and agro grab while in darkness."
	purchase_flags = LASOMBRA_CAN_BUY
	constant_bloodcost = 0.3
	ascended_power = null

/datum/action/cooldown/bloodsucker/fortitude/shadow/ActivatePower()
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(light_amount <= LIGHTING_TILE_IS_DARK)
		bloodsuckerdatum.frenzygrab.teach(user, TRUE)
		to_chat(user, span_notice("Shadow tentacles form and attach themselves to your body, you feel as if your muscles have merged with the shadows!"))
	user.physiology.punchdamagehigh_bonus += 0.5 * level_current
	user.physiology.punchdamagelow_bonus += 0.5 * level_current
	user.physiology.punchstunthreshold_bonus += 0.5 * level_current	//So we dont give them stun baton hands

/datum/action/cooldown/bloodsucker/fortitude/shadow/process()
	. = ..()
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	var/mob/living/carbon/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(light_amount > LIGHTING_TILE_IS_DARK)
		bloodsuckerdatum.frenzygrab.remove(user)
		to_chat(user, span_warning("As you enter in contact with the light, the tentacles dissipate!"))

/datum/action/cooldown/bloodsucker/fortitude/shadow/DeactivatePower()
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.frenzygrab.remove(user)
	user.physiology.punchdamagehigh_bonus -= 0.5 * level_current
	user.physiology.punchdamagelow_bonus -= 0.5 * level_current
	user.physiology.punchstunthreshold_bonus -= 0.5 * level_current
