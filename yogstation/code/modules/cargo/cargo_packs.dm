/datum/supply_pack/misc/miscclothing
	name = "Designer clothes"
	desc = "Contains a variety of overpriced sneakers and clothing items, show your brand loyalty like never before!"
	cost = 1000
	contains = list(/obj/item/clothing/shoes/yogs/trainers,
					/obj/item/clothing/shoes/yogs/trainers/red,
					/obj/item/clothing/shoes/yogs/trainers/zebra,
					/obj/item/clothing/shoes/yogs/trainers/darkbrown,
					/obj/item/clothing/shoes/yogs/trainers/black,
					/obj/item/clothing/shoes/yogs/trainers/white,
					/obj/item/clothing/shoes/yogs/trainers/white,
					/obj/item/clothing/suit/yogs/zebrasweat,
					/obj/item/clothing/suit/yogs/zebrasweat,
					/obj/item/clothing/suit/yogs/blackwhitesweat,
					/obj/item/clothing/suit/yogs/blackwhitesweat,
					/obj/item/clothing/shoes/yogs/trainers/white)
	crate_name = "Spring/Summer 2413(SS2413) clothes crate"

/datum/supply_pack/misc/sneakerprotector
	name = "Sneaker cleaning supplies"
	desc = "Contains a few cans of cleaning spray! Blast that blood off your clothes with ease!"
	cost = 1200
	contains = list(/obj/item/shoe_protector,
					/obj/item/shoe_protector,
					/obj/item/shoe_protector,
					/obj/item/shoe_protector,
					/obj/item/shoe_protector)
	crate_name = "Shoe cleaning supplies"

/datum/supply_pack/misc/ultrasneakerspray
	name = "Prototype sneaker cleaning spray"
	desc = "Contains a prototype can of cleaning spray dubbed: 'The portable washing machine' which has the potential to clean an infinite number of clothes. Never worry about clown blood on your uniform EVER AGAIN."
	cost = 3000
	contains = list(/obj/item/shoe_protector,
					/obj/item/shoe_protector/ultra)
	crate_name = "clearance level: AMBER 'cleaning spray' crate"

/datum/supply_pack/critter/chocobo
	name = "Chocobo Crate"
	desc = "A rideable, flightless bird that comes in a variety of colors."
	hidden = TRUE
	cost = 8000
	contains = list(/mob/living/simple_animal/chocobo)
	crate_name = "chocobo crate"

/datum/supply_pack/misc/sphere
	name = "Advanced Crates"
	desc = "Contains a Advanced Crate that defies all known cargo standards!"
	cost = 10000
	contains = list(/obj/structure/closet/crate/sphere)
	crate_name = "Advanced Crate Container"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/organic/cheeseculture
	name = "Cheese Culture Crate"
	desc = "Contains a variety of advanced cheese bacteria cultures."
	cost = 800
	contains = list(/obj/item/storage/box/cheese)
	crate_name = "cheese culture crate"
	
/datum/supply_pack/organic/randomized/cheesewheel
	name = "Cheese Wheel Crate"
	desc = "Contains 6 various cheese wheels, for stations that don't have a chef or work ethic."
	cost = 1000
	contains = list(/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/swiss,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/mozzarella,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/halloumi,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/goat,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/feta,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/brie,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/blue,
					/obj/item/reagent_containers/food/snacks/store/cheesewheel/american)
	crate_name = "cheese wheel crate"

/datum/supply_pack/organic/randomized/cheesewheel/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 6)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/critter/exoticgoat
	name = "Exotic Goat Crate"
	desc = "Contains a bunch of genetically altered goats from Goat Tech Industries. Try to collect them all!"
	cost = 3000
	contains = list(/obj/structure/closet/crate/critter/exoticgoats)
	crate_name = "Exotic Goat Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/costumes_toys/plushes
	name = "Plushie Crate"
	desc = "Plushies sold in this crate come from affiliated allies of Nanotrasen. Note: Remove Phushvar from Narplush if you want to keep both."
	cost = 2000
	contains = list(/obj/item/toy/plush/carpplushie,
					/obj/item/toy/plush/bubbleplush,
					/obj/item/toy/plush/plushvar,
					/obj/item/toy/plush/narplush,
					/obj/item/toy/plush/lizardplushie,
					/obj/item/toy/plush/snakeplushie,
					/obj/item/toy/plush/nukeplushie,
					/obj/item/toy/plush/goatplushie,
					/obj/item/toy/plush/realgoat,
					/obj/item/toy/plush/teddybear,
					/obj/item/toy/plush/stuffedmonkey,
					/obj/item/toy/plush/flowerbunch,
					/obj/item/toy/plush/inorixplushie,
					/obj/item/toy/plush/beeplushie,
					/obj/item/toy/plush/slimeplushie)
	crate_name = "plush crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/security/prisonclothes
	name = "Prison Jumpsuit Crate"
	desc = "A crate containing a five cheap looking orange jumpsuits."
	cost = 500
	contains = list(/obj/item/clothing/under/rank/prisoner,
					/obj/item/clothing/under/rank/prisoner,
					/obj/item/clothing/under/rank/prisoner,
					/obj/item/clothing/under/rank/prisoner,
					/obj/item/clothing/under/rank/prisoner,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange)
	crate_name = "prison crate"

/datum/supply_pack/misc/skub
	name = "Skub Crate"
	desc = "Contains skub, you skub."
	cost = 1000
	contains = list(/obj/item/skub,
					/obj/item/skub,
					/obj/item/skub,
					/obj/item/skub,
					/obj/item/skub)
	crate_name = "skub crate"

/datum/supply_pack/engine/am_jar
	name = "Antimatter Containment Jar Crate"
	desc = "Two Antimatter containment jars stuffed into a single crate."
	cost = 2000
	contains = list(/obj/item/am_containment,
					/obj/item/am_containment)
	crate_name = "antimatter jar crate"

/datum/supply_pack/engine/am_core
	name = "Antimatter Control Crate"
	desc = "The brains of the Antimatter engine, this device is sure to teach the station's powergrid the true meaning of real power."
	cost = 5000
	contains = list(/obj/machinery/power/am_control_unit)
	crate_name = "antimatter control crate"

/datum/supply_pack/engine/am_shielding
	name = "Antimatter Shielding Crate"
	desc = "Contains ten Antimatter shields, somehow crammed into a crate."
	cost = 2000
	contains = list(/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container) //10 shields: 3x3 containment and a core
	crate_name = "antimatter shielding crate"

/datum/supply_pack/emergency/syndicate
	name = "NULL_ENTRY"
	desc = "(#@&^$THIS PACKAGE CONTAINS 30TC WORTH OF SOME RANDOM SYNDICATE GEAR WE HAD LYING AROUND THE WAREHOUSE. GIVE EM HELL, OPERATIVE@&!*() "
	hidden = TRUE
	cost = 20000
	contains = list()
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals
	dangerous = TRUE

/datum/supply_pack/emergency/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(SSticker.mode)
	while(crate_value)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]
		if(!I.surplus_nullcrates || prob(100 - I.surplus_nullcrates))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)

/datum/supply_pack/misc/milliondollarhat
	name = "Half Off Million Dollar Hat"
	desc = "Contains a hat that defies both logic and fashion sense. Now half off!"
	cost = 500000
	contains = list(/obj/item/clothing/head/milliondollarhat)
	crate_name = "million dollar hat crate"
	crate_type = /obj/structure/closet/crate/large
