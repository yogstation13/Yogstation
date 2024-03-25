GLOBAL_LIST_EMPTY(total_extraction_beacons)

/obj/item/extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/structure/extraction_point/beacon
	var/list/beacon_networks = list("station")
	var/uses_left = 3
	var/can_use_indoors
	var/safe_for_living_creatures = 1
	var/max_force_fulton = MOVE_FORCE_STRONG

	/// If false, puts atom in nullspace instead of a beacon
	/// You are expected to handle the atom in post_extract()
	var/uses_beacon = TRUE

/obj/item/extraction_pack/examine()
	. = ..()
	if(uses_left < INFINITY - 2000)
		. += span_info("It has [uses_left] use\s remaining.")

/obj/item/extraction_pack/attack_self(mob/user)
	if(!uses_beacon)
		return FALSE
	if(is_species(user, /datum/species/lizard/ashwalker))
		to_chat(user, span_warning("You don't know how to use this!"))
		return FALSE
	if(is_species(user, /datum/species/pod/ivymen)) // yogs - ivymen
		to_chat(user, span_warning("You don't know how to use this!"))
		return FALSE
	var/list/possible_beacons = list()
	for(var/B in GLOB.total_extraction_beacons)
		var/obj/structure/extraction_point/EP = B
		if(EP.beacon_network in beacon_networks)
			possible_beacons += EP

	if(!possible_beacons.len)
		to_chat(user, "There are no extraction beacons in existence!")
		return

	else
		var/A

		A = input("Select a beacon to connect to", "Balloon Extraction Pack", A) as null|anything in possible_beacons

		if(!A)
			return
		beacon = A
		to_chat(user, "You link the extraction pack to the beacon system.")

/obj/item/extraction_pack/proc/can_extract(atom/movable/A)
	return TRUE

/obj/item/extraction_pack/proc/post_extract(atom/movable/A)
	return

/obj/item/extraction_pack/afterattack(atom/movable/A, mob/living/carbon/human/user, flag, params)
	. = ..()
	if(is_species(user, /datum/species/lizard/ashwalker))
		to_chat(user, span_warning("You don't know how to use this!"))
		return FALSE
	if(!beacon && uses_beacon)
		to_chat(user, "[src] is not linked to a beacon, and cannot be used.")
		return
	if(!can_use_indoors)
		var/area/area = get_area(A)
		if(!area.outdoors)
			to_chat(user, "[src] can only be used on things that are outdoors!")
			return
	if(!flag)
		return
	if(!istype(A) || !can_extract(A))
		return
	else
		if(!safe_for_living_creatures && check_for_living_mobs(A))
			to_chat(user, "[src] is not safe for use with living creatures, they wouldn't survive the trip back!")
			return
		if(!isturf(A.loc)) // no extracting stuff inside other stuff
			return
		if(A.anchored || (A.move_resist > max_force_fulton))
			return
		to_chat(user, span_notice("You start attaching the pack to [A]..."))
		if(do_after(user, 5 SECONDS, A))
			if(!can_extract(A))
				return
			to_chat(user, span_notice("You attach the pack to [A] and activate it."))
			if(loc == user && istype(user.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = user.back
				SEND_SIGNAL(B, COMSIG_TRY_STORAGE_INSERT, src, user, FALSE, FALSE)
			uses_left--
			if(uses_left <= 0)
				user.transferItemToLoc(src, A, TRUE)
			var/mutable_appearance/balloon
			var/mutable_appearance/balloon2
			var/mutable_appearance/balloon3
			if(isliving(A))
				var/mob/living/M = A
				M.Paralyze(320) // Keep them from moving during the duration of the extraction
				M.buckled = 0 // Unbuckle them to prevent anchoring problems
			else
				A.anchored = TRUE
				A.density = FALSE
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.forceMove(holder_obj)
			balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
			balloon2.pixel_y = 10
			balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.add_overlay(balloon2)
			sleep(0.4 SECONDS)
			balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon2)
			holder_obj.add_overlay(balloon)
			playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, 1, -3)
			animate(holder_obj, pixel_z = 10, time = 2 SECONDS)
			sleep(2 SECONDS)
			animate(holder_obj, pixel_z = 15, time = 1 SECONDS)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 10, time = 1 SECONDS)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 15, time = 1 SECONDS)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 10, time = 1 SECONDS)
			sleep(1 SECONDS)
			playsound(holder_obj.loc, 'sound/items/fultext_launch.ogg', 50, 1, -3)
			animate(holder_obj, pixel_z = 1000, time = 3 SECONDS)
			if(ishuman(A))
				var/mob/living/carbon/human/L = A
				L.SetUnconscious(0)
				L.remove_status_effect(/datum/status_effect/drowsiness)
				L.SetSleeping(0)
			sleep(3 SECONDS)
			if(uses_beacon)
				var/list/flooring_near_beacon = list()
				for(var/turf/open/floor in orange(1, beacon))
					flooring_near_beacon += floor
				if(LAZYLEN(flooring_near_beacon) > 0)
					holder_obj.forceMove(pick(flooring_near_beacon))
				else
					to_chat(user, span_userdanger("The fulton malfunctions! It couldn't find a place to land!"))
				animate(holder_obj, pixel_z = 10, time = 5 SECONDS)
				sleep(5 SECONDS)
				animate(holder_obj, pixel_z = 15, time = 1 SECONDS)
				sleep(1 SECONDS)
				animate(holder_obj, pixel_z = 10, time = 1 SECONDS)
				sleep(1 SECONDS)
				balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
				balloon3.pixel_y = 10
				balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
				holder_obj.cut_overlay(balloon)
				holder_obj.add_overlay(balloon3)
				sleep(0.4 SECONDS)
				holder_obj.cut_overlay(balloon3)
				A.anchored = FALSE // An item has to be unanchored to be extracted in the first place.
				A.density = initial(A.density)
				animate(holder_obj, pixel_z = 0, time = 0.5 SECONDS)
				sleep(0.5 SECONDS)
				A.forceMove(holder_obj.loc)
			else
				A.doMove(null)
			qdel(holder_obj)
			post_extract(A)
			if(uses_left <= 0)
				qdel(src)


