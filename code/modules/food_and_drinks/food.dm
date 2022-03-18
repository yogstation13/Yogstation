////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/// Note: When adding food items with dummy parents, make sure to add
/// the parent to the exclusion list in code/__HELPERS/unsorted.dm's
/// get_random_food proc.
////////////////////////////////////////////////////////////////////////////////
#define STOP_SERVING_BREAKFAST (15 MINUTES)

/obj/item/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	reagent_flags = INJECTABLE
	resistance_flags = FLAMMABLE
	var/foodtype = NONE
	var/last_check_time
	///Will this food turn into badrecipe on a grill? Don't use this for everything; preferably mostly for food that is made on a grill to begin with so it burns after some time
	var/burns_on_grill = FALSE
	///Will this food turn into badrecipe in an oven? Don't use this for everything; preferably mostly for food that is made in an oven to begin with so it burns after some time
	var/burns_in_oven = FALSE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)
	MakeGrillable()
	MakeBakeable()

///This proc handles grillable components, overwrite if you want different grill results etc.
/obj/item/reagent_containers/food/proc/MakeGrillable()
	if(burns_on_grill)
		AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/badrecipe, rand(20 SECONDS, 30 SECONDS), FALSE)
	return

///This proc handles bakeable components, overwrite if you want different bake results etc.
/obj/item/reagent_containers/food/proc/MakeBakeable()
	if(burns_in_oven)
		AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/badrecipe, rand(25 SECONDS, 40 SECONDS), FALSE)
	return

/obj/item/reagent_containers/food/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!HAS_TRAIT(H, TRAIT_AGEUSIA))
				if(foodtype & H.dna.species.toxic_food)
					to_chat(H,span_warning("What the hell was that thing?!"))
					H.adjust_disgust(25 + 30 * fraction)
					SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
				else if(foodtype & H.dna.species.disliked_food)
					to_chat(H,span_notice("That didn't taste very good..."))
					H.adjust_disgust(11 + 15 * fraction)
					SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
				else if(foodtype & H.dna.species.liked_food)
					to_chat(H,span_notice("I love this taste!"))
					H.adjust_disgust(-5 + -2.5 * fraction)
					SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)
			else
				if(foodtype & H.dna.species.toxic_food)
					to_chat(H, span_warning("You don't feel so good..."))
					H.adjust_disgust(25 + 30 * fraction)
			if((foodtype & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
			last_check_time = world.time

#undef STOP_SERVING_BREAKFAST
