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

/datum/reagent/medicine/adminordrazine/gamergirlpee
	name = "Gamer Girl Pee"
	id = "gamergirlpee"
	description = "The urine right out a legendary gamer girl. Said to be the nectar of gods."
	color = "##FFF8C975"
	can_synth = FALSE
	taste_description = "urine"
	taste_mult = 4