/obj/machinery/griddle
	name = "griddle"
	desc = "Because using pans is for pansies."
	icon = 'icons/obj/machines/kitchenmachines.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/griddle
	resistance_flags = FIRE_PROOF

	///Things that are being griddled right now
	var/list/griddled_objects = list()
	///Looping sound for the grill
	var/datum/looping_sound/grill/grill_loop
	///Whether or not the machine is turned on right now
	var/on = FALSE
	///What variant of griddle is this?
	var/variant = 1
	///How many shit fits on the griddle?
	var/max_items = 8

/obj/machinery/griddle/Initialize()
	. = ..()
	end_processing() //doesn't start on
	grill_loop = new(list(src), FALSE)
	variant = rand(1,3)

/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_crowbar(I))
		return

	if(!on && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return

	if(griddled_objects.len >= max_items)
		to_chat(user, "<span class='notice'>[src] can't fit more items!</span>")
		return
	if(user.transferItemToLoc(I, src))
		I.pixel_x = pick(-(world.icon_size/4), 0, (world.icon_size/4))
		I.pixel_y = pick(-(world.icon_size/8), 0, (world.icon_size/4))
		var/list/click_params = params2list(params)
		//Attempt to center the icon where the user clicked.
		if(click_params && click_params["icon-x"] && click_params["icon-y"])
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/4), world.icon_size/4)
			I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/8), world.icon_size/4)
		to_chat(user, "<span class='notice'>You place [I] on [src].</span>")
		AddToGrill(I, user)
		update_icon()
	else
		return ..()

/obj/machinery/griddle/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		return
	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	update_icon()
	update_grill_audio()


/obj/machinery/griddle/proc/AddToGrill(obj/item/item_to_grill, mob/user)
	vis_contents += item_to_grill
	griddled_objects += item_to_grill
	//item_to_grill.flags_1 |= IS_ONTOP_1
	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, .proc/ItemMoved,TRUE)
	RegisterSignal(item_to_grill, COMSIG_GRILL_COMPLETED, .proc/GrillCompleted)
	update_grill_audio()

/obj/machinery/griddle/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	//I.flags_1 &= ~IS_ONTOP_1
	griddled_objects -= I
	vis_contents -= I
	UnregisterSignal(I, COMSIG_GRILL_COMPLETED)
	update_grill_audio()

/obj/machinery/griddle/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	griddled_objects -= source //Old object
	AddToGrill(grilled_result)

/obj/machinery/griddle/proc/update_grill_audio()
	if(on && griddled_objects.len)
		grill_loop.start()
	else
		grill_loop.stop()


/obj/machinery/griddle/process(delta_time)
	..()
	listclearnulls(griddled_objects)
	for(var/i in griddled_objects)
		var/obj/item/griddled_item = i
		if(QDELETED(griddled_item))
			griddled_objects -= i
			return
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILLED, src, delta_time) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(prob(10))
			visible_message("<span class='danger'>[griddled_item] doesn't seem to be doing too great on the [src]!</span>")

/obj/machinery/griddle/update_icon()
	. = ..()
	if(panel_open)
		icon_state = "griddle[variant]_o"
	else
		icon_state = "griddle[variant]_[on ? "on" : "off"]"
