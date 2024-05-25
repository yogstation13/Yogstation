///How much time each tile travelled will add to the cooldown.
#define COOLDOWN_PERSTEP (0.4 SECONDS)
#define COOLDOWN_STEPLIMIT (60 SECONDS)
#define COOLDOWN_FLURRYATTACK (5 SECONDS)

/obj/item/mirage_drive
	name = "mirage drive"
	desc = "A peculiar device with an almost inaudible thrumming sound coming from the center. \
		Landing near other people will slow them down and recharge the drive faster. Directly \
		traveling to someone will open a window for a concentrated assault with power proportional to distance."
	icon = 'icons/obj/device.dmi'
	icon_state = "miragedrive"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_state = "mdrive"
	w_class = WEIGHT_CLASS_SMALL

	COOLDOWN_DECLARE(last_dash)
	COOLDOWN_DECLARE(last_attack)
	var/obj/item/card/id/access_card
	var/list/moving = list()

/obj/item/mirage_drive/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id/captains_spare()

/obj/item/mirage_drive/Destroy(force=FALSE)
	QDEL_NULL(access_card)
	moving = null
	return ..()

/obj/item/mirage_drive/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	if(!COOLDOWN_FINISHED(src, last_dash))
		. += span_notice("A digital display on it reads [COOLDOWN_TIMELEFT(src, last_dash)/10].")

/obj/item/mirage_drive/afterattack(atom/target, mob/living/carbon/user)
	var/turf/T = get_turf(target)
	var/next_dash = 0
	var/list/testpath = list()
	var/bonus_cd = 0
	var/slowing = 0
	var/lagdist = 0 //for the sake of not having dragged stuff's afterimage being put on the same tile as the user's
	if(!COOLDOWN_FINISHED(src, last_dash))
		to_chat(user, span_warning("You can't use the drive for another [COOLDOWN_TIMELEFT(src, last_dash)/10] seconds!"))
		return
	testpath = get_path_to(src, T, /turf/proc/Distance_cardinal, 0, 0, 0, /turf/proc/reachableTurftestdensity, id = access_card, simulated_only = FALSE, get_best_attempt = TRUE)
	if(length(testpath) == 0)
		to_chat(user, span_warning("There's no unobstructed path to the destination!"))
		return
	if(user.legcuffed && !(target in view(9, (user))))
		to_chat(user, span_warning("Your movement is restricted to your line of sight until your legs are free!"))
		return
	moving |= user 
	for(var/mob/living/L in range(2, testpath[length(testpath)]))
		if(L != user)
			L.apply_status_effect(STATUS_EFFECT_CATCHUP)
			slowing++
	bonus_cd = COOLDOWN_PERSTEP*(length(testpath))
	next_dash = next_dash + bonus_cd
	if(next_dash >= COOLDOWN_STEPLIMIT)
		next_dash = COOLDOWN_STEPLIMIT
	if(slowing)
		next_dash = next_dash/(2*slowing)
	COOLDOWN_START(src, last_dash, next_dash)
	addtimer(CALLBACK(src, PROC_REF(reload)), COOLDOWN_TIMELEFT(src, last_dash))
	for(var/atom/movable/K in moving)
		if(K.pulling)
			conga(K)
	for(var/turf/open/next_step in testpath)
		var/datum/component/wet_floor/wetfloor = next_step.GetComponent(/datum/component/wet_floor)
		if(wetfloor)
			if(next_step.handle_slip(user))// one of your greatest enemies just freezes the floor and you go flying. you're a seasonal supervillain
				for(var/atom/movable/K in moving)
					K.forceMove(next_step)
				unload()
				return
		for(var/mob/living/speedbump in next_step)
			if(!(speedbump in moving))
				whoosh(user, speedbump)
	user.visible_message(span_warning("[user] appears at [target]!"))
	playsound(user, 'sound/effects/stealthoff.ogg', 50, 1)
	for(var/atom/movable/K in moving)
		shake_camera(K, 1, 1)
		K.forceMove(testpath[length(testpath)-lagdist])
		addtimer(CALLBACK(src, PROC_REF(nyoom), K, testpath, lagdist))
		lagdist++	
	for(var/i = 2 to length(moving))
		var/atom/movable/ahead = moving[i-1]
		ahead.start_pulling(moving[i])
	for(var/mob/living/punchingbag in testpath[length(testpath)])
		if(!(punchingbag in moving))
			flurry(user, punchingbag, length(testpath))
	unload()

