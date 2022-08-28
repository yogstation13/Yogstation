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
	//switch(action)


/obj/item/fishingbook/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/item/fishingbook/ui_static_data(mob/user)
	var/list/data = list()
	var/list/f_list = list()
	for(var/obj/item/reagent_containers/food/snacks/fish/f in GLOB.fish_list)
		var/list/details = list()
		details["name"] = initial(f.name)
		details["min_length"] = initial(f.min_length)
		details["max_length"] = initial(f.max_length)
		details["min_weight"] = initial(f.min_weight)
		details["max_weight"] = initial(f.max_weight)
		f_list += details
	data["f_list"] = f_list
	return data

	
