/obj/vehicle/ridden/lawnmower
	name = "lawnmower"
	desc = "Somewhat of a relic of pre-spaceflight, still seen on colonies for its utility, and on stations for unusual emergencies. Has electronic safties to prevent accidents."
	icon_state = "lawnmower"
	key_type = /obj/item/key/janitor
	are_legs_exposed = TRUE
	var/obj/item/storage/bag/trash/mybag = null
	var/bladeattached = FALSE
	var/emagged = FALSE
	var/active = FALSE
	var/obj/item/reagent_containers/glass/mycontainer = null
	var/static/list/mowable = typecacheof(list(/obj/structure/flora, /obj/structure/glowshroom))
	var/datum/looping_sound/mower/soundloop

/obj/vehicle/ridden/lawnmower/Initialize(mapload)
	. = ..()
	mow_lawn()
	mycontainer = list(new /obj/item/reagent_containers/glass/beaker/large(null), )
	update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-5, 2), TEXT_WEST = list( 5, 2)))

/obj/vehicle/ridden/lawnmower/Destroy()
	explosion(get_turf(src), 0, 1, 5, flame_range = 5)
	qdel(src)
	. = ..()

/obj/item/mowerupgrade
	name = "energy blade upgrade"
	desc = "An upgrade for lawnmowers, allowing them to cut through dense organic matter."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/vehicle/ridden/lawnmower/examine(mob/user)
	. += ..()
	if(bladeattached)
		. += "It has been upgraded with an energy blade."

/obj/vehicle/ridden/lawnmower/proc/HasFuel() //Placeholder for fuel check.


/obj/vehicle/ridden/lawnmower/proc/UseFuel() //Placeholder for fuel use.


/obj/vehicle/ridden/lawnmower/proc/ToggleEngine()
	if(active)
		active = FALSE
		soundloop.stop()
	else if(HasFuel)
		if(key_type)
			active = TRUE
			START_PROCESSING(SSobj, src)
			soundloop.start()
		else
			return

/obj/vehicle/ridden/lawnmower/process()
	if(active)
		if(!HasFuel() || !key_type)
			TogglePower()
			return
		else
			UseFuel()
	else
		return

/obj/vehicle/ridden/lawnmower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mowerupgrade))
		if(bladeattached)
			to_chat(user, span_warning("[src] already has an energy blade!"))
			return
		add_type_to_cache()
		bladeattached = TRUE
		qdel(I)
		to_chat(user, span_notice("You upgrade [src] with the energy blade."))
	else
		return ..()

/obj/vehicle/ridden/lawnmower/update_icon()
	cut_overlays()
	if(mybag)
		add_overlay("mower_bag")
	if(bladeattached)
		add_overlay("mower_blade")

/obj/vehicle/ridden/lawnmower/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	else if(mybag)
		mybag.forceMove(get_turf(user))
		user.put_in_hands(mybag)
		mybag = null
		update_icon()

/obj/vehicle/ridden/lawnmower/driver_move(mob/user, direction)
	. = ..()
	mow_lawn()

/obj/vehicle/ridden/lawnmower/upgraded
	bladeattached = TRUE

/obj/vehicle/ridden/lawnmower/emagged
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/upgraded/emagged
	bladeattached = TRUE
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/emag_act(mob/user)
	if(emagged)
		to_chat(user, span_warning("The safety mechanisms on [src] are already disabled!"))
		return
	to_chat(user, span_warning("You disable the safety mechanisms on [src]."))
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/upgraded/emag_act(mob/user)
	if(emagged)
		to_chat(user, span_warning("The safety mechanisms on [src] are already disabled!"))
		return
	to_chat(user, span_warning("You disable the safety mechanisms on [src]."))
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/proc/mow_lawn()
	var/mowed = FALSE
	for(var/obj/structure/S in loc)
		if(is_type_in_typecache(S, mowable))
			qdel(S)
			mowed = TRUE

/obj/vehicle/ridden/lawnmower/proc/add_type_to_cache()
	mowable = typecacheof(list(/obj/structure/flora, /obj/structure/glowshroom, /obj/structure/spacevine, /obj/structure/alien/weeds))
