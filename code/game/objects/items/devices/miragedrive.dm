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
	var/next_dash = 0
	var/next_hit
	var/mob/living/L
	var/access_card = new /obj/item/card/id/captains_spare()

obj/item/mdrive/afterattack(atom/target, mob/user)
	var/turf/T = get_turf(target)
	zoom(T, user)

obj/item/mdrive/proc/zoom(turf/target, mob/user, turf/avoid = null, repeating = FALSE)
	var/obj/item/offhand = user.get_inactive_held_item()
	var/aoe_attack = FALSE
	var/list/testpath = list()
	if((target.density))
		return
	if(next_dash > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	testpath = get_path_to(src, target, /turf/proc/Distance_cardinal, 0, 0, 0, /turf/proc/reachableTurftestdensity, id = access_card, simulated_only = FALSE, get_best_attempt = TRUE)
	user.forceMove(testpath[testpath.len])
	var/obj/effect/temp_visual/decoy/fading/halfsecond/F = new(get_turf(user), user)
	user.visible_message(span_warning("[user] appears at [target]!"))
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
			if(get_dist(L, user) <= 1 && (next_hit < world.time) && (offhand))
				offhand.attack(L, user)
				aoe_attack = TRUE
			else 
				continue
	for(var/i in 1 to testpath.len)
		var/turf/next_step = testpath[i]
		if(ISMULTIPLE(i, 2) && (next_step))
			F.forceMove(next_step)
			sleep(0.1 SECONDS)
	if(aoe_attack == TRUE)
		next_hit = world.time + COOLDOWN_HIT
