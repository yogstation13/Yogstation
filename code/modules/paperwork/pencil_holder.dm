/obj/item/storage/pencil_holder//i have no idea wtf im doing
	name = "holder"
	desc = "a holder for your utensils"
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state ="pencil_holder0"
	item_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8

/atom/obj/item/storage/pencil_holder/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 200
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/pen,
		/obj/item/toy/crayon,
	))

/obj/item/storage/pencil_holder/crew
//the populated holder
	name = "pencil holder"
	desc = "a holder for writing utensils"
	icon_state = "pencil_holder0"

/obj/item/storage/pencil_holder/crew/PopulateContents()
	. = ..()
	new	/obj/item/pen (src)
	new	/obj/item/pen (src)
	new	/obj/item/pen (src)
	new	/obj/item/pen/red (src)
	new	/obj/item/pen/red (src)
	new	/obj/item/pen/red (src)
	new	/obj/item/pen/blue (src)
	new	/obj/item/pen/blue (src)
	new	/obj/item/pen/blue (src)
	new	/obj/item/pen/green (src)
	new	/obj/item/pen/green (src)
	new	/obj/item/pen/green (src)
	