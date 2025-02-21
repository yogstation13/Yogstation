/datum/chemical_reaction/drink/ratvander
	results = list(/datum/reagent/consumable/ethanol/ratvander = 10)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/datum/reagent/consumable/ethanol/triple_sec = 5,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/iron = 1,
		/datum/reagent/copper = 0.6
	)
	mix_message = "The mixture develops a golden glow."
	mix_sound = 'sound/magic/clockwork/scripture_tier_up.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER
