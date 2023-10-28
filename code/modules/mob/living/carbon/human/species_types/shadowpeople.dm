#define HEART_RESPAWN_THRESHHOLD 40
#define HEART_SPECIAL_SHADOWIFY 2
#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	plural_form = "???"
	id = "shadow"
	sexes = FALSE
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBLOOD,NOEYESPRITES,NOFLASH, AGENDER)
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH,TRAIT_GENELESS,TRAIT_NOHUNGER)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutanteyes = /obj/item/organ/eyes/night_vision
	species_language_holder = /datum/language_holder/darkspawn
	var/powerful_heal = FALSE
	var/dark_healing = 1
	var/light_burning = 1

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	H.bubble_icon = "darkspawn"
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		switch(light_amount)
			if(0 to SHADOW_SPECIES_DIM_LIGHT) //rapid healing and stun reduction in the darkness
				H.adjustBruteLoss(-dark_healing)
				H.adjustFireLoss(-dark_healing)
				H.adjustCloneLoss(-dark_healing)
				if(powerful_heal) //only darkspawn gets this
					H.adjustToxLoss(-dark_healing)
					H.adjustStaminaLoss(-dark_healing * 20)
					H.AdjustAllImmobility(-dark_healing * 40)
					H.SetSleeping(0)
					H.setOrganLoss(ORGAN_SLOT_BRAIN,0)
			if(SHADOW_SPECIES_DIM_LIGHT to SHADOW_SPECIES_BRIGHT_LIGHT) //not bright, but still dim
				if(HAS_TRAIT(H, TRAIT_DARKSPAWN_SPACEWALK) && isspaceturf(T))
					return
				if(HAS_TRAIT(H, TRAIT_DARKSPAWN_LIGHTRES))
					return
				if(H.has_status_effect(STATUS_EFFECT_CREEP))
					return
				to_chat(H, span_userdanger("The light singes you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 40 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning * 0.2)
			if(SHADOW_SPECIES_BRIGHT_LIGHT to INFINITY) //but quick death in the light
				if(HAS_TRAIT(H, TRAIT_DARKSPAWN_SPACEWALK) && isspaceturf(T))
					return
				if(H.has_status_effect(STATUS_EFFECT_CREEP))
					return
				to_chat(H, span_userdanger("The light burns you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		seethrough filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/get_species_lore()
	return list(
		"Long ago, the Spinward Sector used to be inhabited by terrifying aliens aptly named \"Shadowlings\" \
		after their control over darkness, and tendancy to kidnap victims into the dark maintenance shafts. \
		Around 2558, the long campaign Nanotrasen waged against the space terrors ended with the full extinction of the Shadowlings.",

		"Victims of their kidnappings would become brainless thralls, and via surgery they could be freed from the Shadowling's control. \
		Those more unlucky would have their entire body transformed by the Shadowlings to better serve in kidnappings. \
		Unlike the brain tumors of lesser control, these greater thralls could not be reverted.",

		"With Shadowlings long gone, their will is their own again. But their bodies have not reverted, burning in exposure to light. \
		Nanotrasen has assured the victims that they are searching for a cure. No further information has been given, even years later. \
		Most shadowpeople now assume Nanotrasen has long since shelfed the project.",
	)

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add

//////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow/nightmare
	name = "Nightmare"
	plural_form = null
	id = "nightmare"
	limbs_id = "shadow"
	burnmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOHUNGER)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare
	mutant_organs = list(/obj/item/organ/heart/nightmare)
	mutantbrain = /obj/item/organ/brain/nightmare
	
	var/info_text = "You are a <span class='danger'>Nightmare</span>. The ability <span class='warning'>shadow walk</span> allows unlimited, unrestricted movement in the dark while activated. \
					Your <span class='warning'>light eater</span> will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile. If killed, you will eventually revive if left in darkness."

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
			playsound(T, "bullet_miss", 75, 1)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")

	C.fully_replace_character_name("[C.real_name]","[pick(GLOB.nightmare_names)]") // Yogs -- fixes nightmares not having special spooky names. this proc takes the old name first, and *THEN* the new name!

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

///////////////////////////ANTAG////////////////////////////////////////
/datum/species/shadow/darkspawn
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

	var/shadow_charges = 3
	powerful_heal = TRUE
	shadow_charges = 3
	dark_healing = 5
	light_burning = 7

/datum/species/shadow/darkspawn/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(prob(50) && shadow_charges > 0)
		H.visible_message(span_danger("The shadows around [H] ripple as they absorb \the [P]!"))
		playsound(H, "bullet_miss", 75, 1)
		shadow_charges = min(shadow_charges - 1, 0)
		addtimer(CALLBACK(src, PROC_REF(regen_shadow)), DARKSPAWN_REFLECT_COOLDOWN)//so they regen on different timers
		return BULLET_ACT_BLOCK
	return 0

/datum/species/shadow/darkspawn/proc/regen_shadow()
	shadow_charges = min(shadow_charges++, initial(shadow_charges))

/datum/species/shadow/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "[pick(GLOB.nightmare_names)]"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name

/datum/species/shadow/darkspawn/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.bubble_icon = initial(C.bubble_icon)

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	H.bubble_icon = "darkspawn"
	. = ..()

/datum/species/shadow/darkspawn/spec_updatehealth(mob/living/carbon/human/H)
	if(H.mind?.has_antag_datum(ROLE_DARKSPAWN))
		var/datum/antagonist/darkspawn/antag = H.mind.has_antag_datum(ROLE_DARKSPAWN)
		dark_healing = antag.dark_healing
		light_burning = antag.light_burning

/datum/species/shadow/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/shadow/darkspawn/check_roundstart_eligible()
	return FALSE
/////////////////////////////Organs/////////////////////////////////////
/obj/item/organ/brain/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon_state = "brain-x-d"
	var/datum/action/cooldown/spell/jaunt/shadow_walk/our_jaunt

/obj/item/organ/brain/nightmare/Insert(mob/living/carbon/host, special = FALSE)
	..()
	if(host.dna.species.id != "nightmare")
		host.set_species(/datum/species/shadow/nightmare)
		visible_message(span_warning("[host] thrashes as [src] takes root in [host.p_their()] body!"))
	
	our_jaunt = new(host)
	our_jaunt.Grant(host)

/obj/item/organ/brain/nightmare/Remove(mob/living/carbon/host, special = FALSE)
	QDEL_NULL(our_jaunt)
	return ..()

/obj/item/organ/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	visual = TRUE
	color = "#1C1C1C"
	var/respawn_progress = 0
	var/obj/item/light_eater/blade
	decay_factor = 0

/obj/item/organ/heart/nightmare/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/organ/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"), \
						 span_danger("[src] feels unnaturally cold in your hands. You raise [src] your mouth and devour it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)


	user.visible_message(span_warning("Blood erupts from [user]'s arm as it reforms into a weapon!"), \
						 span_userdanger("Icy blood pumps through your veins as your arm reforms itself!"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/nightmare/Insert(mob/living/carbon/M, special = 0)
	..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater
		blade.force = 25
		blade.armour_penetration = 35
		M.put_in_hands(blade)
	START_PROCESSING(SSobj, src)

/obj/item/organ/heart/nightmare/Remove(mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		M.visible_message(span_warning("\The [blade] disintegrates!"))
		QDEL_NULL(blade)
	..()

/obj/item/organ/heart/nightmare/Stop()
	return 0

/obj/item/organ/heart/nightmare/process()
	if(QDELETED(owner) || owner.stat != DEAD || !owner)
		respawn_progress = 0
		return
	var/turf/T = get_turf(owner)

	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			respawn_progress++
			playsound(owner,'sound/effects/singlebeat.ogg',40,1)
	if(respawn_progress >= HEART_RESPAWN_THRESHHOLD)
		owner.revive(full_heal = TRUE)
		if(!(owner.dna.species.id == "shadow" || owner.dna.species.id == "nightmare"))
			var/mob/living/carbon/old_owner = owner
			Remove(owner, HEART_SPECIAL_SHADOWIFY)
			old_owner.set_species(/datum/species/shadow)
			Insert(old_owner, HEART_SPECIAL_SHADOWIFY)
			to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping into the center of your chest! You're alive!"))
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
		owner.visible_message(span_warning("[owner] staggers to [owner.p_their()] feet!"))
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, 1)
		respawn_progress = 0

//Weapon
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 15
	armour_penetration = 20
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	tool_behaviour = TOOL_MINING
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 20
	resistance_flags = ACID_PROOF

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)

#undef DARKSPAWN_REFLECT_COOLDOWN
#undef HEART_SPECIAL_SHADOWIFY
#undef HEART_RESPAWN_THRESHHOLD
