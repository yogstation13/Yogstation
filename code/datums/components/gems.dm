/// Components to list other things as gems so it would have sweeping changes across all gems
/datum/component/gems
	///owning ID, used to give points when sold
	var/obj/item/card/id/claimed_by = null
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the thing that spawns in the item.
	var/sheet_type = null
	//shows this overlay when not claimed
	var/image/shine_overlay

/datum/component/gems/Initialize()
	. = ..()
	///the thing that makes it a parent 
	var/atom/parent = src.parent

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), .proc/welder_act)

	shine_overlay = image(icon = 'icons/obj/gems.dmi',icon_state = "shine")
	parent.add_overlay(shine_overlay)
	parent.pixel_x = rand(-8,8)
	parent.pixel_y = rand(-8,8)

/datum/component/gems/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Its value of [point_value] mining points can be registered by hitting it with an ID, to be claimed when sold.")

/datum/component/gems/proc/attackby(datum/source, obj/item/item, mob/living/user, params) //Stolen directly from geysers, removed the internal gps
	///yes I do need to cast this again everytime I call a parent 
	var/atom/parent = src.parent

	if(!istype(item, /obj/item/card/id))
		return
	if(claimed_by)
		to_chat(user, span_warning("This gem has already been claimed!"))
		return

	to_chat(user, span_notice("You register the precious gemstone to your ID card, and will gain [point_value] mining points when it is sold!"))
	playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

	claimed_by = item
	if(true_name)
		parent.name = true_name

	if(shine_overlay)
		parent.cut_overlay(shine_overlay)
		qdel(shine_overlay)

/datum/component/gems/proc/welder_act(datum/source, mob/living/user, obj/item/I) //Jank code that detects if the gem in question has a sheet_type and spawns the items specifed in it
	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), user, I)
	
	if(I.use_tool(src, user, 0, volume=50))
		if(src.sheet_type)
			new src.sheet_type(user.loc)
			to_chat(user, span_notice("You carefully cut [src]."))
			qdel(src)
		else
			to_chat(user, span_notice("You can't seem to cut [src]."))
	return TRUE
