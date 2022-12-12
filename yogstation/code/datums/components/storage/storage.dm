/datum/component/storage/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	. = ..()
	if (.)
		SEND_SIGNAL(parent, COMSIG_STORAGE_INSERTED, I, M)

/datum/component/storage/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	if (.)
		SEND_SIGNAL(parent, COMSIG_STORAGE_REMOVED, AM, new_location)

/datum/component/storage/RemoveComponent() // hey TG you dropped this
	UnregisterSignal(parent, COMSIG_CONTAINS_STORAGE)
	UnregisterSignal(parent, COMSIG_IS_STORAGE_LOCKED)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_SHOW)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_INSERT)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_CAN_INSERT)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_TAKE_TYPE)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_FILL_TYPE)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_SET_LOCKSTATE)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_TAKE)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_QUICK_EMPTY)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_HIDE_FROM)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_HIDE_ALL)
	UnregisterSignal(parent, COMSIG_TRY_STORAGE_RETURN_INVENTORY)

	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_PAW)
	UnregisterSignal(parent, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST)
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	UnregisterSignal(parent, COMSIG_ATOM_EXITED)
	UnregisterSignal(parent, COMSIG_ATOM_CANREACH)

	UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

	UnregisterSignal(parent, COMSIG_MOVABLE_POST_THROW)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	UnregisterSignal(parent, COMSIG_MOUSEDROP_ONTO)
	UnregisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO)
	. = ..()

/datum/component/storage/concrete/RemoveComponent()
	UnregisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL)
	UnregisterSignal(parent, COMSIG_OBJ_DECONSTRUCT)
	. = ..()

// You know, TG created the component system to prevent exactly this problem.
// Turns out they did a shit job. Enjoy the literal copypaste.
// in case you didn't catch it these are the same as the original but without "/concrete" in them
/datum/component/storage/bluespace
	var/dumping_range = 8
	var/dumping_sound = 'sound/items/pshoom.ogg'
	var/alt_sound = 'sound/items/pshoom_2.ogg'

/datum/component/storage/bluespace/dump_content_at(atom/dest, mob/M)
	var/atom/A = parent
	if(A.Adjacent(M))
		var/atom/dumping_location = dest.get_dumping_location()
		if(get_dist(M, dumping_location) < dumping_range)
			if(dumping_location.storage_contents_dump_act(src, M))
				if(alt_sound && prob(1))
					playsound(src, alt_sound, 40, 1)
				else
					playsound(src, dumping_sound, 40, 1)
				M.Beam(dumping_location, icon_state="rped_upgrade", time=5)
				return TRUE
		to_chat(M, "The [A.name] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	return FALSE

/datum/component/storage/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W)		//don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.GetAllContents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Abort", "Proceed")
		if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)))
			return
		var/turf/loccheck = get_turf(A)
		if(is_reebe(loccheck.z))
			user.visible_message(span_warning("An unseen force knocks [user] to the ground!"), "[span_big_brass("\"I think not!\"")]")
			user.Paralyze(60)
			return
		if(istype(loccheck.loc, /area/fabric_of_reality))
			to_chat(user, span_danger("You can't do that here!"))
		to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
		playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)

		message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
		log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")
		
		new /obj/singularity(loccheck, 800)
		qdel(W)
		qdel(A)
		return
	. = ..()
	
/datum/component/storage/concrete/trashbag/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	..() // Actually sets the default return value
	var/atom/real_location = real_location()
	var/sum_w_class = I.w_class
	for(var/obj/item/_I in real_location)
		sum_w_class += _I.w_class //Adds up the combined w_classes
	if((real_location.contents.len / max_items > 0.95 || sum_w_class / max_combined_w_class > 0.95) && !rand(0,124))
		var/obj/item/storage/bag/trash/devito = parent
		devito.snap(M)
