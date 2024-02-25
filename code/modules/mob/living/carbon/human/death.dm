/mob/living/carbon/human/gib_animation()
	switch(dna.species.species_gibs)
		if("human")
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h")
		if("robotic")
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")
		if("plasma")
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-h") //This will have more use in the near future
		if("polysmorph")
			new /obj/effect/temp_visual/gib_animation(loc, "gibbed-a")

/mob/living/carbon/human/dust(just_ash, drop_items, force)
	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	Stun(100, TRUE, TRUE)//hold them still as they get deleted so they don't fuck up the animation
	notransform = TRUE
	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src, 20) // since this is sometimes called in

/mob/living/carbon/human/dust_animation()
	var/obj/effect/dusting_anim/dust_effect = new(loc, ref(src))
	filters += filter(type = "displace", size = 256, render_source = "*snap[ref(src)]")
	animate(src, alpha = 0, time = 20, easing = (EASE_IN | SINE_EASING))

	QDEL_IN(dust_effect, 20)

/mob/living/carbon/human/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		switch(dna.species.species_gibs)
			if("human")
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if("robotic")
				new /obj/effect/gibspawner/robot(get_turf(src))
			if("plasma")
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if("polysmorph")
				new /obj/effect/gibspawner/xeno(get_turf(src), src, get_static_viruses())
	else
		switch(dna.species.species_gibs)
			if("human")
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if("robotic")
				new /obj/effect/gibspawner/robot(get_turf(src))
			if("plasma")
				new /obj/effect/gibspawner/human(get_turf(src), src, get_static_viruses())
			if("polysmorph")
				new /obj/effect/gibspawner/xeno(get_turf(src), src, get_static_viruses())

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		switch(dna.species.species_gibs)
			if("human")
				new /obj/effect/decal/remains/human(loc)
			if("robotic")
				new /obj/effect/decal/remains/robot(loc)
			if("plasma")
				new /obj/effect/decal/remains/plasma(loc)
			if("polysmorph")
				new /obj/effect/decal/remains/xeno(loc)
				

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	. = ..()

	if(ismecha(loc))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_game("[key_name(src)] has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()]) ([AREACOORD(src)])")
	if(is_devil(src))
		INVOKE_ASYNC(is_devil(src), TYPE_PROC_REF(/datum/antagonist/devil, beginResurrectionCheck), src)
	if(is_hivemember(src))
		remove_hivemember(src)
	if(is_hivehost(src))
		var/datum/antagonist/hivemind/hive = mind.has_antag_datum(/datum/antagonist/hivemind)
		hive.destroy_hive()

	if(client)
		SSachievements.unlock_achievement(/datum/achievement/death, client)

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
	ADD_TRAIT(src, TRAIT_BADDNA, MADE_UNCLONEABLE)
	blood_volume = 0
	return TRUE
