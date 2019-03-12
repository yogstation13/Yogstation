/obj/item/storage/box/mre
	name = "Nanotrasen MRE Ration Kit (Dehydrated bread with tomato ketchup and cheesy spread, meat steak type 1, chocolate bar)"
	desc = "A package containing food suspended in a bluespace pocket which lasts for centuries, if you're lucky you may even find the legendary MRE 2349 Menu 3 Pepperoni Pizza Slice MRE with coffee instant type 2 in it!"
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "mre"
	item_state = "box"
	var/expiry_date = 2401 //Randomized with each MRE, collect them all!

/obj/item/storage/box/mre/examine(mob/user)
	. = ..()
	to_chat(user, "<span_clas='notice'>An expiry date is listed on it. It reads: [expiry_date]</span>")

/obj/item/storage/box/mre/Initialize()
	. = ..()
	expiry_date = rand(2300, 2700)

/obj/item/storage/box/mre/menu2
	name = "Nanotrasen MRE Ration Kit (Vegetable omelette, chips, meat cutlet type 2, chocolate bar)"
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "mre"
	item_state = "box"

/obj/item/storage/box/mre/menu3
	name = "Nanotrasen MRE Ration Kit (2349 Menu 3: pepperoni pizza and Italian breadsticks with cheesy jalapeno spread.)"
	desc = "The holy grail of MREs. This item contains the fabled MRE pizza and a sample of coffee instant type 2. Any NT employee lucky enough to get their hands on one of these is truly blessed."
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "menu3"
	item_state = "box"

/obj/item/storage/box/mre/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/breadslice/plain(src)
	new /obj/item/reagent_containers/food/snacks/breadslice/creamcheese(src)
	new /obj/item/reagent_containers/food/condiment/pack/ketchup(src)
	new /obj/item/reagent_containers/food/snacks/chocolatebar(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

/obj/item/storage/box/mre/menu2/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/omelette(src)
	new /obj/item/reagent_containers/food/snacks/meat/cutlet/plain(src)
	new /obj/item/reagent_containers/food/snacks/fries(src)
	new /obj/item/reagent_containers/food/snacks/chocolatebar(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

/obj/item/storage/box/mre/menu3/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/pizzaslice/meat(src)
	new /obj/item/reagent_containers/food/snacks/breadslice/plain(src)
	new /obj/item/reagent_containers/food/snacks/cheesewedge(src)
	new /obj/item/reagent_containers/food/snacks/grown/chili(src)
	new /obj/item/reagent_containers/food/drinks/coffee(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

/datum/supply_pack/organic/mre
	name = "MRE supply kit (emergency rations)"
	desc = "The lights are out. Oxygen's running low. You've run out of food except space weevils. Don't let this be you! Order our NT branded MRE kits today! This pack contains 5 MRE packs with a randomized menu and an oxygen tank."
	cost = 2000 // Best prices this side of the galaxy.
	contains = list(/obj/item/storage/box/mre,
					/obj/item/storage/box/mre,
					/obj/item/storage/box/mre/menu2,
					/obj/item/storage/box/mre/menu2,
					/obj/item/storage/box/mre/menu3)
	crate_name = "MRE crate (emergency rations)"