/obj/item/organ/heart/gland/blood
	abductor_hint = "pseudonuclear hemo-destabilizer. It periodically randomizes the abductee's bloodtype into a random reagent."
	cooldown_low = 2 MINUTES
	cooldown_high = 3 MINUTES
	icon_state = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	mind_control_uses = 3
	mind_control_duration = 3 MINUTES

/obj/item/organ/heart/gland/blood/activate()
	if(!ishuman(owner) || !owner.dna.species)
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/species = H.dna.species
	to_chat(H, span_warning("You feel your blood heat up for a moment."))
	species.exotic_blood = get_random_reagent_id()

