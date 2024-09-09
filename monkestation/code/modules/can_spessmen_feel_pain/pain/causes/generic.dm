// -- Causes of pain, from non-modular actions --
/datum/brain_trauma/mild/concussion/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(1, seconds_per_tick))
		owner.cause_pain(BODY_ZONE_HEAD, 10)

// Shocks
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	. = ..()
	if(!.)
		return

	sharp_pain(BODY_ZONES_ALL, min((. / 2), 25), BURN)
	set_timed_pain_mod(PAIN_MOD_RECENT_SHOCK, 0.5, 30 SECONDS)

// Fleshmend of course heals pain.
/datum/status_effect/fleshmend/tick()
	. = ..()
	if(iscarbon(owner) && !owner.on_fire)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.cause_pain(BODY_ZONES_ALL, -2)

// Regen cores.
/datum/status_effect/regenerative_core/on_apply()
	. = ..()
	var/mob/living/carbon/human/human_owner = owner
	if(istype(human_owner) && human_owner.pain_controller)
		human_owner.cause_pain(BODY_ZONES_LIMBS, -25)
		human_owner.cause_pain(BODY_ZONE_CHEST, -30)
		human_owner.cause_pain(BODY_ZONE_HEAD, -15) // heals 90 pain total

// Flight potion's flavor says "it hurts a shit ton bro", so it should cause decent pain
/datum/reagent/flightpotion/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	var/has_wings_before = exposed_mob.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		var/mob/living/carbon/exposed_carbon = exposed_mob
		if(reac_volume < 5 || !(ishumanbasic(exposed_carbon) || islizard(exposed_carbon) || ismoth(exposed_carbon)))
			return
		if(has_wings_before)
			exposed_carbon.cause_pain(BODY_ZONE_HEAD, 10)
			exposed_carbon.cause_pain(BODY_ZONE_CHEST, 45)
			exposed_carbon.cause_pain(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), 18)
		else
			exposed_carbon.cause_pain(BODY_ZONE_HEAD, 16)
			exposed_carbon.cause_pain(BODY_ZONE_CHEST, 75)
			exposed_carbon.cause_pain(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), 30)

/datum/wound/blunt/bone/moderate/chiropractice(mob/living/carbon/human/user)
	. = ..()
	user.cause_pain(limb.body_zone, 25)

/datum/wound/blunt/bone/moderate/malpractice(mob/living/carbon/human/user)
	. = ..()
	user.cause_pain(limb.body_zone, 40)
