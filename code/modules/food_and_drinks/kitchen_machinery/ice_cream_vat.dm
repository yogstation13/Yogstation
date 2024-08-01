/obj/machinery/ice_cream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	//Ice cream to be dispensed into cone on attackby
	var/selected_scoop = null
	//Cone to be dispensed with alt click
	var/selected_cone = null
	//Max amount of items that can be in vat's storage
	var/storage_capacity = 120
	//If it starts empty or not
	var/start_empty = FALSE
	//Sound made when an item is dispensed
	var/dispense_sound = 'sound/machines/click.ogg'
	//Sound made when selecting/deselecting an item
	var/select_sound = 'sound/machines/doorclick.ogg'
	//Items to be added upon creation to the vat and what is shown in the UI
	var/list/ui_list = list(
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/vanilla,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/chocolate,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/strawberry,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/blue,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/lemon_sorbet,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/caramel,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/banana,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/orange_creamsicle,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/peach,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/cherry_chocolate,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/meat,
		/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake,
		/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate)
	//Please don't add anything other than scoops or cones to the list or it could/maybe/possibly/definitely break it	

/obj/machinery/ice_cream_vat/ui_interact(mob/user, datum/tgui/ui) //Thanks bug eating lizard for helping me with the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IceCreamVat", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/ice_cream_vat/ui_data(mob/user)
	//Define variables from UI
	var/list/data = list()
	data["cones"] = list()
	data["ice_cream"] = list()

	//Loop through list for data to send to UI
	for(var/item_detail in ui_list)

		//Create needed list and variable for geting data for UI
		var/list/details = list()
		var/obj/item/reagent_containers/food/snacks/item = new item_detail

		//Get information for UI
		details["item_name"] = item.name
		details["item_quantity"] = find_amount(item)
		details["item_type_path"] = item.type

		//Get an image for the UI
		var/icon/item_pic = getFlatIcon(item)
		var/md5 = md5(fcopy_rsc(item_pic))
		if(!SSassets.cache["photo_[md5]_[item.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[item.name]_icon.png", item_pic)
		SSassets.transport.send_assets(user, list("photo_[md5]_[item.name]_icon.png" = item_pic))
		details["item_image"] = SSassets.transport.get_asset_url("photo_[md5]_[item.name]_icon.png")

		//Sort into different data lists depending on what the item is
		if(istype(item, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))
			details["selected_item"] = selected_scoop
			data["ice_cream"] += list(details)
		else
			details["selected_item"] = selected_cone
			data["cones"] += list(details)

	//Send stored information to UI	
	return data

/obj/machinery/ice_cream_vat/ui_act(action, list/params)
	. = ..()
	if(.)

		return

	switch(action)
		if("select")
			var/itemPath = text2path(params["itemPath"])
			select_item(itemPath)
		if("dispense")
			var/itemPath = text2path(params["itemPath"])
			dispense_item(itemPath)

/obj/machinery/ice_cream_vat/Initialize(mapload)
	. = ..()
	
	if(!start_empty)

		//Loop through and add items from ui_list into content
		for(var/item in ui_list)
			
			var/loop_cycles = 5
			var/obj/item/reagent_containers/food/snacks/check_item = new item
			
			//5 of every scoop; 10 of every cone
			if(istype(check_item, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
				loop_cycles = 10

			//Add amount of items to the list depending on type
			for(var/i in 1 to loop_cycles)
				new item(src)

/obj/machinery/ice_cream_vat/examine(mob/user)
	. = ..()

	//Selected cones
	if(selected_cone == null)
		. += span_notice("You can <b>Alt Click</b> to dispense a cone once one is selected.")
	else
		var/obj/item/reagent_containers/food/snacks/examine_cone = new selected_cone
		. += span_notice("<b>Alt Click</b> to dispense [examine_cone.name].")

	//Selected scoops
	if(selected_scoop == null)
		. += span_notice("No ice cream scoop currently selected.")
	else
		var/obj/item/reagent_containers/food/snacks/examine_scoop = new selected_scoop
		. += span_notice("[examine_scoop.name] is currently selected.")

	//Scooping cone instruction
	. += span_notice("<b>Right Click</b> to add a scoop to a cone.")

//For dispensing selected cone
/obj/machinery/ice_cream_vat/AltClick(mob/living/carbon/user)
	if(selected_cone != null)
		dispense_item(selected_cone)
	else
		user.balloon_alert(user, "None selected!")

//For scooping cones
/obj/machinery/ice_cream_vat/attackby_secondary(obj/item/A, mob/user, params)
	//Check if item is a cone
	if(istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
		var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = A
		//Check if cone is scooped
		if(cone.scooped == FALSE)
			//Check if a scoop has been selected
			if(selected_scoop != null)
				//Check if there are any of selected scoop in contents
				if(find_amount(selected_scoop) > 0)
					//Select last of selected scoop in contents
					var/obj/item/reagent_containers/food/snacks/cone_scoop = LAZYACCESS(contents, last_index(selected_scoop))
					//Remove scoop from contents and add relevant variables to cone
					cone_scoop.forceMove(loc)
					cone.reagents.reagent_list += cone_scoop.reagents.reagent_list
					cone.foodtype = cone_scoop.foodtype
					//Change description of cone
					cone.desc = "[cone.base_desc] with a [cone_scoop.name]."
					//Add overlay of scoop to cone
					cone.add_overlay(cone_scoop.icon_state)
					//Alert that the cone has been scooped
					user.visible_message(span_notice("[user] scoops a [cone_scoop.name] into the [cone.name]"), span_notice("You scoop a [cone_scoop.name] into the [cone.name]"))
					//Set scooped to TRUE
					cone.scooped = TRUE
					//Delete scoop
					qdel(cone_scoop)

					playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

				//Warn user that there are no selected scoops left
				else
					user.balloon_alert(user, "No selected scoops in storage!")

			//Warn user about no selected scoop
			else
				user.balloon_alert(user, "No scoop selected!")

		//Warn user about cone already being scooped
		else
			user.balloon_alert(user, "Already scooped!")

	//Warn user about invalid item
	else
		user.balloon_alert(user, "Invalid item!")

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

//For adding items to storage
/obj/machinery/ice_cream_vat/attackby(obj/item/A, mob/user, params)
	//For adding individual items
	if(istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_cone) || istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))	
		//Check if there is room
		if(contents.len < storage_capacity)
			//If a cone, check if it has already been scooped. If it has, do not store it
			if(istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
				var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = A
				if(cone.scooped == TRUE)
					user.balloon_alert(user, "Cannot store scooped cones!")

					return
			//Move item to content
			A.forceMove(src)
			user.visible_message(span_notice("[user] inserts [A] into [src]."), span_notice("You insert [A] into [src]."))
			playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

			return
		else
			//Warn about full capacity
			user.balloon_alert(user, "No space!")

	//Adding carton contents to storage
	else if(istype(A, /obj/item/storage/box/ice_cream_carton))
		var/end_message = "[user] empties the [A] into [src]."
		var/end_self_message = "You empty the [A] into [src]."
		//Check to see if it is empty
		if(A.contents.len > 0 && contents.len < storage_capacity)
			//Hide carton's storage UI to prevent ghost scoop bug
			SEND_SIGNAL(A, COMSIG_TRY_STORAGE_HIDE_FROM, user)
			//Loop through all contents
			for(var/obj/item/reagent_containers/food/snacks/ice_cream_scoop/carton_item in A)
				//Transfer items one at a time
				carton_item.forceMove(src)

				if(contents.len >= storage_capacity)
					//Unique message depending on carton and vat contents
					if(A.contents.len == 0)
						end_message = "[user] empties the [A] into [src], filling it to its capacity."
						end_self_message = "You empty the [A] into [src], filling it to its capacity."
					else
						end_message = "[user] fills [src] to its capacity, with some ice cream still in the [A]."
						end_self_message = "You fill [src] to its capacity, with some ice cream still in the [A]."
					break
			user.visible_message(span_notice(end_message), span_notice(end_self_message))
			playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

			return
		else
			if(A.contents.len == 0)
				user.balloon_alert(user, "Carton empty!")
			else
				user.balloon_alert(user, "Vat full!")
			return

	

	..()

/obj/machinery/ice_cream_vat/proc/find_amount(obj/item/counting_item)
	var/amount = 0

	//Loop through contents, counting every instance of the given target
	for(var/obj/item/list_item in contents)
		if(list_item.type == counting_item.type)
			amount += 1
	
	return amount

/obj/machinery/ice_cream_vat/proc/dispense_item(received_item, mob/user = usr)

	var/obj/item/reagent_containers/food/snacks/ui_item = new received_item

	if(find_amount(ui_item) > 0)
		var/obj/item/reagent_containers/food/snacks/dispensed_item = LAZYACCESS(contents, last_index(ui_item))
		dispensed_item.forceMove(loc)
		user.put_in_hands(dispensed_item)
		user.visible_message(span_notice("[user] dispenses [ui_item.name] from [src]."), span_notice("You dispense [ui_item.name] from [src]."))
		playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
	else
		//For Alt click and when buttons don't disable themselves
		user.balloon_alert(user, "All out!")

/obj/machinery/ice_cream_vat/proc/select_item(received_item, mob/user = usr)

	var/obj/item/reagent_containers/food/snacks/ui_item = new received_item

	//Deselecting
	if(istype(ui_item, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
		if(selected_cone == ui_item.type)
			user.visible_message(span_notice("[user] deselects [ui_item.name] from [src]."), span_notice("You deselect [ui_item.name] from [src]."))
			selected_cone = null
			playsound(src, select_sound, 25, TRUE, extrarange = -3)

			return
	else if(selected_scoop == ui_item.type)
		user.visible_message(span_notice("[user] deselects [ui_item.name] from [src]."), span_notice("You deselect [ui_item.name] from [src]."))
		selected_scoop = null
		playsound(src, select_sound, 25, TRUE, extrarange = -3)

		return

	//Selecting
	if(find_amount(ui_item.type) > 0)
		if(istype(ui_item, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			selected_cone = ui_item.type
		else
			selected_scoop = ui_item.type
		playsound(src, select_sound, 25, TRUE, extrarange = -3)
		user.visible_message(span_notice("[user] sets [src] to dispense [ui_item.name]s."), span_notice("You set [src] to dispense [ui_item.name]s."))
	else
		user.balloon_alert(user, "All out!")

/obj/machinery/ice_cream_vat/proc/last_index(obj/item/search_item)

	var/obj/item/reagent_containers/food/snacks/item_index = null

	//Search for the same item path in storage
	for(var/i in 1 to LAZYLEN(contents))
		//Loop through entire list to get last/most recent item
		if(contents[i].type == search_item.type)
			item_index = i
	
	return item_index

///////////////////
//ICE CREAM CONES//
///////////////////

/obj/item/reagent_containers/food/snacks/ice_cream_cone
	name = "ice cream cone base"
	desc = "Please report this, as this should not be seen."
	icon = 'icons/obj/kitchen.dmi'
	bitesize = 3
	foodtype = GRAIN
	//Used for changing the description after being scooped
	var/base_desc = null
	//If the cone has a scoop or not
	var/scooped = FALSE
	//For adding chems to specific cones
	var/extra_reagent = null
	//Amount of extra_reagent to add to cone
	var/extra_reagent_amount = 1

/obj/item/reagent_containers/food/snacks/ice_cream_cone/Initialize(mapload)
	. = ..()
	create_reagents(20)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 4)
	if(extra_reagent != null)
		reagents.add_reagent(extra_reagent, extra_reagent_amount)

/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake
	name = "cake ice cream cone"
	desc = "A delicious cake cone, but with no ice cream."
	icon_state = "icecream_cone_waffle"
	tastes = list("bland" = 6)
	base_desc = "A delicious cake cone"
	extra_reagent = /datum/reagent/consumable/nutriment
	
/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate
	name = "chocolate ice cream cone"
	desc = "A delicious chocolate cone, but with no ice cream."
	icon_state = "icecream_cone_chocolate"
	tastes = list("bland" = 4, "chocolate" = 6)
	base_desc = "A delicious chocolate cone"
	extra_reagent = /datum/reagent/consumable/coco
