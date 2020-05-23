/obj/item/weapon/storage/byummie
	name = "borer yummies"
	desc = "These'll squeeze your brains out, and make your mind go poppin!"
	storage_slots = 4 // obviously nanotrasen brand
	icon_state = "byummie"
	w_class = 1
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/borer)

/obj/item/weapon/storage/byummie/New()
	..()
	var/obj/item/weapon/reagent_containers/food/snacks/borer/B
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
