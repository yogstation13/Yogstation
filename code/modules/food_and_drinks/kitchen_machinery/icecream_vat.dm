/obj/machinery/icecream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	component_parts = list( new /obj/item/stock_parts/matter_bin,
							new /obj/item/circuitboard/machine/icecream_vat)
	circuit = /obj/item/circuitboard/machine/icecream_vat
	//Ice cream to be dispensed into cone on attackby
	var/obj/item/reagent_containers/food/snacks/ice_cream_scoop/selected_scoop_type
	//Cone to be dispensed with alt click
	var/obj/item/reagent_containers/food/snacks/selected_cone_type
	//Max amount of items that can be in vat's storage
	var/storage_capacity = 80
	//If it starts empty or not
	var/start_empty = FALSE
	//If the vat will perform scooping_failure proc
	var/scoop_fail = TRUE
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
	//If adding new items to the list: INCREASE STORAGE_CAPACITY TO ACCOUNT FOR ITEM!!
	
/obj/machinery/icecream_vat/ui_interact(mob/user, datum/tgui/ui) //Thanks bug eating lizard for helping me with the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IceCreamVat", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/icecream_vat/ui_data(mob/user)
	//Define variables from UI
	var/list/data = list()
	data["cones"] = list()
	data["ice_cream"] = list()
	data["tabs"] = list()
	data["storage"] = list()

	//Loop through starting list for data to send to main tab
	for(var/obj/item/reagent_containers/food/snacks/item_path as anything in ui_list)

		//Create needed list and variable for geting data for UI
		var/list/details = list()

		//Get information for UI
		details["item_name"] = item_path::name
		details["item_quantity"] = find_amount(item_path)
		details["item_type_path"] = item_path


		var/obj/item/reagent_containers/food/snacks/initialized_item = new item_path
		//Get an image for the UI
		var/icon/item_pic = getFlatIcon(initialized_item)
		var/md5 = md5(fcopy_rsc(item_pic))
		if(!SSassets.cache["photo_[md5]_[initialized_item.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[initialized_item.name]_icon.png", item_pic)
		SSassets.transport.send_assets(user, list("photo_[md5]_[initialized_item.name]_icon.png" = item_pic))
		details["item_image"] = SSassets.transport.get_asset_url("photo_[md5]_[initialized_item.name]_icon.png")

		//Sort into different data lists depending on what the item is
		if(ispath(item_path, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))
			details["selected_item"] = selected_scoop_type
			data["ice_cream"] += list(details)
		else
			details["selected_item"] = selected_cone_type
			data["cones"] += list(details)
		qdel(initialized_item)

	//Loop through children of /datum/info_tab/icecream_vat for data to send to info tab
	for(var/datum/info_tab/icecream_vat/info_detail_path as anything in subtypesof(/datum/info_tab/icecream_vat))
		
		//Create needed list and variable for geting data for UI
		var/list/details = list()

		//Get info from children
		details["section_title"] = info_detail_path::section
		details["section_text"] = info_detail_path::section_text

		//Add info to data
		data["info_tab"] += list(details)

	//Get content and capacity data
	data["contents_length"] = contents.len
	data["storage_capacity"] = storage_capacity

	//Send stored information to UI	
	return data

/obj/machinery/icecream_vat/ui_act(action, list/params)
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

/obj/machinery/icecream_vat/Initialize(mapload)
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

/obj/machinery/icecream_vat/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		//Capacity increases by 25 per item rating above T1
		storage_capacity = initial(storage_capacity) + ( 25 * (B.rating - 1))

/obj/machinery/icecream_vat/examine(mob/user)
	. = ..()

	//Selected cones
	if(selected_cone_type == null)
		. += span_notice("You can <b>Alt Click</b> to dispense a cone once one is selected.")
	else
		. += span_notice("<b>Alt Click</b> to dispense [selected_cone_type::name].")

	//Selected scoops
	if(selected_scoop_type == null)
		. += span_notice("No ice cream scoop currently selected.")
	else
		. += span_notice("[selected_scoop_type::name] is currently selected.")

	//Scooping cone instruction
	. += span_notice("<b>Right Click</b> to add a scoop to a cone.")

//For dispensing selected cone
/obj/machinery/icecream_vat/AltClick(mob/living/carbon/user)
	if(selected_cone_type != null)
		dispense_item(selected_cone_type)
	else
		user.balloon_alert(user, "None selected!")


/obj/machinery/icecream_vat/attackby_secondary(obj/item/A, mob/user, params)
	//For scooping cones
	scoop_cone(A)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

//For adding items to storage
/obj/machinery/icecream_vat/attackby(obj/item/A, mob/user, params)

	//For adding individual items
	if(istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_cone) || istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))	
		storage_single(A)

	//Adding carton contents to storage
	else if(istype(A, /obj/item/storage/box/ice_cream_carton))
		storage_container(A)

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, A))
		if(panel_open)
			add_overlay("[initial(icon_state)]_panel")
		else
			cut_overlay("[initial(icon_state)]_panel")
		updateUsrDialog()
		return

	if(default_deconstruction_crowbar(A))
		updateUsrDialog()
		return

	..()

