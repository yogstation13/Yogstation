/datum/disease/corruption
	name = "Corruption"
	max_stages = 5
	spread_text = "Touch"
    spread_flags = DISEASE_SPREAD_CONTACT_SKIN
	cure_text = "The Manly Dorf"
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 90
	agent = "???"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A strange disease, that makes people decay alive and forces them to act harmfull to not diseased people."
	severity = DISEASE_SEVERITY_HARMFUL
	required_organs = list(/obj/item/bodypart/head)