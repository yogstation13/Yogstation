/obj/vehicle/sealed/car
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	default_driver_move = FALSE
	var/car_traits = NONE //Bitflag for special behavior such as kidnapping
	var/engine_sound = 'sound/vehicles/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 20 //Set this to the length of the engine sound
	var/escape_time = 60 //Time it takes to break out of the car

/obj/vehicle/sealed/car/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = movedelay
	D.slowvalue = 0

/obj/vehicle/sealed/car/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/DumpKidnappedMobs, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/driver_move(mob/user, direction)
	if(key_type && !is_key(inserted_key))
		to_chat(user, span_warning("[src] has no key inserted!"))
		return FALSE
	var/datum/component/riding/R = GetComponent(/datum/component/riding)
	R.handle_ride(user, direction)
	if(world.time < last_enginesound_time + engine_sound_length)
		return
	last_enginesound_time = world.time
	playsound(src, engine_sound, 100, TRUE)
	return TRUE

/obj/vehicle/sealed/car/MouseDrop_T(atom/dropping, mob/M)
	if(M.stat || M.restrained())
		return FALSE
	if((car_traits & CAN_KIDNAP) && isliving(dropping) && M != dropping)
		var/mob/living/L = dropping
		L.visible_message(span_warning("[M] starts forcing [L] into [src]!"))
		mob_try_forced_enter(M, L)
	return ..()

/obj/vehicle/sealed/car/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M == user && (occupants[M] & VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, span_notice("You push against the back of [src] trunk to try and get out."))
		if(!do_after(user, escape_time, src))
			return FALSE
		to_chat(user,span_danger("[user] gets out of [src]"))
		mob_exit(M, silent)
		return TRUE
	mob_exit(M, silent)
	return TRUE

/obj/vehicle/sealed/car/attacked_by(obj/item/I, mob/living/user)
	if(!I.force)
		return
	if(occupants[user])
		to_chat(user, span_notice("Your attack bounces off of the car's padded interior."))
		return
	return ..()

/obj/vehicle/sealed/car/attack_hand(mob/living/user)
	. = ..()
	if(!(car_traits & CAN_KIDNAP))
		return
	if(occupants[user])
		return
	to_chat(user, span_notice("You start opening [src]'s trunk."))
	if(do_after(user, 3 SECONDS, src))
		if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
			to_chat(user, span_notice("The people stuck in [src]'s trunk all come tumbling out."))
			DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)
		else
			to_chat(user, span_notice("It seems [src]'s trunk was empty."))

/obj/vehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	var/atom/old_loc = loc
	if(do_mob(forcer, M, get_enter_delay(M), extra_checks=CALLBACK(src, /obj/vehicle/sealed/car/proc/is_car_stationary, old_loc)))
		mob_forced_enter(M, silent)
		return TRUE
	return FALSE

/obj/vehicle/sealed/car/proc/is_car_stationary(atom/old_loc)
	return (old_loc == loc)

/obj/vehicle/sealed/car/proc/mob_forced_enter(mob/M, silent = FALSE)
	if(!silent)
		M.visible_message(span_warning("[M] is forced into \the [src]!"))
	M.forceMove(src)
	add_occupant(M, VEHICLE_CONTROL_KIDNAPPED)
