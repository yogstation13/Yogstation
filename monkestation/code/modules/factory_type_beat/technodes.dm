/datum/techweb_node/ore_processing
	id = "ore_processing_nodes"
	display_name = "Ore Processing Nodes"
	description = "Contains all of the ore processing designs."
	design_ids = list(
		"brine_chamber",
		"purification_chamber",
		"enricher",
		"crusher",
		"crystalizer",
		"chemical_injector",
		"chemical_washer",
		"dissolution_chamber",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE
