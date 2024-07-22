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
	//Max ammount of any one scoop/cone type in storage
	var/max_storage = 15
	var/selected_ice_cream = null
	//List of ice cream scoops to start with and to draw from
	var/list/ice_cream_list = list(
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/vanilla = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/chocolate = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/strawberry = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/blue = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/lemon_sorbet = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/caramel = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/banana = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/orange_creamsicle = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/peach = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/cherry_chocolate = 5,
		/obj/item/reagent_containers/food/snacks/ice_cream_scoop/meat = 5)
	//List of cones to start with and to draw from
	var/list/cone_list = list(
		/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake = 10,
		/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate = 10)


/obj/machinery/ice_cream_vat/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IceCreamVat", ui)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/ice_cream_vat/ui_data(mob/user)
	var/list/data = list()
	data["cones"] = list()
	data["ice_cream"] = list()
	for(var/cone_item in cone_list)
		var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = new cone_item
		var/list/details = list()
		details["item_name"] = cone.name
		details["item_quantity"] = cone_item
		details["item_type_path"] = cone.type

		var/icon/cone_pic = getFlatIcon(cone)
		var/md5 = md5(fcopy_rsc(cone_pic))
		if(!SSassets.cache["photo_[md5]_[cone.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[cone.name]_icon.png", cone_pic)
		SSassets.transport.send_assets(user, list("photo_[md5]_[cone.name]_icon.png" = cone_pic))
		details["cone_pic"] = SSassets.transport.get_asset_url("photo_[md5]_[cone.name]_icon.png")
		data["cones" += cone_item]
		
	return data

/obj/machinery/ice_cream_vat/ui_act(action, list/params)
	. = ..()
	if(.)
		return

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
