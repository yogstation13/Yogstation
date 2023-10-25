/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.mobility_flags & MOBILITY_MOVE)
			if(prob(10))
				step(M, pick(GLOB.cardinals))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You start tripping hard!"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/affected_mob)
	var/hallucination_duration_in_seconds = (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) / 10)
	if(hallucination_duration_in_seconds < volume && prob(20))
		affected_mob.adjust_hallucinations(10 SECONDS)
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 10
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, span_notice("[smoke_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.AdjustStun(-5, FALSE)
	M.AdjustKnockdown(-5, FALSE)
	M.AdjustUnconscious(-5, FALSE)
	M.AdjustParalyzed(-5, FALSE)
	M.AdjustImmobilized(-5, FALSE)
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 2*REM)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 1.25*REM)
	..()
	. = 1

/datum/reagent/drug/nicotine/addiction_act_stage1(mob/living/M)
	if(prob(5) && iscarbon(M))
		M.adjust_jitter(10 SECONDS)
	..()

/datum/reagent/drug/nicotine/addiction_act_stage2(mob/living/M)
	if(prob(20) && iscarbon(M))
		M.adjust_jitter(10 SECONDS)
	..()
	. = 1

/datum/reagent/drug/nicotine/addiction_act_stage3(mob/living/M)
	if(prob(20) && iscarbon(M))
		M.adjust_jitter(10 SECONDS)
	..()
	. = 1

/datum/reagent/drug/nicotine/addiction_act_stage4(mob/living/M)
	if(prob(40) && iscarbon(M))
		M.adjust_jitter(10 SECONDS)
	..()
	. = 1

