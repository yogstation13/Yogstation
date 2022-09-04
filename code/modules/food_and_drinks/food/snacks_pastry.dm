//Pastry is a food that is made from dough which is made from wheat or rye flour.
//This file contains pastries that don't fit any existing categories.
////////////////////////////////////////////DONUTS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with robust coffee."
	icon_state = "donut1"
	bitesize = 5
	bonus_reagents = list(/datum/reagent/consumable/sugar = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/sugar = 2)
	filling_color = "#D2691E"
	tastes = list("donut" = 1)
	foodtype = JUNKFOOD | GRAIN | FRIED | SUGAR | BREAKFAST
	var/frosted_icon = "donut2"
	var/is_frosted = FALSE
	var/extra_reagent = null

/obj/item/reagent_containers/food/snacks/donut/Initialize()
	. = ..()
	if(prob(30))
		frost_donut()

/obj/item/reagent_containers/food/snacks/donut/proc/frost_donut()
	if(is_frosted || !frosted_icon)
		return
	is_frosted = TRUE
	name = "frosted [name]"
	icon_state = frosted_icon //delish!
	reagents.add_reagent(/datum/reagent/consumable/sprinkles, 1)
	filling_color = "#FF69B4"
	return TRUE

/obj/item/reagent_containers/food/snacks/donut/checkLiked(fraction, mob/M)	//Sec officers always love donuts
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(HAS_TRAIT(H.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM) && !HAS_TRAIT(H, TRAIT_AGEUSIA))
				to_chat(H,span_notice("I love this taste!"))
				H.adjust_disgust(-5 + -2.5 * fraction)
				var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
				if(mood)
					mood.add_event(null, "fav_food", /datum/mood_event/favorite_food)
				last_check_time = world.time
				return
	..()

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut3"
	bitesize = 10
	tastes = list("donut" = 3, "chaos" = 1)

/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize()
	. = ..()
	extra_reagent = pick(/datum/reagent/consumable/nutriment, /datum/reagent/consumable/capsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/drug/krokodil, /datum/reagent/toxin/plasma, /datum/reagent/consumable/coco, /datum/reagent/toxin/slimejelly, /datum/reagent/consumable/banana, /datum/reagent/consumable/berryjuice, /datum/reagent/medicine/omnizine)
	reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/food/snacks/donut/laugh
	name = "sweet pea donut"
	desc = "Goes great with a glass of Bastion Burbon!"
	icon_state = "donut_laugh"
	bonus_reagents = list(/datum/reagent/consumable/laughter = 3)
	tastes = list("donut" = 3, "fizzy tutti frutti" = 1,)
	filling_color = "#803280"

/obj/item/reagent_containers/food/snacks/donut/deadly
	desc = "Goes great with Doctor's Delight."
	volume = 1000
	bitesize = 1000
	list_reagents = list(/datum/reagent/consumable/nutriment = 950, /datum/reagent/consumable/sugar = 50,)
	tastes = list("countless donuts" = 2, "sugar" = 2)
	foodtype = SUGAR | FRIED | GRAIN

/obj/item/reagent_containers/food/snacks/donut/deadly/On_Consume(mob/living/eater)
	. = ..()
	to_chat(eater, span_notice("You couldn't stop yourself... It was so delicious..."))
	eater.set_nutrition(1000)

/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	frosted_icon = "jdonut2"
	bonus_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	extra_reagent = /datum/reagent/consumable/berryjuice
	tastes = list("jelly" = 1, "donut" = 3)
	foodtype = JUNKFOOD | GRAIN | FRIED | FRUIT | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize()
	. = ..()
	if(extra_reagent)
		reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = /datum/reagent/toxin/slimejelly
	foodtype = JUNKFOOD | GRAIN | FRIED | TOXIC | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = /datum/reagent/consumable/cherryjelly
	foodtype = JUNKFOOD | GRAIN | FRIED | FRUIT | BREAKFAST

/obj/item/reagent_containers/food/snacks/donut/jelly/laugh
	name = "sweet pea jelly donut"
	desc = "Goes great with a glass of Bastion Burbon!"
	icon_state = "jelly_laugh"
	bonus_reagents = list(/datum/reagent/consumable/laughter = 3)
	tastes = list("jelly" = 3, "donut" = 1, "fizzy tutti frutti" = 1)
	filling_color = "#803280"

