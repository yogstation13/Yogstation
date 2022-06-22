
/**
 * # FrenzyGrab
 *
 * The martial art given to Bloodsuckers so they can instantly aggressively grab people.
 */
/datum/martial_art/frenzygrab
	name = "Frenzy Grab"
	id = MARTIALART_FRENZYGRAB

/datum/martial_art/frenzygrab/grab_act(mob/living/user, mob/living/target)
	if(user != target)
		target.grabbedby(user)
		user.grab_state = GRAB_AGGRESSIVE
		restraining = TRUE
		return TRUE
	..()

/**
 * # Status effect
 *
 * This is the status effect given to Bloodsuckers in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 10
	examine_text = span_notice("They seem... inhumane, and feral!")
	alert_type = /obj/screen/alert/status_effect/frenzy
	/// Store whether they were an advancedtooluser, to give the trait back upon exiting.
	var/was_tooluser = FALSE
	/// The stored Bloodsucker antag datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum

/obj/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a Frenzy! You are entirely feral, and depending on your Clan - fighting for your life! <i>Feeding</i> while in this state is instant!"
	icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	icon_state = "power_recover"

/obj/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	// Disable ALL Powers and notify their entry
	bloodsuckerdatum.DisableAllPowers()
	to_chat(owner, span_userdanger("<FONT size = 3>Blood! You need Blood, now! You enter a total Frenzy! Your skin starts sizzling...."))
	to_chat(owner, span_announce("* Bloodsucker Tip: While in Frenzy, you instantly Aggresively grab, have stun resistance, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	// Stamina resistances
	user.physiology.stamina_mod *= 0.4

	// Give the other Frenzy effects
	ADD_TRAIT(owner, TRAIT_MUTE, FRENZY_TRAIT)
	ADD_TRAIT(owner, TRAIT_DEAF, FRENZY_TRAIT)
	ADD_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, FRENZY_TRAIT)
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, FRENZY_TRAIT)
	if(user.IsAdvancedToolUser())
		was_tooluser = TRUE
		ADD_TRAIT(owner, TRAIT_MONKEYLIKE, SPECIES_TRAIT)
	owner.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.4, blacklisted_movetypes=(FLYING|FLOATING))
	bloodsuckerdatum.frenzygrab.teach(user, TRUE)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	var/obj/item/cuffs = user.get_item_by_slot(SLOT_HANDCUFFED)
	var/obj/item/legcuffs = user.get_item_by_slot(SLOT_LEGCUFFED)
	if(user.handcuffed || user.legcuffed)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
	// Keep track of how many times we've entered a Frenzy.
	bloodsuckerdatum.frenzies++
	bloodsuckerdatum.frenzied = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	var/mob/living/carbon/human/user = owner
	to_chat(owner, span_warning("You come back to your senses."))
	REMOVE_TRAIT(owner, TRAIT_MUTE, FRENZY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_DEAF, FRENZY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, FRENZY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, FRENZY_TRAIT)
	if(was_tooluser)
		REMOVE_TRAIT(owner, TRAIT_MONKEYLIKE, SPECIES_TRAIT)
		was_tooluser = FALSE
	owner.remove_movespeed_modifier(type)
	bloodsuckerdatum.frenzygrab.remove(user)
	owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)
	owner.Dizzy(3 SECONDS)
	owner.Paralyze(2 SECONDS)
	user.physiology.stamina_mod /= 0.4

	bloodsuckerdatum.frenzied = FALSE
	return ..()

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	var/obj/item/cuffs = user.get_item_by_slot(SLOT_HANDCUFFED)
	var/obj/item/legcuffs = user.get_item_by_slot(SLOT_LEGCUFFED)
	if(user.handcuffed || user.legcuffed)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
	if(!bloodsuckerdatum.frenzied)
		return
	user.adjustFireLoss(0.5 + (bloodsuckerdatum.humanity_lost / 15))
