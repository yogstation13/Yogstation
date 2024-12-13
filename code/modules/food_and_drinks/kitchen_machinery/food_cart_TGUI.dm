/obj/machinery/food_cart_TGUI
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	//Max amount of items that can be in the cart's contents list
	var/contents_capacity = 80
	//How many drinking glasses the cart has
	var/glass_quantity = 10
	//Max amount of drink glasses the cart can have
	var/glass_capacity = 30
	//Max amount of reagents that can be in cart's storage
	var/reagent_capacity = 200
	//Sound made when an item is dispensed
	var/dispense_sound = 'sound/machines/click.ogg'
	//List used to show food items in UI
	var/list/food_ui_list = list()
	//List of transfer amounts for reagents
	var/list/transfer_list = list(5, 10, 15, 20, 30, 50)
	//What transfer amount is currently selected
	var/selected_transfer = 0
	//Mixer for dispencing drinks
	var/obj/item/reagent_containers/mixer

	var/list/drink_list
	var/list/mixer_list

/obj/machinery/food_cart_TGUI/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoodCart", name)
		ui.open()

/obj/machinery/food_cart_TGUI/ui_data(mob/user)
	//Define variables from UI
	var/list/data = list()
	data["food"] = list()
	data["storage"] = list()

	drink_list = reagents.reagent_list
	mixer_list = mixer.reagents.reagent_list

	//Loop through food list for data to send to food tab
	for(var/item_detail in food_ui_list)
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

	//Loop through drink list for data to send to cart's reagent storage tab
	for(var/datum/reagent/drink in drink_list)
		var/list/details = list()

		//Get information for UI
		details["drink_name"] = drink.name
		details["drink_quantity"] = drink.volume
		details["drink_type_path"] = drink.type

		//Add to drink list
		data["mainDrinks"] += list(details)
	
	//Loop through drink list for data to send to cart's reagent mixer tab
	for(var/datum/reagent/drink in mixer_list)
		var/list/details = list()

		//Get information for UI
		details["drink_name"] = drink.name
		details["drink_quantity"] = drink.volume
		details["drink_type_path"] = drink.type
		
		//Add to drink list
		data["mixerDrinks"] += list(details)

	//Get content and capacity data
	//Have to subtract contents.len by 1 due to reagents container being in contents
	data["contents_length"] = contents.len - 1
	data["storage_capacity"] = contents_capacity
	data["glass_quantity"] = glass_quantity
	data["glass_capacity"] = glass_capacity
	data["dispence_options"] = transfer_list
	data["dispence_selected"] = selected_transfer
	//Add the total_volumne of both cart and mixer storage for quantity
	data["drink_quantity"] = mixer.reagents.total_volume + reagents.total_volume
	data["drink_capacity"] = reagent_capacity

	//Send stored information to UI	
	return data

/obj/machinery/food_cart_TGUI/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		//Dispense food item
		if("dispense")
			var/itemPath = text2path(params["itemPath"])
			dispense_item(itemPath)
		//Change selected_transfer
		if("transferNum")
			selected_transfer = params["dispenceAmount"]
		//Remove reagent from cart
		if("purge")
			reagents.remove_reagent(text2path(params["itemPath"]), selected_transfer)
		//Add reagent to mixer
		if("addMixer")
			src.reagents.trans_id_to(mixer, text2path(params["itemPath"]), selected_transfer)
		//Return reagent to storage
		if("transferBack")
			mixer.reagents.trans_id_to(src, text2path(params["itemPath"]), selected_transfer)
		//Pour glass
		if("pour")
			pour_glass()

/obj/machinery/food_cart_TGUI/Initialize(mapload)
	. = ..()
	//Create reagents holder for drinks
	create_reagents(reagent_capacity, OPENCONTAINER | NO_REACT)
	mixer = new /obj/item/reagent_containers(src, 50)

/obj/machinery/food_cart_TGUI/Destroy()
	QDEL_NULL(mixer)
	return ..()

//For adding items and reagents to storage
/obj/machinery/food_cart_TGUI/attackby(obj/item/A, mob/user, params)
	//Depending on the item, either attempt to store it or ignore it
	if(istype(A, /obj/item/reagent_containers/food/snacks))
		storage_single(A)
	else if(istype(A, /obj/item/reagent_containers/food/drinks/drinkingglass))
		//Check if glass is empty
		if(!A.reagents.total_volume)
			qdel(A)
			glass_quantity++
			user.visible_message(span_notice("[user] inserts [A] into [src]."), span_notice("You insert [A] into [src]."))
			playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)
	else if(A.is_drainable())
		return

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
			LAZYREMOVE(food_ui_list, received_item)
	else
		//For Alt click and because UI buttons are slow to disable themselves
		user.balloon_alert(user, "All out!")

/obj/machinery/food_cart_TGUI/proc/storage_single(obj/item/target_item, mob/user = usr)
	//Check if there is room
	if(contents.len - 1 < contents_capacity)
		//If item's typepath is not already in  food_ui_list, add it
		if(!LAZYFIND(food_ui_list, target_item.type))
			LAZYADD(food_ui_list, target_item.type)
		//Move item to content
		target_item.forceMove(src)
		user.visible_message(span_notice("[user] inserts [target_item] into [src]."), span_notice("You insert [target_item] into [src]."))
		playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

		return
	else
		//Warn about full capacity
		user.balloon_alert(user, "No space!")

/obj/machinery/food_cart_TGUI/proc/pour_glass(mob/user = usr)
	//Check if there are any glasses in storage
	if(glass_quantity > 0)
		glass_quantity -= 1
		//Create new glass
		var/obj/item/reagent_containers/food/drinks/drinkingglass/drink = new(loc)
		//Move all reagents in mixer to glass
		mixer.reagents.trans_to(drink, mixer.reagents.total_volume)
		//Attempt to put glass into user's hand
		user.put_in_hands(drink)
	else
		user.balloon_alert(user, "No Drinking Glasses!")

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
