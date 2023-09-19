/datum/eldritch_transmutation/void_knife
	name = "Cerebral Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/book) 
	result_atoms = list(/obj/item/gun/magic/hook/sickly_blade/void)
	required_shit_list = "A book and a knife."

/datum/eldritch_transmutation/final/void_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	
	ADD_TRAIT(user, TRAIT_NOBREATH, type)
	ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, type)
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, type)
	
	priority_announce("Immense destabilization of the bluespace veil has been observed. @&#^$&#^@# The nobleman of void [user.real_name] has arrived, stepping along the Waltz that ends worlds!  $&#^@#@&#^ Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
		
	return ..()
