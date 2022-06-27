//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu

////////////////////////////////////////////KEBAB////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/kebab
	trash = /obj/item/stack/rods
	icon_state = "kebab"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("meat" = 3, "metal" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/kebab/human
	name = "human kebab"
	desc = "Human meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("tender meat" = 3, "metal" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/kebab/monkey
	name = "kebab"
	desc = "Delicious meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 3, "metal" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/kebab/tofu
	name = "tofu kebab"
	desc = "Vegan meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("tofu" = 3, "metal" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/kebab/tail
	name = "lizard tail kebab"
	desc = "Severed lizard tail on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("meat" = 8, "metal" = 4, "scales" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/kebab/rat
	name = "rat kebab"
	desc = "Not so delicious rat meat, on a stick."
	icon_state = "ratkebab"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("rat meat" = 1, "metal" = 1)
	foodtype = MICE

/obj/item/reagent_containers/food/snacks/kebab/rat/double
	name = "double rat kebab"
	icon_state = "doubleratkebab"
	tastes = list("rat meat" = 2, "metal" = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)

////////////////////////////////////////////FISH////////////////////////////////////////////

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
	foodtype = SEAFOOD

/obj/item/reagent_containers/food/snacks/carpmeat/Initialize()
	. = ..()
	eatverb = pick("bite","chew","gnaw","swallow","chomp")

/obj/item/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

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

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	filling_color = "#F0E68C"
	tastes = list("tofu" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/tofu/prison
	name = "soggy tofu"
	desc = "You refuse to eat this strange bean curd."
	tastes = list("sour, rotten water" = 1)
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin = 2)
	filling_color = "#000000"
	tastes = list("cobwebs" = 1)
	foodtype = MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/spiderleg/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/boiledspiderleg, rand(50 SECONDS, 60 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon_state = "cornedbeef"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("meat" = 1, "cabbage" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/bearsteak
	name = "filet migrawr"
	desc = "Because eating bear wasn't manly enough."
	icon_state = "bearsteak"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/ethanol/manly_dorf = 5)
	tastes = list("meat" = 1, "salmon" = 1)
	foodtype = MEAT | ALCOHOL

/obj/item/reagent_containers/food/snacks/raw_meatball
	name = "raw meatball"
	desc = "A great meal all round. Not a cord of wood. Kinda raw"
	icon_state = "raw_meatball"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/meatball_type = /obj/item/reagent_containers/food/snacks/meatball
	var/patty_type = /obj/item/reagent_containers/food/snacks/raw_patty

/obj/item/reagent_containers/food/snacks/raw_meatball/MakeGrillable()
	AddComponent(/datum/component/grillable, meatball_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/raw_meatball/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			if(!do_after(user, 1 SECONDS, src)) {
				return
			}
			new patty_type(loc)
			to_chat(user, span_notice("You flatten [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to roll it out!"))
	else
		..()

/obj/item/reagent_containers/food/snacks/raw_meatball/human
	name = "strange raw meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/human
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/human

/obj/item/reagent_containers/food/snacks/raw_meatball/corgi
	name = "raw corgi meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/corgi
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/corgi

/obj/item/reagent_containers/food/snacks/raw_meatball/xeno
	name = "raw xeno meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/xeno
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/xeno

/obj/item/reagent_containers/food/snacks/raw_meatball/bear
	name = "raw bear meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/bear
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/bear

/obj/item/reagent_containers/food/snacks/raw_meatball/chicken
	name = "raw chicken meatball"
	meatball_type = /obj/item/reagent_containers/food/snacks/meatball/chicken
	patty_type = /obj/item/reagent_containers/food/snacks/raw_patty/chicken

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	filling_color = "#800000"
	tastes = list("meat" = 1)
	foodtype = MEAT
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/meatball/human
	name = "strange meatball"

/obj/item/reagent_containers/food/snacks/meatball/corgi
	name = "corgi meatball"

/obj/item/reagent_containers/food/snacks/meatball/bear
	name = "bear meatball"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meatball/xeno
	name = "xenomorph meatball"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meatball/chicken
	name = "chicken meatball"
	tastes = list("chicken" = 1)
	icon_state = "chicken_meatball"

/obj/item/reagent_containers/food/snacks/raw_patty
	name = "raw patty"
	desc = "I'm.....NOT REAAADDYY."
	icon_state = "raw_patty"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/patty_type = /obj/item/reagent_containers/food/snacks/patty/plain

/obj/item/reagent_containers/food/snacks/raw_patty/MakeGrillable()
	AddComponent(/datum/component/grillable, patty_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/raw_patty/human
	name = "strange raw patty"
	patty_type = /obj/item/reagent_containers/food/snacks/patty/human

/obj/item/reagent_containers/food/snacks/raw_patty/corgi
	name = "raw corgi patty"
	patty_type = /obj/item/reagent_containers/food/snacks/patty/corgi

/obj/item/reagent_containers/food/snacks/raw_patty/bear
	name = "raw bear patty"
	tastes = list("meat" = 1, "salmon" = 1)
	patty_type = /obj/item/reagent_containers/food/snacks/patty/bear

/obj/item/reagent_containers/food/snacks/raw_patty/xeno
	name = "raw xenomorph patty"
	tastes = list("meat" = 1,"acid" = 1)
	patty_type = /obj/item/reagent_containers/food/snacks/patty/xeno

/obj/item/reagent_containers/food/snacks/raw_patty/chicken
	name = "raw chicken patty"
	tastes = list("chicken" = 1)
	patty_type = /obj/item/reagent_containers/food/snacks/patty/chicken

/obj/item/reagent_containers/food/snacks/patty
	name = "patty"
	desc = "The nanotrasen patty is the patty for you and me!"
	icon_state = "patty"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

///Exists purely for the crafting recipe (because itll take subtypes)
/obj/item/reagent_containers/food/snacks/patty/plain

/obj/item/reagent_containers/food/snacks/patty/human
	name = "strange patty"

/obj/item/reagent_containers/food/snacks/patty/corgi
	name = "corgi patty"

/obj/item/reagent_containers/food/snacks/patty/bear
	name = "bear patty"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/patty/xeno
	name = "xenomorph patty"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/patty/chicken
	name = "chicken patty"
	tastes = list("chicken" = 1)
	icon_state = "chicken_patty"

/obj/item/reagent_containers/food/snacks/raw_sausage
	name = "raw sausage"
	desc = "A piece of mixed, long meat, but then raw"
	icon_state = "raw_sausage"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/raw_sausage/Initialize()
	. = ..()
	eatverb = pick("bite","chew","nibble","gobble","chomp")

/obj/item/reagent_containers/food/snacks/raw_sausage/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/sausage, rand(60 SECONDS, 75 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#CD5C5C"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("meat" = 1)
	foodtype = MEAT | BREAKFAST
	var/roasted = FALSE
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/sausage/Initialize()
	. = ..()
	eatverb = pick("bite","chew","nibble","gobble","chomp")

/obj/item/reagent_containers/food/snacks/sausage/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/knife))
		if(!do_after(user, 1 SECONDS, src)) {
			return
		}
		new /obj/item/reagent_containers/food/snacks/sausage/american(loc)
		to_chat(user, span_notice("You snip [src]."))
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/sausage/american
	name = "american sausage"
	desc = "Snip."
	icon_state = "american_sausage"

/obj/item/reagent_containers/food/snacks/rawkhinkali
	name = "raw khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/garlic = 1)
	tastes = list("meat" = 1, "onions" = 1, "garlic" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/rawkhinkali/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/khinkali, rand(50 SECONDS, 60 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/khinkali
	name = "khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/garlic = 1)
	bitesize = 3
	filling_color = "#F0F0F0"
	tastes = list("meat" = 1, "onions" = 1, "garlic" = 1)
	foodtype = MEAT
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	bitesize = 4
	filling_color = "#FFA07A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/capsaicin = 6)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/chipsandsalsa
	name = "chips and salsa"
	desc = "A handful of tortilla chips, paired with a cup of zesty salsa. Highly addictive!"
	icon_state = "chipsandsalsa"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("peppers" = 1, "salsa" = 3, "tortilla chips" = 1, "onion" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soymeat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	filling_color = "#D2691E"
	tastes = list("soy" = 1, "vegetables" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/stewedsoymeat/Initialize()
	. = ..()
	eatverb = pick("slurp","sip","inhale","drink")

/obj/item/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/capsaicin = 2)
	filling_color = "#000000"
	tastes = list("hot peppers" = 1, "cobwebs" = 1)
	foodtype = MEAT
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/nugget
	name = "chicken nugget"
	filling_color = "#B22222"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("\"chicken\"" = 1)
	foodtype = MEAT
	var/mob/living/nugget_man

/obj/item/reagent_containers/food/snacks/nugget/Initialize()
	. = ..()
	var/shape = pick("lump", "star", "lizard", "corgi")
	desc = "A 'chicken' nugget vaguely shaped like a [shape]."
	icon_state = "nugget_[shape]"

/obj/item/reagent_containers/food/snacks/nugget/Destroy()
	if(nugget_man)
		qdel(nugget_man)
	. = ..()

/obj/item/reagent_containers/food/snacks/pigblanket
	name = "pig in a blanket"
	desc = "A tiny sausage wrapped in a flakey, buttery roll. Free this pig from its blanket prison by eating it."
	icon_state = "pigblanket"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#800000"
	tastes = list("meat" = 1, "butter" = 1)

/obj/item/reagent_containers/food/snacks/dolphinmeat
  name = "dolphin fillet"
  desc = "A fillet of spess dolphin meat."
  icon_state = "fishfillet"
  list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
  bitesize = 6
  filling_color = "#FA8072"
  tastes = list("fish" = 1,"cruelty" = 2)
  foodtype = MEAT

/obj/item/reagent_containers/food/snacks/dolphinmeat/Initialize()
  . = ..()
  eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")

/obj/item/reagent_containers/food/snacks/meatclown
	name = "meat clown"
	desc = "A delicious, round piece of meat clown. How horrifying."
	icon_state = "meatclown"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/banana = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("meat" = 5, "clowns" = 3, "sixteen teslas" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meatclown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 30)

////////////////////////////////////////////ANIMAL CUBES////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	list_reagents = list(/datum/reagent/monkey_powder = 30)
	filling_color = "#CD853F"
	tastes = list("the jungle" = 1, "bananas" = 1)
	foodtype = MEAT | SUGAR
	var/faction
	var/spawned_mob = /mob/living/carbon/monkey

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	var/mob/spammer = get_mob_by_key(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location(), TRUE, spammer)
	if(faction)
		bananas.faction = faction
	if (!QDELETED(bananas))
		visible_message(span_notice("[src] expands!"))
		bananas.log_message("Spawned via [src] at [AREACOORD(src)], Last attached mob: [key_name(spammer)].", LOG_ATTACK)
	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message(span_notice("[src] fails to expand!"))
	qdel(src)

/obj/item/reagent_containers/food/snacks/monkeycube/suicide_act(mob/living/M)
	M.visible_message(span_suicide("[M] is putting [src] in [M.p_their()] mouth! It looks like [M.p_theyre()] trying to commit suicide!"))
	var/eating_success = do_after(M, 1 SECONDS, src)
	if(QDELETED(M)) //qdeletion: the nuclear option of self-harm
		return SHAME
	if(!eating_success || QDELETED(src)) //checks if src is gone or if they failed to wait for a second
		M.visible_message(span_suicide("[M] chickens out!"))
		return SHAME
	if(HAS_TRAIT(M, TRAIT_NOHUNGER)) //plasmamen don't have saliva/stomach acid
		M.visible_message(span_suicide("[M] realizes [M.p_their()] body won't activate [src]!")
		,span_warning("Your body won't activate [src]..."))
		return SHAME
	playsound(M, 'sound/items/eatfood.ogg', rand(10,50), TRUE)
	M.temporarilyRemoveItemFromInventory(src) //removes from hands, keeps in M
	addtimer(CALLBACK(src, .proc/finish_suicide, M), 15) //you've eaten it, you can run now
	return MANUAL_SUICIDE

/obj/item/reagent_containers/food/snacks/monkeycube/proc/finish_suicide(mob/living/M) ///internal proc called by a monkeycube's suicide_act using a timer and callback. takes as argument the mob/living who activated the suicide
	if(QDELETED(M) || QDELETED(src))
		return
	if((src.loc != M)) //how the hell did you manage this
		to_chat(M, span_warning("Something happened to [src]..."))
		return
	Expand()
	M.visible_message(span_danger("[M]'s torso bursts open as a primate emerges!"))
	M.gib(null, TRUE, null, TRUE)

/obj/item/reagent_containers/food/snacks/monkeycube/syndicate
	faction = list("neutral", ROLE_SYNDICATE)

/obj/item/reagent_containers/food/snacks/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Co. brand gorilla cube. Now with extra molecules! Just add water!"
	bitesize = 20
	list_reagents = list(/datum/reagent/gorilla_powder = 30, /datum/reagent/medicine/strange_reagent = 5)
	tastes = list("the jungle" = 1, "bananas" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/gorilla

/obj/item/reagent_containers/food/snacks/monkeycube/sheep
	name = "sheep cube"
	desc = "A Farm Town brand sheep cube. Just add water!"
	bitesize = 15
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("fluff" = 1, "the farm" = 1)
	spawned_mob = /mob/living/simple_animal/sheep

/obj/item/reagent_containers/food/snacks/monkeycube/cow
	name = "cow cube"
	desc = "A Farm Town brand cow cube. Just add water!"
	bitesize = 18
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("milk" = 1, "the farm" = 1)
	spawned_mob = /mob/living/simple_animal/cow

/obj/item/reagent_containers/food/snacks/monkeycube/goat
	name = "goat cube"
	desc = "A Goat Tech Industries goat cube. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "goatcube"
	bitesize = 20
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("fur" = 1, "blood" = 1, "rage" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/retaliate/goat