/obj/machinery/icecream_vat/proc/find_amount(obj/item/counting_item, target_name = null, list/target_list = null)
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

/obj/machinery/icecream_vat/proc/dispense_item(obj/item/reagent_containers/food/snacks/received_item_type, mob/user = usr)
	//If the vat has some of the desired item, dispense it
	if(find_amount(received_item_type) > 0)
		//Select the last(most recent) of desired item
		var/obj/item/reagent_containers/food/snacks/dispensed_item = LAZYACCESS(contents, last_index(received_item_type))
		//Drop it on the floor and then move it into the user's hands
		dispensed_item.forceMove(loc)
		user.put_in_hands(dispensed_item)
		user.visible_message(span_notice("[user] dispenses [received_item_type::name] from [src]."), span_notice("You dispense [received_item_type::name] from [src]."))
		playsound(src, dispense_sound, 25, TRUE, extrarange = -3)
	else
		//For Alt click and because UI buttons are slow to disable themselves
		user.balloon_alert(user, "All out!")

/obj/machinery/icecream_vat/proc/select_item(obj/item/reagent_containers/food/snacks/received_item_type, mob/user = usr)
	//Deselecting
	if(ispath(received_item_type, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
		if(selected_cone_type == received_item_type)
			user.visible_message(span_notice("[user] deselects [received_item_type::name] from [src]."), span_notice("You deselect [received_item_type::name] from [src]."))
			selected_cone_type = null
			playsound(src, select_sound, 25, TRUE, extrarange = -3)
			return

	else if(selected_scoop_type == received_item_type)
		user.visible_message(span_notice("[user] deselects [received_item_type::name] from [src]."), span_notice("You deselect [received_item_type::name] from [src]."))
		selected_scoop_type = null
		playsound(src, select_sound, 25, TRUE, extrarange = -3)
		return

	//Selecting
	if(find_amount(received_item_type) > 0)
		//Set item to selected based on its type
		if(ispath(received_item_type, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			selected_cone_type = received_item_type
		else
			selected_scoop_type = received_item_type
		playsound(src, select_sound, 25, TRUE, extrarange = -3)
		user.visible_message(span_notice("[user] sets [src] to dispense [received_item_type::name]s."), span_notice("You set [src] to dispense [received_item_type::name]s."))
	//Prevent them from selecting items that the vat does not have
	else
		user.balloon_alert(user, "All out!")

/obj/machinery/icecream_vat/proc/last_index(obj/item/search_item)

	var/obj/item/reagent_containers/food/snacks/item_index

	//Search for the same item path in storage
	for(var/i in 1 to LAZYLEN(contents))
		//Loop through entire list to get last/most recent item
		if(contents[i].type == search_item.type)
			item_index = i
	
	return item_index

/obj/machinery/icecream_vat/proc/storage_single(obj/item/target_item, mob/user = usr)
	//Check if there is room
	if(contents.len < storage_capacity)
		//If a cone, check if it has already been scooped. If it has, do not store it
		if(istype(target_item, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = target_item
			if(cone.scoops > 0)
				user.balloon_alert(user, "Cannot store scooped cones!")

				return
		//Move item to content
		target_item.forceMove(src)
		user.visible_message(span_notice("[user] inserts [target_item] into [src]."), span_notice("You insert [target_item] into [src]."))
		playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

		return
	else
		//Warn about full capacity
		user.balloon_alert(user, "No space!")

/obj/machinery/icecream_vat/proc/storage_container(obj/item/storage/box/ice_cream_carton/target_container, mob/user = usr)
	var/end_message = "[user] empties the [target_container] into [src]."
	var/end_self_message = "You empty the [target_container] into [src]."
	//Check to see if it is empty
	if(target_container.contents.len > 0 && contents.len < storage_capacity)
		//Hide container's storage UI to prevent ghost scoop bug
		SEND_SIGNAL(target_container, COMSIG_TRY_STORAGE_HIDE_FROM, user)
		//Loop through all contents
		for(var/obj/item/reagent_containers/food/snacks/carton_item in target_container)
			//Transfer items one at a time
			carton_item.forceMove(src)
			if(contents.len >= storage_capacity)
				//Unique message depending on carton and vat contents
				if(target_container.contents.len == 0)
					end_message = "[user] empties the [target_container] into [src], filling it to its capacity."
					end_self_message = "You empty the [target_container] into [src], filling it to its capacity."
				else
					end_message = "[user] fills [src] to its capacity, with some [target_container.contents_type] still in the [target_container]."
					end_self_message = "You fill [src] to its capacity, with some [target_container.contents_type] still in the [target_container]."
				break

		user.visible_message(span_notice(end_message), span_notice(end_self_message))
		playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

		return
	else
		if(target_container.contents.len == 0)
			user.balloon_alert(user, "[target_container.contents_type] empty!")
		else
			user.balloon_alert(user, "Vat full!")
		return

/obj/machinery/icecream_vat/proc/scoop_cone(obj/item/target_cone, mob/user = usr)
	//Check if item is a cone
	if(istype(target_cone, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
		var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = target_cone
		//Check if a scoop has been selected
		if(selected_scoop_type != null)
			//Check if there are any of selected scoop in contents
			if(find_amount(selected_scoop_type) > 0)
				//Increase scooped variable
				cone.scoops += 1
				//Select last of selected scoop in contents
				var/obj/item/reagent_containers/food/snacks/cone_scoop = LAZYACCESS(contents, last_index(selected_scoop_type))
				//Remove scoop from contents
				cone_scoop.forceMove(loc)
				//Increase maximum volume to make room for scoop's chems
				cone.reagents.maximum_volume += 15
				//Add scoop's reagents to cone
				cone_scoop.reagents.trans_to(cone, cone_scoop.reagents.total_volume, transfered_by = user)
				//Change cone's foodtype to scoop's
				cone.foodtype = cone_scoop.foodtype
				//Add scoop to scoop_names list
				LAZYADD(cone.scoop_names, cone_scoop.name)
				//Determine how to add the overlay and change description and name depending on scoops value
				if(cone.scoops == 1)
					//Add overlay of scoop to cone
					cone.add_overlay(cone_scoop.icon_state)
					//Change name and desc
					name_cone(cone)
				else
					//Add overlay but with y-axis position depending on amount of scoops
					var/mutable_appearance/TOP_SCOOP = mutable_appearance(cone_scoop.icon, "[cone_scoop.icon_state]")
					TOP_SCOOP.pixel_y = 2 * (cone.scoops - 1)
					cone.add_overlay(TOP_SCOOP)
					//Change name and desc based on scoop amount
					name_cone(cone)
				//Alert that the cone has been scooped
				user.visible_message(span_notice("[user] scoops a [cone_scoop.name] into the [cone.name]"), span_notice("You scoop a [cone_scoop.name] into the [cone.name]"))
				//Delete scoop
				qdel(cone_scoop)
				//Dispencing sound
				playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)

				//If there are more than four scoops and scoop_fail is true, check for scooping failure
				if(cone.scoops > 4 && scoop_fail)
					scooping_failure(cone, usr)

			//Warn user that there are no selected scoops left
			else
				user.balloon_alert(user, "No selected scoops in storage!")

		//Warn user about no selected scoop
		else
			user.balloon_alert(user, "No scoop selected!")

	//Warn user about invalid item
	else
		user.balloon_alert(user, "Invalid item!")

/obj/machinery/icecream_vat/proc/name_cone(obj/item/reagent_containers/food/snacks/ice_cream_cone/target_cone)
	//Change name and desc based on amount of scoops
	switch(target_cone.scoops)
		if(1)
			target_cone.name = "Scooped [target_cone.base_name]"
			target_cone.desc = "A delicious [target_cone.name] with a [target_cone.scoop_names[1]]."
		if(2)
			target_cone.name = "Double scooped [target_cone.base_name]"
			target_cone.desc = "A delicious [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(3)
			target_cone.name = "Thrice cream [target_cone.base_name]"
			target_cone.desc = "A delicious [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(4)
			target_cone.name = "Quadruple scooped [target_cone.base_name]"
			target_cone.desc = "A delicious [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(5)
			target_cone.name = "Quintuple scooped [target_cone.base_name]"
			target_cone.desc = "A delicious [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(6 to 9)
			target_cone.name = "Tower scooped [target_cone.base_name]"
			target_cone.desc = "A tall [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(10 to 14)
			target_cone.name = "Scoopimanjaro [target_cone.base_name]"
			target_cone.desc = "A towering [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(15 to 19)
			target_cone.name = "Scooperest [target_cone.base_name]"
			target_cone.desc = "A mountainous [target_cone.name] with[list_scoops(target_cone.scoop_names)]."
		if(20 to INFINITY)
			target_cone.name = "Scoopageddon [target_cone.base_name]"
			target_cone.desc = "A [target_cone.name] of apocalyptic proportions with[list_scoops(target_cone.scoop_names)]."

//Create properly formated string for showing a cone's scoops in its desc
/obj/machinery/icecream_vat/proc/list_scoops(list/scoops)
	//List used for searching through list
	var/list/unique_scoops = null
	//What to return for the desc
	var/final_string = ""

	//Populate unique_scoops based on given list
	for(var/search_item in scoops)
		if(!unique_scoops)
			LAZYADD(unique_scoops, search_item)
		else if(!LAZYFIND(unique_scoops, search_item))
			LAZYADD(unique_scoops, search_item)
	
	//Use populated unique_scoops to make final_string
	for(var/search_name in unique_scoops)
		//If search_name is the only name in the list
		if(find_amount(target_name = search_name, target_list = scoops) == LAZYLEN(scoops))
			final_string = " [LAZYLEN(scoops)] [unique_scoops[1]]s"
			break
		else
			//Check if it is not the last name in the list
			if(LAZYFIND(unique_scoops, search_name) != LAZYLEN(unique_scoops))
				//Check if it is the only instance in the list
				if(find_amount(target_name = search_name, target_list = scoops) == 1)
					final_string += " 1 [search_name],"
				else
					final_string += " [find_amount(target_name = search_name, target_list = scoops)] [search_name]s,"
			else
				//Check if it is the only instance in the list
				if(find_amount(target_name = search_name, target_list = scoops) == 1)
					final_string += " and 1 [search_name]"
				else
					final_string += " and [find_amount(target_name = search_name, target_list = scoops)] [search_name]s"

	return final_string

/obj/machinery/icecream_vat/proc/scooping_failure(obj/item/reagent_containers/food/snacks/ice_cream_cone/target_cone, mob/living/carbon/human/user = usr)
	//Base chance of failure
	var/base_chance = 15
	//Chance of failure that is multiplied by scoop count minus 4
	var/added_chance = 5
	//Total chance of failure
	var/failure_chance = base_chance + (added_chance * (target_cone.scoops - 4))

	if(prob(failure_chance))
		switch(target_cone.scoops)
			//Alert user
			if(5 to 9)
				user.visible_message(span_alert("[user] accidently crushes their [target_cone.name] while trying to add another scoop!"), span_alert("You accidently crush your [target_cone.name] while trying to add another scoop!"))
			//Alert user and damage them based on amount of scoops
			if(10 to 20)
				user.visible_message(span_alert("[user] accidently tips their [target_cone.name] over and is hit in the ensuing avalanche!"), span_alert("You accidently tip your [target_cone.name] over and are hit by the ensuing avalanche!"))
				//Maximum of 20 brute damage from failure
				user.adjustBruteLoss(target_cone.scoops)
				//Cool them down
				user.adjust_bodytemperature((-6 * target_cone.scoops) * TEMPERATURE_DAMAGE_COEFFICIENT, target_cone.scoops)
			//Punish them for their hubris
			if(21 to INFINITY)
				user.visible_message(span_alert("[user] is minced in a flash of light!"), span_alert("Within nanoseconds, your [target_cone.name] colapses into itself. The ensuing micro singularity rips you to shreads!"))
				//Regret
				user.say(pick("Oh no...", "Mein gott...", "Uh oh...", "Fuuuuu...", "Shiiii...", "Not yoggers..."), forced="scoop fail")
				//Explode their spessmen
				explosion(user.loc,1,1,1,flash_range = 15)
		//Delete cone after failure
		qdel(target_cone)

/obj/machinery/icecream_vat/empty
	start_empty = TRUE

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
	var/base_name = null
	//How many scoops it has
	var/scoops = 0
	//Variables for cone's scoops
	var/list/scoop_names = null
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

//Hand scooping only allows one scoop. Vat needed for multi-scooping
/obj/item/reagent_containers/food/snacks/ice_cream_cone/attackby(obj/item/A, mob/user, params)
	//Check if item is a scoop
	if(istype(A, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))
		//Check if not already scooped
		if(src.scoops == 0)
			//Make variables for scoop and cone for readability
			var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = src
			var/obj/item/reagent_containers/food/snacks/cone_scoop = A
			//Increase maximum volume to make room for scoop's chems
			cone.reagents.maximum_volume += 15
			//Add scoop's reagents to cone
			cone_scoop.reagents.trans_to(cone, cone_scoop.reagents.total_volume, transfered_by = user)
			//Change cone's foodtype to scoop's
			cone.foodtype = cone_scoop.foodtype
			//Add scoop to scoop_names list
			LAZYADD(cone.scoop_names, cone_scoop.name)
			//Change description of cone
			cone.desc = "A hand scooped [cone.base_name] with a [cone_scoop.name]. Kinda gross."
			//Add overlay of scoop to cone
			cone.add_overlay(cone_scoop.icon_state)
			//Alert that the cone has been scooped
			user.visible_message(span_notice("[user] hand scoops a [cone_scoop.name] into the [cone.name]"), span_notice("You hand scoop a [cone_scoop.name] into the [cone.name]"))
			//Change the name
			cone.name = "Hand scooped [cone.base_name]"
			//Increase scooped variable
			cone.scoops += 1
			//Delete scoop
			qdel(cone_scoop)

			playsound(src, 'sound/effects/rustle2.ogg', 50, TRUE, extrarange = -3)
		
		//Warn about no multi-scooping with hands
		else
			user.balloon_alert(user, "Cannot multi-scoop with hands!")

	..()

/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake
	name = "cake ice cream cone"
	desc = "A delicious cake cone, but with no ice cream."
	icon_state = "icecream_cone_waffle"
	tastes = list("bland" = 6)
	base_name = "cake ice cream cone"
	extra_reagent = /datum/reagent/consumable/sugar
	
/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate
	name = "chocolate ice cream cone"
	desc = "A delicious chocolate cone, but with no ice cream."
	icon_state = "icecream_cone_chocolate"
	tastes = list("bland" = 4, "chocolate" = 6)
	base_name = "chocolate ice cream cone"
	extra_reagent = /datum/reagent/consumable/coco

///////////////////////////
//ICE CREAM CONE CRAFTING//
///////////////////////////

/obj/item/reagent_containers/food/snacks/raw_cone
	name = "base raw cone"
	desc = "Please report this, as this should not be seen."
	icon = 'icons/obj/food/food_ingredients.dmi'
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("bland" = 6)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/raw_cone/cake
	name = "raw cake cone"
	desc = "A raw cake cone that needs to be processed."
	icon_state = "raw_cake_cone"

/obj/item/reagent_containers/food/snacks/raw_cone/chocolate
	name = "raw chocolate cone"
	desc = "A raw chocolate cone that needs to be processed."
	icon_state = "raw_chocolate_cone"
