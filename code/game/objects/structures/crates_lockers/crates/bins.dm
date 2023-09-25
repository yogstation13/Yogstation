/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	open_flags = ALLOW_OBJECTS | ALLOW_DENSE
	delivery_icon = null

/obj/structure/closet/crate/bin/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/closet/crate/bin/update_overlays()
	. = ..()
	if(contents.len == 0)
		. += "largebing"
	else if(contents.len >= storage_capacity)
		. += "largebinr"
	else
		. += "largebino"

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = W
		to_chat(user, span_notice("You fill the bag."))
		for(var/obj/item/O in src)
			SEND_SIGNAL(T, COMSIG_TRY_STORAGE_INSERT, O, user, TRUE)
		T.update_appearance(UPDATE_ICON)
		do_animate()
	else if(istype(W, /obj/item/wrench))
		anchored = !anchored
		W.play_tool_sound(src, 75)
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, 1, -3)
	flick("animate_largebins", src)
	spawn(13)
		playsound(loc, close_sound, 15, 1, -3)
		update_appearance(UPDATE_ICON)
