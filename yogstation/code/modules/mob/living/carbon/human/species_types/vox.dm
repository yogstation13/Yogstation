/datum/species/vox
	name = "Vox"
	plural_form = "Vox"
	id = SPECIES_VOX
	monitor_icon = "crow"
	monitor_color = "#13c230"
	is_dimorphic = FALSE
	generate_husk_icon = TRUE
	species_traits = list(EYECOLOR, HAS_TAIL, HAS_FLESH, HAS_BONE, HAIRCOLOR, FACEHAIRCOLOR, MUTCOLORS, MUTCOLORS_SECONDARY) // Robust, but cannot be cloned easily.
	inherent_traits = list(TRAIT_RESISTCOLD, TRAIT_NOCLONE, TRAIT_IGNORE_SHAREDFOOD)
	mutant_bodyparts = list("vox_quills", "vox_body_markings", "vox_facial_quills", "vox_tail", "vox_tail_markings")
	default_features = list("vox_quills" = "None", "vox_facial_quills" = "None", "vox_body_markings" = "None", "vox_tail" = "lime", "vox_tail_markings" = "None", "vox_skin_tone" = "lime")
	attack_verbs = list("scratch", "claw")
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	screamsound = list('sound/voice/vox/shriek1.ogg'/*, 'sound/voice/vox/ashriek.ogg'*/)
	mutantbrain = /obj/item/organ/brain/vox // Brain damage on EMP
	mutantheart = /obj/item/organ/heart/vox
	mutantliver = /obj/item/organ/liver/vox // Liver damage on EMP
	mutantstomach = /obj/item/organ/stomach/vox // Disgust on EMP
	mutanttongue = /obj/item/organ/tongue/vox
	mutantlungs = /obj/item/organ/lungs/vox // Causes them to.. gasp.
	mutantears = /obj/item/organ/ears/vox // Very brief deafness
	mutanteyes = /obj/item/organ/eyes/vox // Quick hallucination
	mutanttail = /obj/item/organ/tail/vox
	mutantappendix = /obj/item/organ/appendix/vox
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/vox
	skinned_type = /obj/item/stack/sheet/animalhide/vox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	breathid = "n2"
	suicide_messages = list(
		"%%SUICIDER%% is jamming %%P_THEIR%% claws into %%P_THEIR%% eye sockets!",
		"%%SUICIDER%% is deeply inhaling oxygen!")
	husk_color = null
	eyes_icon = 'icons/mob/species/vox/eyes.dmi'
	icon_husk = 'icons/mob/species/vox/bodyparts.dmi'
	limb_icon_file = 'icons/mob/species/vox/bodyparts.dmi'
	static_part_body_zones = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	survival_box_replacements = list(items_to_delete = list(/obj/item/clothing/mask/breath, /obj/item/tank/internals/emergency_oxygen),\
											 new_items = list(/obj/item/tank/internals/emergency_oxygen/nitrogen, /obj/item/clothing/mask/breath/vox))
	creampie_id = "creampie_vox"
	exotic_bloodtype = "V"
	smells_like = "musty quills"
	liked_food = MEAT | FRIED
	species_language_holder = /datum/language_holder/vox

/datum/species/vox/get_species_description()
	return "The Vox are remnants of an ancient race, that originate from arkships. \
	These bioengineered, reptilian, beaked, and quilled beings have a physiological caste system and follow 'The Inviolate' tenets. \
	Breathing pure nitrogen, they need specialized masks and tanks for survival outside their arkships. \
	Their insular nature limits their involvement in broader galactic affairs, maintaining a distinct, yet isolated presence away from other species."

/datum/species/vox/get_species_lore()
	return list("Vox have no colonies of their own to speak of. Most Vox originate from a location known as the Shoal, a sprawling, labyrinth-like space megalith of debris and asteroids fused together over countless orbits. It is there where their cutthroat and opportunistic behavior stems from.",\
	"Little is known of Vox history itself, as the Vox do not keep many records beyond personal accomplishments and tales of profit and triumph. They have lived among the Shoal and the stars as long as they or anyone else can remember.",\
	"It is possible the species went through a dark age before being introduced to the greater galactic community. Those taken by Vox raiders are rumored to be taken back to the Shoal to be sold as slaves. Other rumors speculate those not cut out to be slaves are sold by fleshpeddlers for “extraction”.",\
	"Many Vox have grown fond of life among the stars, and typically avoid living on planetary colonies. They have a penchant for capitalism and goods peddling, deep space salvage, and sometimes interstellar crime. Many Vox now seek their fortune on the border of civilized space. Some trading with stations and worlds as (questionably legal) merchants, or applying to work for any one of the countless mega-corporations on the frontier. Others profit off crime and marauding, hijacking ships, cargo, and sometimes people to bring back to the Shoal.")

/datum/species/vox/get_butt_sprite()
	return BUTT_SPRITE_VOX

/datum/species/vox/get_cough_sound(mob/living/carbon/human/vox)
	return 'sound/voice/vox/shriekcough.ogg'

