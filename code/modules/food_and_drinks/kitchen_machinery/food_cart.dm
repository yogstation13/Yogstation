///For sending images to the UI with base 64
/datum/data/ui_image
	///Image to be shown in UI
	var/image = null

//Thanks hedgehog1029 for the help on this
/datum/data/ui_image/New(obj/item/I)
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
	//This, combined with the find_amount() bellow, allow parmesan cheese to show in the UI after maturing
	for(var/obj/list_element in contents)
		//Only check food items
		if(istype(list_element, /obj/item/reagent_containers/food))
			//Add to list if not already in it
			if(!LAZYFIND(food_ui_list, list_element.type))
				LAZYADD(food_ui_list, list_element.type)

	
	//Loop through food list for data to send to food tab
	for(var/item_detail in food_ui_list)
		//If none are found in contents, remove from list and move on to next element
		if(find_amount(item_detail) == 0)
			LAZYREMOVE(food_ui_list, item_detail)
			continue

		//Create needed list and variable for geting data for UI
		var/list/details = list()
		var/obj/item/reagent_containers/food/item = new item_detail

		//Get information for UI
		details["name"] = item.name
		details["quantity"] = find_amount(item)
		details["type_path"] = item.type

		//Get an image for the UI
		var/datum/data/ui_image/ui_image = new /datum/data/ui_image(item)
		details["image"] = ui_image.image

		//Add to food list
		data["food"] += list(details)

		//Delete instances to prevent server being overrun by spoopy ghost items
		qdel(item)
		qdel(ui_image)

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
			pour_glass()

/obj/machinery/food_cart/Initialize(mapload)
	. = ..()
	//Create reagents holder for drinks
	create_reagents(reagent_capacity, OPENCONTAINER | NO_REACT)
	mixer = new /obj/item/reagent_containers(src, 50)
	mixer.create_reagents(50, NO_REACT)

/obj/machinery/food_cart/Destroy()
	//Only alert others if the cart or mixer has any reagents
	if(mixer.reagents.total_volume > 0 || reagents.total_volume > 0)
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
	//Make a variable for checking amount of item
	var/obj/item/reagent_containers/food/ui_item = new received_item

	//If the vat has some of the desired item, dispense it
	if(find_amount(ui_item) > 0)
		//Select the last(most recent) of desired item
		var/obj/item/reagent_containers/food/snacks/dispensed_item = LAZYACCESS(contents, last_index(ui_item))
		//Drop it on the floor and then move it into the user's hands
		dispensed_item.forceMove(loc)
		user.put_in_hands(dispensed_item)
		user.visible_message(span_notice("[user] dispenses [dispensed_item.name] from [src]."), span_notice("You dispense [dispensed_item.name] from [src]."))
		playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
		//If the last one was dispenced, remove from UI
		if(find_amount(ui_item) == 0)
			LAZYREMOVE(food_ui_list, received_item)
	else
		//Incase the UI buttons are slow to disable themselves
		user.balloon_alert(user, "All out!")

	//Delete instance
	qdel(ui_item)

/obj/machinery/food_cart/proc/storage_single(obj/item/target_item, mob/user = usr)
	//Check if there is room
	if(contents.len - 1 < contents_capacity)
		//If item's typepath is not already in  food_ui_list, add it
		if(!LAZYFIND(food_ui_list, target_item.type))
			LAZYADD(food_ui_list, target_item.type)
		//Move item to content
		target_item.forceMove(src)
		user.visible_message(span_notice("[user] inserts [target_item] into [src]."), span_notice("You insert [target_item] into [src]."))
		playsound(src, insert_sound, 50, TRUE, extrarange = -3)

		return
	else
		//Warn about full capacity
		user.balloon_alert(user, "No space!")

/obj/machinery/food_cart/proc/pour_glass(mob/user = usr)
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

/obj/machinery/food_cart/proc/find_amount(obj/item/counting_item, target_name = null, list/target_list = null)
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

/obj/machinery/food_cart/proc/last_index(obj/item/search_item)
	var/obj/item/reagent_containers/food/snacks/item_index = null

	//Search for the same item path in storage
	for(var/i in 1 to LAZYLEN(contents))
		//Loop through entire list to get last/most recent item
		if(contents[i].type == search_item.type)
			item_index = i
	
	return item_index
