/* the samuel sword
 * this weapon contains 2 parts: the sword (good at swording) and the sheath (handles abilities)
 * ability 1: a mobility/offense attack which after a short delay quickly moves you to the target location, if something interrupts your movement, the dash stops and they take heavy damage
 * ability 2: a close range defense attack, after a short delay, slash the 3 tiles in front of you for heavy damage. This will delimb any arms with with less than 30 health.
*/

/obj/item/melee/musarama
	name = "Musarama"
	desc = "A blade of legendary quality, boasting an array of energy projectors for extreme precision and cutting power."
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	color = COLOR_RED
	force = 35
	armour_penetration = 60
	block_chance = 40
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	attack_verb = list("slashed", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/melee/musarama/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 5 SECONDS, 100, 40) // BULLSEYE

/obj/item/storage/belt/musarama_sheath
	name = "gunsheath"
	desc = "A sheath for a sword, capable of explosively releasing its contained weapon. Contains a DNA lock to prevent unauthorized use."
	icon_state = "sheath"
	item_state = "sheath"
	/// the blade we spawn with, used to easily keep track of the piece of shit since we care about it quite a lot
	var/obj/item/melee/musarama/blade
	///the mind that owns this blade, not using actual DNA because this is easier and less likely to break
	var/datum/mind/owner
	///used to store people who have been hit by a dash attack
	var/list/got_stabbed

/obj/item/storage/belt/musarama_sheath/examine(mob/user)
	. = ..()
	. += span_notice("Use the sheath in-hand to lock it to your DNA, allowing you to use the blade to its full effectiveness")
	. += span_notice("Alt+click a tile to dash to it, hitting anyone along your path for light damage, directly hitting someone will deal heavier damage and stop the dash.")
	. += span_notice("Alt+click yourself to prepare a wide, close range slash.")
	. += span_notice("Both abilities require the sword to be inside the sheath and will take 2 seconds to charge, but block all incoming damage while charging.")

/obj/item/storage/belt/musarama_sheath/PopulateContents()
	blade = new /obj/item/melee/musarama(src)

/obj/item/storage/belt/musarama_sheath/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/melee/musarama
		))

/obj/item/storage/belt/musarama_sheath/attack_self(mob/user)
	if(owner)
		to_chat(user, span_warning("The sheath's DNA lock has already been set."))
		return
	if(iscarbon(user) && user.mind) //xeno with a sword? ??? ? ? ?? ? ? ?? ? ? ?? ? ? ? ?  ??
		to_chat(user, span_notice("You lock the sheath to your DNA, allowing you to use it and its sword to their fullest capabilities!"))
		owner = user.mind
		RegisterSignal(user, COMSIG_ALT_CLICK_ON, .proc/use_ability) //we component now boys

/obj/item/storage/belt/musarama_sheath/proc/use_ability(mob/living/carbon/C, atom/target)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.belt != src) //yes this is stupid
			return
	else if(!(src in C.contents))
		return
	if(!(blade in contents))
		to_chat(C, span_warning("You need to have the sword in the sheathe to do much of anything with it!"))
		return
	if(C.mind != owner)
		to_chat(C, span_warning("The DNA lock on [src] flashes red; it appears that function is locked."))
	if(target == C || (C in target.contents))
		slash(C)
	else
		charge(C, target)

///slash attack, 2 seconds of waiting then we stab anyone in front of us really hard.
/obj/item/storage/belt/musarama_sheath/proc/slash(mob/user)
	var/stored_move_resist = user.move_resist
	var/stored_pull_resist = user.pull_force
	to_chat(user, span_warning("You prepare to unleash your blade for a close range strike..."))
	block_chance = 200
	user.move_resist = MOVE_FORCE_VERY_STRONG
	user.pull_force = MOVE_FORCE_VERY_STRONG
	if(!do_after(user, 2 SECONDS, target = src))
		to_chat(user, span_warning("You were interrupted!"))
		block_chance = initial(block_chance)
		user.move_resist = stored_move_resist
		user.pull_force = stored_pull_resist
		return
	user.visible_message(span_warning("[user]'s [blade] suddenly explodes from [src], slashing everyone in front of them!"), span_warning("You pull [src]'s trigger and slash [blade] in front of you!"), span_italics("You hear a loud bang!"))
	user.put_in_active_hand(blade)
	playsound(user, "sound/weapons/shotgunshot.ogg", 50)
	var/turf/user_turf = get_turf(user)
	var/dir_to_attack = get_dir(user_turf, get_step(user_turf, user.dir))
	for(var/mob/living/L in user_turf)
		if(user)
			continue
		if(user.Adjacent(L))
			blade.melee_attack_chain(user, L)
	var/static/list/musamara_angles = list(0, -45, 45) //this is copied from cleaving saw code
	for(var/i in musamara_angles)
		var/turf/T = get_step(user_turf, turn(dir_to_attack, i))
		for(var/mob/living/L in T)
			if(user.Adjacent(L))
				blade.melee_attack_chain(user, L)
	block_chance = initial(block_chance) //to do check if this can be flattened SAFELY
	user.move_resist = stored_move_resist
	user.pull_force = stored_pull_resist

