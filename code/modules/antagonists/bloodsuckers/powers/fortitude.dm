/datum/action/bloodsucker/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "<b>Fortitude</b>:\n\
		Activating Fortitude will provide pierce, stun and dismember immunity.\n\
		You will additionally gain resistance to Brute and Stamina damge, scaling with level.\n\
		While using Fortitude, attempting to run will crush you.\n\
		At level 4, you gain complete stun immunity.\n\
		Higher levels will increase Brute and Stamina resistance."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 30
	cooldown = 8 SECONDS
	constant_bloodcost = 0.2
	var/was_running
	var/fortitude_resist // So we can raise and lower your brute resist based on what your level_current WAS.

/datum/action/bloodsucker/fortitude/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("Your flesh, skin, and muscles become as steel."))
	// Traits & Effects
	ADD_TRAIT(owner, TRAIT_PIERCEIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, BLOODSUCKER_TRAIT)
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

/datum/action/bloodsucker/fortitude/UsePower(mob/living/carbon/user)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	/// Prevents running while on Fortitude
	if(user.m_intent != MOVE_INTENT_WALK)
		user.toggle_move_intent()
		to_chat(user, span_warning("You attempt to run, crushing yourself."))
		user.adjustBruteLoss(rand(5,15))
	/// We don't want people using fortitude being able to use vehicles
	if(user.buckled && istype(user.buckled, /obj/vehicle))
		user.buckled.unbuckle_mob(src, force=TRUE)

/datum/action/bloodsucker/fortitude/DeactivatePower()
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
	REMOVE_TRAIT(bloodsucker_user, TRAIT_PIERCEIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(bloodsucker_user, TRAIT_NODISMEMBER, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(bloodsucker_user, TRAIT_PUSHIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(bloodsucker_user, TRAIT_STUNIMMUNE, BLOODSUCKER_TRAIT)

	if(was_running && bloodsucker_user.m_intent == MOVE_INTENT_WALK)
		bloodsucker_user.toggle_move_intent()
	return ..()

/// Monster Hunter version
/datum/action/bloodsucker/fortitude/hunter
	name = "Flow"
	desc = "Use the arts to Flow, giving shove and stun immunity, as well as brute, burn, dismember and pierce resistance. You cannot run while this is active."
	purchase_flags = HUNTER_CAN_BUY

/datum/action/bloodsucker/fortitude/shadow
	name = "Shadow Armor"
	desc = "Empowered to the abyss, fortitude will now grant you a shadow armor, making your grip harder to escape and reduce projectile damage while in darkness."
	button_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	background_icon_state_on = "lasombra_power_on"
	background_icon_state_off = "lasombra_power_off"
	icon_icon = 'icons/mob/actions/actions_lasombra_bloodsucker.dmi'
	button_icon_state = "power_armor"
	additional_text = "Additionally gives you extra damage while fortitude'd and agro grab while in darkness."
	purchase_flags = LASOMBRA_CAN_BUY
	constant_bloodcost = 0.3
	var/mutable_appearance/armor_overlay

/datum/action/bloodsucker/fortitude/shadow/ActivatePower()
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	armor_overlay = mutable_appearance('icons/obj/vamp_obj.dmi', "fortarmor")
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(light_amount <= 0.2)
		owner.add_overlay(armor_overlay)
		bloodsuckerdatum.frenzygrab.teach(user, TRUE)
		to_chat(user, span_notice("Shadow tentacles form and attach themselves to your body, you feel as if your muscles have merged with the shadows!"))
	var/datum/species/user_species = user.dna.species
	user_species.punchdamagelow += 0.5 * level_current
	user_species.punchdamagehigh += 0.5 * level_current

/datum/action/bloodsucker/fortitude/shadow/UsePower()
	. = ..()
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	var/mob/living/carbon/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(light_amount > 0.2)
		owner.cut_overlay(armor_overlay)
		bloodsuckerdatum.frenzygrab.remove(user)
		to_chat(user, span_warning("As you enter in contact with the light, the tentacles dissipate!"))

/datum/action/bloodsucker/fortitude/shadow/DeactivatePower()
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	owner.cut_overlay(armor_overlay)
	bloodsuckerdatum.frenzygrab.remove(user)
	var/datum/species/user_species = user.dna.species
	user_species.punchdamagelow -= 0.5 / level_current
	user_species.punchdamagehigh -= 0.5 / level_current