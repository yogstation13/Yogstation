/datum/species/teratoma
	name = "Teratoma"
	id = SPECIES_TERATOMA
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_CUSTOM

	inherent_traits = list(
		TRAIT_BADDNA,
		TRAIT_EASILY_WOUNDED,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_JUMPSUIT,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_ZOMBIFY,
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
	mutantbrain = /obj/item/organ/internal/brain/teratoma
	mutanttongue = /obj/item/organ/internal/tongue/teratoma
	mutantliver = /obj/item/organ/internal/liver/teratoma
	mutantlungs = null
	mutantappendix = null

	maxhealthmod = 0.75
	stunmod = 1.4

	no_equip_flags = ITEM_SLOT_ICLOTHING | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	fire_overlay = "monkey"
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

/datum/species/teratoma/random_name(gender, unique, lastname)
	return "teratoma ([rand(1, 999)])"

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

/obj/item/organ/internal/brain/teratoma
	name = "vaguely brain-shaped mass"
	desc = "How the hell can this thing even think?!"
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_ILLITERATE)
	var/datum/component/omen/teratoma/misfortune

/obj/item/organ/internal/brain/teratoma/Initialize(mapload)
	. = ..()
	gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/item/organ/internal/brain/teratoma/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	misfortune = organ_owner.AddComponent(/datum/component/omen/teratoma)

/obj/item/organ/internal/brain/teratoma/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	QDEL_NULL(misfortune)

/obj/item/organ/internal/liver/teratoma
	name = "horribly malformed liver"
	desc = "It seems to pulse as if existed out of spite of nature itself."
	var/datum/component/regenerator/oh_god_why

/obj/item/organ/internal/liver/teratoma/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	oh_god_why = organ_owner.AddComponent(\
		/datum/component/regenerator,\
		brute_per_second = 2,\
		burn_per_second = 2,\
		tox_per_second = 1,\
		heals_wounds = TRUE,\
		ignore_damage_types = list(OXY, STAMINA),\
		outline_colour = COLOR_RED_LIGHT\
	) // ignore oxy damage so they can regen while in crit if you just leave them there
	RegisterSignal(organ_owner, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(prevent_banned_reagent_exposure))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		human_owner.physiology?.tox_mod *= 0.25

/obj/item/organ/internal/liver/teratoma/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	QDEL_NULL(oh_god_why)
	UnregisterSignal(organ_owner, COMSIG_ATOM_EXPOSE_REAGENTS)
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		human_owner.physiology?.tox_mod /= 0.25

/obj/item/organ/internal/liver/teratoma/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	if(is_banned_chem(chem))
		chem.holder?.remove_reagent(chem.type, chem.volume)
		return COMSIG_MOB_STOP_REAGENT_CHECK

/obj/item/organ/internal/liver/teratoma/proc/is_banned_chem(reagent)
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

// removes banned reagents from the list of reagents that'll be exposed
/obj/item/organ/internal/liver/teratoma/proc/prevent_banned_reagent_exposure(datum/source, list/reagents, datum/reagents/holder, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	for(var/datum/reagent/reagent as anything in reagents)
		if(is_banned_chem(reagent))
			reagents -= reagent

/datum/component/omen/teratoma
	incidents_left = INFINITY
	luck_mod = 0.75
	damage_mod = 0.2