/obj/item/fulton_core
	name = "extraction beacon signaller"
	desc = "Emits a signal which fulton recovery devices can lock onto. Activate in hand to create a beacon."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "subspace_amplifier"

/obj/item/fulton_core/attack_self(mob/user)
	if(do_after(user, 1.5 SECONDS, user) && !QDELETED(src))
		new /obj/structure/extraction_point(get_turf(user))
		qdel(src)

/obj/structure/extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	density = FALSE
	var/beacon_network = "station"

/obj/structure/extraction_point/Initialize(mapload)
	. = ..()
	name += " ([rand(100,999)]) ([get_area_name(src, TRUE)])"
	GLOB.total_extraction_beacons += src

/obj/structure/extraction_point/Destroy()
	GLOB.total_extraction_beacons -= src
	..()

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "You shouldn't see this."
	var/atom/movable/stored_obj

/obj/item/extraction_pack/proc/check_for_living_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return 1
	for(var/thing in A.get_all_contents())
		if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD)
				return 1
	return 0

/obj/effect/extraction_holder/singularity_pull()
	return

/obj/effect/extraction_holder/singularity_pull()
	return

/obj/item/extraction_pack/mech_drop
	name = "mech extraction pack"
	desc = "An industrial balloon pack designed to transport heavy-duty mecha."
	uses_left = INFINITY
	can_use_indoors = TRUE
	safe_for_living_creatures = FALSE
	max_force_fulton = MOVE_FORCE_EXTREMELY_STRONG
	uses_beacon = FALSE
	var/list/stored_mecha
	var/ever_used = FALSE

/obj/item/extraction_pack/mech_drop/attack_self(mob/user)
	if(!user.canUseTopic(src, TRUE))
		return
	if(!stored_mecha)
		stored_mecha = list()
	if(stored_mecha.len == 0)
		balloon_alert(user, "no mecha in storage")
		return
	var/mecha_names = list()
	for(var/obj/mecha/mecha_choice in stored_mecha)
		mecha_names[mecha_choice.name] = mecha_choice // Generate this list *now* to avoid potential naming exploits
	var/choice = tgui_input_list(user, "Choose a mech to deploy", "Mech Drop", mecha_names)
	var/obj/mecha/chosen_mecha = mecha_names[choice]
	if(!chosen_mecha || !istype(chosen_mecha) || !(chosen_mecha in stored_mecha) || !user.canUseTopic(src, TRUE))
		return
	ever_used = TRUE
	balloon_alert(user, "stand back!")
	var/obj/structure/closet/supplypod/pod = new
	pod.style = STYLE_SEETHROUGH
	pod.explosionSize = list(0,0,0,1)
	pod.bluespace = TRUE
	pod.damage = 50
	chosen_mecha.forceMove(pod)
	stored_mecha -= chosen_mecha
	new /obj/effect/DPtarget(get_teleport_turf(get_turf(user), 1), pod)

/obj/item/extraction_pack/mech_drop/examine()
	. = ..()
	. += span_info("Use in-hand to summon stored mecha.")

/obj/item/extraction_pack/mech_drop/Initialize(mapload)
	. = ..()
	stored_mecha = list()
	RegisterSignal(src, COMSIG_ITEM_REFUND, PROC_REF(refund_check))

/obj/item/extraction_pack/mech_drop/proc/refund_check()
	return !ever_used

/obj/item/extraction_pack/mech_drop/can_extract(atom/movable/A)
	var/obj/mecha/mecha_to_store = A
	. = istype(mecha_to_store) && !mecha_to_store.silicon_pilot && !mecha_to_store.occupant
	if(.)
		ever_used = TRUE

/obj/item/extraction_pack/mech_drop/post_extract(atom/movable/A)
	if(!istype(A, /obj/mecha))
		return
	ever_used = TRUE
	stored_mecha |= A
