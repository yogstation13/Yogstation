/*
	Everything relating to food containers:
	* Borer Yummie Bag
*/

/obj/item/storage/byummie
	name = "borer yummies"
	desc = "These'll squeeze your brains out, and make your mind go poppin'!"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "byummie"
	w_class = WEIGHT_CLASS_TINY
	custom_price = 20

/obj/item/storage/byummie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 4
	STR.max_w_class = WEIGHT_CLASS_TINY
	STR.set_holdable(list(
		/obj/item/reagent_containers/food/snacks/borer
		))

/obj/item/storage/byummie/New()
	..()
	var/obj/item/reagent_containers/food/snacks/borer/B
	for(var/i, i < 4, i++)
		B = new(src)
		B.icon_state = pick("redyum", "greenyum", "blueyum", "yellowyum")
		switch(B.icon_state)
			if("redyum")
				B.desc = "A cherry flavoured yummie! This'll do the trick!"
			if("blueyum")
				B.desc = "A squishy berry-flavoured yummie! This'll leave your mouth full!"
			if("greenyum")
				B.desc = "A green yummie! It's ... moving."
			if("yellowyum")
				B.desc = "A banana flavoured yummie! Packed with lots of flavour!"