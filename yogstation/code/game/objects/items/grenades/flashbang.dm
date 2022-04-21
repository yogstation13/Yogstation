/obj/item/grenade/flashbang/proc/bang(turf/T , mob/living/M)
	if (M.stat == DEAD) // They're dead!
		return
	if (istype(M.loc, /obj/vehicle/sealed))
		return
	if (istype(M.loc, /obj/mecha))
		var/obj/mecha/mech = M.loc
		if (mech.enclosed)
			return
	M.show_message(span_userdanger("BANG"), MSG_AUDIBLE)
	var/distance = max(0, get_dist(get_turf(src), T))
	if (!distance || get_atom_on_turf(src, /mob) == M)
		M.Paralyze(20 SECONDS)
		M.soundbang_act(1, 20, 10, 15)
		return
	if (iscyborg(M))
		var/mob/living/silicon/robot/C = M
		if (C.sensor_protection)					//Do other annoying stuff that isnt a hard stun if they're protected
			C.overlay_fullscreen("reducedbang", /obj/screen/fullscreen/flash/static)
			C.uneq_all()
			C.stop_pulling()
			C.break_all_cyborg_slots(TRUE)
			addtimer(CALLBACK(C, /mob/living/silicon/robot/.proc/clear_fullscreen, "reducedbang"), 3 SECONDS)
			addtimer(CALLBACK(C, /mob/living/silicon/robot/.proc/repair_all_cyborg_slots), 3 SECONDS)
			return
	var/flashed = M.flash_act(affect_silicon = TRUE)
	var/banged = M.soundbang_act(1, 20 / max(1, distance), rand(0, 5))
	if (flashed && M.eye_blurry < 2 SECONDS) // you can't stack a shitton of eye blur to half-blind someone for half an hour, sorry!
		M.blur_eyes(10 SECONDS)
	if (flashed || banged)
		M.Knockdown(5 SECONDS)
		M.Dizzy(flashed && banged ? 10 SECONDS : 5 SECONDS)
