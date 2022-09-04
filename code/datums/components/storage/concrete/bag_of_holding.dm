/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W)		//don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.GetAllContents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, .proc/recursive_insertion, W, user)
		return
	. = ..()

/datum/component/storage/concrete/bluespace/bag_of_holding/proc/recursive_insertion(obj/item/W, mob/living/user)
	var/atom/A = parent
	var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Abort", "Proceed")
	if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)) || !user.canUseTopic(W, BE_CLOSE, iscarbon(user)))
		return
	var/turf/loccheck = get_turf(A)
	if(is_reebe(loccheck.z))
		user.visible_message(span_warning("An unseen force knocks [user] to the ground!"), "[span_big_brass("\"I think not!\"")]")
		user.Paralyze(60)
		return
	if(istype(loccheck.loc, /area/fabric_of_reality))
		to_chat(user, span_danger("You can't do that here!"))
	if(user.has_status_effect(STATUS_EFFECT_VOIDED))
		user.remove_status_effect(STATUS_EFFECT_VOIDED)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(W)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)

	to_chat(user, span_danger("You are pulled into the bluespace disruption!")) // No escaping
	user.forceMove(loccheck)
	user.Paralyze(10)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")
	log_bomber(keyname(user), "detonated a bag of holding at", src, null, notify_admins)

	for(var/turf/T in range(2,loccheck))
		if(istype(T, /turf/open/space/transit))
			continue
		for(var/atom/AT in T)
			AT.emp_act(EMP_HEAVY)
			if(istype(AT, /obj))
				var/obj/O = AT
				O.obj_break()
			if(istype(AT, /mob/living))
				var/mob/living/M = AT
				M.take_overall_damage(85)
				if(M.movement_type & FLYING)
					M.visible_message(span_danger("The bluespace collapse crushes the air towards it, pulling [M] towards the ground..."))
					M.Paralyze(5, TRUE, TRUE)		//Overrides stun absorbs.
		T.TerraformTurf(/turf/open/chasm/magic, /turf/open/chasm/magic)
	for(var/fabricarea in get_areas(/area/fabric_of_reality))
		var/area/fabric_of_reality/R = fabricarea
		R.origin = loccheck
	for (var/obj/structure/ladder/unbreakable/binary/ladder in GLOB.ladders)
		ladder.ActivateAlmonds()
	qdel(A)