/obj/item/mirage_drive/proc/reload()
	playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	return

/obj/item/mirage_drive/proc/nyoom(atom/movable/target, list/path, lagdist)
	var/list/testpath = path
	var/obj/effect/temp_visual/decoy/fading/onesecond/F = new(get_turf(target), target)
	hesfast(F, testpath, 2, lagdist)

/obj/item/mirage_drive/proc/hesfast(atom/movable/target, list/path, progress, lagdist)
	progress = progress+2
	if(progress > path.len || !(path[progress-lagdist]))
		return
	target.forceMove(path[progress-lagdist])
	addtimer(CALLBACK(src, PROC_REF(hesfast), target, path, progress, lagdist), 0.1 SECONDS)

/obj/item/mirage_drive/proc/whoosh(mob/living/user, mob/living/target)
	target.emote("spin")
	to_chat(target, span_userdanger("[user] rushes by you!"))
	target.adjust_dizzy(5 SECONDS)

/obj/item/mirage_drive/proc/flurry(mob/living/user, mob/living/target, traveldist)
	var/list/mirage = list()
	var/hurtamount = (traveldist)
	var/rushdowncd = 0
	if(!COOLDOWN_FINISHED(src, last_attack))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	user.Immobilize (0.6 SECONDS)
	if(hurtamount <= 5)
		hurtamount = 5
	if(hurtamount >= 10)
		hurtamount = 10
	mirage |= user
	target.visible_message(span_warning("[user] sets upon [target] and delivers strikes from all sides!"))
	to_chat(target, span_userdanger("[user] rains a barrage of blows on you!"))
	for(var/b = 1 to 3) 
		var/obj/effect/temp_visual/decoy/fading/onesecond/F = new(get_turf(user), user)
		mirage |= F
	blenderinstall(mirage, target, hurtamount)
	rushdowncd = COOLDOWN_FLURRYATTACK
	COOLDOWN_START(src, last_attack, rushdowncd)

/obj/item/mirage_drive/proc/blenderinstall(list/mirage, mob/living/target, hurtamount, jumpangle, limit)
	if(limit > 2)
		return
	for(var/atom/movable/K in mirage)
		jumpangle = jumpangle + 150
		var/turf/open/Q = get_step(get_turf(target), turn(target.dir, jumpangle))
		if(Q.reachableTurftestdensity(T = Q))
			K.forceMove(Q)
		else
			K.forceMove(get_turf(target))
		K.setDir(get_dir(K, target))
	var/armor = target.run_armor_check(armour_penetration = 10)
	target.apply_damage(
		damage = hurtamount,
		blocked = armor,
		wound_bonus = CANT_WOUND,
	)
	jab(target)
	limit++
	addtimer(CALLBACK(src, PROC_REF(blenderinstall), mirage, target, hurtamount, jumpangle, limit), 0.2 SECONDS)

/obj/item/mirage_drive/proc/jab(mob/living/target, limit)
	if(limit > 3)
		return
	playsound(target, get_sfx(pick(SFX_PUNCH, SFX_SWING_HIT)), 25, 1, -1)
	limit++
	addtimer(CALLBACK(src, PROC_REF(jab), target, limit), 0.1 SECONDS)

/obj/item/mirage_drive/proc/conga(atom/movable/target)
	moving |= target 
	if(target.pulling)
		conga(target.pulling)

/obj/item/mirage_drive/proc/unload(atom/movable/target)
	for(var/atom/movable/K in moving)
		moving.Remove(K)
