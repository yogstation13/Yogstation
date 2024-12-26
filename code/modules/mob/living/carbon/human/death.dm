GLOBAL_LIST_EMPTY(dead_players_during_shift)
/mob/living/carbon/human/gib_animation()
	switch(dna.species.species_gibs)
		if(GIB_TYPE_HUMAN)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		if(GIB_TYPE_ROBOTIC)
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/carbon/human/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, dna.species.dust_anim)

/mob/living/carbon/human/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/human(drop_location(), src, get_static_viruses())
	else
		new /obj/effect/gibspawner/human/bodypartless(drop_location(), src, get_static_viruses())

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed, cause_of_death = get_cause_of_death())
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/internal/heart/H = get_organ_slot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	. = ..()

	if(client && !HAS_TRAIT(src, TRAIT_SUICIDED) && !(client in GLOB.dead_players_during_shift))
		GLOB.dead_players_during_shift += client

	if(!QDELETED(dna)) //The gibbed param is bit redundant here since dna won't exist at this point if they got deleted.
		dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_message("has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()])", LOG_ATTACK)
		if(key) // Prevents log spamming of keyless mob deaths (like xenobio monkeys)
			investigate_log("has died at [loc_name(src)].<br>\
				BRUTE: [src.getBruteLoss()] BURN: [src.getFireLoss()] TOX: [src.getToxLoss()] OXY: [src.getOxyLoss()] CLONE: [src.getCloneLoss()] STAM: [src.stamina.loss]<br>\
				<b>Brain damage</b>: [src.get_organ_loss(ORGAN_SLOT_BRAIN) || "0"]<br>\
				<b>Blood volume</b>: [src.blood_volume]cl ([round((src.blood_volume / BLOOD_VOLUME_NORMAL) * 100, 0.1)]%)<br>\
				<b>Reagents</b>:<br>[reagents_readout()]", INVESTIGATE_DEATHS)
	to_chat(src, span_warning("You have died. Barring complete bodyloss, you can in most cases be revived by other players. If you do not wish to be brought back, use the \"Do Not Resuscitate\" verb in the ghost tab."))
	to_chat(src, span_greentext("You can no longer recall who was responsible for your death.")) // MONKESTATION EDIT: making an explicit request that someone review DA RULEZ.

	var/death_block = ""
	death_block += span_danger("<center><span style='font-size: 32px'>You have succumbed to [cause_of_death].</font></center>")
	death_block += "<hr>"
	death_block += span_danger("Barring complete bodyloss, you can (in most cases) be revived by other players. \
		If you do not wish to be brought back, use the \"Do Not Resuscitate\" verb in the ghost tab.")
	to_chat(src, boxed_message(death_block))

/mob/living/carbon/human/proc/get_cause_of_death(probable_cause)
	switch(probable_cause)
		// This should all be refactored later it's a bit of a mess ngl
		if(null, "revival_sickess", "anesthetics")
			return "unknown causes"

		if(OXY_DAMAGE)
			var/obj/item/organ/internal/lungs/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
			if(isnull(lungs) || (lungs.organ_flags & ORGAN_FAILING))
				return "lung failure"

			if(!HAS_TRAIT(src, TRAIT_NOBLOOD) && blood_volume < BLOOD_VOLUME_BAD)
				return BLOOD_LOSS

		if(TOX_DAMAGE)
			var/obj/item/organ/internal/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
			if(isnull(liver) || (liver.organ_flags & ORGAN_FAILING))
				return "liver failure"

			var/datum/reagent/toxin/most_toxic
			for(var/datum/reagent/toxin/poison in reagents?.reagent_list)
				if(!most_toxic || most_toxic.toxpwr < poison.toxpwr)
					most_toxic = poison

			if(most_toxic)
				return "[lowertext(most_toxic.name)] poisoning"

		if("heart_attack")
			return "cardiac arrest"

		if("drunk")
			var/datum/reagent/consumable/ethanol/most_alcohol
			for(var/datum/reagent/consumable/ethanol/alcohol in reagents?.reagent_list)
				if(!most_alcohol || most_alcohol.boozepwr < alcohol.boozepwr)
					most_alcohol = alcohol

			if(most_alcohol)
				return "alcohol poisoning ([lowertext(most_alcohol.name)])"

			return "alcohol poisoning"

		if("thermia")
			if(bodytemperature < standard_body_temperature)
				return "hypothermia"
			return "hyperthermia"

		else
			if(findtext(probable_cause, "disease"))
				return "disease"
			if(findtext(probable_cause, "addiction"))
				return "addiction"

	return probable_cause

/mob/living/carbon/human/proc/reagents_readout()
	var/readout = "Blood:"
	for(var/datum/reagent/reagent in reagents?.reagent_list)
		readout += "<br>[round(reagent.volume, 0.001)] units of [reagent.name]"

	readout += "<br>Stomach:"
	var/obj/item/organ/internal/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	for(var/datum/reagent/bile in belly?.reagents?.reagent_list)
		if(!belly.food_reagents[bile.type])
			readout += "<br>[round(bile.volume, 0.001)] units of [bile.name]"

	return readout

/mob/living/carbon/human/proc/makeSkeleton()
	ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)
	set_species(/datum/species/skeleton)
	return TRUE

/mob/living/carbon/proc/Drain()
	become_husk(CHANGELING_DRAIN)
	ADD_TRAIT(src, TRAIT_BADDNA, CHANGELING_DRAIN)
	blood_volume = 0
	return TRUE

/mob/living/carbon/proc/makeUncloneable()
	ADD_TRAIT(src, TRAIT_BADDNA, UNCLONEABLE_TRAIT)
	blood_volume = 0
	return TRUE
