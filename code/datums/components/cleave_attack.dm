/datum/component/cleave_attack
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/arc_size = 90 // size of the attack arc in degrees
	var/requires_wielded = FALSE // make this TRUE for two-handed weapons like axes
	var/swing_speed_mod = 1.25 // how much slower is it to swing
	var/cleave_effect = /obj/effect/temp_visual/dir_setting/firing_effect/mecha_swipe

/datum/component/cleave_attack/Initialize(arc_size=90, swing_speed_mod=1.25, requires_wielded=FALSE, cleave_effect=/obj/effect/temp_visual/dir_setting/firing_effect/mecha_swipe, ...)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	
	src.arc_size = arc_size
	src.swing_speed_mod = swing_speed_mod
	src.requires_wielded = requires_wielded
	src.cleave_effect = cleave_effect
	//RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(perform_sweep))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/cleave_attack/InheritComponent(datum/component/C, i_am_original, arc_size, swing_speed_mod, requires_wielded, cleave_effect)
	if(!i_am_original)
		return
	if(arc_size)
		src.arc_size = arc_size
	if(swing_speed_mod)
		src.swing_speed_mod = swing_speed_mod
	if(requires_wielded)
		src.requires_wielded = requires_wielded

/datum/component/cleave_attack/Destroy(force, silent)
	//UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK)
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)
	. = ..()

/datum/component/cleave_attack/proc/on_afterattack(obj/item/item, atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		return // don't sweep on precise hits
	perform_sweep(item, target, user, click_parameters)


/datum/component/cleave_attack/proc/perform_sweep(obj/item/item, atom/target, mob/living/user, params)
	if(user.a_intent != INTENT_HARM) 
		return // don't sweep unless on harm intent
	if(user.next_move > world.time)
		return // don't spam it
	if(requires_wielded && !HAS_TRAIT(item, TRAIT_WIELDED))
		return // if it needs to be wielded, check to make sure it is

	// some information we're going to need later
	var/turf/user_turf = get_turf(user)
	var/turf/center_turf = get_turf_in_angle(get_angle(user, target), user_turf)
	var/facing_dir = get_dir(user, center_turf)
	var/swing_direction = (user.active_hand_index % 2) ? -1 : 1

	// make a list of turfs to swing across
	var/list/turf_list = list()
	var/turfs_count = round(arc_size / 90, 1)
	for(var/i in -turfs_count to turfs_count)
		turf_list.Add(get_step(user_turf, turn(facing_dir, i * 45 * swing_direction)))
	
	// now swing across those turfs
	for(var/turf/T as anything in turf_list)
		for(var/atom/movable/A in T)
			if(A == user)
				continue // why are you hitting yourself
			if(!A.density && !isliving(A))
				continue // if it isn't in the way, don't hit it unless it's a mob
			if(A.pass_flags & LETPASSTHROW)
				continue // if you can throw something over it, you can swing over it too
			item.melee_attack_chain(user, A, params)
	
	// now do some effects
	new cleave_effect(get_step(user_turf, SOUTHWEST), facing_dir)
	user.changeNext_move(CLICK_CD_MELEE * item.weapon_stats[SWING_SPEED] * swing_speed_mod)
	user.do_attack_animation(center_turf, no_effect=TRUE)
	user.weapon_slow(item)
	
	// return COMPONENT_NO_ATTACK
