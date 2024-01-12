/datum/reagent/baldium
	name = "Baldium"
	description = "A major cause of hair loss across the world."
	reagent_state = LIQUID
	color = "#ecb2cf"
	taste_description = "bitterness"

/datum/reagent/baldium/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message=TRUE, touch_protection=FALSE)
	. = ..()
	if(!(method & (TOUCH|VAPOR)) || !ishuman(L))
		return

	var/mob/living/carbon/human/baldtarget = L
	to_chat(baldtarget, span_danger("Your hair is falling out in clumps!"))
	baldtarget.facial_hair_style = "Shaved"
	baldtarget.hair_style = "Bald"
