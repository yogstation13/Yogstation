/obj/machinery/food_cart_TGUI
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	//Max amount of items that can be in cart's storage
	var/storage_capacity = 80
	//Sound made when an item is dispensed
	var/dispense_sound = 'sound/machines/click.ogg'
	//List used to show items in UI
	var/list/ui_list = list()

/obj/machinery/food_cart_TGUI/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoodCart", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/food_cart_TGUI/ui_data(mob/user)
	//Define variables from UI
	var/list/data = list()
	data["food"] = list()
	data["storage"] = list()

	//Loop through starting list for data to send to main tab
	for(var/item_detail in ui_list)

		//Create needed list and variable for geting data for UI
		var/list/details = list()
		var/obj/item/reagent_containers/food/item = new item_detail

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

		//Add to food list
		data["food"] += list(details)

	//Get content and capacity data
	data["contents_length"] = contents.len
	data["storage_capacity"] = storage_capacity

	//Send stored information to UI	
	return data

/obj/machinery/food_cart_TGUI/ui_act(action, list/params)
	. = ..()
	if(.)

		return

	switch(action)
		if("dispense")
			var/itemPath = text2path(params["itemPath"])
			dispense_item(itemPath)

//For adding items to storage
/obj/machinery/food_cart_TGUI/attackby(obj/item/A, mob/user, params)
	//Check to make sure it is a food item
	if(istype(A, /obj/item/reagent_containers/food))
		storage_single(A)

	..()

/obj/machinery/food_cart_TGUI/proc/dispense_item(received_item, mob/user = usr)
	//Make a variable for checking the type of the selected item
	var/obj/item/reagent_containers/food/ui_item = new received_item

	//If the vat has some of the desired item, dispense it
	if(find_amount(ui_item) > 0)
		//Select the last(most recent) of desired item
		var/obj/item/reagent_containers/food/snacks/dispensed_item = LAZYACCESS(contents, last_index(ui_item))
		//Drop it on the floor and then move it into the user's hands
		dispensed_item.forceMove(loc)
		user.put_in_hands(dispensed_item)
		user.visible_message(span_notice("[user] dispenses [ui_item.name] from [src]."), span_notice("You dispense [ui_item.name] from [src]."))
		playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
		//If the last one was dispenced, remove from UI
		if(find_amount(ui_item) == 0)
			LAZYREMOVE(ui_list, received_item)
	else
		//For Alt click and because UI buttons are slow to disable themselves
		user.balloon_alert(user, "All out!")

/obj/machinery/food_cart_TGUI/proc/storage_single(obj/item/target_item, mob/user = usr)
	//Check if there is room
	if(contents.len < storage_capacity)
		//If item's typepath is not already in  ui_list, add it
		if(!LAZYFIND(ui_list, target_item.type))
			LAZYADD(ui_list, target_item.type)
		//Move item to content
		target_item.forceMove(src)
		user.visible_message(span_notice("[user] inserts [target_item] into [src]."), span_notice("You insert [target_item] into [src]."))
		playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

		return
	else
		//Warn about full capacity
		user.balloon_alert(user, "No space!")
		
/obj/machinery/food_cart_TGUI/proc/find_amount(obj/item/counting_item, target_name = null, list/target_list = null)
	var/amount = 0

	//If target_list is null, search contents for type paths
	if(!target_list)
		//Loop through contents, counting every instance of the given target
		for(var/obj/item/list_item in contents)
			if(list_item.type == counting_item.type)
				amount += 1
	//Else, search target_list
	else
		for(var/list_item in target_list)
			if(list_item == target_name)
				amount += 1

	return amount

/obj/machinery/food_cart_TGUI/proc/last_index(obj/item/search_item)
	var/obj/item/reagent_containers/food/snacks/item_index = null

	//Search for the same item path in storage
	for(var/i in 1 to LAZYLEN(contents))
		//Loop through entire list to get last/most recent item
		if(contents[i].type == search_item.type)
			item_index = i
	
	return item_index
