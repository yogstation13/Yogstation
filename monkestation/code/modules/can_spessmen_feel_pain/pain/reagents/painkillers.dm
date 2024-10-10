
/datum/chemical_reaction/medicine/ondansetron
	results = list(/datum/reagent/medicine/ondansetron = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 1)
	required_catalysts = list(/datum/reagent/consumable/ethanol = 3)
	optimal_ph_max = 11
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/aspirin
	results = list(/datum/reagent/medicine/painkiller/aspirin = 3)
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/paracetamol
	results = list(/datum/reagent/medicine/painkiller/paracetamol = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid/nitracid = 1)
	optimal_temp = 480
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/ibuprofen
	results = list(/datum/reagent/medicine/painkiller/ibuprofen = 5)
	required_reagents = list(/datum/reagent/propionic_acid = 1, /datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/propionic_acid
	results = list(/datum/reagent/propionic_acid = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	is_cold_recipe = TRUE
	required_temp = 250
	optimal_temp = 200
	overheat_temp = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/medicine/aspirin_para_coffee
	results = list(/datum/reagent/medicine/painkiller/aspirin_para_coffee = 3)
	required_reagents = list(/datum/reagent/medicine/painkiller/aspirin = 1, /datum/reagent/medicine/painkiller/paracetamol = 1, /datum/reagent/consumable/coffee = 1)
	optimal_ph_min = 2
	optimal_ph_max = 12
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/ibaltifen
	results = list(/datum/reagent/medicine/painkiller/specialized/ibaltifen = 3)
	required_reagents = list(/datum/reagent/propionic_acid = 1, /datum/reagent/chlorine = 1, /datum/reagent/copper = 1)
	required_catalysts = list(/datum/reagent/medicine/c2/libital = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/anurifen
	results = list(/datum/reagent/medicine/painkiller/specialized/anurifen = 3)
	required_reagents = list(/datum/reagent/propionic_acid= 1, /datum/reagent/fluorine = 1, /datum/reagent/phosphorus = 1)
	required_catalysts = list(/datum/reagent/medicine/c2/aiuri = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

// Not really reactions, but I'm leaving these here
// Gain oxycodone from juicing poppies
/obj/item/food/grown/poppy
	juice_results =  list(/datum/reagent/medicine/painkiller/oxycodone = 0)

/obj/item/food/grown/poppy/geranium
	juice_results = list()

/obj/item/food/grown/poppy/lily
	juice_results = list()

// Painkillers! They help with pain.
/datum/reagent/medicine/painkiller
	name = "prescription painkiller"

/datum/reagent/medicine/painkiller/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()

	// Painkillers make you numb.
	if(current_cycle >= 5)
		switch(pain_modifier)
			if(0 to 0.45)
				M.add_mood_event("numb", /datum/mood_event/narcotic_heavy, name)
			if(0.45 to 0.55)
				M.add_mood_event("numb", /datum/mood_event/narcotic_medium, name)
			else
				M.add_mood_event("numb", /datum/mood_event/narcotic_light, name)

	// However, drinking with painkillers is toxic.
	var/highest_boozepwr = 0
	for(var/datum/reagent/consumable/ethanol/alcohol in M.reagents.reagent_list)
		if(alcohol.boozepwr > highest_boozepwr)
			highest_boozepwr = alcohol.boozepwr

	if(highest_boozepwr > 0)
		M.apply_damage(round(highest_boozepwr / 33, 0.5) * REM * seconds_per_tick, TOX)
		. = TRUE

// Morphine is the well known existing painkiller.
// It's very strong but makes you sleepy. Also addictive.
/datum/reagent/medicine/painkiller/morphine
	name = "Morphine"
	description = "A painkiller that allows the patient to move at full speed even when injured. \
		Causes drowsiness and eventually unconsciousness in high doses. \
		Overdose causes minor dizziness and jitteriness."
	reagent_state = LIQUID
	color = "#A9FBFB"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM // 0.1 units per second
	overdose_threshold = 30
	ph = 8.96
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 30) //5u = 100 progress, 25-30u = addiction
	// Morphine is THE painkiller
	pain_modifier = 0.4

/datum/reagent/medicine/painkiller/morphine/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/painkiller/morphine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	return ..()

/datum/reagent/medicine/painkiller/morphine/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// Morphine heals a very tiny bit
	M.adjustBruteLoss(-0.2 * REM * seconds_per_tick, FALSE)
	M.adjustFireLoss(-0.1 * REM * seconds_per_tick, FALSE)
	// Morphine heals pain, dur
	M.cause_pain(BODY_ZONES_ALL, -2.5)
	// Morphine causes a bit of disgust
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(50 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(2 * REM * seconds_per_tick)

	// The longer we're metabolzing it, the more we get sleepy
	// for reference: (with 0.1 metabolism rate)
	// ~2.5 units = 12 cycles = ~30 seconds
	switch(current_cycle)
		if(64) //~12
			to_chat(M, span_warning("You start to feel tired..."))
			M.adjust_eye_blur(2 SECONDS * REM * seconds_per_tick) // just a hint teehee
			if(prob(50))
				M.emote("yawn")

		if(96 to 144) // 20 to 30u
			if(SPT_PROB(33, seconds_per_tick))
				M.adjust_drowsiness_up_to(1 * REM * seconds_per_tick, 6 SECONDS)

		if(144 to 192) // 30u to 40u
			if(SPT_PROB(66, seconds_per_tick))
				M.adjust_drowsiness_up_to(1 * REM * seconds_per_tick, 12 SECONDS)

		if(192 to INFINITY) //40u onward
			M.adjust_drowsiness_up_to(1 * REM * seconds_per_tick, 20 SECONDS)
			M.Sleeping(4 SECONDS * REM * seconds_per_tick)

	..()
	return TRUE

/datum/reagent/medicine/painkiller/morphine/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(18, seconds_per_tick))
		M.drop_all_held_items()
		M.set_dizzy_if_lower(4 SECONDS)
		M.set_jitter_if_lower(4 SECONDS)

// Aspirin. Bad at headaches, good at everything else, okay at fevers.
// Use healing chest and limb pain primarily.
/datum/reagent/medicine/painkiller/aspirin
	name = "Aspirin"
	description = "A medication that combats pain and fever. Can cause mild nausea. Overdosing is toxic, and causes high body temperature, sickness, hallucinations, dizziness, and confusion."
	reagent_state = LIQUID
	color = "#9c46ff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 6.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/aspirin/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// Not good at headaches, but very good at treating everything else.
	M.adjustBruteLoss(-0.1 * REM * seconds_per_tick, FALSE)
	M.adjustFireLoss(-0.05 * REM * seconds_per_tick, FALSE)
	// Numbers seem low, but our metabolism is very slow
	M.cause_pain(BODY_ZONE_HEAD, -0.08 * REM * seconds_per_tick)
	M.cause_pain(BODY_ZONES_LIMBS, -0.16 * REM * seconds_per_tick)
	M.cause_pain(BODY_ZONE_CHEST, -0.32 * REM * seconds_per_tick)
	// Okay at fevers.
	M.adjust_bodytemperature(-0.1 KELVIN * REM * seconds_per_tick, M.standard_body_temperature)
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(66 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(1.5 * REM * seconds_per_tick)

	..()
	return TRUE

/datum/reagent/medicine/painkiller/aspirin/overdose_process(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(!istype(M))
		return

	// On overdose, heat up the body...
	M.adjust_bodytemperature(0.5 KELVIN * REM * seconds_per_tick, max_temp = HYPERTHERMIA - 1 KELVIN)
	// Causes sickness...
	M.apply_damage(1 * REM * seconds_per_tick, TOX)
	if(M.disgust < 100 && SPT_PROB(100 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(3 * REM * seconds_per_tick)
	// ...Hallucinations after a while...
	if(current_cycle >= 15 && SPT_PROB(75 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_hallucinations_up_to(6 SECONDS * REM * seconds_per_tick, 40 SECONDS)
	// ...Dizziness after a longer while...
	if(current_cycle >= 20 && SPT_PROB(50 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_dizzy_up_to(2 SECONDS * REM * seconds_per_tick, 10 SECONDS)
	// ...And finally, confusion
	if(current_cycle >= 25 && SPT_PROB(30 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_confusion_up_to(4 SECONDS, 12 SECONDS)
	..()
	return TRUE

// Paracetamol. Okay at headaches, okay at everything else, bad at fevers, less disgust.
// Use for general healing every type of pain.
/datum/reagent/medicine/painkiller/paracetamol // Also known as Acetaminophen, or Tylenol
	name = "Paracetamol"
	description = "A painkiller that combats mind to moderate pain, headaches, and low fever. Causes mild nausea. Overdosing causes liver damage, sickness, and can be lethal."
	reagent_state = LIQUID
	color = "#fcaeff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 4.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/paracetamol/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// Good general painkiller.
	// Numbers seem lowish, but our metabolism is very slow
	M.adjustBruteLoss(-0.05 * REM * seconds_per_tick, FALSE)
	M.adjustFireLoss(-0.05 * REM * seconds_per_tick, FALSE)
	M.adjustToxLoss(-0.05 * REM * seconds_per_tick, FALSE)
	M.cause_pain(BODY_ZONES_ALL, -0.2 * REM * seconds_per_tick)
	// Not very good at treating fevers.
	M.adjust_bodytemperature(-0.05 KELVIN * REM * seconds_per_tick, M.standard_body_temperature)
	// Causes liver damage - higher dosages causes more liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, volume / 30 * REM * seconds_per_tick)
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(66 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(1.2 * REM * seconds_per_tick)

	..()
	return TRUE

/datum/reagent/medicine/painkiller/paracetamol/overdose_process(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(!istype(M))
		return

	// On overdose, cause sickness and liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2 * REM * seconds_per_tick)
	if(M.disgust < 100 && SPT_PROB(100 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(3 * REM * seconds_per_tick)

	return ..()

// Ibuprofen. Best at headaches, best at fevers, less good at everything else.
// Use for treating head pain primarily.
/datum/reagent/medicine/painkiller/ibuprofen // Also known as Advil
	name = "Ibuprofen"
	description = "A medication that combats mild pain, headaches, and fever. Causes mild nausea and dizziness in higher dosages. Overdosing causes sickness, drowsiness, dizziness, and mild pain."
	reagent_state = LIQUID
	color = "#e695ff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 5.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/ibuprofen/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// Really good at treating headaches.
	M.adjustBruteLoss(-0.05 * REM * seconds_per_tick, FALSE)
	M.adjustToxLoss(-0.1 * REM * seconds_per_tick, FALSE)
	// Heals pain, numbers seem low but our metabolism is very slow
	M.cause_pain(BODY_ZONE_HEAD, -0.32 * REM * seconds_per_tick)
	M.cause_pain(BODY_ZONE_CHEST, -0.16 * REM * seconds_per_tick)
	M.cause_pain(BODY_ZONES_LIMBS, -0.08 * REM * seconds_per_tick)
	// Causes flat liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.25 * REM * seconds_per_tick)
	// Really good at treating fevers.
	M.adjust_bodytemperature(-0.5 KELVIN * REM * seconds_per_tick, M.standard_body_temperature)
	// Causes more disgust the longer it's in someone...
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(66 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(min(current_cycle * 0.02, 2.4) * REM * seconds_per_tick)
	// ...and dizziness.
	if(current_cycle >= 25 && SPT_PROB(30 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_dizzy_up_to(2 SECONDS * REM * seconds_per_tick, 10 SECONDS)

	..()
	return TRUE

/datum/reagent/medicine/painkiller/ibuprofen/overdose_process(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(!istype(M))
		return

	// On overdose, causes liver damage and chest pain...
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * seconds_per_tick)
	M.cause_pain(BODY_ZONE_CHEST, 0.24 * REM * seconds_per_tick)
	// Sickness...
	if(M.disgust < 100 && SPT_PROB(100 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_disgust(3 * REM * seconds_per_tick)
	// ...Drowsyness...
	if(SPT_PROB(75 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_drowsiness(2 SECONDS * REM * seconds_per_tick)
	// ...And dizziness
	if(SPT_PROB(85 * max(1 - creation_purity, 0.5), seconds_per_tick))
		M.adjust_dizzy(4 SECONDS * REM * seconds_per_tick)

	return ..()

// Combination drug of other painkillers. It's a real thing. Less side effects, heals pain generally, mildly toxic in high doses.
// Upgrade to paracetamol and aspirin if you go through the effort to get coffee.
/datum/reagent/medicine/painkiller/aspirin_para_coffee
	name = "aspirin/paracetamol/caffeine"
	description = "A combination drug that effectively treats moderate pain with low side effects when used in low dosage. Toxic in higher dosages."
	reagent_state = LIQUID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#e695ff"
	metabolization_rate = REAGENTS_METABOLISM
	pain_modifier = 0.75

/datum/reagent/medicine/painkiller/aspirin_para_coffee/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// Heals all pain a bit if in low dosage.
	if(volume <= 10)
		// Number looks high, compared to other painkillers,
		// but we have a comparatively much higher metabolism than them.
		M.cause_pain(BODY_ZONES_ALL, -2.8 * REM * seconds_per_tick)
	// Mildly toxic in higher dosages.
	else if(SPT_PROB(volume * 3, seconds_per_tick))
		M.apply_damage(3 * REM * seconds_per_tick, TOX)
		. = TRUE

	..()

// Oxycodone. Very addictive, heals pain very fast, also a drug.
/datum/reagent/medicine/painkiller/oxycodone
	name = "Oxycodone"
	description = "A drug that rapidly treats major to extreme pain. Highly addictive. Overdose can cause heart attacks."
	reagent_state = LIQUID
	color = "#ffcb86"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 5.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 45) //5u = 150 progress, 15-20u = addiction
	pain_modifier = 0.35

/datum/reagent/medicine/painkiller/oxycodone/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	M.adjustBruteLoss(-0.3 * REM * seconds_per_tick, FALSE)
	M.adjustFireLoss(-0.2 * REM * seconds_per_tick, FALSE)
	M.cause_pain(BODY_ZONES_ALL, -3.4 * REM * seconds_per_tick)
	M.set_drugginess(20 SECONDS * REM * seconds_per_tick)
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(40, seconds_per_tick))
		M.adjust_disgust(2 * REM * seconds_per_tick)
	if(SPT_PROB(33, seconds_per_tick))
		M.adjust_dizzy_up_to(2 SECONDS * REM * seconds_per_tick, 10 SECONDS)

	..()
	return TRUE

/datum/reagent/medicine/painkiller/oxycodone/overdose_process(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/human_mob = M
	if(SPT_PROB(12, seconds_per_tick))
		var/can_heart_fail = (!human_mob.undergoing_cardiac_arrest() && human_mob.can_heartattack())
		var/picked_option = rand(1, (can_heart_fail ? 6 : 3))
		switch(picked_option)
			if(1)
				to_chat(human_mob, span_danger("Your legs don't want to move."))
				human_mob.Paralyze(6 SECONDS * REM * seconds_per_tick)
			if(2)
				to_chat(human_mob, span_danger("Your breathing starts to shallow."))
				human_mob.losebreath = clamp(human_mob.losebreath + 3 * REM * seconds_per_tick, 0, 12)
				human_mob.apply_damage((15 / creation_purity), OXY)
			if(3)
				human_mob.drop_all_held_items()
			if(4)
				to_chat(human_mob, span_danger("You feel your heart skip a beat."))
				human_mob.set_jitter_if_lower(6 SECONDS * REM * seconds_per_tick)
			if(5)
				to_chat(human_mob, span_danger("You feel the world spin."))
				human_mob.set_dizzy_if_lower(6 SECONDS * REM * seconds_per_tick)
			if(6)
				to_chat(human_mob, span_userdanger("You feel your heart seize and stop completely!"))
				if(human_mob.stat == CONSCIOUS)
					human_mob.visible_message(span_userdanger("[human_mob] clutches at [human_mob.p_their()] chest as if [human_mob.p_their()] heart stopped!"), ignored_mobs = human_mob)
				human_mob.emote("scream")
				human_mob.set_heartattack(TRUE)
				metabolization_rate *= 4
		return TRUE

/datum/reagent/medicine/painkiller/hydromorphone
	name = "Hydromorphone"
	description = "Pretty sure you wouldn't be able to feel anything"
	reagent_state = LIQUID
	color = "#ffcb86"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	pain_modifier = 0.1

/datum/reagent/medicine/painkiller/hydromorphone/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	M.cause_pain(BODY_ZONES_ALL, -12 * REM * seconds_per_tick)
	..()

// Future painkiller ideas:
// - Real world stuff
// Tramadol
// Fentanyl (Rework) (Also a potential anesthetic)
// Hydrocodone (And its combination drugs)
// Dihydromorphine
// Pethidine
// - Space stuff (Suffix: -fen)

// A subtype of painkillers that will heal pain better
// depending on what type of pain the part's feeling
/datum/reagent/medicine/painkiller/specialized
	name = "specialized painkiller"
	addiction_types = list(/datum/addiction/opioids = 15) //5u = 50 progress, 60u = addiction

	/// How much pain we restore on life ticks, modified by modifiers (yeah?)
	var/pain_heal_amount = 2.4
	/// What type of pain are we looking for? If we aren't experiencing this type, it will be 10x less effective
	var/pain_type_to_look_for
	/// What type of wound are we looking for? If our bodypart has this wound, it will be 1.5x more effective
	var/wound_type_to_look_for

/datum/reagent/medicine/painkiller/specialized/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	if(!M.pain_controller)
		return

	for(var/obj/item/bodypart/part as anything in M.bodyparts)
		if(!IS_ORGANIC_LIMB(part))
			continue

		var/final_pain_heal_amount = -1 * pain_heal_amount * REM * seconds_per_tick
		if(pain_type_to_look_for && (part.last_received_pain_type != pain_type_to_look_for))
			final_pain_heal_amount *= 0.1
		if(wound_type_to_look_for && (locate(wound_type_to_look_for) in part.wounds))
			final_pain_heal_amount *= 1.5

		M.cause_pain(part.body_zone, final_pain_heal_amount)

// Libital, but helps pain: ib-alti-fen
// Heals lots of pain for bruise pain, otherwise lower
/datum/reagent/medicine/painkiller/specialized/ibaltifen
	name = "Ibaltifen"
	description = "A painkiller designed to combat pain caused by broken limbs and bruises."
	reagent_state = LIQUID
	color = "#feffae"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 7.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.75
	pain_type_to_look_for = BRUTE
	wound_type_to_look_for = /datum/wound/blunt

/datum/reagent/medicine/painkiller/specialized/ibaltifen/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// a bit of libital influence
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5 * REM * seconds_per_tick)
	M.adjustBruteLoss(-0.5 * REM * normalise_creation_purity() * seconds_per_tick)
	..()
	return TRUE

// Aiuri, but helps pain: an-uri-fen
// Heals lots of pain for burn pain, otherwise lower
/datum/reagent/medicine/painkiller/specialized/anurifen
	name = "Anurifen"
	description = "A painkiller designed to combat pain caused by burns."
	reagent_state = LIQUID
	color = "#c4aeff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 3.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.75
	pain_type_to_look_for = BURN
	wound_type_to_look_for = /datum/wound/burn

/datum/reagent/medicine/painkiller/specialized/anurifen/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	// a bit of aiuri influence
	M.adjustOrganLoss(ORGAN_SLOT_EYES, 0.4 * REM * seconds_per_tick)
	M.adjustFireLoss(-0.5 * REM * normalise_creation_purity() * seconds_per_tick)
	..()
	return TRUE
