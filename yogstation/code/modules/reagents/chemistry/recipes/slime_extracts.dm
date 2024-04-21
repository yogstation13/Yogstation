/datum/chemical_reaction/slime/slimegorilla
	name = "Gorilla Mutation Toxin"
	id = "gorillamuttoxin"
	results = list(/datum/reagent/mutationtoxin/gorilla = 1)
	required_reagents = list(/datum/reagent/consumable/milk = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/slimevox
	name = "Vox Mutation Toxin"
	id = "voxmuttoxin"
	results = list(/datum/reagent/mutationtoxin/vox = 1)
	required_reagents = list(/datum/reagent/nitrogen = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/green
