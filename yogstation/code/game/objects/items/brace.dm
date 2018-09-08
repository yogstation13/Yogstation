/obj/item/brace
	name = "airlock brace"
	desc = "Used to prevent airlocks from opening in emergencies. It may be removed by using a security ID."
	force = 11
	icon = 'yogstation/icons/obj/brace.dmi'
	icon_state = "brace_item"
	item_state = "brace"
	lefthand_file = 'yogstation/icons/obj/brace_lefthand.dmi' //this is so stupid
	righthand_file = 'yogstation/icons/obj/brace_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/structure/deployed_brace
	name = "airlock brace"
	desc = "Used to prevent airlocks from opening in emergencies. It may be removed by using a security ID."
	icon = 'yogstation/icons/obj/brace.dmi'
	icon_state = "brace_noshadow"
	anchored = TRUE
	density = FALSE
	req_access = list(ACCESS_SECURITY)
	layer = ABOVE_OBJ_LAYER

	var/obj/item/brace/brace_item
	var/obj/machinery/door/airlock/placed_on
	var/cover_open = FALSE

/obj/structure/deployed_brace/update_icon()
	..()
	cut_overlays()
	if(cover_open)
		add_overlay("cover_open")

/obj/structure/deployed_brace/examine(mob/user)
	. = ..()
	if(!cover_open)
		to_chat(user, "<span class='notice'>The cover is <b>screwed</b> in place.</span>")
	else
		to_chat(user, "<span class='notice'>The inside is filled with <b>pipes</b>.</span>")

/obj/structure/deployed_brace/attackby(obj/item/I, mob/user, params)
	if(get_dist(user, placed_on) > 1)
		return
	if(I.GetID())
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
		remove(user)

/obj/structure/deployed_brace/screwdriver_act(mob/user, obj/item/tool)
	if(get_dist(user, placed_on) > 1)
		return
	if(..())
		return TRUE
	cover_open = !cover_open
	tool.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] the cover.</span>")
	update_icon()

/obj/structure/deployed_brace/wrench_act(mob/user, obj/item/tool)
	if(get_dist(user, placed_on) > 1)
		return
	if(..())
		return TRUE
	if(!cover_open)
		to_chat(user, "<span class='warning'>Open the cover first!</span>")
		return
	to_chat(user, "<span class='notice'>You struggle to disable the hydraulics...</span>")
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
	if(do_after(user, 20 SECONDS, target = src))
		remove(user)

/obj/structure/deployed_brace/proc/remove(mob/user = null)
	playsound(src, 'sound/items/deconstruct.ogg', 50)
	if(user)
		to_chat(user, "<span class='notice'>You remove [src] from [placed_on].</span>") //and screw the cover back on but ssshhh
		if(user.put_in_hands(brace_item))
			brace_item = null
	qdel(src)

/obj/structure/deployed_brace/Destroy()
	if(brace_item)
		brace_item.forceMove(get_turf(src))
		brace_item = null
	if(placed_on)
		placed_on.brace = null
	return ..()

/obj/structure/deployed_brace/singularity_pull()
	return