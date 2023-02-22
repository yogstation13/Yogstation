/obj/structure/closet/crate/wooden
	name = "wooden crate"
	desc = "Works just as well as a metal one."
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 6
	icon_state = "wooden"

/obj/structure/closet/crate/wooden/toy
	name = "toy box"
	desc = "It has the words \"Clown + Mime\" written underneath of it with marker."

/obj/structure/closet/crate/wooden/toy/PopulateContents()
	. = ..()
	new	/obj/item/megaphone/clown(src)
	new	/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter(src)
	new /obj/item/pneumatic_cannon/pie(src)
	new /obj/item/reagent_containers/food/snacks/pie/cream(src)
	new /obj/item/storage/crayons(src)
	new /obj/item/bikehorn/rubber_pigeon(src) //yogs a single rubber pigeon

/obj/structure/closet/crate/wooden/ashwalker
	name = "tribal clothing box"
	desc = "An wooden box covered in ash, contains clothing used by an ashwalker tribe."

/obj/structure/closet/crate/wooden/ashwalker/PopulateContents()
	. = ..()
	new	/obj/item/clothing/under/chestwrap(src)
	new	/obj/item/clothing/under/chestwrap(src)
	new	/obj/item/clothing/under/ash_robe(src)
	new /obj/item/clothing/under/ash_robe(src)
	new /obj/item/clothing/under/ash_robe(src)
	new /obj/item/clothing/under/ash_robe/young(src)
	new /obj/item/clothing/under/ash_robe/young(src)
	new /obj/item/clothing/under/ash_robe/hunter(src)
	new /obj/item/clothing/under/ash_robe/hunter(src)
	new /obj/item/clothing/under/ash_robe/chief(src)
	new /obj/item/clothing/under/ash_robe/shaman(src)
	new /obj/item/clothing/neck/cloak/tribalmantle(src)
	new /obj/item/clothing/neck/cloak/tribalmantle(src)
	new /obj/item/clothing/suit/hooded/cloak/goliath/desert(src)
	new /obj/item/clothing/suit/hooded/cloak/goliath/desert(src)
	new /obj/item/clothing/suit/leather_mantle(src)
	new /obj/item/clothing/suit/leather_mantle(src)

// Testing
/obj/structure/closet/crate/wooden/ashwalker/extra/PopulateContents()
	. = ..()
	new	/obj/item/clothing/under/raider_leather(src)
	new	/obj/item/clothing/under/tribal(src)
	new	/obj/item/clothing/under/ash_robe/tunic(src)
	new	/obj/item/clothing/under/ash_robe/dress(src)
