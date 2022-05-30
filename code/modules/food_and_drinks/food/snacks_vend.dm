////////////////////////////////////////////SNACKS FROM VENDING MACHINES////////////////////////////////////////////
//in other words: junk food
//don't even bother looking for recipes for these

/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	junkiness = 25
	filling_color = "#D2691E"
	tastes = list("candy" = 1)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sodiumchloride = 2)
	junkiness = 25
	filling_color = "#8B0000"
	tastes = list("dried meat" = 1)
	foodtype = JUNKFOOD | MEAT | SUGAR

/obj/item/reagent_containers/food/snacks/sosjerky/healthy
	name = "homemade beef jerky"
	desc = "Homemade beef jerky made from the finest space cows."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	junkiness = 0

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sodiumchloride = 1)
	junkiness = 20
	filling_color = "#FFD700"
	tastes = list("salt" = 1, "crisps" = 1)
	foodtype = JUNKFOOD | FRIED

/obj/item/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 4)
	junkiness = 25
	filling_color = "#8B0000"
	tastes = list("dried raisins" = 1)
	foodtype = JUNKFOOD | FRUIT | SUGAR
	custom_price = 30

/obj/item/reagent_containers/food/snacks/no_raisin/healthy
	name = "homemade raisins"
	desc = "Homemade raisins, the best in all of spess."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	junkiness = 0
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	list_reagents = list(/datum/reagent/consumable/sugar = 4)
	junkiness = 25
	filling_color = "#FFD700"
	foodtype = JUNKFOOD | GRAIN | SUGAR
	custom_price = 11

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	junkiness = 25
	filling_color = "#FFD700"
	tastes = list("cheese" = 5, "crisps" = 2)
	foodtype = JUNKFOOD | DAIRY | SUGAR
	custom_price = 16

/obj/item/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/doctor_delight = 5)
	filling_color = "#F5F5DC"
	tastes = list("sweetness" = 3, "cake" = 1)
	foodtype = GRAIN | FRUIT | VEGETABLES

/obj/item/reagent_containers/food/snacks/energybar
	name = "High-power energy bars"
	icon_state = "energybar"
	desc = "An energy bar with a lot of punch, you probably shouldn't eat this if you're not an Ethereal."
	trash = /obj/item/trash/energybar
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/liquidelectricity = 4)
	filling_color = "#97ee63"
	tastes = list("pure electricity" = 3, "fitness" = 2)
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/toritose
	name = "toritose"
	desc = "An excellent snack when you need it, however they become salty real fast. Hopefully stands on it's own in the market."
	icon_state = "toritose"
	trash = /obj/item/trash/toritose
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/sodiumchloride = 5)
	junkiness = 21
	filling_color = "#FF0000"
	tastes = list("salt" = 3, "crunchiness" = 1)
	foodtype = JUNKFOOD | GRAIN | FRIED
	custom_price = 15

/obj/item/reagent_containers/food/snacks/borer
	name = "borer yummies"
	desc = "So good they'll squeeze your brains out!"
	icon_state = "blueyum"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 2)
	junkiness = 12
	tastes = list("a squirming sensation down your throat" = 3, "sweetness" = 1)
	foodtype = JUNKFOOD | FRUIT | SUGAR
	custom_price = 5

/obj/item/reagent_containers/food/snacks/kakes
	name = "top kakes"
	desc = "Sugary bitsized cake delights guaranteed to keep you up all night!"
	trash = /obj/item/trash/topkakes
	icon_state = "topkakes"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 6)
	filling_color = "#F5F5DC"
	tastes = list("sweetness" = 3, "cake" = 1)
	foodtype = JUNKFOOD | GRAIN | SUGAR
	custom_price = 20

/obj/item/reagent_containers/food/snacks/tatorling
	name = "tatorling branded cereal"
	desc = "The most consumed brand of cereal! 8+ Only. (WARNING: CHOKING HAZARD.)"
	icon_state = "tatorling"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 3, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/sugar = 6)
	tastes = list("murderbone" = 1, "lime" = 3, "strawberry" = 3)
	foodtype = GRAIN | FRUIT | BREAKFAST
	var/opened = FALSE
	var/searched = FALSE

/obj/item/reagent_containers/food/snacks/tatorling/attack_self(mob/living/user)
	if(!opened)
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
		if(HAS_TRAIT(user, TRAIT_CLUMSY))
			to_chat(user, span_warning("You rip open the [src]!"))
		else
			to_chat(user, span_notice("You open the [src]."))
		icon_state += "_open"
		opened = TRUE
	else
		if(!searched)
			if(INTERACTING_WITH(user, src))
				return
			to_chat(user, span_warning("You start searching for the toy..."))
			if(!do_after(user, 1.5 SECONDS, target = src))
				return
			if(prob(50))
				switch(rand(1,2))
					if(1)
						new /obj/item/toy/figure/ling(get_turf(src))
					if(2)
						new /obj/item/toy/figure/traitor(get_turf(src))
				to_chat(user, span_notice("You found a toy! Yay!"))
			else
				to_chat(user, span_warning("You didn't find anything..."))
				user.emote("cry")
			return searched = TRUE
	. = ..()

/obj/item/reagent_containers/food/snacks/tatorling/attack(mob/living/M, mob/user, def_zone)
	if(!opened)
		to_chat(user, span_warning("[src]'s lid hasn't been opened!"))
		return FALSE
	return ..()

/obj/item/reagent_containers/food/snacks/vermin
	name = "vermin bites"
	desc = "A small can with a cartoon mouse on the label. A noise that sounds suspiciously like squeaking can be heard coming from inside."
	icon_state = "verminbites"
	tastes = list("rats" = 1 , "mouse" = 2, "cheese" = 1)
	foodtype = MEAT
	/// What animal does the snack contain?
	var/mob/living/simple_animal/mouse/contained_animal

/obj/item/reagent_containers/food/snacks/vermin/attack_self(mob/user)
	. = ..()
	contained_animal = new /mob/living/simple_animal/mouse(get_turf(src))
	to_chat(user, span_warning("You pry open the [src]. A [contained_animal.name] falls out from inside!"))
	qdel(src)

/obj/item/reagent_containers/food/snacks/vermin/attack(mob/living/M, mob/user, def_zone)
	to_chat(user, span_warning("You need to open [src]' lid first."))
	return FALSE
