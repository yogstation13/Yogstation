/mob/living/carbon/Life(seconds, times_fired)
	set invisibility = 0

	if(notransform)
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(SHOULD_LIFETICK(src, times_fired))

		if(stat != DEAD) //Reagent processing needs to come before breathing, to prevent edge cases.
			handle_organs()

		. = ..()

		if (QDELETED(src))
			return

		// yogs start -- typing indicators, look in yogstation specific folder for proc
		handle_typing_indicator()
		//yogs end

		if(.) //not dead
			handle_blood()

		if(stat != DEAD)
			var/bprv = handle_bodyparts()
			if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
				update_stamina() //needs to go before updatehealth to remove stamcrit
				updatehealth()

		if(stat != DEAD)
			handle_brain_damage()

		if(stat != DEAD)
			handle_liver()

		if(stat != DEAD)
			//Stuff jammed in your limbs hurts
			handle_embedded_objects()

	else
		. = ..()

	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
		LoadComponent(/datum/component/rot/corpse)

	if(stat != DEAD)
		return 1

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(times_fired)
	var/next_breath = 4
	var/obj/item/organ/lungs/L = getorganslot(ORGAN_SLOT_LUNGS)
	if(L?.damage)
		next_breath = max(next_breath * L.get_organ_efficiency(), 1)

	if((times_fired % next_breath) == 0 || failed_last_breath || isipc(src)) //IPCs breathe every tick to stabilize cooling
		breathe() //Breathe per 4 ticks if healthy, down to 1 based on lung damage, unless suffocating
		if(failed_last_breath)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(reagents.has_reagent(/datum/reagent/toxin/lexorin, needs_metabolizing = TRUE))
		return
	if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby && pulledby.grab_state >= GRAB_KILL) || HAS_TRAIT(src, TRAIT_MAGIC_CHOKE) || (lungs && lungs.organ_flags & ORGAN_FAILING))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			INVOKE_ASYNC(src, PROC_REF(emote), "gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //in case of 0 pressure internals

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_ratio = 0
				if(environment)
					breath_ratio = BREATH_VOLUME/environment.return_volume()

				breath = loc.remove_air_ratio(breath_ratio)
		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	if(breath)
		breath.set_volume(BREATH_VOLUME)
	check_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return

	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE) && lungs)
			return
		adjustOxyLoss(1)

		failed_last_breath = 1
		throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		return 0

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/moles = breath.total_moles()

	
	var/breath_pressure = (moles*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME
	var/O2_partialpressure = ((breath.get_moles(GAS_O2)/moles)*breath_pressure) + (((breath.get_moles(GAS_PLUOXIUM)*8)/moles)*breath_pressure)
	var/Toxins_partialpressure = (breath.get_moles(GAS_PLASMA)/moles)*breath_pressure
	var/CO2_partialpressure = (breath.get_moles(GAS_CO2)/moles)*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			INVOKE_ASYNC(src, PROC_REF(emote), "gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = breath.get_moles(GAS_O2)*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)

	else //Enough oxygen
		failed_last_breath = 0
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = breath.get_moles(GAS_O2)
		clear_alert("not_enough_oxy")

	breath.adjust_moles(GAS_O2, -oxygen_used)
	breath.adjust_moles(GAS_CO2, oxygen_used)

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Unconscious(60)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.get_moles(GAS_PLASMA)/safe_tox_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")

	//NITROUS OXIDE
	if(breath.get_moles(GAS_NITROUS))
		var/SA_partialpressure = (breath.get_moles(GAS_NITROUS)/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			Unconscious(60)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	//yogs start -- Adds Nitrogen Narcosis https://en.wikipedia.org/wiki/Nitrogen_narcosis
	//NITROGEN
	if(breath.get_moles(GAS_N2))
		var/SA_partialpressure = (breath.get_moles(GAS_N2)/breath.total_moles())*breath_pressure
		if(SA_partialpressure > NITROGEN_NARCOSIS_PRESSURE_LOW) // Giggles
			if(prob(20))
				emote(pick("giggle","laugh"))
			if(SA_partialpressure > NITROGEN_NARCOSIS_PRESSURE_HIGH) // Hallucinations
				if(prob(15))
					to_chat(src, span_userdanger("You can't think straight!"))
					adjust_confusion_up_to(SA_partialpressure/10, 12 SECONDS)
				adjust_hallucinations(5 SECONDS)
	//yogs end
	//BZ (Facepunch port of their Agent B)
	if(breath.get_moles(GAS_BZ))
		var/bz_partialpressure = (breath.get_moles(GAS_BZ)/breath.total_moles())*breath_pressure
		/* Yogs comment-out: Smoothed BZ hallucination levels
		if(bz_partialpressure > 1)
			adjust_hallucinations(10 SECONDS)
		else if(bz_partialpressure > 0.01)
			adjust_hallucinations(5 SECONDS)
		*/
		adjust_hallucinations(round(BZ_MAX_HALLUCINATION * (1 - NUM_E ** (-BZ_LAMBDA * bz_partialpressure)))) // Yogs -- Better BZ hallucination values. Keep in mind that hallucination has to be an integer value, due to how it's handled in handle_hallucination()

	//TRITIUM
	if(breath.get_moles(GAS_TRITIUM))
		var/tritium_partialpressure = (breath.get_moles(GAS_TRITIUM)/breath.total_moles())*breath_pressure
		radiation += tritium_partialpressure/10

	//FREON
	if(breath.get_moles(GAS_FREON))
		var/freon_partialpressure = (breath.get_moles(GAS_FREON)/breath.total_moles())*breath_pressure
		adjustFireLoss(freon_partialpressure * 0.25)

	//MIASMA
	if(breath.get_moles(GAS_MIASMA))
		var/miasma_partialpressure = (breath.get_moles(GAS_MIASMA)/breath.total_moles())*breath_pressure

		if(prob(1 * miasma_partialpressure))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2,3)
			miasma_disease.name = "Unknown"
			ForceContractDisease(miasma_disease, TRUE, TRUE)

		//Miasma side effects
		switch(miasma_partialpressure)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
				if(prob(5))
					to_chat(src, span_notice("There is an unpleasant smell in the air."))
			if(5 to 20)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(src, span_warning("You smell something horribly decayed inside this room."))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(25))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			else
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")


	//Clear all moods if no miasma at all
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")


	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

/// Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(invalid_internals())
		// Unexpectely lost breathing apparatus and ability to breathe from the internal air tank.
		cutoff_internals()
		return
	if (external)
		. = external.remove_air_volume(volume_needed)
	else if (internal)
		. = internal.remove_air_volume(volume_needed)
	else
		// Return without taking a breath if there is no air tank.
		return
	// To differentiate between no internals and active, but empty internals.
	return . || FALSE

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_bodyparts()
	var/stam_regen = FALSE
	if(stam_regen_start_time <= world.time)
		stam_regen = TRUE
		if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
			. |= BODYPART_LIFE_UPDATE_HEALTH //make sure we remove the stamcrit
	for(var/I in bodyparts)
		var/obj/item/bodypart/BP = I
		if(BP.needs_processing)
			. |= BP.on_life(stam_regen)

/mob/living/carbon/proc/handle_organs()
	for(var/V in internal_organs)
		var/obj/item/organ/O = V
		if(O.compatible_biotypes & mob_biotypes) // assume carbons are organic by default
			O.on_life()

/mob/living/carbon/handle_diseases()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act()

/mob/living/carbon/handle_wounds()
	for(var/thing in all_wounds)
		var/datum/wound/W = thing
		if(W.processes) // meh
			W.handle_process()

/mob/living/carbon/handle_mutations_and_radiation()
	if(dna && dna.temporary_mutations.len)
		for(var/mut in dna.temporary_mutations)
			if(dna.temporary_mutations[mut] < world.time)
				if(mut == UI_CHANGED)
					if(dna.previous["UI"])
						dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
						updateappearance(mutations_overlay_update=1)
						dna.previous.Remove("UI")
					dna.temporary_mutations.Remove(mut)
					continue
				if(mut == UF_CHANGED)
					if(dna.previous["UF"])
						dna.unique_features = merge_text(dna.unique_features,dna.previous["UF"])
						updateappearance(mutcolor_update=1, mutations_overlay_update=1)
						dna.previous.Remove("UF")
					dna.temporary_mutations.Remove(mut)
					continue
				if(mut == UE_CHANGED)
					if(dna.previous["name"])
						real_name = dna.previous["name"]
						name = real_name
						dna.previous.Remove("name")
					if(dna.previous["UE"])
						dna.unique_enzymes = dna.previous["UE"]
						dna.previous.Remove("UE")
					if(dna.previous["blood_type"])
						dna.blood_type = dna.previous["blood_type"]
						dna.previous.Remove("blood_type")
					dna.temporary_mutations.Remove(mut)
					continue
		for(var/datum/mutation/human/HM in dna.mutations)
			if(HM && HM.timed)
				dna.remove_mutation(HM.type)

	radiation -= min(radiation, RAD_LOSS_PER_TICK)
	if(radiation > RAD_MOB_SAFE)
		adjustToxLoss(log(radiation-RAD_MOB_SAFE)*RAD_TOX_COEFFICIENT)


/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/
#define BALLMER_POINTS 5
GLOBAL_LIST_INIT(ballmer_good_msg, list("Hey guys, what if we rolled out a bluespace wiring system so mice can't destroy the powergrid anymore?",
										"Hear me out here. What if, and this is just a theory, we made R&D controllable from our PDAs?",
										"I'm thinking we should roll out a git repository for our research under the AGPLv3 license so that we can share it among the other stations freely.",
										"I dunno about you guys, but IDs and PDAs being separate is clunky as fuck. Maybe we should merge them into a chip in our arms? That way they can't be stolen easily.",
										"Why the fuck aren't we just making every pair of shoes into galoshes? We have the technology."))
GLOBAL_LIST_INIT(ballmer_windows_me_msg, list("Yo man, what if, we like, uh, put a webserver that's automatically turned on with default admin passwords into every PDA?",
												"So like, you know how we separate our codebase from the master copy that runs on our consumer boxes? What if we merged the two and undid the separation between codebase and server?",
												"Dude, radical idea: H.O.N.K mechs but with no bananium required.",
												"Best idea ever: Disposal pipes instead of hallways.",
												"We should store bank records in a webscale datastore, like /dev/null.",
												"You ever wonder if /dev/null supports sharding?",
												"What if we use a language that was written on a napkin and created over 1 weekend for all of our servers?"))

//this updates all special effects: stun, sleeping, knockdown, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()

	if(cultslurring)
		cultslurring = max(cultslurring-1, 0)

	if(silent)
		silent = max(silent-1, 0)

//used in human and monkey handle_environment()
/mob/living/carbon/proc/natural_bodytemperature_stabilization()
	var/body_temperature_difference = BODYTEMP_NORMAL - bodytemperature
	if(HAS_TRAIT(src, TRAIT_COLDBLOODED)) // Return 0 as your natural temperature. Species proc handle_environment() will adjust your temperature based on this.
		return 0
	switch(bodytemperature)
		if(-INFINITY to BODYTEMP_COLD_DAMAGE_LIMIT) //Cold damage limit is 50 below the default, the temperature where you start to feel effects.
			return max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(BODYTEMP_COLD_DAMAGE_LIMIT to BODYTEMP_NORMAL)
			return max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_NORMAL to BODYTEMP_HEAT_DAMAGE_LIMIT) // Heat damage limit is 50 above the default, the temperature where you start to feel effects.
			return min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, max(body_temperature_difference, -BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
			return min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers

/////////
//LIVER//
/////////

///Decides if the liver is failing or not.
/mob/living/carbon/proc/handle_liver()
	if(!dna)
		return
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		if(liver.damage < liver.maxHealth)
			return
		liver.organ_flags |= ORGAN_FAILING
	liver_failure()

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(liver && (liver.organ_flags & ORGAN_FAILING))
		return TRUE

/mob/living/carbon/proc/liver_failure()
	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, can_overdose=FALSE, liverless = TRUE)
	if(HAS_TRAIT(src, TRAIT_STABLELIVER))
		return
	adjustToxLoss(4, TRUE,  TRUE)
	if(prob(30))
		to_chat(src, span_warning("You feel a stabbing pain in your abdomen!"))


