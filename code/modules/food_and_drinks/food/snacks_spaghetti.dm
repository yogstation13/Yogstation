
//spaghetti prototype used by all subtypes
/obj/item/reagent_containers/food/snacks/spaghetti
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#F0E68C"
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/spaghetti/Initialize()
	. = ..()
	if(!cooked_type) // This isn't cooked, why would you put uncooked spaghetti in your pocket?
		var/list/display_message = list(
			span_notice("Something wet falls out of their pocket and hits the ground. Is that... [name]?"),
			span_warning("Oh shit! All your pocket [name] fell out!"))
		AddComponent(/datum/component/spill, display_message, 'sound/effects/splat.ogg')
	
/obj/item/reagent_containers/food/snacks/spaghetti/raw
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	cooked_type = /obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti
	tastes = list("pasta" = 1)

/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon_state = "spaghettiboiled"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/pasta

/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	bitesize = 4
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#DC143C"
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/spaghetti/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	bitesize = 4
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/tomatojuice = 20, /datum/reagent/consumable/nutriment/vitamin = 8)
	filling_color = "#DC143C"
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/spaghetti/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nice meatball!"
	icon_state = "meatballspaghetti"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/spaghetti/spesslaw
	name = "spesslaw"
	desc = "A lawyer's favorite."
	icon_state = "spesslaw"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/spaghetti/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon_state = "chowmein"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("noodle" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/spaghetti/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon_state = "beefnoodle"
	trash = /obj/item/reagent_containers/glass/bowl
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/liquidgibs = 3)
	tastes = list("noodle" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/spaghetti/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon_state = "butternoodles"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("noodle" = 1, "butter" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/spaghetti/falfredo
	name = "fettuccine alfredo"
	desc = "A dish of fresh fettuccine tossed with creamy butter and parmesan cheese. The proportions are huge."
	icon_state = "falfredo"
	bitesize = 8
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/parmesan_delight = 4)
	filling_color = "#DC143C"
	tastes = list("fettuccine" = 1, "alfredo" = 1, "italy" = 1, "creamy goodness" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/lasagna
	name = "lasagna"
	desc = "I hate Mondays."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "lasagna"
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("pasta" = 2, "meat" = 1, "cheese" = 1)
	foodtype = MEAT | DAIRY | GRAIN

/obj/item/reagent_containers/food/snacks/pizzaghetti
	name = "pizzaghetti"
	desc = "A frightening combination of two classic Italian dishes, pasta and pizza. You start to sweat just looking at it."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzaghetti"
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 6
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("grease" = 4, "crust" = 1, "pasta" = 1, "cheese" = 1, "tomato" = 1,)
	foodtype = GRAIN | VEGETABLES | DAIRY