/obj/item/reagent_containers/food/snacks/donut/meat
	name = "meat donut"
	desc = "Tastes as gross as it looks."
	icon_state = "donut4"
	bonus_reagents = list(/datum/reagent/consumable/ketchup = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/ketchup = 2)
	tastes = list("meat" = 1)
	foodtype = JUNKFOOD | MEAT | GROSS | FRIED | BREAKFAST

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/laugh
	name = "sweet pea jelly donut"
	desc = "Goes great with a glass of Bastion Burbon!"
	icon_state = "jelly_laugh"
	bonus_reagents = list(/datum/reagent/consumable/laughter = 3)
	tastes = list("jelly" = 3, "donut" = 1, "fizzy tutti frutti" = 1)
	filling_color = "#803280"

/obj/item/reagent_containers/food/snacks/donut/spaghetti
	name = "Spagh-o-nut"
	desc = "An unholy mixture of carbs. It's a donut made out of spaghetti."
	icon_state = "donut_spaghetti"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("Spaghetti"= 3, "Carbs" = 2, "Bewilderment" = 1)

/obj/item/reagent_containers/food/snacks/donut/spaghetti/jelly
	name = "'Jelly' Spagh-o-nut"
	desc = "A Spaghetti Donut stuffed with ketchup."
	icon_state = "jdonut_spaghetti"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/ketchup = 2)
	tastes = list("Spaghetti"= 3, "Carbs" = 2, "Ketchup" = 1)