/datum/species/vox/get_sneeze_sound(mob/living/carbon/human/vox)
	return 'sound/voice/vox/shrieksneeze.ogg'

/datum/species/vox/random_name(unique)
	if(unique)
		return random_unique_vox_name()
	return capitalize(vox_name())

/datum/species/vox/go_bald(mob/living/carbon/human/vox)
	if(QDELETED(vox))	//may be called from a timer
		return
	vox.dna.features["vox_facial_quills"] = "None"
	vox.dna.features["vox_quills"] = "None"
	vox.dna.update_uf_block(DNA_VOX_FACIAL_QUILLS_BLOCK)
	vox.dna.update_uf_block(DNA_VOX_QUILLS_BLOCK)
	vox.update_hair()

/datum/species/vox/survival_box_replacement(mob/living/carbon/human/box_holder, obj/item/storage/box/survival_box, list/soon_deleted_items, list/soon_added_items)
	var/mask_to_replace = /obj/item/clothing/mask/breath/vox
	if(mask_to_replace in soon_added_items)
		var/list/possible_masks = list(/obj/item/clothing/mask/breath/vox, /obj/item/clothing/mask/breath/vox/respirator)
		soon_added_items -= mask_to_replace
		soon_added_items += pick(possible_masks)
	..()

/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source) // Don't forget your voxygen tank
	if(!H.can_breathe_mask())
		var/obj/item/clothing/mask/current_mask = H.get_item_by_slot(ITEM_SLOT_MASK)
		if(!H.equip_to_slot_if_possible(current_mask, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
			H.put_in_hands(current_mask)
	var/obj/item/clothing/mask/vox_mask
	var/mask_pref = preference_source?.prefs?.read_preference(/datum/preference/choiced/vox_mask)
	if(mask_pref == "Respirator")
		vox_mask = new /obj/item/clothing/mask/breath/vox/respirator
	else
		vox_mask = new /obj/item/clothing/mask/breath/vox
	H.equip_to_slot_or_del(vox_mask, ITEM_SLOT_MASK)
	var/obj/item/tank/internals_tank
	var/tank_pref = preference_source?.prefs?.read_preference(/datum/preference/choiced/vox_tank_type)
	if(tank_pref == "Large")
		internals_tank = new /obj/item/tank/internals/nitrogen
	else
		internals_tank = new /obj/item/tank/internals/emergency_oxygen/vox
	if(!H.equip_to_appropriate_slot(internals_tank))
		H.put_in_hands(internals_tank)
	to_chat(H, span_notice("You are now running on nitrogen internals from [internals_tank]. Your species finds oxygen toxic, so you must breathe pure nitrogen."))
	H.open_internals(internals_tank)

/datum/species/vox/get_icon_variant(mob/living/carbon/person_to_check)
	return person_to_check.dna.features["vox_skin_tone"]

/datum/species/vox/get_footprint_sprite()
	return FOOTPRINT_SPRITE_CLAWS

/datum/species/vox/get_eyes_static(mob/living/carbon/person_to_check)
	var/list/blue_static_skin_tones = list("crimson", "mossy")
	if(person_to_check.dna.features["vox_skin_tone"] in blue_static_skin_tones)
		return "blue"
	else
		return "green"

/datum/species/vox/handle_body(mob/living/carbon/human/H)
	update_skin_tone(H)
	..()

/datum/species/vox/proc/update_skin_tone(mob/living/carbon/human/vox, skin_tone)
	if(!skin_tone)
		skin_tone = vox.dna.features["vox_skin_tone"]
	vox.dna.features["vox_skin_tone"] = skin_tone
	vox.dna.update_uf_block(DNA_VOX_SKIN_TONE_BLOCK)
	var/obj/item/organ/tail/vox/vox_tail = vox.getorganslot(ORGAN_SLOT_TAIL)
	if(vox_tail && istype(vox_tail))
		vox_tail.update_tail_appearance(vox)

/datum/species/vox/get_special_statics(mob/living/carbon/human/vox)
	return list("mossy")

/datum/species/vox/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Resistance",
			SPECIES_PERK_DESC = "Vox hides provide excellent insulation against the coldness of space.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart-circle-check",
			SPECIES_PERK_NAME = "Imperishable Organs",
			SPECIES_PERK_DESC = "Vox organs contain advanced cybernetics that prevent them from decaying.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hamburger",
			SPECIES_PERK_NAME = "Communal Eater",
			SPECIES_PERK_DESC = "Due to their tribal background, Vox are unbothered by the thought of sharing a meal.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "EMP Sensitivity",
			SPECIES_PERK_DESC = "Due to their organs being partially synthetic, they are susceptible to EMP damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "head-side-mask",
			SPECIES_PERK_NAME = "Nitrogen Breathing",
			SPECIES_PERK_DESC = "Oxygen is toxic to Vox, they must breathe pure nitrogen.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "Unclonable",
			SPECIES_PERK_DESC = "Their peculiar physiology prevents Vox from being cloned.",
		),
	)

	return to_add

/datum/species/vox/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/gas/oxygen)
		H.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()
