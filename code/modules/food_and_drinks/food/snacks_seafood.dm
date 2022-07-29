/obj/item/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	bitesize = 3
	filling_color = "#CD853F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/capsaicin = 1)
	tastes = list("fish" = 4, "batter" = 1, "hot peppers" = 1)
	foodtype = SEAFOOD

/obj/item/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin/carpotoxin = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	bitesize = 6
	filling_color = "#FA8072"
	tastes = list("fish" = 1)
	foodtype = SEAFOOD | GROSS

/obj/item/reagent_containers/food/snacks/carpmeat/Initialize()
	. = ..()
	eatverb = pick("bite","chew","gnaw","swallow","chomp")

/obj/item/reagent_containers/food/snacks/carpmeat/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/carpmeat/fish/cooked, rand(30 SECONDS, 60 SECONDS), TRUE, TRUE)  //loses its carpotoxin in the heat :)
/obj/item/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/reagent_containers/food/snacks/carpmeat/imitation/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/carpmeat/fish/cooked, rand(40 SECONDS, 60 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/carpmeat/fish //basic fish fillet (no carpotoxin) for fish butchering
	name = "fish fillet"
	desc = "A fillet of spess fish meat. You should cook this."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/reagent_containers/food/snacks/carpmeat/fish/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/carpmeat/fish/cooked, rand(30 SECONDS, 60 SECONDS), TRUE, TRUE)
/obj/item/reagent_containers/food/snacks/carpmeat/fish/cooked
	name = "cooked fish fillet"
	desc = "A fillet of spess fish meat. Cooked to perfection."
	icon_state = "fishfillet_cooked"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 5) //cooked fish is actually pretty good for you
	foodtype = SEAFOOD

/obj/item/reagent_containers/food/snacks/carpmeat/fish/battered
	name = "battered fish fillet"
	desc = "A fillet of spess fish meat. Coated in crunchy fried beer batter."
	icon_state = "fishfillet_battered"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/cooking_oil = 1) //spontaniously fries because battering code doesn't actually exist yet.
	foodtype = SEAFOOD

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	bitesize = 1
	filling_color = "#CD853F"
	tastes = list("fish" = 1, "breadcrumbs" = 1)
	foodtype = SEAFOOD

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	filling_color = "#FA8072"
	tastes = list("fish" = 1, "chips" = 1)
	foodtype = SEAFOOD | VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/fishfry
	name = "fish fry"
	desc = "All that and no bag of chips..."
	icon_state = "fish_fry"
	list_reagents = list (/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	filling_color = "#ee7676"
	tastes = list("fish" = 1, "pan seared vegtables" = 1)
	foodtype = SEAFOOD | VEGETABLES | FRIED

/obj/item/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving an attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/capsaicin = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/capsaicin = 5)
	filling_color = "#FA8072"
	tastes = list("fish" = 1, "hot peppers" = 1)
	foodtype = SEAFOOD | TOXIC

/obj/item/reagent_containers/food/snacks/fishtaco
	name = "fish taco"
	desc = "A taco with fish, cheese, and cabbage."
	icon_state = "fishtaco"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("taco" = 4, "fish" = 2, "cheese" = 2, "cabbage" = 1)
	foodtype = SEAFOOD | DAIRY | GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/vegetariansushiroll
	name = "vegetarian sushi roll"
	desc = "A roll of simple vegetarian sushi, made with rice, carrots, and potatoes. Able to be sliced into pieces!"
	icon_state = "vegetariansushiroll"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)
	foodtype = VEGETABLES
	slice_path = /obj/item/reagent_containers/food/snacks/vegetariansushislice
	slices_num = 4

/obj/item/reagent_containers/food/snacks/vegetariansushislice
	name = "vegetarian sushi slice"
	desc = "A slice of simple vegetarian sushi, made with rice, carrots, and potatoes."
	icon_state = "vegetariansushislice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)
	foodtype = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/spicyfiletsushiroll
	name = "spicy filet sushi roll"
	desc = "A roll of tasty, spicy sushi, made with fish and vegetables. Able to be sliced into pieces!"
	icon_state = "spicyfiletroll"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/capsaicin = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtype = VEGETABLES | SEAFOOD
	slice_path = /obj/item/reagent_containers/food/snacks/spicyfiletsushislice
	slices_num = 4

