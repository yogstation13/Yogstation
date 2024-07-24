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
	//Ice cream to be dispenced into cone on attackby
	var/selected_ice_cream = null
	//Cone to be dispenced with alt click
	var/selected_cone = null
	//Max amount of items that can be in vat's storage
	var/storage_capacity = 120
	//Items currently stored in the vat
	var/list/stored_items = list()
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
		details["item_quantity"] = find_amount(stored_items, item_detail)
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
			data["ice_cream"] += list(details)
		else
			data["cones"] += list(details)

	//Send stored information to UI	
	return data

/obj/machinery/ice_cream_vat/ui_act(action, list/params)
	. = ..()

	if(.)
		return

/obj/machinery/ice_cream_vat/proc/find_amount(list/target_list, target)
	var/amount = 0
	
	//Check to see if it is even in the list before going through it
	if(target_list.Find(target))

		//Loop through given list, counting every instance of the given variable
		for(var/list_item in target_list)
			if(list_item == target)
				amount += 1
	
	return amount

/obj/machinery/ice_cream_vat/Initialize(mapload)
	. = ..()
	
	//Loop through and add items from ui_list into stored_items
	for(var/item in ui_list)
		
		var/loop_cycles = 5
		var/obj/item/reagent_containers/food/snacks/check_item = new item
		
		//5 of every scoop; 10 of every cone
		if(istype(check_item, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			loop_cycles = 10

		//Add amount of items to the list depending on type, with 5 being the base amount
		for(var/i in 1 to loop_cycles)
			stored_items += item

///////////////////
//ICE CREAM CONES//
///////////////////

/obj/item/reagent_containers/food/snacks/ice_cream_cone
	name = "ice cream cone base"
	desc = "Please report this, as this should not be seen."
	icon = 'icons/obj/kitchen.dmi'
	bitesize = 3
	foodtype = GRAIN
	var/ice_creamed = FALSE //FALSE when empty, TRUE when scooped
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
	desc = "Delicious cake cone, but no ice cream."
	icon_state = "icecream_cone_waffle"
	tastes = list("bland" = 6)
	extra_reagent = /datum/reagent/consumable/nutriment
	
/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate
	name = "chocolate ice cream cone"
	desc = "Delicious chocolate cone, but no ice cream."
	icon_state = "icecream_cone_chocolate"
	tastes = list("bland" = 4, "chocolate" = 6)
	extra_reagent = /datum/reagent/consumable/coco
