/datum/reagent/mutationtoxin/gorilla
	name = "Gorilla Mutation Toxin"
	id = "gorillamutationtoxin"
	description = "A gorilla-ing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/gorilla
	mutationtext = "<span class='danger'>The pain subsides. You feel... damn dirty.</span>"

/datum/reagent/cluwnification
	name = "Cluwne Tears"
	id = "cluwnification"
	description = "Tears from thousands of cluwnes compressed into a dangerous cluwnification virus."
	color = "#535E66" // rgb: 62, 224, 33
	can_synth = FALSE
	taste_description = "something funny"

/datum/reagent/cluwnification/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)