/obj/item/reagent_containers/food/snacks/spicyfiletsushislice
	name = "spicy filet sushi slice"
	desc = "A slice of tasty, spicy sushi, made with fish and vegetables. Don't eat it too fast!"
	icon_state = "spicyfiletslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtype = VEGETABLES | SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/dolphincereal
	name = "dolphin cereal"
	desc = "Finest dolphin skin flakes. This looks flippin' disgusting."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "dolphincereal"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("milk" = 1, "old cardboard" = 1)

/obj/item/reagent_containers/food/snacks/dolphinandchips
	name = "dolphin and chips"
	desc = "Dolphin and chips, wrapped in the finest newspaper from the clown's newscaster channel."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "dolphinandchips"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("dolphin meat" = 1, "fries" = 1)

/obj/item/reagent_containers/food/snacks/fishdumpling
	name = "fish dumplings"
	desc = "powerful little pockets of flavor."
	icon_state = "fishdumpling"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 15) //delicious onion and garlic and fish
	filling_color = "#2e211b"
	tastes = list("steamed dough" = 3, "fish" = 2, "seasonings" = 2)
	foodtype = GRAIN | SEAFOOD | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/youmonster
	name = "full dolphin platter"
	desc = "A whole dolphin. Good luck eating this. (WARNING: do not consume any wafer thin mints after consumption)"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "youmonster"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 100, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("dolphin meat" = 1, "regret" = 1)

/obj/item/reagent_containers/food/snacks/seaweedsheet
	name = "seaweed sheet"
	desc = "A dried sheet of seaweed used for making sushi."
	icon_state = "seaweedsheet"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("seaweed" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/shrimpcocktail
	name = "shrimp cocktail"
	desc = "A tall glass of tomato sauce with shrimp and a lemon wedge."
	icon_state = "shrimpcocktail"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 8) //this is tomato sauce, a fruit, and seafood. Very good for you
	filling_color = "#bd0000"
	trash = /obj/item/reagent_containers/food/drinks/drinkingglass
	tastes = list("shrimp" = 3, "tomatos" = 1, "lemon" = 1)
	foodtype = VEGETABLES | FRUIT | SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/spaghetti/fishalfredo
	name = "seafood alfredo"
	desc = "A dish of fresh fettuccine tossed with creamy butter and parmesan cheese. The proportions are huge. Also has some shrimp tossed in it!"
	icon_state = "fishalfredo"
	bitesize = 10
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 16, /datum/reagent/consumable/parmesan_delight = 4)
	filling_color = "#DC143C"
	tastes = list("fettuccine" = 1, "alfredo" = 1, "italy" = 1, "creamy goodness" = 1, "shrimp" = 2)
	foodtype = GRAIN | DAIRY | VEGETABLES | SEAFOOD

/obj/item/reagent_containers/food/snacks/surfnturf
	name = "surf 'n turf"
	desc = "A meaty steak sharing the plate with a slice of cooked fish and some veggies."
	icon_state = "surfnturf"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 12)
	filling_color = "#a13333"
	tastes = list("fish" = 2, "steak" = 2, "vegetables" = 2)
	foodtype = VEGETABLES | SEAFOOD | MEAT

/obj/item/reagent_containers/food/snacks/ceviche
	name = "ceviche"
	desc = "A dish of fish cured in citrus juices!"
	icon_state = "ceviche"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 16)
	filling_color = "#df919e"
	tastes = list("fish" = 1, "citrus" = 6)
	foodtype = FRUIT | SEAFOOD

/obj/item/reagent_containers/food/snacks/spaghetti/ink
	name = "squid ink spaghetti"
	desc = "Spaghetti and squid ink sauce. Just like your completely normal and not-a-squid father used to make!"
	icon_state = "pastasquid"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/colorful_reagent/crayonpowder/black = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/colorful_reagent/crayonpowder/black = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#000000"
	tastes = list("pasta" = 1, "seawater" = 1)
	foodtype = GRAIN | SEAFOOD
