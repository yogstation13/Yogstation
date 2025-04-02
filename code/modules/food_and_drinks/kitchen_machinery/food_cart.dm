///Holding info for UI elements
/datum/data/cart_item
	///Amount of item in contents
	var/amount = null
	///Item's type path
	var/type_path = null
	///Image to be shown in UI
	var/image = null

//Thanks hedgehog1029 for the help on base64 icon
/datum/data/cart_item/New(obj/item/I)
	name = I.name
	amount = 1
	type_path = I.type
	var/icon/icon = icon(I.icon, I.icon_state, SOUTH, 1)
	image = icon2base64(icon)

/obj/machinery/food_cart
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	///Max amount of items that can be in the cart's contents list
	var/contents_capacity = 80
	///How many drinking glasses the cart has
	var/glass_quantity = 10
	///Max amount of drink glasses the cart can have
	var/glass_capacity = 30
	///Max amount of reagents that can be in cart's storage
	var/reagent_capacity = 200
	///Sound made when an item is dispensed
	var/dispense_sound = 'sound/machines/click.ogg'
	///Sound made when an item is inserted
	var/insert_sound = 'sound/effects/rustle2.ogg'
	///Sound made when selecting/deselecting an item
	var/select_sound = 'sound/machines/doorclick.ogg'
	///List used to show food items in UI
	var/list/food_ui_list = list()
	///List of transfer amounts for reagents
	var/list/transfer_list = list(5, 10, 15, 20, 30, 50)
	///What transfer amount is currently selected
	var/selected_transfer = 0
	///Mixer for dispencing drinks
	var/obj/item/reagent_containers/mixer

/obj/machinery/food_cart/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoodCart", name)
		ui.open()

/obj/machinery/food_cart/ui_data(mob/user)
	///Define data for sending info to UI
	var/list/data = list()

	//Define lists for each property of data so that they send to UI regardless of what happens
	//Thanks bug eating lizard and offbeatwitch for helping solve UI updating issue
	data["food"] = list()
	data["mainDrinks"] = list()
	data["mixerDrinks"] = list()
	data["storage"] = list()

	//Make sure food_ui_list has desired contents
	//This, along with contents check for food_ui_list, allows parmesan cheese to show in the UI after maturing
	var/in_list
	for(var/obj/item/content_item in contents)
		in_list = FALSE
		//Only check food items
		if(istype(content_item, /obj/item/reagent_containers/food/snacks))
			//Loop through all datums in ui list to check if item is in the UI
			for(var/datum/data/cart_item/item in food_ui_list)
				if(item.type_path == content_item.type)
					in_list = TRUE
					break
			//If not already in food_ui_list, add to it
			if(!in_list)
				LAZYADD(food_ui_list, new /datum/data/cart_item(content_item))

	//Loop through food list for data to send to food tab
	for(var/datum/data/cart_item/item_detail in food_ui_list)
		in_list = FALSE
		//If none are found in contents, remove from list and move on to next element
		for(var/obj/content_item in contents)
			if(content_item.type == item_detail.type_path)
				in_list = TRUE
		if(!in_list)
			LAZYREMOVE(food_ui_list, item_detail)
			break

		//Create needed list and variable for geting data for UI
		var/list/details = list()

		//Get information for UI
		details["name"] = item_detail.name
		details["quantity"] = item_detail.amount
		details["type_path"] = item_detail.type_path

		//Get an image for the UI
		details["image"] = item_detail.image

		//Add to food list
		data["food"] += list(details)

	//Loop through drink list for data to send to cart's reagent storage tab
	for(var/datum/reagent/drink in reagents.reagent_list)
		var/list/details = list()

		//Get information for UI
		details["name"] = drink.name
		details["quantity"] = drink.volume
		details["type_path"] = drink.type

		//Add to drink list
		data["mainDrinks"] += list(details)
	
	//Loop through drink list for data to send to cart's reagent mixer tab
	for(var/datum/reagent/drink in mixer.reagents.reagent_list)
		var/list/details = list()

		//Get information for UI
		details["name"] = drink.name
		details["quantity"] = drink.volume
		details["type_path"] = drink.type
		
		//Add to drink list
		data["mixerDrinks"] += list(details)

	//Get content and capacity data
	var/list/storageDetails = list()
	//Have to subtract contents.len by 1 due to reagents container being in contents
	storageDetails["contents_length"] = contents.len - 1
	storageDetails["storage_capacity"] = contents_capacity
	storageDetails["glass_quantity"] = glass_quantity
	storageDetails["glass_capacity"] = glass_capacity
	storageDetails["dispence_options"] = transfer_list
	storageDetails["dispence_selected"] = selected_transfer
	//Add the total_volumne of both cart and mixer storage for quantity
	storageDetails["drink_quantity"] = mixer.reagents.total_volume + reagents.total_volume
	storageDetails["drink_capacity"] = reagent_capacity

	data["storage"] += storageDetails
	//Send stored information to UI	
	return data

/obj/machinery/food_cart/ui_act(action, list/params)
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
			playsound(src, select_sound, 50, TRUE, extrarange = -3)
		//Remove reagent from cart
		if("purge")
			reagents.remove_reagent(text2path(params["itemPath"]), selected_transfer)
			playsound(src, select_sound, 50, TRUE, extrarange = -3)
		//Add reagent to mixer
		if("addMixer")
			reagents.trans_id_to(mixer, text2path(params["itemPath"]), selected_transfer)
			playsound(src, select_sound, 50, TRUE, extrarange = -3)
		//Return reagent to storage
		if("transferBack")
			mixer.reagents.trans_id_to(src, text2path(params["itemPath"]), selected_transfer)
			playsound(src, select_sound, 50, TRUE, extrarange = -3)
		//Pour glass
		if("pour")
			pour_glass(usr)