////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage()
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life()


////////////
// EMBEDS //
////////////

/mob/living/carbon/proc/handle_embedded_objects()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		for(var/obj/item/I in BP.embedded_objects)
			// If its not embedded, don't bother proccessing it
			if(!get_embedded_part(I))
				continue
			if(CHECK_BITFIELD(SEND_SIGNAL(I, COMSIG_ITEM_EMBED_TICK, src, BP), COMSIG_ITEM_BLOCK_EMBED_TICK))
				continue
			var/pain_chance_current = I.embedding.embedded_pain_chance
			if(!(mobility_flags & MOBILITY_STAND))
				pain_chance_current *= 0.2
			if(prob(pain_chance_current))
				BP.receive_damage(I.w_class*I.embedding.embedded_pain_multiplier, wound_bonus = CANT_WOUND)
				to_chat(src, span_userdanger("[I] embedded in your [BP.name] hurts!"))

			var/fall_chance_current = I.embedding.embedded_fall_chance
			if(!(mobility_flags & MOBILITY_STAND))
				fall_chance_current *= 0.2

			if(prob(fall_chance_current))
				BP.receive_damage(I.w_class*I.embedding.embedded_fall_pain_multiplier, wound_bonus = CANT_WOUND) // can wound
				remove_embedded_object(I, drop_location(), FALSE)
				visible_message(span_danger("[I] falls out of [name]'s [BP.name]!"), span_userdanger("[I] falls out of your [BP.name]!"))

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (NOBLOOD in dna.species.species_traits)) //not all carbons have species!
		return FALSE
	return TRUE

/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
