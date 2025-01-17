#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/****************************************************
				BLOOD SYSTEM
****************************************************/

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(seconds_per_tick, times_fired)

	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return

	if(bodytemperature < BLOOD_STOP_TEMP || HAS_TRAIT(src, TRAIT_HUSK)) //cold or husked people do not pump the blood.
		return

	var/sigreturn = SEND_SIGNAL(src, COMSIG_HUMAN_ON_HANDLE_BLOOD, seconds_per_tick, times_fired)
	if(sigreturn & HANDLE_BLOOD_HANDLED)
		return
	//begin Monkestation addition
	//This is processing for spleen organ which effects blood regen
	var/mob/living/carbon/human/humantarget = src
	var/spleen_process = 0
	if(!HAS_TRAIT(src, TRAIT_SPLEENLESS_METABOLISM) && src.get_organ_slot(ORGAN_SLOT_SPLEEN) && !isnull(humantarget.dna.species.mutantspleen))
		spleen_process = 1
	if(blood_volume < BLOOD_VOLUME_OKAY)
		if(spleen_process)
			SEND_SIGNAL(src, COMSIG_SPLEEN_EMERGENCY)
	//End Monkestation addition

	if(!(sigreturn & HANDLE_BLOOD_NO_NUTRITION_DRAIN))
		if(blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			if(satiety > 80)
				nutrition_ratio *= 1.25
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * seconds_per_tick)
			if(spleen_process) //monkestation addition for spleens
				SEND_SIGNAL(src, COMSIG_SPLEEN_MULT_BLOODGEN, humantarget, blood_volume, nutrition_ratio, seconds_per_tick) //does blood generation process in spleen instead of below in else
			else
				blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * seconds_per_tick), BLOOD_VOLUME_NORMAL)

	// // we call lose_blood() here rather than quirk/process() to make sure that the blood loss happens in sync with life()
	// if(HAS_TRAIT(src, TRAIT_BLOOD_DEFICIENCY))
	// 	var/datum/quirk/blooddeficiency/blooddeficiency = get_quirk(/datum/quirk/blooddeficiency)
	// 	if(!isnull(blooddeficiency))
	// 		blooddeficiency.lose_blood(seconds_per_tick)

	//Effects of bloodloss
	if(!(sigreturn & HANDLE_BLOOD_NO_EFFECTS))
		var/word = pick("dizzy","woozy","faint")
		switch(blood_volume)
			if(BLOOD_VOLUME_MAX_LETHAL to INFINITY)
				if(SPT_PROB(7.5, seconds_per_tick))
					to_chat(src, span_userdanger("Blood starts to tear your skin apart. You're going to burst!"))
					investigate_log("has been gibbed by having too much blood.", INVESTIGATE_DEATHS)
					inflate_gib()
			if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(src, span_warning("You feel your skin swelling."))
			if(BLOOD_VOLUME_MAXIMUM to BLOOD_VOLUME_EXCESS)
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(src, span_warning("You feel terribly bloated."))
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(SPT_PROB(2.5, seconds_per_tick))
					to_chat(src, span_warning("You feel [word]."))
				adjustOxyLoss(round(0.005 * (BLOOD_VOLUME_NORMAL - blood_volume) * seconds_per_tick, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				adjustOxyLoss(round(0.01 * (BLOOD_VOLUME_NORMAL - blood_volume) * seconds_per_tick, 1))
				if(SPT_PROB(2.5, seconds_per_tick))
					set_eye_blur_if_lower(12 SECONDS)
					to_chat(src, span_warning("You feel very [word]."))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				adjustOxyLoss(2.5 * seconds_per_tick)
				if(SPT_PROB(7.5, seconds_per_tick))
					Unconscious(rand(20,60))
					to_chat(src, span_warning("You feel extremely [word]."))
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				if(!HAS_TRAIT(src, TRAIT_NODEATH))
					investigate_log("has died of bloodloss.", INVESTIGATE_DEATHS)
					death()

	var/temp_bleed = 0
	//Bleeding out
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		var/iter_bleed_rate = iter_part.get_modified_bleed_rate()
		temp_bleed += iter_bleed_rate * seconds_per_tick
		if(HAS_TRAIT(src, TRAIT_HEAVY_BLEEDER))
			temp_bleed *= 2

		if(iter_part.generic_bleedstacks) // If you don't have any bleedstacks, don't try and heal them
			if(HAS_TRAIT(src, TRAIT_HEAVY_BLEEDER))
				iter_part.adjustBleedStacks(-1, minimum = 0) /// we basically double up on bleedstacks
			iter_part.adjustBleedStacks(-1, 0)

	if(temp_bleed)
		bleed(temp_bleed)
		bleed_warn(temp_bleed)

/// Has each bodypart update its bleed/wound overlay icon states
/mob/living/carbon/proc/update_bodypart_bleed_overlays()
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		iter_part.update_part_wound_overlay()

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt, no_visual = FALSE)
	if((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	blood_volume = max(blood_volume - amt, 0)

	//Blood loss still happens in locker, floor stays clean
	if(!no_visual && isturf(loc) && prob(sqrt(amt) * 80))
		add_splatter_floor(loc, small_drip = (amt < 10))

/mob/living/carbon/human/bleed(amt, no_visual = FALSE)
	amt *= physiology.bleed_mod
	return ..()

/// A helper to see how much blood we're losing per tick
/mob/living/carbon/proc/get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return 0
	var/bleed_amt = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/iter_bodypart = X
		bleed_amt += iter_bodypart.get_modified_bleed_rate()
	return bleed_amt

/mob/living/carbon/human/get_bleed_rate()
	. = ..()
	. *= physiology.bleed_mod

/**
 * bleed_warn() is used to for carbons with an active client to occasionally receive messages warning them about their bleeding status (if applicable)
 *
 * Arguments:
 * * bleed_amt- When we run this from [/mob/living/carbon/human/proc/handle_blood] we already know how much blood we're losing this tick, so we can skip tallying it again with this
 * * forced-
 */
/mob/living/carbon/proc/bleed_warn(bleed_amt = 0, forced = FALSE)
	if(!client || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	if(!COOLDOWN_FINISHED(src, bleeding_message_cd) && !forced)
		return

	if(!bleed_amt) // if we weren't provided the amount of blood we lost this tick in the args
		bleed_amt = get_bleed_rate()

	var/bleeding_severity = ""
	var/next_cooldown = BLEEDING_MESSAGE_BASE_CD

	switch(bleed_amt)
		if(-INFINITY to 0)
			return
		if(0 to 1)
			bleeding_severity = "You feel light trickles of blood across your skin"
			next_cooldown *= 2.5
		if(1 to 3)
			bleeding_severity = "You feel a small stream of blood running across your body"
			next_cooldown *= 2
		if(3 to 5)
			bleeding_severity = "You skin feels clammy from the flow of blood leaving your body"
			next_cooldown *= 1.7
		if(5 to 7)
			bleeding_severity = "Your body grows more and more numb as blood streams out"
			next_cooldown *= 1.5
		if(7 to INFINITY)
			bleeding_severity = "Your heartbeat thrashes wildly trying to keep up with your bloodloss"

	var/rate_of_change = ", but it's getting better." // if there's no wounds actively getting bloodier or maintaining the same flow, we must be getting better!
	if(HAS_TRAIT(src, TRAIT_COAGULATING)) // if we have coagulant, we're getting better quick
		rate_of_change = ", but it's clotting up quickly!"
	else
		// flick through our wounds to see if there are any bleeding ones getting worse or holding flow (maybe move this to handle_blood and cache it so we don't need to cycle through the wounds so much)
		for(var/i in all_wounds)
			var/datum/wound/iter_wound = i
			if(!iter_wound.blood_flow)
				continue
			var/iter_wound_roc = iter_wound.get_bleed_rate_of_change()
			switch(iter_wound_roc)
				if(BLOOD_FLOW_INCREASING) // assume the worst, if one wound is getting bloodier, we focus on that
					rate_of_change = ", <b>and it's getting worse!</b>"
					break
				if(BLOOD_FLOW_STEADY) // our best case now is that our bleeding isn't getting worse
					rate_of_change = ", and it's holding steady."
				if(BLOOD_FLOW_DECREASING) // this only matters if none of the wounds fit the above two cases, included here for completeness
					continue

	to_chat(src, span_warning("[bleeding_severity][rate_of_change]"))
	COOLDOWN_START(src, bleeding_message_cd, next_cooldown)

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		BP.setBleedStacks(0)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	var/datum/blood_type/blood = get_blood_type()
	if(isnull(blood) || !AM.reagents)
		return FALSE
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	blood_volume -= amount

	AM.reagents.add_reagent(blood.reagent_type, amount, blood.get_blood_data(src), bodytemperature)
	return TRUE

/*
/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	var/blood_data = list()
	//set the blood data
	blood_data["viruses"] = list()

	for(var/thing in diseases)
		var/datum/disease/D = thing
		blood_data["viruses"] += D.Copy()

	if (immune_system)
		blood_data["immunity"] = immune_system.GetImmunity()

	blood_data["blood_DNA"] = dna.unique_enzymes
	if(LAZYLEN(disease_resistances))
		blood_data["resistances"] = disease_resistances.Copy()
	var/list/temp_chem = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		temp_chem[R.type] = R.volume
	blood_data["trace_chem"] = list2params(temp_chem)
	if(mind)
		blood_data["mind"] = mind
	else if(last_mind)
		blood_data["mind"] = last_mind
	if(ckey)
		blood_data["ckey"] = ckey
	else if(last_mind)
		blood_data["ckey"] = ckey(last_mind.key)

	if(!HAS_TRAIT_FROM(src, TRAIT_SUICIDED, REF(src)))
		blood_data["cloneable"] = 1
	blood_data["blood_type"] = dna.blood_type
	blood_data["gender"] = gender
	blood_data["real_name"] = real_name
	blood_data["features"] = dna.features
	blood_data["factions"] = faction
	blood_data["quirks"] = list()
	for(var/V in quirks)
		var/datum/quirk/T = V
		blood_data["quirks"] += T.type
	return blood_data
*/

/mob/living/proc/get_blood_type()
	RETURN_TYPE(/datum/blood_type)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	return GLOB.blood_types[/datum/blood_type/animal]

/mob/living/silicon/get_blood_type()
	return GLOB.blood_types[/datum/blood_type/oil]

/mob/living/simple_animal/bot/get_blood_type()
	return GLOB.blood_types[/datum/blood_type/oil]

/mob/living/basic/bot/get_blood_type()
	return GLOB.blood_types[/datum/blood_type/oil]

/mob/living/carbon/alien/get_blood_type()
	if(HAS_TRAIT(src, TRAIT_HUSK) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	return GLOB.blood_types[/datum/blood_type/xenomorph]

/mob/living/carbon/human/get_blood_type()
	if(HAS_TRAIT(src, TRAIT_HUSK) || isnull(dna) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	if(check_holidays(APRIL_FOOLS) && is_clown_job(mind?.assigned_role))
		return GLOB.blood_types[/datum/blood_type/clown]
	if(dna.species.exotic_bloodtype)
		return GLOB.blood_types[dna.species.exotic_bloodtype]
	return GLOB.blood_types[dna.human_blood_type]

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/blood_turf = get_turf(src), small_drip)
	// Create a bit of metallic pollution, as that's how blood smells
	blood_turf?.pollute_turf(/datum/pollutant/metallic_scent, 30) // TODO Move to blood_datum
	return get_blood_type()?.make_blood_splatter(src, blood_turf, small_drip)

/mob/living/proc/do_splatter_effect(splat_dir = pick(GLOB.cardinals))
	var/obj/effect/temp_visual/dir_setting/bloodsplatter/splatter = new(get_turf(src), splat_dir, get_blood_type()?.color)
	splatter.color = get_blood_type()?.color

/**
 * This proc is a helper for spraying blood for things like slashing/piercing wounds and dismemberment.
 *
 * The strength of the splatter in the second argument determines how much it can dirty and how far it can go
 *
 * Arguments:
 * * splatter_direction: Which direction the blood is flying
 * * splatter_strength: How many tiles it can go, and how many items it can pass over and dirty
 */
/mob/living/proc/spray_blood(splatter_direction, splatter_strength = 3)
	if(QDELETED(src) || !isturf(loc) || QDELING(loc) || !blood_volume || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	var/obj/effect/decal/cleanable/blood/hitsplatter/our_splatter = new(loc)
	if(QDELETED(our_splatter))
		return
	our_splatter.add_mob_blood(src)
	var/turf/targ = get_ranged_target_turf(src, splatter_direction, splatter_strength)
	our_splatter.fly_towards(targ, splatter_strength)

/**
 * Helper proc for throwing blood particles around, similar to the spray_blood proc.
 */
/mob/living/proc/blood_particles(amount = rand(1, 3), angle = rand(0,360), min_deviation = -30, max_deviation = 30, min_pixel_z = 0, max_pixel_z = 6)
	if(QDELETED(src) || !isturf(loc) || QDELING(loc) || !blood_volume || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	for(var/i in 1 to amount)
		var/obj/effect/decal/cleanable/blood/particle/droplet = new(loc)
		if(QDELETED(droplet)) // if they're deleting upon init, let's not waste any more time, any others will prolly just do the same thing
			return
		droplet.color = get_blood_type()?.color
		droplet.add_mob_blood(src)
		droplet.pixel_z = rand(min_pixel_z, max_pixel_z)
		droplet.start_movement(angle + rand(min_deviation, max_deviation))

#undef BLOOD_DRIP_RATE_MOD
