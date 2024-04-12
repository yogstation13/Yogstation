/datum/reagent/mutationtoxin/gorilla
	name = "Gorilla Mutation Toxin"
	description = "A gorilla-ing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/gorilla
	mutationtext = span_danger("The pain subsides. You feel... damn dirty.")

/datum/reagent/mutationtoxin/ivymen
	name = "Ivymen Mutation Toxin"
	description = "A thorny toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/pod/ivymen
	mutationtext = span_danger("The pain subsides. You feel... thorny.")

/datum/reagent/cluwnification
	name = "Cluwne Tears"
	description = "Tears from thousands of cluwnes compressed into a dangerous cluwnification virus."
	color = "#535E66" // rgb: 62, 224, 33
	can_synth = FALSE
	taste_description = "something funny"

/datum/reagent/cluwnification/reaction_mob(mob/living/L, methods=TOUCH, reac_volume, show_message = 1, permeability = 1)
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*permeability)))
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)
