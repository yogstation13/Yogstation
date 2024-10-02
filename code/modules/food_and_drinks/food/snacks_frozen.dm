
/////////////////
//Misc. Frozen.//
/////////////////

/obj/item/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in its own packaging."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "icecreamsandwich"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/ice = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/ice = 2)
	tastes = list("ice cream" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/spacefreezy
	name = "space freezy"
	desc = "The best icecream in space."
	icon_state = "spacefreezy"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/bluecherryjelly = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#87CEFA"
	tastes = list("blue cherries" = 2, "ice cream" = 2)
	foodtype = FRUIT | DAIRY

/obj/item/reagent_containers/food/snacks/sundae
	name = "sundae"
	desc = "A classic dessert."
	icon_state = "sundae"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	filling_color = "#FFFACD"
	tastes = list("ice cream" = 1, "banana" = 1)
	foodtype = FRUIT | DAIRY | SUGAR

/obj/item/reagent_containers/food/snacks/honkdae
	name = "honkdae"
	desc = "The clown's favorite dessert."
	icon_state = "honkdae"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#FFFACD"
	tastes = list("ice cream" = 1, "banana" = 1, "a bad joke" = 1)
	foodtype = FRUIT | DAIRY | SUGAR


/////////////
//ICE CREAM//
/////////////

/obj/item/reagent_containers/food/snacks/ice_cream_scoop
	name = "plain ice cream scoop"
	desc = "Also known as sweet cream; it still makes for a tasty treat."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_plain"
	//10u for ice cream chem, 5u for anything injected
	volume = 15
	bonus_reagents = list(/datum/reagent/consumable/ice_cream = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream = 10)
	filling_color = "#EDF7DF"
	tastes = list("ice cream" = 1)
	foodtype = SUGAR

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/vanilla
	name = "vanilla ice cream scoop"
	desc = "The most commonly known ice cream flavor; it has bean and still is widely popular."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vanilla"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/vanilla = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/vanilla = 10)
	filling_color = "#ECE2C5"
	tastes = list("ice cream" = 1, "vanilla" = 1)
	foodtype = SUGAR

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/chocolate
	name = "chocolate ice cream scoop"
	desc = "Ice cream mixed with natural cocoa; made for those who can't get enough chocolate."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_chocolate"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/chocolate = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/chocolate = 10)
	filling_color = "#865C32"
	tastes = list("ice cream" = 1, "chocolate" = 1)
	foodtype = SUGAR | CHOCOLATE

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/strawberry
	name = "strawberry ice cream scoop"
	desc = "Ice cream supposedly made with real strawberries."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_strawberry"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/strawberry = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/strawberry = 10)
	filling_color = "#EFB8B8"
	tastes = list("ice cream" = 1, "strawberries" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/blue
	name = "blue ice cream scoop"
	desc = "A faintly blue ice cream flavor; it is notorious for its ability to stain."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_blue"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/blue = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/blue = 10)
	filling_color = "#B8C5EF"
	tastes = list("ice cream" = 1, "blue" = 1)
	foodtype = SUGAR | ALCOHOL

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/lemon_sorbet
	name = "lemon sorbet scoop"
	desc = "An ancient frozen treat supposedly invented by the Persians that is still enjoyed today."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_lemon sorbet"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/lemon_sorbet = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/lemon_sorbet = 10)
	filling_color = "#D4DB86"
	tastes = list("ice cream" = 1, "lemons" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/caramel
	name = "caramel ice cream scoop"
	desc = "Ice cream that has been flavored with caramel; a treat for sugar lovers."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_caramel"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/caramel = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/caramel = 10)
	filling_color = "#BC762F"
	tastes = list("ice cream" = 1, "caramel" = 1)
	foodtype = SUGAR

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/banana
	name = "banana ice cream scoop"
	desc = "The ice cream of choice for clowns everywhere. Honk!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_banana"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/banana = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/banana = 10)
	filling_color = "#DEDE00"
	tastes = list("ice cream" = 1, "banana" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/orange_creamsicle
	name = "orange creamsicle scoop"
	desc = "An ice cream flavor made after a popular popsicle flavor. It is not quite the same off the stick..."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_orangesicle"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/orange_creamsicle = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/orange_creamsicle = 10)
	filling_color = "#D8B258"
	tastes = list("ice cream" = 1, "oranges" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/peach
	name = "peach ice cream scoop"
	desc = "Ice cream flavored with peaches; it is rather uncommon due to wizards buying up most of it."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_peach"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/peach = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/peach = 10)
	filling_color = "#CD8D68"
	tastes = list("ice cream" = 1, "peaches" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/cherry_chocolate
	name = "cherry chocolate ice cream scoop"
	desc = "A wonderfully tangy and sweet ice cream made with coco and cherries."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cherry chocolate"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/cherry_chocolate = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/cherry_chocolate = 10)
	filling_color = "#6F0000"
	tastes = list("ice cream" = 1, "cherries" = 1, "chocolate" = 1)
	foodtype = FRUIT | CHOCOLATE

/obj/item/reagent_containers/food/snacks/ice_cream_scoop/meat
	name = "meat lover's ice cream scoop"
	desc = "Ice cream flavored with meat, because someone wanted meat in their ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_mob"
	bonus_reagents = list(/datum/reagent/consumable/ice_cream/meat = 2)
	list_reagents = list(/datum/reagent/consumable/ice_cream/meat = 10)
	filling_color = "#BD0000"
	tastes = list("ice cream" = 1, "blood" = 1)
	foodtype = MICE

/////////////
//SNOWCONES//
/////////////

/obj/item/reagent_containers/food/snacks/snowcones //We use this as a base for all other snowcones
	name = "flavorless snowcone"
	desc = "It's just shaved ice. Still fun to chew on."
	icon = 'icons/obj/food/snowcones.dmi'
	icon_state = "flavorless_sc"
	trash = /obj/item/reagent_containers/food/drinks/sillycup //We dont eat paper cups
	bonus_reagents = list(/datum/reagent/water = 10) //Base line will always give water
	list_reagents = list(/datum/reagent/water = 1) // We dont get food for water/juices
	filling_color = "#FFFFFF" //Ice is white
	tastes = list("ice" = 1, "water" = 1)
	foodtype = SUGAR //We use SUGAR as a base line to act in as junkfood, otherwise we use fruit

/obj/item/reagent_containers/food/snacks/snowcones/lime
	name = "lime snowcone"
	desc = "Lime syrup drizzled over a snowball in a paper cup."
	icon_state = "lime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/limejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "limes" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/lemon
	name = "lemon snowcone"
	desc = "Lemon syrup drizzled over a snowball in a paper cup."
	icon_state = "lemon_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5)
	tastes = list("ice" = 1, "water" = 1, "lemons" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/apple
	name = "apple snowcone"
	desc = "Apple syrup drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/applejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "apples" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/grape
	name = "grape snowcone"
	desc = "Grape syrup drizzled over a snowball in a paper cup."
	icon_state = "grape_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/grapejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "grape" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/orange
	name = "orange snowcone"
	desc = "Orange syrup drizzled over a snowball in a paper cup."
	icon_state = "orange_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/orangejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "orange" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/blue
	name = "bluecherry snowcone"
	desc = "Bluecherry syrup drizzled over a snowball in a paper cup, how rare!"
	icon_state = "blue_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/bluecherryjelly = 5)
	tastes = list("ice" = 1, "water" = 1, "cherries" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/red
	name = "cherry snowcone"
	desc = "Cherry syrup drizzled over a snowball in a paper cup."
	icon_state = "red_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 5)
	tastes = list("ice" = 1, "water" = 1, "cherries" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/berry
	name = "mixed berry snowcone"
	desc = "Berry syrup drizzled over a snowball in a paper cup."
	icon_state = "berry_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/berryjuice = 5)
	tastes = list("ice" = 1, "water" = 1, "berries" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/fruitsalad
	name = "fruit salad snowcone"
	desc = "A delightful mix of citrus syrups drizzled over a snowball in a paper cup."
	icon_state = "fruitsalad_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/limejuice = 5, /datum/reagent/consumable/orangejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "oranges" = 5, "limes" = 5, "lemons" = 5, "citrus" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/pineapple
	name = "pineapple snowcone"
	desc = "Pineapple syrup drizzled over a snowball in a paper cup."
	icon_state = "pineapple_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/pineapplejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "pineapples" = 5)
	foodtype = FRUIT | PINEAPPLE //Pineapple to allow all that like pineapple to enjoy

/obj/item/reagent_containers/food/snacks/snowcones/mime
	name = "mime snowcone"
	desc = "..."
	icon_state = "mime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nothing = 5)
	tastes = list("ice" = 1, "water" = 1, "nothing" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/clown
	name = "clown snowcone"
	desc = "Laughter drizzled over a snowball in a paper cup."
	icon_state = "clown_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/laughter = 1)
	tastes = list("ice" = 1, "water" = 1, "jokes" = 5, "brainfreeze" = 5, "joy" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/soda
	name = "space cola snowcone"
	desc = "Space Cola drizzled over a snowball in a paper cup."
	icon_state = "soda_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/space_cola = 5)
	tastes = list("ice" = 1, "water" = 1, "cola" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/spacemountainwind
	name = "Space Mountain Wind snowcone"
	desc = "Space Mountain Wind drizzled over a snowball in a paper cup."
	icon_state = "mountainwind_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/space_cola/spacemountainwind = 5)
	tastes = list("ice" = 1, "water" = 1, "mountain wind" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/pwrgame
	name = "pwrgame snowcone"
	desc = "Pwrgame soda drizzled over a snowball in a paper cup."
	icon_state = "pwrgame_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/pwr_game = 5)
	tastes = list("ice" = 1, "water" = 1, "vaild" = 5, "salt" = 5, "wats" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/honey
	name = "honey snowcone"
	desc = "Honey drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/honey = 5)
	tastes = list("ice" = 1, "water" = 1, "sweetness" = 5, "wax" = 1)

/obj/item/reagent_containers/food/snacks/snowcones/rainbow
	name = "rainbow snowcone"
	desc = "A very colorful snowball in a paper cup."
	icon_state = "rainbow_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/laughter = 25)
	tastes = list("ice" = 1, "water" = 1, "sunlight" = 5, "light" = 5, "slime" = 5, "paint" = 3, "clouds" = 3)

/obj/item/reagent_containers/food/snacks/taiyaki
	name = "vanilla taiyaki"
	desc = "A vanilla flavored ice cream treat with a rolled cookie and cherry, in a whimsical fish shaped cone."
	icon_state = "deluxe_taiyaki_vanilla"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/cream = 2)
	tastes = list("ice cream" = 1, "cherry" = 1, "cookie" = 1, "vanilla" = 1)
	foodtype = DAIRY | SUGAR | FRUIT

/obj/item/reagent_containers/food/snacks/taiyaki/chocolate
	name = "chocolate taiyaki"
	desc = "A chocolate flavored ice cream treat with a rolled cookie and cherry, in a whimsical fish shaped cone."
	icon_state = "deluxe_taiyaki_chocolate"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/cream = 2,  /datum/reagent/consumable/coco = 2)
	tastes = list("ice cream" = 1, "cherry" = 1, "cookie" = 1, "chocolate" = 1)
	foodtype = FRUIT | DAIRY | SUGAR | CHOCOLATE | FRUIT

/obj/item/reagent_containers/food/snacks/taiyaki/strawberry
	name = "strawberry taiyaki"
	desc = "A strawberry flavored ice cream treat with a rolled cookie and a blue cherry, in a whimsical fish shaped cone."
	icon_state = "deluxe_taiyaki_strawberry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/berryjuice = 2)
	tastes = list("ice cream" = 1, "blue cherry" = 1, "cookie" = 1, "strawberry" = 1)
	foodtype = FRUIT | DAIRY | SUGAR | FRUIT

/obj/item/reagent_containers/food/snacks/taiyaki/blue
	name = "blue taiyaki"
	desc = "A...blue...flavored ice cream treat with a rolled cookie and cherry, in a whimsical fish shaped cone."
	icon_state = "deluxe_taiyaki_blue"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/ethanol/singulo = 2)
	tastes = list("ice cream" = 1, "cherry" = 1, "cookie" = 1, "blue" = 1)
	foodtype = ALCOHOL | DAIRY | SUGAR | FRUIT

/obj/item/reagent_containers/food/snacks/taiyaki/mobflavor
	name = "red taiyaki"
	desc = "A...red...flavored ice cream treat with a rolled cookie and a blue cherry, in a whimsical fish shaped cone. You're pretty sure that's not strawberry?"
	icon_state = "deluxe_taiyaki_strawberry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/cream = 2, /datum/reagent/blood = 1)
	tastes = list("ice cream" = 1, "blue cherry" = 1, "cookie" = 1, "blood" = 1)
	foodtype = DAIRY | SUGAR | MICE | FRUIT
