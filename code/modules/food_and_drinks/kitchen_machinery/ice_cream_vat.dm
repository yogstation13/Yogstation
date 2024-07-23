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
	//Items currently stored in the vat
	var/list/stored_items = list()
	//Items to be added upon creation to the vat and what is used for the UI
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

/obj/machinery/ice_cream_vat/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IceCreamVat", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/ice_cream_vat/ui_data(mob/user)
	var/list/data = list()
	data["cones"] = list()
	data["ice_cream"] = list()
	for(var/item_detail in ui_list)

		var/list/details = list()
		var/obj/item/reagent_containers/food/snacks/item = new item_detail

		details["item_name"] = item.name
		details["item_quantity"] = find_amount(stored_items, item_detail)
		details["item_type_path"] = item.type

		var/icon/item_pic = getFlatIcon(item)
		var/md5 = md5(fcopy_rsc(item_pic))
		if(!SSassets.cache["photo_[md5]_[item.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[item.name]_icon.png", item_pic)
		SSassets.transport.send_assets(user, list("photo_[md5]_[item.name]_icon.png" = item_pic))
		details["item_image"] = SSassets.transport.get_asset_url("photo_[md5]_[item.name]_icon.png")

		if(istype(item, /obj/item/reagent_containers/food/snacks/ice_cream_scoop))
			data["ice_cream"] += list(details)
		else
			data["cones"] += list(details)
		
	return data

/obj/machinery/ice_cream_vat/ui_act(action, list/params)
	. = ..()

	if(.)
		return

/obj/machinery/ice_cream_vat/proc/find_amount(target_list, target)
	var/amount = 0
	
	for(var/list_item in target_list)
		if(list_item == target)
			amount += 1
	
	return amount

/obj/machinery/ice_cream_vat/Initialize(mapload)
	. = ..()

	for(var/item in ui_list)
		//Remember to change it to 5 scoops, 10 cones
		var/loop_cycles = 5

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
	var/extra_reagent = null //For adding chems to specific cones
	var/extra_reagent_amount = 1 //Amount of extra_reagent to add to cone

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
