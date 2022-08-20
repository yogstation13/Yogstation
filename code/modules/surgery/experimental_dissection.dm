#define EXPDIS_BASE_REWARD 500

/datum/surgery/experimental_dissection
	name = "Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and gives notes with the points given."
	icon = 'icons/mob/actions.dmi'
	icon_state = "scan_mode"
	tier = "1"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/dissection,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living) //Feel free to dissect devils but they're magic.
	replaced_by = /datum/surgery/experimental_dissection/adv
	requires_tech = FALSE
	var/value_multiplier = 1

/datum/surgery/experimental_dissection/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED, "[name]"))
		return FALSE
	if(target.stat != DEAD)
		return FALSE

/datum/surgery_step/dissection
	name = "dissection"
	implements = list(/obj/item/scalpel/augment = 75, /obj/item/scalpel/advanced = 60, /obj/item/scalpel = 45, /obj/item/kitchen/knife = 20, /obj/item/shard = 10)// special tools not only cut down time but also improve probability
	time = 12.5 SECONDS
	silicons_obey_prob = TRUE
	repeatable = TRUE
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'

/datum/surgery_step/dissection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts dissecting [target].", span_notice("You start dissecting [target]."))

/datum/surgery_step/dissection/proc/check_value(mob/living/target, datum/surgery/experimental_dissection/ED)
	var/cost = EXPDIS_BASE_REWARD
	var/multi_surgery_adjust = 0

	//determine bonus applied
	if(isalienroyal(target))
		cost = (EXPDIS_BASE_REWARD * 10)
	else if(isalienadult(target))
		cost = (EXPDIS_BASE_REWARD * 5)
	else if(ismonkey(target))
		cost = (EXPDIS_BASE_REWARD * 0.5)
	else if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H?.dna?.species)
			if(isabductor(H))
				cost = (EXPDIS_BASE_REWARD * 4)
			else if(isgolem(H) || iszombie(H))
				cost = (EXPDIS_BASE_REWARD * 3)
			else if(isjellyperson(H) || ispodperson(H))
				cost = (EXPDIS_BASE_REWARD * 2)
	else
		cost = (EXPDIS_BASE_REWARD * 0.6)



	//now we do math for surgeries already done (no double dipping!).
	for(var/i in typesof(/datum/surgery/experimental_dissection))
		var/datum/surgery/experimental_dissection/dissection = i
		if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED, "[initial(dissection.name)]"))
			multi_surgery_adjust = max(multi_surgery_adjust, initial(dissection.value_multiplier)) - 1

	multi_surgery_adjust *= cost

	//multiply by multiplier in surgery
	cost *= ED.value_multiplier
	return (cost-multi_surgery_adjust)

/datum/surgery_step/dissection/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/points_earned = check_value(target, surgery)
	user.visible_message("[user] dissects [target], discovering [points_earned] point\s of data!", span_notice("You dissect [target], and write down [points_earned] point\s worth of discoveries!"))
	new /obj/item/research_notes(user.loc, points_earned, TECHWEB_POINT_TYPE_GENERIC, "biology")
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	ADD_TRAIT(target, TRAIT_DISSECTED, "[surgery.name]")
	repeatable = FALSE
	return TRUE

/datum/surgery_step/dissection/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] dissects [target]!", span_notice("<span class='notice'>You dissect [target], but do not find anything particularly interesting."))
	new /obj/item/research_notes(user.loc, round(check_value(target, surgery)) * 0.01, TECHWEB_POINT_TYPE_GENERIC, "biology")
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	return TRUE

/datum/surgery/experimental_dissection/adv
	name = "Thorough Dissection"
	tier = "2"
	value_multiplier = 2
	replaced_by = /datum/surgery/experimental_dissection/adv/exp
	requires_tech = TRUE

/datum/surgery/experimental_dissection/adv/exp
	name = "Experimental Dissection"
	tier = "3"
	value_multiplier = 5
	replaced_by = /datum/surgery/experimental_dissection/adv/alien

/datum/surgery/experimental_dissection/adv/alien
	name = "Extraterrestrial Dissection"
	tier = "4"
	value_multiplier = 10
	replaced_by = null

#undef EXPDIS_BASE_REWARD