/datum/reagent/drug/crank
	name = "Crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
		to_chat(M, span_notice("[high_message]"))
	M.AdjustStun(-20, FALSE)
	M.AdjustKnockdown(-20, FALSE)
	M.AdjustUnconscious(-20, FALSE)
	M.AdjustImmobilized(-20, FALSE)
	M.AdjustParalyzed(-20, FALSE)
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3*REM)
	M.adjustToxLoss(5*REM, 0)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		to_chat(M, span_notice("[high_message]"))
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage2(mob/living/M)
	if(prob(25))
		to_chat(M, span_danger("Your skin feels loose..."))
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		to_chat(M, span_danger("Your skin starts to peel away..."))
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(!istype(M.dna.species, /datum/species/krokodil_addict))
		to_chat(M, span_userdanger("Your skin falls off easily!"))
		M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
		M.set_species(/datum/species/krokodil_addict)
	else
		M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Neutralizes mannitol. Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 40
	addiction_threshold = 20 // make sure this is more than what you can fit in a syringe
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1.6, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		to_chat(M, span_notice("[high_message]"))
	M.AdjustStun(-40, FALSE)
	M.AdjustKnockdown(-40, FALSE)
	M.AdjustUnconscious(-40, FALSE)
	M.AdjustParalyzed(-40, FALSE)
	M.AdjustImmobilized(-40, FALSE)
	M.adjustStaminaLoss(-2, 0)
	M.adjust_jitter(2 SECONDS)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1,4))
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message(span_danger("[M]'s hands flip out and flail everywhere!"))
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/M)
	M.adjust_jitter(5 SECONDS)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/M)
	M.adjust_jitter(10 SECONDS)
	M.adjust_dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(15 SECONDS)
	M.adjust_dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(20 SECONDS)
	M.adjust_dizzy(20)
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 40
	addiction_threshold = 20 // make sure this is more than one you can fit in a syringe
	metabolization_rate = REAGENTS_METABOLISM
	taste_description = "salt" // because they're bathsalts?
	var/datum/brain_trauma/special/psychotic_brawling/bath_salts/rage

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	..()
	
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(iscarbon(L))
		var/mob/living/carbon/human/H = L
		rage = new()
		H.gain_trauma(rage, TRAUMA_RESILIENCE_ABSOLUTE)
		H.physiology.stun_mod *= 0.1
		H.physiology.stamina_mod *= 0.2

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)

	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stun_mod *= 10	//Dividing by small numbers is scawy :(
		H.physiology.stamina_mod *= 5
	if(rage)
		QDEL_NULL(rage)
	..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, span_notice("[high_message]"))
	M.adjustStaminaLoss(-5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4)
	M.adjust_hallucinations(5 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.adjust_hallucinations(5 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i in 1 to 8)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.adjust_hallucinations(5 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(5 SECONDS)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.adjust_hallucinations(10 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(10 SECONDS)
	M.adjust_dizzy(10 SECONDS)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.adjust_hallucinations(30 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 12, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(15 SECONDS)
	M.adjust_dizzy(15 SECONDS)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.adjust_hallucinations(30 SECONDS)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 16, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(50 SECONDS)
	M.adjust_dizzy(50 SECONDS)
	M.adjustToxLoss(5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, span_notice("[high_message]"))
	M.adjustStaminaLoss(-18, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#FFF378"
	addiction_threshold = 10
	overdose_threshold = 20

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/affected_mob)
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	affected_mob.remove_status_effect(/datum/status_effect/confusion)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)
	..()
	. = 1

/datum/reagent/drug/happiness/overdose_process(mob/living/M)
	if(prob(30))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.adjust_dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
	..()
	. = 1

/datum/reagent/drug/happiness/addiction_act_stage1(mob/living/M)// all work and no play makes jack a dull boy
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_DISTURBED))
	M.adjust_jitter(5 SECONDS)
	if(prob(20))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage2(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_UNSTABLE))
	M.adjust_jitter(10 SECONDS)
	if(prob(30))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage3(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_CRAZY))
	M.adjust_jitter(15 SECONDS)
	if(prob(40))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage4(mob/living/carbon/human/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(SANITY_INSANE)
	M.adjust_jitter(20 SECONDS)
	if(prob(50))
		M.emote(pick("twitch","laugh","frown"))
	..()
	. = 1

/datum/reagent/drug/ketamine
	name = "Ketamine"
	description = "A heavy duty tranquilizer found to also invoke feelings of euphoria, and assist with pain. Popular at parties and amongst small frogmen who drive Honda Civics."
	reagent_state = LIQUID
	color = "#c9c9c9"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_threshold = 8
	overdose_threshold = 16

/datum/reagent/drug/ketamine/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_SURGERY_PREPARED, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_SURGERY_PREPARED, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_life(mob/living/carbon/M)
	//Friendly Reminder: Ketamine is a tranquilizer and will sleep you.
	switch(current_cycle)
		if(10)
			to_chat(M, span_warning("You start to feel tired...") )
		if(11 to 25)
			M.adjust_drowsiness(2 SECONDS)
		if(26 to INFINITY)
			M.Sleeping(60, 0)
			. = 1
	//Providing a Mood Boost
	M.adjust_confusion(-3 SECONDS)
	M.adjust_jitter(-5 SECONDS)
	M.disgust -= 3

	//Ketamine is also a dissociative anasthetic which means Hallucinations!
	M.adjust_hallucinations(20 SECONDS)
	..()

/datum/reagent/drug/ketamine/overdose_process(mob/living/M)
	var/obj/item/organ/brain/B = M.getorgan(/obj/item/organ/brain)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	if(B.can_gain_trauma(/datum/brain_trauma/mild/hallucinations, 1))
		B.brain_gain_trauma(/datum/brain_trauma/mild/hallucinations, 1)

/datum/reagent/drug/ketamine/addiction_act_stage1(mob/living/M)
	if(prob(20))
		M.drop_all_held_items()
		M.adjust_jitter(2 SECONDS)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.adjust_jitter(3 SECONDS)
		M.adjust_dizzy(3)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage3(mob/living/M)
	if(prob(40))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.adjust_jitter(4 SECONDS)
		M.adjust_dizzy(4)
	..()

//traitor only drug made with telecrystals
/datum/reagent/drug/red_eye
	name = "Red-Eye" //i love cowboy bebop
	description = "An experimental drug developed by the Syndicate in attempt to recreate wizards"
	reagent_state = GAS
	color = "#fd1a5e"
	addiction_threshold = 20
	overdose_threshold = 40
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	can_synth = FALSE

//Teleport like normal telecrystals
/datum/reagent/drug/red_eye/proc/tele_teleport(mob/living/L)
	var/turf/destination = get_teleport_loc(L.loc, L, rand(3,6))
	if(!istype(destination))
		return
	new /obj/effect/particle_effect/sparks(L.loc)
	playsound(L.loc, "sparks", 50, 1)
	if(!do_teleport(L, destination, asoundin = 'sound/effects/phaseinred.ogg', channel = TELEPORT_CHANNEL_BLUESPACE))
		return
	L.throw_at(get_edge_target_turf(L, L.dir), 1, 3, spin = FALSE, diagonals_first = TRUE)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.adjust_disgust(15)

/datum/reagent/drug/red_eye/on_mob_metabolize(mob/living/L)
	L.next_move_modifier *= 0.8
	L.action_speed_modifier *= 0.5
	tele_teleport(L)
	..()	

/datum/reagent/drug/red_eye/on_mob_end_metabolize(mob/living/L)
	L.next_move_modifier *= 1.25
	L.action_speed_modifier *= 2
	..()

/datum/reagent/drug/red_eye/on_mob_life(mob/living/carbon/M)
	var/mob/living/carbon/human/H = M
	H.eye_color = "fd1a5e"
	H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
	H.update_body()

	M.adjust_red_eye_up_to(15,40)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(0,1))
	M.AdjustKnockdown(-15, FALSE)
	M.adjustStaminaLoss(-4, 0)
	M.AdjustUnconscious(-5, FALSE)
	M.AdjustParalyzed(-20, FALSE)
	M.adjust_jitter(2 SECONDS)
	if(prob(10))
		to_chat(M, span_notice("[pick("TOK-LYR RQA-NAP", "BAPR NTNVA", "ZL-YVTUG FUVARF", "MAH'WEYH PLEGGH AT E'NTRATH", "TARCOL MINTI ZHERI.", "G'OLT-ULOFT")]"))
	if(prob(5))
		M.visible_message(span_danger("[M]'s eyes start bulging out of [M.p_their()] skull!"))
	if(prob(5))
		M.emote(pick("twitch","drool","moan","giggle"))
	if(prob(1))
		tele_teleport(M)
	..()

/datum/reagent/drug/red_eye/overdose_process(mob/living/M)
	M.adjustToxLoss(2, 0)
	if(isturf(M.loc) && !isspaceturf(M.loc) && prob(10))
		if(M.mobility_flags & MOBILITY_MOVE)
			step(M, pick(GLOB.cardinals))
	if(prob(8))
		M.visible_message(span_danger("[M]'s fingers curl into occult shapes!"))
		M.drop_all_held_items()
	if(prob(4))
		M.adjustToxLoss(1, 0)
		tele_teleport(M)
	if(prob(1))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1,4))
		M.adjustToxLoss(4, 0)
		tele_teleport(M)
		tele_teleport(M)
	..()
