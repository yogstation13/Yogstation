/obj/item/laserlevel
	name = "laser level"
	desc = "Emits a light grid for easy construction."
	icon = 'icons/obj/tools.dmi'
	icon_state = "laser-level"
	item_state = "laserlevel"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/lightlevel = 0;
	var/brightness_on = 4 //range of light when on
	var/flashlight_power = 1 //strength of the light when on

/obj/item/laserlevel/Initialize()
	. = ..()
	update_icon()

/obj/item/laserlevel/attack_self(mob/user)
	lightlevel--;
	if(lightlevel < 0)
		lightlevel = 3
	playsound(user, lightlevel ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, 1)
	if(lightlevel)
		set_light(l_range = lightlevel / 2, l_power = (lightlevel / 4), l_color = "#00ff00")
	else
		set_light(0)
	update_icon()
	update_overlay(user)

/obj/item/laserlevel/update_icon()
	cut_overlays()
	add_overlay("[initial(icon_state)][lightlevel]")
	return


/obj/item/laserlevel/proc/update_overlay(mob/user)
	user.clear_fullscreen("laser",0)
	if(lightlevel)
		var/atom/movable/screen/fullscreen/laser/laserscreen = user.overlay_fullscreen("laser", /atom/movable/screen/fullscreen/laser)
		laserscreen.alpha = 42 * lightlevel

/obj/item/laserlevel/dropped(mob/user, silent)
	. = ..()
	user.clear_fullscreen("laser",0)

/obj/item/laserlevel/pickup(mob/user)
	. = ..()
	update_overlay(user)

