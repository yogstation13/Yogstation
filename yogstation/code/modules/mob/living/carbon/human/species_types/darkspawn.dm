#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

/datum/species/darkspawn
	name = "Darkspawn"
	id = "darkspawn"
	limbs_id = "darkspawn"
	sexes = FALSE
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	siemens_coeff = 0
	brutemod = 0.9
	heatmod = 1.5
	no_equip = list(SLOT_WEAR_MASK, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE, SLOT_HEAD)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	var/list/upgrades = list()
	COOLDOWN_DECLARE(reflect_cd_1)
	COOLDOWN_DECLARE(reflect_cd_2)
	COOLDOWN_DECLARE(reflect_cd_3)

/datum/species/darkspawn/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(prob(50) && (COOLDOWN_FINISHED(reflect_cd_1) || COOLDOWN_FINISHED(reflect_cd_2) || COOLDOWN_FINISHED(reflect_cd_3)))
		if(COOLDOWN_FINISHED(reflect_cd_1))
			COOLDOWN_START(src, reflect_cd_1, DARKSPAWN_REFLECT_COOLDOWN)
		else if(COOLDOWN_FINISHED(reflect_cd_2))
			COOLDOWN_START(src, reflect_cd_2, DARKSPAWN_REFLECT_COOLDOWN)
		else if(COOLDOWN_FINISHED(reflect_cd_3))
			COOLDOWN_START(src, reflect_cd_3, DARKSPAWN_REFLECT_COOLDOWN)
		H.visible_message(span_danger("The shadows around [H] ripple as they absorb \the [P]!"))
		playsound(T, "bullet_miss", 75, 1)
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
	handle_upgrades(H)
	H.bubble_icon = "darkspawn"
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < DARKSPAWN_DIM_LIGHT) //rapid healing and stun reduction in the darkness
			var/healing_amount = DARKSPAWN_DARK_HEAL
			if(upgrades["dark_healing"])
				healing_amount *= 1.25
			H.adjustBruteLoss(-healing_amount)
			H.adjustFireLoss(-healing_amount)
			H.adjustToxLoss(-healing_amount)
			H.adjustStaminaLoss(-healing_amount * 20)
			H.AdjustStun(-healing_amount * 40)
			H.AdjustKnockdown(-healing_amount * 40)
			H.AdjustUnconscious(-healing_amount * 40)
			H.SetSleeping(0)
			H.setOrganLoss(ORGAN_SLOT_BRAIN,0)
			H.setCloneLoss(0)
		else if(light_amount < DARKSPAWN_BRIGHT_LIGHT && !upgrades["light_resistance"]) //not bright, but still dim
			H.adjustFireLoss(1)
		else if(light_amount > DARKSPAWN_BRIGHT_LIGHT && !H.has_status_effect(STATUS_EFFECT_CREEP)) //but quick death in the light
			if(upgrades["spacewalking"] && isspaceturf(T))
				return
			else if(!upgrades["light_resistance"])
				to_chat(H, span_userdanger("The light burns you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				H.adjustFireLoss(DARKSPAWN_LIGHT_BURN)
			else
				to_chat(H, span_userdanger("The light singes you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 50 * light_amount), TRUE)
				H.adjustFireLoss(DARKSPAWN_LIGHT_BURN * 0.5)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/darkspawn/proc/handle_upgrades(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/darkspawn
	if(H.mind)
		darkspawn = H.mind.has_antag_datum(/datum/antagonist/darkspawn)
		if(darkspawn)
			upgrades = darkspawn.upgrades