////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	filling_color = "#F4A460"
	tastes = list("muffin" = 1)
	foodtype = GRAIN | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	desc = "A delicious and spongy little cake with berries."
	icon_state = "berrymuffin"
	tastes = list("muffin" = 3, "berry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"
	icon_state = "berrymuffin"
	alpha = 125
	tastes = list("muffin" = 3, "spookiness" = 1)
	foodtype = GRAIN | FRUIT | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	filling_color = "#FFE4E1"
	tastes = list("custard" = 1)
	foodtype = GRAIN | MEAT | VEGETABLES

////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#D2691E"
	tastes = list("waffles" = 1)
	foodtype = GRAIN | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#9ACD32"
	tastes = list("waffles" = 7, "people" = 1)
	foodtype = GRAIN | GROSS | MEAT

/obj/item/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#9ACD32"
	tastes = list("waffles" = 7, "the colour green" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	bitesize = 4
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/drug/mushroomhallucinogen = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	filling_color = "#00BFFF"
	tastes = list("waffle" = 1, "mushrooms" = 1)
	foodtype = GRAIN | VEGETABLES | TOXIC | SUGAR | BREAKFAST

////////////////////////////////////////////DONKPOCKETS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	bitesize = 1
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	filling_color = "#F0E68C"
	tastes = list("cookie" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "donkpocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	filling_color = "#CD853F"
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtype = GRAIN | MEAT

//donk pockets cook quick... try not to burn them for using an unoptimal tool
/obj/item/reagent_containers/food/snacks/donkpocket/MakeBakeable()
	AddComponent(/datum/component/bakeable, cooked_type, rand(25 SECONDS, 30 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/donkpocket/warm
	name = "warm donkpocket"
	desc = "The heated food of choice for the seasoned traitor."
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 3)
	cooked_type = null
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtype = GRAIN | MEAT

///Override for fast-burning food
/obj/item/reagent_containers/food/snacks/donkpocket/warm/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/badrecipe, rand(10 SECONDS, 15 SECONDS), FALSE)

/obj/item/reagent_containers/food/snacks/donkpocket/dank
	name = "dankpocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	list_reagents = list(/datum/reagent/drug/space_drugs = 1, /datum/reagent/consumable/nutriment = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/dank
	filling_color = "#00FF00"
	tastes = list("grass" = 2, "dough" = 2)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/donkpocket/warm/dank
	name = "warm dankpocket"
	desc = "The food of choice for the seasoned botanist. Smells danker now."
	icon_state = "dankpocket"
	list_reagents = list(/datum/reagent/toxin/lipolicide = 3, /datum/reagent/drug/space_drugs = 3, /datum/reagent/consumable/nutriment = 4)
	tastes = list("grass" = 2, "dough" = 2, "drugs" = 2)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/donkpocket/spicy
	name = "spicy donkpocket"
	desc = "The classic snack food, now with a heat-activated spicy flair."
	icon_state = "donkpocketspicy"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/capsaicin = 2)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/spicy
	filling_color = "#CD853F"
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/warm/spicy
	name = "warm spicy donkpocket"
	desc = "The classic snack food, now maybe a bit too spicy."
	icon_state = "donkpocketspicy"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/capsaicin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/capsaicin = 2)
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/meaty
	name = "meatpocket"
	desc = "Can this really be called a donkpocket? You should...probably cook this."
	icon_state = "donkpocketmeaty"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/meaty
	filling_color = "#CD853F"
	tastes = list("raw meat" = 4)
	foodtype = MICE

/obj/item/reagent_containers/food/snacks/donkpocket/warm/meaty
	name = "warm meatpocket"
	desc = "Can this really be called a donkpocket?"
	icon_state = "donkpocketcookedmeaty"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/drippings = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/drippings = 2)
	tastes = list("meat" = 4)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/teriyaki
	name = "teriyaki donkpocket"
	desc = "An east-asian take on the classic stationside snack."
	icon_state = "donkpocketteriyaki"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/soysauce = 2)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/teriyaki
	filling_color = "#CD853F"
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/warm/teriyaki
	name = "warm teriyaki donkpocket"
	desc = "An east-asian take on the classic stationside snack, now steamy and warm."
	icon_state = "donkpocketteriyaki"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/soysauce = 2)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/pizza
	name = "pizza donkpocket"
	desc = "Delicious, cheesy and surprisingly filling."
	icon_state = "donkpocketpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/tomatojuice = 2)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/pizza
	filling_color = "#CD853F"
	tastes = list("tomato sauce" = 2, "dough" = 2, "cheese"= 2)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/donkpocket/warm/pizza
	name = "warm pizza donkpocket"
	desc = "Delicious, cheesy, and even better when hot."
	icon_state = "donkpocketpizza"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/tomatojuice = 2)
	tastes = list("tomato sauce" = 2, "dough" = 2, "melty cheese"= 2)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/donkpocket/honk
	name = "honkpocket"
	desc = "The award-winning donk-pocket that won the hearts of clowns and humans alike."
	icon_state = "donkpocketbanana"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/honk
	filling_color = "#ffd51c"
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/donkpocket/warm/honk
	name = "warm honkpocket"
	desc = "The award-winning donk-pocket, now warm and toasty."
	icon_state = "donkpocketbanana"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/laughter = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/banana = 4, /datum/reagent/consumable/laughter = 3)
	tastes = list("dough" = 2, "children's antibiotics" = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/donkpocket/berry
	name = "berry donkpocket"
	desc = "A relentlessly sweet donk-pocket first created for use in Operation Dessert Storm."
	icon_state = "donkpocketberry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/berryjuice = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/berry
	filling_color = "#CD853F"
	tastes = list("dough" = 2, "jam" = 2)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/donkpocket/warm/berry
	name = "warm berry donkpocket"
	desc = "A relentlessly sweet donk-pocket, now warm and delicious."
	icon_state = "donkpocketberry"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/consumable/berryjuice = 3)
	tastes = list("dough" = 2, "warm jam" = 2)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/donkpocket/gondola
	name = "gondola donkpocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least." //Only a monster would craft this.
	icon_state = "donkpocketgondola"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/tranquility = 5)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm/gondola
	filling_color = "#CD853F"
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/donkpocket/warm/gondola
	name = "warm gondola donkpocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least."
	icon_state = "donkpocketgondola"
	bonus_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/tranquility = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 1, /datum/reagent/tranquility = 5)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtype = GRAIN | MEAT

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/cookie/sleepy
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/chloralhydrate = 10)

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	filling_color = "#F4A460"
	tastes = list("cookie" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	filling_color = "#F0E68C"
	tastes = list("pretzel" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	filling_color = "#F0E68C"
	tastes = list("mushroom" = 1, "biscuit" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize()
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		bonus_reagents = list(/datum/reagent/medicine/omnizine = 5, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	. = ..()
	if(fey)
		reagents.add_reagent(/datum/reagent/medicine/omnizine, 5)

/obj/item/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker. Favorite of Poly."
	icon_state = "cracker"
	bitesize = 1
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	filling_color = "#F0E68C"
	tastes = list("cracker" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to eat."
	icon_state = "hotdog"
	bitesize = 3
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/ketchup = 3, /datum/reagent/consumable/nutriment/vitamin = 3)
	filling_color = "#8B0000"
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = GRAIN | MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be dog."
	icon_state = "meatbun"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	filling_color = "#8B0000"
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = GRAIN | MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/khachapuri
	name = "khachapuri"
	desc = "Bread with egg and cheese."
	icon_state = "khachapuri"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 2)
	filling_color = "#FFFF4D"
	tastes = list("bread" = 1, "egg" = 1, "cheese" = 1)
	foodtype = GRAIN | MEAT | DAIRY


/obj/item/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3)
	filling_color = "#CD853F"
	tastes = list("sweetness" = 1)
	foodtype = GRAIN | JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/chococornet
	name = "chocolate cornet"
	desc = "Which side's the head, the fat end or the thin end?"
	icon_state = "chococornet"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#FFE4C4"
	tastes = list("biscuit" = 3, "chocolate" = 1)
	foodtype = GRAIN | JUNKFOOD | CHOCOLATE

/obj/item/reagent_containers/food/snacks/oatmealcookie
	name = "oatmeal cookie"
	desc = "The best of both cookie and oats."
	icon_state = "oatmealcookie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#D2691E"
	tastes = list("cookie" = 2, "oat" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/raisincookie
	name = "raisin cookie"
	desc = "Why would you put raisins on a cookie?"
	icon_state = "raisincookie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#F0E68C"
	tastes = list("cookie" = 1, "raisins" = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/cherrycupcake
	name = "cherry cupcake"
	desc = "A sweet cupcake with cherry bits."
	icon_state = "cherrycupcake"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#F0E68C"
	tastes = list("cake" = 3, "cherry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/bluecherrycupcake
	name = "blue cherry cupcake"
	desc = "Blue cherries inside a delicious cupcake."
	icon_state = "bluecherrycupcake"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#F0E68C"
	tastes = list("cake" = 3, "blue cherry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/honeybun
	name = "honey bun"
	desc = "A sticky pastry bun glazed with honey."
	icon_state = "honeybun"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/honey = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/honey = 5)
	filling_color = "#F2CE91"
	tastes = list("pastry" = 1, "sweetness" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/jaffacake
	name = "jaffacake"
	desc = "A moreish jaffacke. Is it a cake or is it a biscuit? Who knows."
	icon_state = "jaffacake"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/coco = 1)
	filling_color = "#D9833E"
	tastes = list("orange" = 1, "cake" = 1)
	foodtype = GRAIN | SUGAR | FRUIT

#define PANCAKE_MAX_STACK 10

/obj/item/reagent_containers/food/snacks/pancakes
	name = "pancake"
	desc = "A fluffy pancake. The softer, superior relative of the waffle."
	icon_state = "pancakes_1"
	item_state = "pancakes"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#D2691E"
	tastes = list("pancakes" = 1)
	foodtype = GRAIN | SUGAR | BREAKFAST

/obj/item/reagent_containers/food/snacks/pancakes/blueberry
	name = "blueberry pancake"
	desc = "A fluffy and delicious blueberry pancake."
	icon_state = "bbpancakes_1"
	item_state = "bbpancakes"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pancakes" = 1, "blueberries" = 1)

/obj/item/reagent_containers/food/snacks/pancakes/chocolatechip
	name = "chocolate chip pancake"
	desc = "A fluffy and delicious chocolate chip pancake."
	icon_state = "ccpancakes_1"
	item_state = "ccpancakes"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	foodtype = GRAIN | SUGAR | BREAKFAST | CHOCOLATE
	tastes = list("pancakes" = 1, "chocolate" = 1)

/obj/item/reagent_containers/food/snacks/pancakes/cinnamon
	name = "cinnamon pancake"
	desc = "A fluffy and delicious cinnamon pancake."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "cinpancakes_1"
	item_state = "cinpancakes"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pancakes" = 1, "cinnamon" = 1)

/obj/item/reagent_containers/food/snacks/cinnamonroll
	name = "cinnamon roll"
	desc = "Too perfect for this world, too pure."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "cinnamonroll"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cinnamon = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/cinnamon = 5, /datum/reagent/consumable/sugar = 5)
	tastes = list("purity" = 1, "cinnamon" = 1)

/obj/item/reagent_containers/food/snacks/churro
	name = "churro"
	desc = "If you're having food troubles, I feel for you son. I got 99 churros 'cus the clown ate one."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "churro"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cinnamon = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/cinnamon = 5, /datum/reagent/consumable/sugar = 5)
	tastes = list("lost dreams" = 1, "cinnamon" = 1)

/obj/item/reagent_containers/food/snacks/pancakes/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/snacks/pancakes/update_icon()
	if(contents.len)
		name = "stack of pancakes"
	else
		name = initial(name)
	if(contents.len < LAZYLEN(overlays))
		overlays-=overlays[overlays.len]

/obj/item/reagent_containers/food/snacks/pancakes/examine(mob/user)
	var/ingredients_listed = ""
	var/pancakeCount = contents.len
	switch(pancakeCount)
		if(0)
			desc = initial(desc)
		if(1 to 2)
			desc = "A stack of fluffy pancakes."
		if(3 to 6)
			desc = "A fat stack of fluffy pancakes!"
		if(7 to 9)
			desc = "A grand tower of fluffy, delicious pancakes!"
		if(PANCAKE_MAX_STACK to INFINITY)
			desc = "A massive towering spire of fluffy, delicious pancakes. It looks like it could tumble over!"
	var/originalBites = bitecount
	if (pancakeCount)
		var/obj/item/reagent_containers/food/snacks/S = contents[pancakeCount]
		bitecount = S.bitecount
	. = ..()
	if (pancakeCount)
		for(var/obj/item/reagent_containers/food/snacks/pancakes/ING in contents)
			ingredients_listed += "[ING.name], "
		. += "It contains [contents.len?"[ingredients_listed]":"no ingredient, "]on top of a [initial(name)]."
	bitecount = originalBites

/obj/item/reagent_containers/food/snacks/pancakes/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/pancakes/))
		var/obj/item/reagent_containers/food/snacks/pancakes/P = I
		if((contents.len >= PANCAKE_MAX_STACK) || ((P.contents.len + contents.len) > PANCAKE_MAX_STACK) || (reagents.total_volume >= volume))
			to_chat(user, span_warning("You can't add that many pancakes to [src]!"))
		else
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, span_notice("You add the [I] to the [name]."))
			P.name = initial(P.name)
			contents += P
			update_overlays(P)
			if (P.contents.len)
				for(var/V in P.contents)
					P = V
					P.name = initial(P.name)
					contents += P
					update_overlays(P)
			P = I
			clearlist(P.contents)
		return
	else if(contents.len)
		var/obj/O = contents[contents.len]
		return O.attackby(I, user, params)
	..()

/obj/item/reagent_containers/food/snacks/pancakes/update_overlays(obj/item/reagent_containers/food/snacks/P)
	var/mutable_appearance/pancake = mutable_appearance(icon, "[P.item_state]_[rand(1,3)]")
	pancake.pixel_x = rand(-1,1)
	pancake.pixel_y = 3 * contents.len - 1
	add_overlay(pancake)
	update_icon()

/obj/item/reagent_containers/food/snacks/pancakes/attack(mob/M, mob/user, def_zone, stacked = TRUE)
	if(user.a_intent == INTENT_HARM || !contents.len || !stacked)
		return ..()
	var/obj/item/O = contents[contents.len]
	. = O.attack(M, user, def_zone, FALSE)
	update_icon()

#undef PANCAKE_MAX_STACK
