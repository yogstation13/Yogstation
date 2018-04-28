/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/money/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 40
	STR.max_combined_w_class = 40
	STR.can_hold = typecacheof(list(/obj/item/coin, /obj/item/stack/spacecash))

<<<<<<< HEAD
/obj/item/storage/bag/money/vault/PopulateContents()
=======
/obj/item/storage/bag/money/vault/Initialize()
	. = ..()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)