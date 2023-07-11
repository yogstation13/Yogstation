#define COOLDOWN_COEF 0.4 SECONDS//determines how many deciseconds each tile traveled adds to the cooldown
#define COOLDOWN_MAX 60 SECONDS

/obj/item/mdrive
	name = "mirage drive"
	desc = "A device that functions to increase the user's kinetic energy and direct it. Should the user land near other beings, the device will draw from them, slowing them down \
	and allowing the device to be used sooner. The recharge time for the device scales with the distance traveled, capping out at one minute. If the user's legs are restrained, \
	they will only be able to jump to a target directly within their vision."
	icon = 'icons/obj/device.dmi'
	icon_state = "miragedrive"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_state = "mdrive"
	w_class = WEIGHT_CLASS_SMALL
	var/access_card = new /obj/item/card/id/captains_spare()
	COOLDOWN_DECLARE(last_dash)


/obj/item/mdrive/afterattack(atom/target, mob/living/carbon/user)
	var/turf/T = get_turf(target)
	var/next_dash = 0
	var/list/testpath = list()
	var/bonus_cd = 0
	var/slowing = FALSE
	if(target.density)
		return
	if(!COOLDOWN_FINISHED(src, last_dash))
		to_chat(user, span_warning("You can't use the drive for another [COOLDOWN_TIMELEFT(src, last_dash)/10] seconds!."))
		return
	testpath = get_path_to(src, T, /turf/proc/Distance_cardinal, 0, 0, 0, /turf/proc/reachableTurftestdensity, id = access_card, simulated_only = FALSE, get_best_attempt = TRUE)
	if(testpath.len == 0)
		to_chat(user, span_warning("There's no unobstructed path to the destination!"))
		return
	if(user.legcuffed && !(target in view(9, (user))))
		to_chat(user, span_warning("Your movement is restricted to your line of sight until your legs are free!"))
		return
	for(var/mob/living/L in range(2, testpath[testpath.len]))
		if(L != user)
			L.apply_status_effect(STATUS_EFFECT_CATCHUP)
			slowing = TRUE
	bonus_cd = COOLDOWN_COEF*testpath.len
	next_dash = next_dash + bonus_cd
	if(slowing == TRUE)
		next_dash = next_dash/2
	if(next_dash >= COOLDOWN_MAX)
		next_dash = COOLDOWN_MAX
	COOLDOWN_START(src, last_dash, next_dash)
	addtimer(CALLBACK(src, PROC_REF(reload)), COOLDOWN_TIMELEFT(src, last_dash))
	user.forceMove(testpath[testpath.len])
	var/obj/effect/temp_visual/decoy/fading/halfsecond/F = new(get_turf(user), user)
	user.visible_message(span_warning("[user] appears at [target]!"))
	playsound(user, 'sound/effects/stealthoff.ogg', 50, 1)
	for(var/i in 1 to testpath.len)
		var/turf/next_step = testpath[i]
		if(ISMULTIPLE(i, 2) && (next_step))
			F.forceMove(next_step)
			sleep(0.1 SECONDS)

/obj/item/mdrive/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	if(!COOLDOWN_FINISHED(src, last_dash))
		. += span_notice("A digital display on it reads [COOLDOWN_TIMELEFT(src, last_dash)/10].")

/obj/item/mdrive/proc/reload()
	playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	return

