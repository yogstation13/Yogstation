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
