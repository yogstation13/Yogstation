/obj/item/fishfinder
	name = "fish finder"
	desc = "A hand-held fish finder that will tell you the fishing related details of the thing scanned."
	icon = 'yogstation/icons/obj/device.dmi'
	icon_state = "fishfinder"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "healthanalyzer"
	var/beep_cooldown = 0

/obj/item/fishfinder/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(beep_cooldown < world.time)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		beep_cooldown = world.time + (4 SECONDS)
	if(!SEND_SIGNAL(target,COMSIG_FISH_FINDER_EXAMINE,user))
		return ..()

	
/obj/item/fishingbook
	name = "fish encyclopedia"
	desc = "The exciting sequel to the encyclopedia of twenty first century trains!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	item_state = "bible"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'

/obj/item/fishingbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user,src,ui)
	if(!ui)
		ui = new(user,src,"FishingEncyclopedia")
		ui.open()

/obj/item/fishingbook/ui_act(action,list/params)
	if(..())
		return

/obj/item/fishingbook/ui_static_data(mob/user)
	var/list/data = list()
	var/list/fish_list = list()
	for(var/fish in GLOB.fish_list)
		var/obj/item/reagent_containers/food/snacks/fish/F = new fish
		var/list/details = list()
		details["name"] = F.name
		details["min_length"] = F.min_length
		details["max_length"] = F.max_length
		details["min_weight"] = F.min_weight
		details["max_weight"] = F.max_weight
		var/icon/fish_icon = getFlatIcon(F)
		var/md5 = md5(fcopy_rsc(fish_icon))
		if(!SSassets.cache["photo_[md5]_[F.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[F.name]_icon.png", fish_icon)
		SSassets.transport.send_assets(user, list("photo_[md5]_[F.name]_icon.png" = fish_icon))
		details["fish_icon"] = SSassets.transport.get_asset_url("photo_[md5]_[F.name]_icon.png")
		fish_list += list(details)
		qdel(F)

	data["fish_list"] = fish_list

	return data

