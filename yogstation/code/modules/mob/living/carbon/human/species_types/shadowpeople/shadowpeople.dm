///cooldown between charges of the projectile absorb 
#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Basic shadow person species---------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	plural_form = "???"
	id = SPECIES_SHADOW
	possible_genders = list(PLURAL)
	bubble_icon = BUBBLE_DARKSPAWN
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBLOOD,NOEYESPRITES, NOFLASH)
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH,TRAIT_GENELESS,TRAIT_NOHUNGER,TRAIT_NODISMEMBER)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutanteyes = /obj/item/organ/eyes/shadow
	species_language_holder = /datum/language_holder/darkspawn
	///If the darkness healing heals all damage types, not just brute and burn
	var/powerful_heal = FALSE
	///How much damage is healed each life tick
	var/dark_healing = 1
	///How much burn damage is taken each life tick, reduced to 20% for dim light
	var/light_burning = 1
	///How many charges their projectile protection has
	var/shadow_charges = 0

/datum/species/shadow/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT && shadow_charges > 0)
			H.visible_message(span_danger("The shadows around [H] ripple as they absorb \the [P]!"))
			playsound(H, "bullet_miss", 75, 1)
			shadow_charges = min(shadow_charges - 1, 0)
			addtimer(CALLBACK(src, PROC_REF(regen_shadow)), DARKSPAWN_REFLECT_COOLDOWN)//so they regen on different timers
			return BULLET_ACT_BLOCK
	return ..()

/datum/species/shadow/proc/regen_shadow()
	shadow_charges = min(shadow_charges++, initial(shadow_charges))

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		switch(light_amount)
			if(0 to SHADOW_SPECIES_DIM_LIGHT)
				var/list/healing_types = list(CLONE, BURN, BRUTE)
				if(powerful_heal)
					healing_types |= list(STAMINA, TOX, OXY, BRAIN) //heal additional damage types
					H.AdjustAllImmobility(-dark_healing * 40)
					H.SetSleeping(0)
				H.heal_ordered_damage(dark_healing, healing_types, BODYPART_ANY)
			if(SHADOW_SPECIES_DIM_LIGHT to SHADOW_SPECIES_BRIGHT_LIGHT) //not bright, but still dim
				var/datum/antagonist/darkspawn/dude = isdarkspawn(H)
				if(dude)
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_LIGHTRES))
						return
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_CREEP))
						return
				to_chat(H, span_userdanger("The light singes you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 40 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning * 0.2)
			if(SHADOW_SPECIES_BRIGHT_LIGHT to INFINITY) //but quick death in the light
				var/datum/antagonist/darkspawn/dude = isdarkspawn(H)
				if(dude)
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_CREEP))
						return
				to_chat(H, span_userdanger("The light burns you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Their flesh is a sickly seethrough filament,\
		their tangled insides in clear view. Their form is a mockery of life, \
		leaving them mostly unable to work with others under normal circumstances."

/datum/species/shadow/get_species_lore()
	return list(
		"WIP.",
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

////////////////////////////////////////////////////////////////////////////////////
//------------------------Midround antag exclusive species------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow/nightmare
	id = SPECIES_NIGHTMARE
	limbs_id = SPECIES_SHADOW
	burnmod = 1.5
	no_equip = list(
		ITEM_SLOT_MASK, 
		ITEM_SLOT_OCLOTHING, 
		ITEM_SLOT_ICLOTHING, 
		ITEM_SLOT_GLOVES, 
		ITEM_SLOT_FEET, 
		ITEM_SLOT_SUITSTORE
		)

	species_traits = list(
		NOBLOOD,
		NO_UNDERWEAR,
		NO_DNA_COPY,
		NOTRANSSTING,
		NOEYESPRITES,
		NOFLASH
		)

	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOGUNS,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER
		)
		
	mutanteyes = /obj/item/organ/eyes/shadow
	mutantheart = /obj/item/organ/heart/nightmare
	mutantbrain = /obj/item/organ/brain/nightmare
	shadow_charges = 1

	species_abilities = list(
		/datum/action/cooldown/spell/toggle/light_eater
		)

	var/info_text = "You are a <span class='danger'>Nightmare</span>. The ability <span class='warning'>shadow walk</span> allows unlimited, unrestricted movement in the dark while activated. \
					Your <span class='warning'>light eater</span> will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile. If killed, you will eventually revive if left in darkness."

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")

	C.fully_replace_character_name("[C.real_name]", nightmare_name())

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

////////////////////////////////////////////////////////////////////////////////////
//----------------------Roundstart antag exclusive species------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow/darkspawn
	id = SPECIES_DARKSPAWN
	limbs_id = SPECIES_DARKSPAWN
	possible_genders = list(PLURAL)
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN //never put this in the pride pool because they look super valid and can never be changed off of
	siemens_coeff = 0
	armor = 10
	burnmod = 1.2
	heatmod = 1.5
	no_equip = list(
		ITEM_SLOT_MASK,
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_FEET,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_EYES
		)
	species_traits = list(
		NOBLOOD,
		NO_UNDERWEAR,
		NO_DNA_COPY,
		NOTRANSSTING,
		NOEYESPRITES,
		NOHUSK
		)
	inherent_traits = list(
		TRAIT_NOGUNS, 
		TRAIT_RESISTCOLD, 
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE, 
		TRAIT_NOBREATH, 
		TRAIT_RADIMMUNE, 
		TRAIT_VIRUSIMMUNE, 
		TRAIT_PIERCEIMMUNE, 
		TRAIT_NODISMEMBER, 
		TRAIT_NOHUNGER, 
		TRAIT_NOSLIPICE, 
		TRAIT_GENELESS, 
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOGUNS,
		TRAIT_SPECIESLOCK //never let them swap off darkspawn, it can cause issues
		)
	mutanteyes = /obj/item/organ/eyes/darkspawn
	mutantears = /obj/item/organ/ears/darkspawn

	powerful_heal = TRUE
	shadow_charges = 3

/datum/species/shadow/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.fully_replace_character_name("[C.real_name]", darkspawn_name())

/datum/species/shadow/darkspawn/spec_updatehealth(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/antag = isdarkspawn(H)
	if(antag)
		dark_healing = antag.dark_healing
		light_burning = antag.light_burning
		if(H.physiology)
			H.physiology.brute_mod = antag.brute_mod
			H.physiology.burn_mod = antag.burn_mod
			H.physiology.stamina_mod = antag.stam_mod

/datum/species/shadow/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/shadow/darkspawn/check_roundstart_eligible()
	return FALSE

#undef DARKSPAWN_REFLECT_COOLDOWN
