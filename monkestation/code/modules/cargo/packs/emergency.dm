// as i have no idea where to put new box types, boxes of oxygen candles go here
/obj/item/storage/box/oxygen_candles
	name = "box of oxygen candles"
	desc = "A box full of emergency oxygen candles."
	icon_state = "internals"
	illustration = "firecracker"

/obj/item/storage/box/oxygen_candles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/oxygen_candle(src)

//also boxed emergency space suits cus why not
/obj/item/storage/box/emergency_eva
	name = "boxed space suit and helmet"
	desc = "A cheap, flimsy metal box used to hold an emergency spacesuit."
	icon_state = "internals"
	illustration = "writing"
	resistance_flags = FIRE_PROOF
	foldable_result = /obj/item/stack/sheet/iron
	w_class = WEIGHT_CLASS_BULKY //just so nobody thinks to pocket these
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	flags_1 = CONDUCT_1

/obj/item/storage/box/emergency_eva/PopulateContents()
	new /obj/item/clothing/suit/space/fragile(src)
	new /obj/item/clothing/head/helmet/space/fragile(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

/obj/item/storage/box/emergency_eva/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3 //smol
	transform = transform.Scale(1.25, 1)

//
//   NOW FOR CRATES
//
/datum/supply_pack/emergency/emergency_eva
	name = "Emergency EVA Crate"
	desc = "Contains three each emergency space suits and helmets, emergency toolboxes, along with one box of oxygen candles."

	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/storage/box/emergency_eva = 3,
		/obj/item/storage/toolbox/emergency = 3,
		/obj/item/storage/box/oxygen_candles,
	)
	crate_name = "emergency eva crate"
	crate_type = /obj/structure/closet/crate/internals