/obj/machinery/food_cart/Initialize(mapload)
	. = ..()
	//Create reagents holder for drinks
	create_reagents(reagent_capacity, OPENCONTAINER | NO_REACT)
	mixer = new /obj/item/reagent_containers(src, 50)
	mixer.create_reagents(50, NO_REACT)

/obj/machinery/food_cart/Destroy()
	//Only alert others if the cart or mixer has any reagents
	if(mixer.reagents.total_volume || reagents.total_volume)
		visible_message(span_alert("[src] spills all of its liquids onto the floor!"))
	//Spill reagents on the cart's turf
	//Thanks baiomu for telling me how to spill reagents
	var/turf/spill_area = get_turf(src)
	spill_area.add_liquid_from_reagents(mixer.reagents, FALSE, mixer.reagents.chem_temp)
	spill_area.add_liquid_from_reagents(reagents, FALSE, mixer.reagents.chem_temp)
	//Reduce mixer to dust
	QDEL_NULL(mixer)
	
	return ..()

//For adding items and reagents to storage
/obj/machinery/food_cart/attackby(obj/item/A, mob/user, params)
	//Depending on the item, either attempt to store it or ignore it
	if(istype(A, /obj/item/reagent_containers/food/snacks))
		storage_single(A)
		return
	else if(istype(A, /obj/item/reagent_containers/food/drinks/drinkingglass))
		//Check if glass is empty
		if(!A.reagents.total_volume)
			//Increment glass_quantity by 1 and then delete glass
			glass_quantity++
			user.visible_message(span_notice("[user] inserts [A] into [src]."), span_notice("You insert [A] into [src]."))
			qdel(A)
			playsound(src, insert_sound, 50, TRUE, extrarange = -3)
		return
	else if(A.is_drainable())
		return

	..()

/obj/machinery/food_cart/proc/dispense_item(received_item, mob/user = usr)
	//Get list item for recieved_item
	var/datum/data/cart_item/ui_item = null
	for(var/datum/data/cart_item/item in food_ui_list)
		if(received_item == item.type_path)
			ui_item = item
			break
	//Continue if ui_item is not null
	if(ui_item)
		//If the vat has some of the desired item, dispense it
		if(ui_item.amount > 0)
			//Select the last(most recent) of desired item
			var/obj/item/reagent_containers/food/snacks/dispensed_item = LAZYACCESS(contents, last_index(ui_item.type_path))
			//Decrease amount by 1
			ui_item.amount -= 1
			//Move it into the user's hands or drop it on the floor
			user.put_in_hands(dispensed_item)
			user.visible_message(span_notice("[user] dispenses [dispensed_item.name] from [src]."), span_notice("You dispense [dispensed_item.name] from [src]."))
			playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
			//If the last one was dispenced, remove from UI
			if(ui_item.amount == 0)
				LAZYREMOVE(food_ui_list, ui_item)
		else
			//Incase the UI buttons are slow to disable themselves
			user.balloon_alert(user, "All out!")
	else
		user.balloon_alert(user, "All out!")

/obj/machinery/food_cart/proc/storage_single(obj/item/target_item, mob/user = usr)
	//Check if there is room, subtract by 1 since the cart's reagent container is added to its contents
	if(contents.len - 1 < contents_capacity)
		//If item is not already in  food_ui_list, add it
		var/in_list = FALSE
		for(var/datum/data/cart_item/item in food_ui_list)
			if(item.type_path == target_item.type)
				//Increment amount by 1
				item.amount += 1
				//Set in_list to true and end loop
				in_list = TRUE
				break
		if(!in_list)
			LAZYADD(food_ui_list, new /datum/data/cart_item(target_item))
		//Move item to content
		target_item.forceMove(src)
		user.visible_message(span_notice("[user] inserts [target_item] into [src]."), span_notice("You insert [target_item] into [src]."))
		playsound(src, insert_sound, 50, TRUE, extrarange = -3)

		return
	else
		//Warn about full capacity
		user.balloon_alert(user, "No space!")

/obj/machinery/food_cart/proc/pour_glass(mob/user)
	//Check if there are any glasses in storage
	if(glass_quantity > 0)
		glass_quantity -= 1
		//Create new glass
		var/obj/item/reagent_containers/food/drinks/drinkingglass/drink = new(loc)
		//Move all reagents in mixer to glass
		mixer.reagents.trans_to(drink, mixer.reagents.total_volume)
		//Attempt to put glass into user's hand
		user.put_in_hands(drink)
		user.visible_message(span_notice("[user] pours [drink] from [src]."), span_notice("You pour [drink] from [src]."))
		playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
	else
		user.balloon_alert(user, "No Drinking Glasses!")

/obj/machinery/food_cart/proc/last_index(obj/item/search_item)
	var/obj/item/reagent_containers/food/snacks/item_index = null

	//Search for the same item path in storage
	for(var/i in 1 to LAZYLEN(contents))
		//Loop through entire list to get last/most recent item
		if(contents[i].type == search_item.type)
			item_index = i
	
	return item_index
