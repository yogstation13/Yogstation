/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7 //how many tiles away the mob will be stunned.

/obj/item/grenade/flashbang/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, LIGHT_COLOR_WHITE, (flashbang_range + 2), 4, 2)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(M), M)
	qdel(src)

/obj/item/grenade/flashbang/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.show_message(span_userdanger("BANG"), MSG_AUDIBLE)
	var/distance = max(0,get_dist(get_turf(src),T))
	if(!distance || loc == M || loc == M.loc)	//Stop allahu akbarring rooms with this.
		M.Knockdown(20 SECONDS)
		M.soundbang_act(1, 20, 10, 15)
		return
	if(iscyborg(M))
		var/mob/living/silicon/robot/C = M
		if(C.sensor_protection)					//Do other annoying stuff that isnt a hard stun if they're protected
			C.overlay_fullscreen("reducedbang", /atom/movable/screen/fullscreen/flash/static)
			C.uneq_all()
			C.stop_pulling()
			C.break_all_cyborg_slots(TRUE)
			addtimer(CALLBACK(C, /mob/living/silicon/robot/.proc/clear_fullscreen, "reducedbang"), 3 SECONDS)
			addtimer(CALLBACK(C, /mob/living/silicon/robot/.proc/repair_all_cyborg_slots), 3 SECONDS)
			return

/*yogs begin*/
	var/time_before_fade = (max(15 / max(1, distance), 15) SECONDS)
	world.log << time_before_fade
	var/flashed = M.flash_act(1, 0, 1, -2.30016220670598061975e-29, /atom/movable/screen/fullscreen/flash, 25, time_before_fade)

	if (flashed)
		M.add_movespeed_modifier(MOVESPEED_ID_FLASHBANG, TRUE, 1000, override=TRUE, multiplicative_slowdown=0.5, movetypes=(~FLYING))
		addtimer(CALLBACK(M, /mob/.proc/remove_movespeed_modifier, MOVESPEED_ID_FLASHBANG), 2 SECONDS)

	M.soundbang_act(1, 20/max(1,distance), rand(0, 5))
