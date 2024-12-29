#define DAMAGE_WATER_STACKS 5
#define REGEN_WATER_STACKS 1
#define HEALTH_HEALED 2.5

/datum/species/oozeling
	name = "\improper Oozeling"
	plural_form = "Oozelings"
	id = SPECIES_OOZELING
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	hair_color = "mutcolor"
	hair_alpha = 160

	mutantliver = /obj/item/organ/internal/liver/slime
	mutantstomach = /obj/item/organ/internal/stomach/slime
	mutantbrain = /obj/item/organ/internal/brain/slime
	mutantears = /obj/item/organ/internal/ears/jelly
	mutantlungs = /obj/item/organ/internal/lungs/slime
	mutanttongue = /obj/item/organ/internal/tongue/jelly
	mutantheart = /obj/item/organ/internal/heart/slime

	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOFIRE,
	)

	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_bloodtype = /datum/blood_type/slime
	burnmod = 0.6 // = 3/5x generic burn damage
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list(FACTION_SLIME) //an oozeling wont be eaten by their brethren
	species_language_holder = /datum/language_holder/oozeling
	//swimming_component = /datum/component/swimming/dissolve

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling,
	)

	var/datum/action/cooldown/spell/slime_washing/slime_washing
	var/datum/action/cooldown/spell/slime_hydrophobia/slime_hydrophobia
	var/datum/action/innate/core_signal/core_signal

/datum/species/oozeling/get_species_description()
	return "A species of sentient semi-solids. \
		They require nutriment in order to maintain their body mass."

/datum/species/oozeling/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.oozeling_first_names)]"
	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.oozeling_last_names)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/oozeling/on_species_loss(mob/living/carbon/C)
	if(slime_washing)
		slime_washing.Remove(C)
	if(slime_hydrophobia)
		slime_hydrophobia.Remove(C)
	if(core_signal)
		core_signal.Remove(C)
	..()
	C.blood_volume = BLOOD_VOLUME_SAFE

/datum/species/oozeling/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		slime_washing = new
		slime_washing.Grant(C)
		slime_hydrophobia = new
		slime_hydrophobia.Grant(C)
		core_signal = new
		core_signal.Grant(C)

//////
/// HEALING SECTION
/// Handles passive healing and water damage.

/datum/species/oozeling/spec_life(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	. = ..()

	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in slime.status_effects
	if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
		return
	if(istype(wetness) && wetness.stacks > (DAMAGE_WATER_STACKS))
		slime.blood_volume -= 2 * seconds_per_tick
		if (SPT_PROB(25, seconds_per_tick))
			slime.visible_message(span_danger("[slime]'s form begins to lose cohesion, seemingly diluting with the water!"), span_warning("The water starts to dilute your body, dry it off!"))

	if(istype(wetness) && wetness.stacks > (REGEN_WATER_STACKS))
		if (SPT_PROB(25, seconds_per_tick)) //Used for old healing system. Maybe use later? For now increase loss for being soaked.
			//to_chat(slime, span_warning("You can't pull your body together and regenerate with water inside it!"))
			to_chat(slime, span_warning("You can't pull your body together it is dripping wet!"))
			slime.blood_volume -= 1 * seconds_per_tick

//////
/// DEATH OF BODY SECTION
///	Handles gibbing

/datum/species/oozeling/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()

	if(gibbed)
		H.dna = null

///////
/// CHEMICAL HANDLING
/// Here's where slimes heal off plasma and where they hate drinking water.

/datum/species/oozeling/handle_chemical(datum/reagent/chem, mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	// slimes use plasma to fix wounds, and if they have enough blood, organs
	var/static/list/organs_we_mend = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
	)
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		var/brute_damage = slime.get_current_damage_of_type(damagetype = BRUTE)
		var/burn_damage = slime.get_current_damage_of_type(damagetype = BURN)
		var/remaining_heal = HEALTH_HEALED
		if(brute_damage + burn_damage > 0)
			if(!HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA) && slime.get_skin_temperature() > slime.bodytemp_cold_damage_limit)
				// Make sure to double check this later.
				remaining_heal -= abs(slime.heal_damage_type(rand(0, remaining_heal) * REM * seconds_per_tick, BRUTE))
				slime.heal_damage_type(remaining_heal * REM * seconds_per_tick, BURN)
				slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
			else
				to_chat(slime, span_purple("Your membrane is too viscous to mend its wounds"))
		if(slime.blood_volume > BLOOD_VOLUME_SLIME_SPLIT)
			slime.adjustOrganLoss(
			pick(organs_we_mend),
			- 2 * seconds_per_tick,
		)
		if (SPT_PROB(5, seconds_per_tick))
			to_chat(slime, span_purple("Your body's thirst for plasma is quenched, your inner and outer membrane using it to regenerate."))

	if(chem.type == /datum/reagent/water)
		if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
			return TRUE

		slime.blood_volume -= 3 * seconds_per_tick
		slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if (SPT_PROB(25, seconds_per_tick))
			to_chat(slime, span_warning("The water starts to weaken and adulterate your insides!"))

	return ..()

/datum/reagent/water/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)
	//Flat blood loss damage from being touched by water
	. = ..()

	if(isoozeling(exposed_mob))
		if(HAS_TRAIT(exposed_mob, TRAIT_SLIME_HYDROPHOBIA))
			to_chat(exposed_mob, span_warning("Water splashes against your oily membrane and rolls right off your body!"))
			return
		exposed_mob.blood_volume = max(exposed_mob.blood_volume - 30, 0)
		to_chat(exposed_mob, span_warning("The water causes you to melt away!"))

/datum/reagent/toxin/slimeooze
	name = "Slime Ooze"
	description = "A gooey semi-liquid produced from Oozelings"
	color = "#611e80"
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 1.5

/datum/reagent/toxin/slimeooze/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		to_chat(M, span_danger("Your insides are burning!</span>"))
		M.adjustToxLoss(rand(1,10)*REM, 0)
		. = 1
	else if(prob(40))
		M.heal_bodypart_damage(5*REM)
		. = 1
	..()

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Respiration",
			SPECIES_PERK_DESC = "[plural_form] can breathe plasma, and restore blood by doing so.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Incombustible",
			SPECIES_PERK_DESC = "[plural_form] cannot be set aflame.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Anaerobic Lineage",
			SPECIES_PERK_DESC = "[plural_form] don't require much oxygen to live."
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Self-Consumption",
			SPECIES_PERK_DESC = "Once hungry enough, [plural_form] will begin to consume their own blood and limbs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Water Soluble",
			SPECIES_PERK_DESC = "[plural_form] will dissolve away when in contact with water.",
		),
		list(
            SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
            SPECIES_PERK_ICON = "briefcase-medical",
            SPECIES_PERK_NAME = "Oozeling Biology",
            SPECIES_PERK_DESC = "[plural_form] take specialized medical knowledge to be \
                treated. Do not expect speedy revival, if you are lucky enough to get \
                one at all.",
        ),
	)

	return to_add
