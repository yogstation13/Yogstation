/obj/item/storage/pencil_holder
	name = "holder"
	desc = "A container for writing utensils."
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "pencilholder_0"
	item_state = "paper !CONFLICT! base"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_range = 5

/obj/item/storage/pencil_holder/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 20
	STR.set_holdable(list(
		/obj/item/pen,
		/obj/item/toy/crayon,
	))

/obj/item/storage/pencil_holder/update_icon_state()
	. = ..()
	switch(contents.len)
		if(0)
			icon_state = "pencilholder_0"
		if(1)
			icon_state = "pencilholder_1"
		if(2 to 10)
			icon_state = "pencilholder_2"
		if(11 to 19)
			icon_state = "pencilholder_3"
		if(20)
			icon_state = "pencilholder_4"
	
/obj/item/storage/pencil_holder/crew
//THE POPULATED CAN FOR CREW
	name = "pencil holder"

/obj/item/storage/pencil_holder/crew/PopulateContents()
	new	/obj/item/pen(src)
	new	/obj/item/pen(src)
	new	/obj/item/pen(src)
	new	/obj/item/pen/red(src)
	new	/obj/item/pen/red(src)
	new	/obj/item/pen/red(src)
	new	/obj/item/pen/blue(src)
	new	/obj/item/pen/blue(src)
	new	/obj/item/pen/blue(src)
	new	/obj/item/pen/green(src)
	new	/obj/item/pen/green(src)
	new	/obj/item/pen/green(src)

/obj/item/storage/pencil_holder/crew/creative
//CRAYON CAN
	name = "crayon holder"
	desc = "What's mightier, the pen or the e-sword?"

/obj/item/storage/pencil_holder/crew/creative/PopulateContents()
	new	/obj/item/toy/crayon/red(src)
	new	/obj/item/toy/crayon/blue(src)
	new	/obj/item/toy/crayon/green(src)
	new	/obj/item/toy/crayon/orange(src)
	new	/obj/item/toy/crayon/yellow(src)
	new	/obj/item/toy/crayon/purple(src)
	new	/obj/item/toy/crayon/black(src)
	new	/obj/item/toy/crayon/white(src)
	
/obj/item/storage/pencil_holder/crew/fancy
//HOITY TOITY PENS CAN
	name = "caligraphy holder"
	desc = "For creating beautiful caligraphy, or forging checks."
	
/obj/item/storage/pencil_holder/crew/fancy/PopulateContents()
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	new	/obj/item/pen/fountain(src)
	
