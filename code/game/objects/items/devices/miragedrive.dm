#define COOLDOWN_DASH 20
#define COOLDOWN_MASH 10
#define COOLDOWN_HIT 50
/obj/item/mdrive
	name = "mirage drive"
	desc = "A device that functions to increase the user's kinetic energy and direct it. Should the user land near other beings, the device will draw from them, slowing them down \
	and allowing the device to be used sooner. Although it's too disorienting to be done with high frequency, the user can attack those they land in the immediate vicinity of."
	icon = 'icons/obj/device.dmi'
	icon_state = "miragedrive"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_state = "mdrive"
	w_class = WEIGHT_CLASS_SMALL
	var/list/path = list()
	var/next_dash = 0
	var/turf/exturf
	var/turf/noturf
	var/next_hit

obj/item/mdrive/afterattack(atom/target, mob/user)
	var/mob/living/L
	var/turf/T = get_turf(target)
	var/obj/item/offhand = user.get_inactive_held_item()
	var/aoe_attack = FALSE
	if(next_dash > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	for(var/obj/machinery/door/D in exturf)// this bit is for the sake of ignoring turfs with closed doors when it comes to making a path to the destination
		if(D.density == TRUE)
			exturf = noturf
	path = get_path_to(src, target, /turf/proc/Distance_cardinal, 0, 0, 0, /turf/proc/reachableTurftest, exclude = noturf, simulated_only = FALSE, get_best_attempt = TRUE)
	if((T.density))
		return
	var/obj/effect/temp_visual/decoy/fading/halfsecond/F = new(get_turf(user), user)
	for(var/i in 1 to path.len)
		var/turf/next_step = path[i]
		for(var/obj/machinery/door/D in next_step)
			if(D.density == TRUE)
				return
	user.forceMove(path[path.len])
	user.visible_message(span_warning("[user] appears at [T]!"))
	playsound(user, 'sound/effects/stealthoff.ogg', 50, 1, 1)
	for(L in range(2, user))
		if(L != user)
			L.apply_status_effect(STATUS_EFFECT_CATCHUP)
			next_dash = world.time + COOLDOWN_MASH
			continue
		else
			next_dash = world.time + COOLDOWN_DASH
	for(L in range(2, user))
		if(L != user)
			if(get_dist(L, user) <= 1 && (next_hit < world.time))
				offhand.attack(L, user)
				aoe_attack = TRUE
			else 
				continue
	for(var/i in 1 to path.len)
		var/turf/next_step = path[i]
		if(ISMULTIPLE(i, 2))
			F.forceMove(next_step)
			sleep(0.1 SECONDS)
	if(aoe_attack == TRUE)
		next_hit = world.time + COOLDOWN_HIT

