/obj/item/organ/heart/gland/pop
	abductor_hint = "anthropomorphic transmorphosizer. After it activates, randomly changes the abductee's species."
	cooldown_low = 90 SECONDS
	cooldown_high = 3 MINUTES
	human_only = TRUE
	icon_state = "species"
	mind_control_uses = 7
	mind_control_duration = 30 SECONDS

/obj/item/organ/heart/gland/pop/activate()
	to_chat(owner, span_notice("You feel unlike yourself."))
	randomize_human(owner)
	var/species = pick(list(/datum/species/human, /datum/species/lizard, /datum/species/gorilla, /datum/species/moth, /datum/species/fly)) // yogs -- gorilla people
	owner.set_species(species)