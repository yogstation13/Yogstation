#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

/datum/species/darkspawn
	name = "Darkspawn"
	id = "darkspawn"
	limbs_id = "darkspawn"
	sexes = FALSE
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | WABBAJACK | ERT_SPAWN //never put this in the pride pool because they look super valid
	siemens_coeff = 0
	brutemod = 0.9
	heatmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_HEAD)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_NOHUNGER)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	COOLDOWN_DECLARE(reflect_cd_1)
	COOLDOWN_DECLARE(reflect_cd_2)
	COOLDOWN_DECLARE(reflect_cd_3)
	var/dark_healing = 5
	var/light_burning = 7

/datum/species/darkspawn/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(prob(50) && (COOLDOWN_FINISHED(src, reflect_cd_1) || COOLDOWN_FINISHED(src, reflect_cd_2) || COOLDOWN_FINISHED(src, reflect_cd_3)))
		if(COOLDOWN_FINISHED(src, reflect_cd_1))
			COOLDOWN_START(src, reflect_cd_1, DARKSPAWN_REFLECT_COOLDOWN)
		else if(COOLDOWN_FINISHED(src, reflect_cd_2))
			COOLDOWN_START(src, reflect_cd_2, DARKSPAWN_REFLECT_COOLDOWN)
		else if(COOLDOWN_FINISHED(src, reflect_cd_3))
			COOLDOWN_START(src, reflect_cd_3, DARKSPAWN_REFLECT_COOLDOWN)
		H.visible_message(span_danger("The shadows around [H] ripple as they absorb \the [P]!"))
		playsound(H, "bullet_miss", 75, 1)
		return -1
	return 0

/datum/species/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "[pick(GLOB.nightmare_names)]"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name

/datum/species/darkspawn/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.bubble_icon = initial(C.bubble_icon)

/datum/species/darkspawn/spec_life(mob/living/carbon/human/H)
	H.bubble_icon = "darkspawn"
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		switch(light_amount)
			if(0 to DARKSPAWN_DIM_LIGHT) //rapid healing and stun reduction in the darkness
				H.adjustBruteLoss(-dark_healing)
				H.adjustFireLoss(-dark_healing)
				H.adjustToxLoss(-dark_healing)
				H.adjustStaminaLoss(-dark_healing * 20)
				H.AdjustStun(-dark_healing * 40)
				H.AdjustKnockdown(-dark_healing * 40)
				H.AdjustUnconscious(-dark_healing * 40)
				H.adjustCloneLoss(-dark_healing)
				H.SetSleeping(0)
				H.setOrganLoss(ORGAN_SLOT_BRAIN,0)
			if(DARKSPAWN_DIM_LIGHT to DARKSPAWN_BRIGHT_LIGHT) //not bright, but still dim
				if(!H.has_status_effect(STATUS_EFFECT_CREEP))
					to_chat(H, span_userdanger("The light singes you!"))
					H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 40 * light_amount), TRUE)
					H.adjustCloneLoss(light_burning * 0.2)
			if(DARKSPAWN_BRIGHT_LIGHT to INFINITY) //but quick death in the light
				if(!H.has_status_effect(STATUS_EFFECT_CREEP))
					to_chat(H, span_userdanger("The light burns you!"))
					H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
					H.adjustCloneLoss(light_burning)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)
