/datum/species/teratoma
	name = "Teratoma"
	id = SPECIES_TERATOMA
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	mutantbrain = /obj/item/organ/internal/brain/primate

	inherent_traits = list(
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_BADDNA,
		TRAIT_CAN_STRIP,
		TRAIT_EASILY_WOUNDED,
		TRAIT_GENELESS,
		TRAIT_ILLITERATE,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_JUMPSUIT,
		TRAIT_NO_ZOMBIFY,
		TRAIT_PRIMITIVE,
		TRAIT_UNCONVERTABLE, // DEAR GOD NO
		TRAIT_WEAK_SOUL,
	)

	bodypart_overrides = list(
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/teratoma,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/teratoma,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/teratoma,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/teratoma,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/teratoma,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/teratoma,
	)
	mutanttongue = /obj/item/organ/internal/tongue/teratoma

	maxhealthmod = 0.75
	stunmod = 1.4

	no_equip_flags = ITEM_SLOT_ICLOTHING | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	fire_overlay = "monkey"
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	var/datum/component/omen/teratoma/misfortune

/datum/species/teratoma/on_species_gain(mob/living/carbon/human/idiot, datum/species/old_species, pref_load)
	. = ..()
	idiot.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)
	misfortune = idiot.AddComponent(/datum/component/omen/teratoma)
	RegisterSignal(idiot, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(prevent_banned_reagent_exposure))

/datum/species/teratoma/on_species_loss(mob/living/carbon/human/idiot, datum/species/new_species, pref_load)
	. = ..()
	QDEL_NULL(misfortune)
	UnregisterSignal(idiot, COMSIG_ATOM_EXPOSE_REAGENTS)

/datum/species/teratoma/random_name(gender, unique, lastname)
	return "teratoma ([rand(1, 999)])"

// removes banned reagents from the list of reagents that'll be exposed
/datum/species/teratoma/proc/prevent_banned_reagent_exposure(datum/source, list/reagents, datum/reagents/holder, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	for(var/datum/reagent/reagent as anything in reagents)
		if(is_banned_chem(reagent))
			reagents -= reagent

/datum/species/teratoma/proc/is_banned_chem(reagent)
	var/static/list/disallowed_chems_typecache
	if(!disallowed_chems_typecache)
		disallowed_chems_typecache = typecacheof(list(
			/datum/reagent/aslimetoxin,
			/datum/reagent/cyborg_mutation_nanomachines,
			/datum/reagent/gluttonytoxin,
			/datum/reagent/magillitis,
			/datum/reagent/mulligan,
			/datum/reagent/mutationtoxin,
			/datum/reagent/xenomicrobes,
		))
	return is_type_in_typecache(reagent, disallowed_chems_typecache)

/datum/component/omen/teratoma
	incidents_left = INFINITY
	luck_mod = 0.75
	damage_mod = 0.2

/mob/living/carbon/human/species/teratoma
	race = /datum/species/teratoma

/obj/item/organ/internal/tongue/teratoma
	liked_foodtypes = MEAT | BUGS | GORE | GROSS | RAW
	disliked_foodtypes = CLOTH

/obj/item/organ/internal/tongue/teratoma/get_scream_sound()
	return pick(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)

/obj/item/organ/internal/tongue/teratoma/get_laugh_sound()
	return 'monkestation/sound/voice/laugh/simian/monkey_laugh_1.ogg'
