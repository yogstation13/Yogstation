/obj/item/fishfinder
	name = "fish finder"
	desc = "A hand-held fish finder that will tell you the fishing related details of the thing scanned."
	icon = 'yogstation/icons/obj/device.dmi'
	icon_state = "fishfinder"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "healthanalyzer"
	
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
	data["all_fish"] = GLOB.fish_list
	return data
