/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	now_failing = span_warning("An explosion of pain erupts in your lower right abdomen!")
	now_fixed = span_info("The pain in your abdomen has subsided.")
	var/inflamed

/obj/item/organ/appendix/update_name(updates=ALL)
	. = ..()
	if(inflamed)
		name = "inflamed appendix"
	else
		name = "appendix"

/obj/item/organ/appendix/update_icon_state()
	. = ..()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"

/obj/item/organ/appendix/on_life()
	..()
	if(!(organ_flags & ORGAN_FAILING))
		return
	var/mob/living/carbon/M = owner
	if(M)
		M.adjustToxLoss(4, TRUE, TRUE)	//forced to ensure people don't use it to gain tox as slime person

/obj/item/organ/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.diseases)
		A.cure()
		inflamed = TRUE
	update_appearance(UPDATE_ICON)
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)

/obj/item/organ/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent(/datum/reagent/toxin/bad_food, 5)
	return S

/obj/item/organ/appendix/get_availability(datum/species/species)
	return !((TRAIT_NOHUNGER in species.inherent_traits) || (TRAIT_POWERHUNGRY in species.inherent_traits))

/obj/item/organ/appendix/cybernetic
	name = "cybernetic appendix"
	desc = "One of the most advanced cybernetic organs ever created."
	icon_state = "implant-filter"
	organ_flags = ORGAN_SYNTHETIC
	compatible_biotypes = ALL_BIOTYPES // THE GREATEST INVENTION IN THE HISTORY OF CYBERNETICS
	now_failing = span_warning("NOT AGAIN!")
	now_fixed = span_info("Thank god that's over.")

/obj/item/organ/appendix/cybernetic/on_life()
	..()
	if(inflamed)
		var/mob/living/carbon/M = owner
		for(var/datum/disease/appendicitis/A in M.diseases)
			A.cure()
		inflamed = FALSE
		M.emote("chuckle") //you really think that will stop me?

/obj/item/organ/appendix/cybernetic/update_name(updates=ALL)
	. = ..()
	name = "cybernetic appendix"

/obj/item/organ/appendix/cybernetic/update_icon(updates=ALL)
	. = ..()
	icon_state = "implant-filter"

/obj/item/organ/appendix/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity > EMP_LIGHT)
		damage += 20 * (severity - EMP_HEAVY)
