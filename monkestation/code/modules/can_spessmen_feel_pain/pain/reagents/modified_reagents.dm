// -- Reagents that modify pain. --
/datum/reagent
	/// Modifier applied by this reagent to the mob's pain.
	/// This is both a multiplicative modifier to their overall received pain,
	/// and an additive modifier to their per tick pain decay rate.
	var/pain_modifier = null

/datum/reagent/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	// hi melbert, this should have SHOULD_CALL_PARENT(TRUE)
	if(isnull(pain_modifier) || !istype(user))
		return

	if(user.set_pain_mod("[PAIN_MOD_CHEMS]-[name]", pain_modifier) && !user.can_feel_pain())
		// If the painkiller's strong enough give them an alert
		user.throw_alert("numbed", /atom/movable/screen/alert/numbed)

/datum/reagent/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	if(isnull(pain_modifier) || !istype(user))
		return
	user.unset_pain_mod("[PAIN_MOD_CHEMS]-[name]")

/datum/reagent/on_mob_delete(mob/living/L)
	. = ..()
	if(!isnull(pain_modifier) && L.can_feel_pain())
		L.clear_alert("numbed")

// Muscle stimulant is functionally morphine without downsides (it's rare)
/datum/reagent/medicine/muscle_stimulant
	pain_modifier = 0.5

// Epinephrine helps pain very very slightly and helps against shock
/datum/reagent/medicine/epinephrine
	pain_modifier = 0.9

/datum/reagent/medicine/epinephrine/on_mob_metabolize(mob/living/carbon/M)
	..()
	ADD_TRAIT(M, TRAIT_ABATES_SHOCK, type)

/datum/reagent/medicine/epinephrine/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_ABATES_SHOCK, type)
	..()

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_pain_shock(-1)

// Atropine fills a simliar niche to epinephrine
/datum/reagent/medicine/atropine
	pain_modifier = 0.8

/datum/reagent/medicine/atropine/on_mob_metabolize(mob/living/carbon/M)
	..()
	ADD_TRAIT(M, TRAIT_ABATES_SHOCK, type)

/datum/reagent/medicine/atropine/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_ABATES_SHOCK, type)
	..()

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_pain_shock(-2)

// Miner's salve is described as a good painkiller
/datum/reagent/medicine/mine_salve
	pain_modifier = 0.66

// Determined = fight or flight mode = should have less pain
/datum/reagent/determination
	pain_modifier = 0.8

// Drugs reduce pain
/datum/reagent/drug/space_drugs
	pain_modifier = 0.8

/datum/reagent/toxin/fentanyl
	pain_modifier = 0.5

/datum/reagent/drug/cocaine
	pain_modifier = 0.4

//Alcohol reduces pain based on boozepwr
/datum/reagent/consumable/ethanol/New()
	if(boozepwr && isnull(pain_modifier))
		var/new_pain_modifier = 12 / (boozepwr * 0.2)
		if(new_pain_modifier < 1)
			pain_modifier = new_pain_modifier
	return ..()

/datum/reagent/consumable/ethanol/painkiller
	pain_modifier = 0.75

// Abductor chem sets pain mod to 0 so abductors can do their surgeries
/datum/reagent/medicine/cordiolis_hepatico
	pain_modifier = 0

// Healium functions as an anesthetic
/datum/reagent/healium
	pain_modifier = 0.75

/datum/reagent/healium/on_mob_metabolize(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/grouped/anesthetic, name)

/datum/reagent/healium/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_status_effect(/datum/status_effect/grouped/anesthetic, name)

// Nitrous Oxide can apply some anesthetic, like the gas
/datum/reagent/nitrous_oxide
	pain_modifier = 0.75

/datum/reagent/nitrous_oxide/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(apply_anesthetic))
	RegisterSignal(user, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(remove_anesthetic))
	if(HAS_TRAIT(user, TRAIT_KNOCKEDOUT))
		apply_anesthetic(user)

/datum/reagent/nitrous_oxide/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	UnregisterSignal(user, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT)))
	remove_anesthetic(user)

/datum/reagent/nitrous_oxide/proc/apply_anesthetic(mob/living/carbon/source)
	SIGNAL_HANDLER
	source.apply_status_effect(/datum/status_effect/grouped/anesthetic, type)

/datum/reagent/nitrous_oxide/proc/remove_anesthetic(mob/living/carbon/source)
	SIGNAL_HANDLER
	source.remove_status_effect(/datum/status_effect/grouped/anesthetic, type)

// Cryoxadone slowly heals pain, like wounds.
// It also helps against shock, sort of.
/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return
	var/power = -0.00003 * (affected_mob.bodytemperature ** 2) + 3

	ADD_TRAIT(affected_mob, TRAIT_ABATES_SHOCK, type) // To negate the fact that being cold is bad for shock
	affected_mob.set_pain_mod(type, 0.5) // Heal pain faster
	affected_mob.cause_pain(BODY_ZONES_ALL, -0.5 * power * REM * seconds_per_tick)
	affected_mob.adjust_pain_shock(-power * REM * seconds_per_tick)

/datum/reagent/medicine/cryoxadone/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	user.unset_pain_mod(type)
	REMOVE_TRAIT(user, TRAIT_ABATES_SHOCK, type)

// Saline glucose helps shock
/datum/reagent/medicine/salglu_solution/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_ABATES_SHOCK, type)

/datum/reagent/medicine/salglu_solution/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_ABATES_SHOCK, type)
	return ..()

// Combat stimulants help against pain
/datum/reagent/medicine/stimulants
	pain_modifier = 0.5

/datum/reagent/medicine/changelingadrenaline
	pain_modifier = 0.5

// Diphenhydrame helps against disgust slightly
/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	M.adjust_disgust(-3 * REM * seconds_per_tick )

/datum/reagent/consumable/laughter/on_mob_metabolize(mob/living/carbon/user)
	pain_modifier = pick(0.8, 1, 1, 1, 1, 1.2)
	return ..()