//charge attack, 2 seconds of waiting then move really fast at something. if we hit anything we try to stab it really hard
/obj/item/storage/belt/musarama_sheath/proc/charge(mob/living/carbon/user, atom/target)
	if(!istype(user))
		return
	var/stored_move_resist = user.move_resist
	var/stored_pull_resist = user.pull_force
	to_chat(user, span_warning("You prepare to unleash your blade for a long range dash..."))
	block_chance = 200 //yes block chance of over 100 does matter
	user.move_resist = MOVE_FORCE_VERY_STRONG
	user.pull_force = MOVE_FORCE_VERY_STRONG
	if(!do_after(user, 2 SECONDS, target = src, extra_checks = CALLBACK(src, .proc/range_check, user, target)))
		to_chat(user, span_warning("You were interrupted!"))
		block_chance = initial(block_chance)
		user.move_resist = stored_move_resist
		user.pull_force = stored_pull_resist
		return
	user.visible_message(span_warning("[user] suddenly flies forwards!"), span_warning("You ready [src]'s trigger, dashing forwards!"))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_move)
	var/turf/targeted_turf = get_turf(target)
	got_stabbed = list()
	got_stabbed[target] = TRUE // so we don't hit them twice

	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consecutive_failures = 0
	var/hit_target = FALSE
	var/turf/next_turf
	while(--safety && (get_turf(user) != targeted_turf))
		next_turf = get_step(user, get_dir(user, targeted_turf))
		for(var/mob/living/L in next_turf) //check if we are going to be interrupted by someone who is about to have a bad day
			if(L == target || L.density)
				blade.force *= 1.5
				user.put_in_active_hand(blade) //so the sword shows up when stabbing
				blade.melee_attack_chain(user, L)
				blade.force /= 1.5
				user.visible_message(span_warning("[blade] suddenly explodes out of [src], slashing [L] with insane speed as [user] catches it!"), span_warning("You pull [src]'s trigger, catching [blade] as it slices [L]"), span_italics("You hear a loud bang!"))
				playsound(user, "sound/weapons/shotgunshot.ogg", 50)
				hit_target = TRUE
				break
		if(hit_target)
			break
		var/success = step_towards(user, targeted_turf) //This does not try to go around obstacles.
		if(!success)
			success = step_to(user, targeted_turf) //this does
		if(!success)
			if(++consecutive_failures >= 3) //if 3 steps don't work
				break //just stop
		else
			consecutive_failures = 0
		if(user.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE)) //actually down? stop.
			break
		if(!(src in user))
			break
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.belt != src) //yes this is stupid
				break
		sleep(world.tick_lag)

	got_stabbed = null
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	block_chance = initial(block_chance)
	user.move_resist = stored_move_resist
	user.pull_force = stored_pull_resist

/obj/item/storage/belt/musarama_sheath/proc/on_move()
	var/mob/living/carbon/C = loc
	if(!C) //Idon't know how this could happen but ok
		return
	blade.force *= 0.5 //oh come on it's an autoattack
	for(var/mob/living/all_targets in dview(1, get_turf(C)))
		if(!got_stabbed[all_targets] && (all_targets != C))
			got_stabbed[all_targets] = TRUE
			C.put_in_active_hand(blade) //so the sword shows up when stabbing
			blade.melee_attack_chain(C, all_targets)
			blade.forceMove(src)
	blade.force *= 2

///check for charge attack so we don't get to do it if the target runs away
/obj/item/storage/belt/musarama_sheath/proc/range_check(mob/user, atom/target)
	var/turf/T = get_turf(user)
	if(target in dview(7, T)) //to do check if this can be flattened
		return TRUE
