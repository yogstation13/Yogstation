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

/datum/reagent/cluwnification/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)

/datum/reagent/shadowling_blindness_smoke
	name = "odd black liquid"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	if(!is_shadow_or_thrall(M))
		to_chat(M, span_warning("<b>You breathe in the black smoke, and your eyes burn horribly!</b>"))
		M.blind_eyes(5)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3, 0)
			. = 1
	else
		to_chat(M, span_notice("<b>You breathe in the black smoke, and you feel revitalized!</b>"))
		M.adjustOxyLoss(-2, 0)
		M.adjustToxLoss(-2, 0)
		. = 1
	return ..() || .

/datum/reagent/shadowfrost
	name = "Shadowfrost"
	description = "A dark liquid that seems to slow down anything that comes into contact with it."
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/shadowfrost/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=2)

/datum/reagent/shadowfrost/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()
