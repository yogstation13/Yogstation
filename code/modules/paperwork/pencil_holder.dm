/obj/item/storage/pencil_holder//i have no idea wtf im doing
	name = "holder"
	desc = "a holder for your utensils"
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state ="pencil_holder0"
	item_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8

/obj/item/storage/pencil_holder/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 20
	STR.set_holdable(list(
		/obj/item/pen,
		/obj/item/pen/blue,
		/obj/item/pen/blue/sleepy,
		/obj/item/pen/red,
		/obj/item/pen/red/edagger,
		/obj/item/pen/green,
		/obj/item/pen/fourcolor,
		/obj/item/pen/invisible,
		/obj/item/pen/charcoal,
		/obj/item/pen/fountain,
		/obj/item/pen/fountain/captain,
		/obj/item/toy/crayon/red,
		/obj/item/toy/crayon/orange,
		/obj/item/toy/crayon/yellow,
		/obj/item/toy/crayon/green,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/purple,
		/obj/item/toy/crayon/black,
		/obj/item/toy/crayon/rainbow,
		/obj/item/toy/crayon/mime,

	))

/obj/item/storage/pencil_holder/crew
//the populated holder
	name = "pencil holder"
	desc = "a holder for writing utensils"
	icon_state = "pencil_holder2"

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
	