/datum/reagent/drug/red_eye/addiction_act_stage1(mob/living/M)
	M.adjust_jitter(5 SECONDS)
	if(prob(20))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/red_eye/addiction_act_stage2(mob/living/M)
	M.adjust_jitter(10 SECONDS)
	M.adjust_dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/red_eye/addiction_act_stage3(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(12 SECONDS)
	M.adjust_dizzy(12)
	if(prob(40))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/red_eye/addiction_act_stage4(mob/living/carbon/human/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(15 SECONDS)
	M.adjust_dizzy(15)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1,4))
	M.adjustToxLoss(2, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()
	if(prob(10))
		M.visible_message(span_danger("[M]'s fingers curl into occult shapes!"))
		M.drop_all_held_items()
	. = 1
/datum/reagent/drug/pumpup
	name = "Pump-Up"
	description = "Take on the world! A fast acting, hard hitting drug that pushes the limit on what you can handle."
	reagent_state = LIQUID
	color = "#e38e44"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/drug/pumpup/on_mob_metabolize(mob/living/L)
	..()
	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/HM = L
		HM.physiology.stamina_mod *= 0.90

/datum/reagent/drug/pumpup/on_mob_end_metabolize(mob/living/L)
	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/HM = L
		HM.physiology.stamina_mod /= 0.90
	..()

/datum/reagent/drug/pumpup/on_mob_life(mob/living/carbon/M)
	M.adjust_jitter(5 SECONDS)

	if(prob(5))
		to_chat(M, span_notice("[pick("Go! Go! GO!", "You feel ready...", "You feel invincible...")]"))
	if(prob(15))
		M.losebreath++
		M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/drug/pumpup/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You can't stop shaking, your heart beats faster and faster..."))

/datum/reagent/drug/pumpup/overdose_process(mob/living/M)
	M.adjust_jitter(5 SECONDS)
	if(prob(5))
		M.drop_all_held_items()
	if(prob(15))
		M.emote(pick("twitch","drool"))
	if(prob(20))
		M.losebreath++
		M.adjustStaminaLoss(4, 0)
	if(prob(15))
		M.adjustToxLoss(2, 0)
	..()
/datum/reagent/drug/blue_eye
	name = "Blue-Eye"
	description = "A stimulating drug often used by Space Wizards with mind altering effects when sprayed into the eye of a user"
	reagent_state = GAS
	color = "#5b5beb"
	taste_description = "swirling blue chaos"
	overdose_threshold = 40
	addiction_threshold = 30
	metabolization_rate = 1.3 * REAGENTS_METABOLISM
	var/original_eye_color = "000" //so we can return it to normal eye on end metabolism
	
/datum/reagent/drug/blue_eye/on_mob_metabolize(mob/living/L)
	..()
	if(prob(50))
		to_chat(L, span_warning("You start to see flickering blue light..."))
	else
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 30)

/datum/reagent/drug/blue_eye/on_mob_life(mob/living/carbon/M)
	if(!M?.mind?.has_antag_datum(/datum/antagonist/cult))
		var/mob/living/carbon/human/H = M
		original_eye_color = H.eye_color
		H.eye_color = "5b5beb"
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		H.update_body()
	if(!is_wizard(M))
		M.set_blue_eye(17)
		M.adjust_jitter(2 SECONDS)
		M.adjustStaminaLoss(-2, 0)
		if(isturf(M.loc) && !isspaceturf(M.loc) && prob(12))
			if(M.mobility_flags & MOBILITY_MOVE)
				step(M, pick(GLOB.cardinals))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","giggle","spin"))
		if(prob(10))
			to_chat(M, span_notice("[pick("SCYAR NILA!!", "NEC CANTIO.", "EI NATH!!!", "AULIE OXIN FIERA.", "TARCOL MINTI ZHERI.", "STI KALY!")]"))
	else
		M.set_blue_eye(30)
		M.adjust_jitter(4 SECONDS)
		M.adjustStaminaLoss(-3, 0)
		M.AdjustUnconscious(-7, FALSE)
		M.AdjustParalyzed(-7, FALSE)
		if(prob(25))
			to_chat(M, span_notice("[pick("SCYAR NILA!!", "NEC CANTIO.", "EI NATH!!!", "AULIE OXIN FIERA.", "TARCOL MINTI ZHERI.", "STI KALY!")]"))
	..()

/datum/reagent/drug/blue_eye/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	if(!is_wizard(M))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.4, 0.5, 0.6))
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.2, 0.3, 0.4))
	if(isturf(M.loc) && !isspaceturf(M.loc) && prob(20))
		if(M.mobility_flags & MOBILITY_MOVE)
			step(M, pick(GLOB.cardinals))
	if(prob(8))
		M.visible_message(span_danger("[M]'s fingers curl into mystical shapes!"))
		M.drop_all_held_items()
	if(prob(8))
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 30)
	..()

/datum/reagent/drug/blue_eye/addiction_act_stage1(mob/living/M)
	M.adjust_jitter(5 SECONDS)
	if(prob(20))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/blue_eye/addiction_act_stage2(mob/living/M)
	M.adjust_jitter(10 SECONDS)
	M.adjust_dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/blue_eye/addiction_act_stage3(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(12 SECONDS)
	M.adjust_dizzy(12)
	if(prob(40))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/blue_eye/addiction_act_stage4(mob/living/carbon/human/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovable(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.adjust_jitter(15 SECONDS)
	M.adjust_dizzy(15)
	if(!is_wizard(M))
		M.adjustToxLoss(3, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()
	. = 1
