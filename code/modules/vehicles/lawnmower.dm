/obj/vehicle/ridden/lawnmower
	name = "lawnmower"
	desc = "Somewhat of a relic of pre-spaceflight, still seen on colonies for its utility, and on stations for unusual emergencies. Has electronic safties to prevent accidents."
	icon_state = "lawnmower"
	key_type = /obj/item/key/janitor
	are_legs_exposed = TRUE //it's a lawnmower not a tank
	var/bladeattached = FALSE //are we upgraded?
	var/active = FALSE //are we on?
	var/panel_open = FALSE //is the service panel open?
	var/hasfuel = FALSE //do we have fuel at all? (required by some procs)
	var/list/consumed_reagents_list = list(/datum/reagent/oil, /datum/reagent/toxin/plasma, /datum/reagent/fuel, /datum/reagent/consumable/ethanol) //what can be used as fuel?
	var/fueluserate = 4 //how thirsty is the engine? Smaller makes this go faster.
	var/obj/item/reagent_containers/glass/G //has to be here so I can use it in multiple procs
	var/obj/item/reagent_containers/glass/mycontainer = null //what's our fuel tank?
	var/static/list/mowable = typecacheof(list(/obj/structure/flora, /obj/structure/glowshroom)) //spinning metal can't cut space vines or weeds
	var/datum/looping_sound/mower/soundloop //internal combustion engine go brrrr

/obj/vehicle/ridden/lawnmower/Initialize()
	. = ..()
	mow_lawn() //so if we start on a tile we could mow, pre-mow it
	mycontainer = /obj/item/reagent_containers/glass/beaker/large //start with a large beaker so its usable for a decent time
	for(var/reagent_id in consumed_reagents_list)
		if(!reagents.has_reagent(reagent_id, consumed_reagents_list[reagent_id]))
			hasfuel = TRUE
	update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-5, 2), TEXT_WEST = list( 5, 2)))

/obj/vehicle/ridden/lawnmower/Destroy()
	. = ..()

/obj/item/mowerupgrade
	name = "energy blade upgrade"
	desc = "An upgrade for lawnmowers, allowing them to cut through dense organic matter."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/vehicle/ridden/lawnmower/examine(mob/user)
	. += ..()
	if(bladeattached)
		. += "It has been upgraded with energy blades."
	if(panelopen)
		. += "Its service panel is open!"
	if(obj_flags & EMAGGED)
		. += "the safety lights appear to be flickering"

/obj/vehicle/ridden/lawnmower/proc/default_deconstruction_screwdriver(mob/user, obj/item/I)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			to_chat(user, span_notice("You open the service panel of [src]."))
		else
			panel_open = FALSE
			to_chat(user, span_notice("You close the service panel of [src]."))
		return 1
	return 0

/obj/vehicle/ridden/lawnmower/proc/replace_container(mob/living/user, obj/item/reagent_containers/new_container)
	if(mycontainer)
		mycontainer.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(mycontainer)
	if(new_container)
		mycontainer = new_container
	else
		mycontainer = null
	return TRUE

/obj/vehicle/ridden/lawnmower/attackby(obj/item/I, mob/user, params)
	reagents.maximum_volume = 0
	//You can only screw open the mower if it's off
	if(default_deconstruction_screwdriver(user, I) && active)
		to_chat(user, span_warning("[src] is still running!"))
		return

	if(!panel_open) //Can't insert objects when its closed, but can fill it with fuel
		FuelFill()
		return TRUE

	if (istype(I, /obj/item/reagent_containers/glass/) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE //no afterattack
		reagents.maximum_volume += G.volume
		if(!user.transferItemToLoc(G, src))
			return
		replace_container(user, G)
		to_chat(user, span_notice("You add [G] to [src]."))
		return TRUE //no afterattack

/obj/vehicle/ridden/lawnmower/proc/UseFuel() //Turns out you need fuel to make this thing go!
	if(hasfuel)

		//world.time + fueluserate
	
/obj/vehicle/ridden/lawnmower/proc/ToggleEngine()
	var/hasfuel = FALSE
	if(G.total_reagents > 0)
		hasfuel = TRUE
	if(active && !hasfuel || !key_type)
		active = FALSE
		soundloop.stop() //put fuel and the key in it first ya goof
	else if(hasfuel && key_type)
		active = TRUE
		START_PROCESSING(SSobj, src)
		soundloop.start() //internal combustion engine go brrrr

/obj/vehicle/ridden/lawnmower/proc/FuelFill()

/obj/vehicle/ridden/lawnmower/process()
	if(active)
		if(!hasfuel || !key_type)
			ToggleEngine()
			return
		else
			UseFuel()
	else
		return

/obj/vehicle/ridden/lawnmower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mowerupgrade))
		if(bladeattached)
			to_chat(user, span_warning("[src] already has energy blades!"))
			return
		add_type_to_cache()
		bladeattached = TRUE
		qdel(I)
		to_chat(user, span_notice("You upgrade [src] with energy blades."))
	else
		return ..()

/obj/vehicle/ridden/lawnmower/update_icon()
	cut_overlays()
	if(bladeattached)
		add_overlay("mower_blade")

/obj/vehicle/ridden/lawnmower/driver_move(mob/user, direction)
	. = ..()
	mow_lawn() //https://www.youtube.com/watch?v=kMxzkBdzTNU

/obj/vehicle/ridden/lawnmower/upgraded
	bladeattached = TRUE

/obj/vehicle/ridden/lawnmower/emagged
	obj_flags = EMAGGED

/obj/vehicle/ridden/lawnmower/upgraded/emagged
	bladeattached = TRUE
	obj_flags = EMAGGED

/obj/vehicle/ridden/lawnmower/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The safety mechanisms on [src] are already disabled!"))
		return
	to_chat(user, span_warning("You disable the safety mechanisms on [src]."))
	obj_flags = EMAGGED


/obj/vehicle/ridden/lawnmower/proc/mow_lawn()
	var/mowed = FALSE
	for(var/obj/structure/S in loc)
		if(is_type_in_typecache(S, mowable))
			qdel(S)
			mowed = TRUE //still want this here so I can make it make a different sound for actually mowing

/obj/vehicle/ridden/lawnmower/proc/add_type_to_cache()
	mowable = typecacheof(list(/obj/structure/flora, /obj/structure/glowshroom, /obj/structure/spacevine, /obj/structure/alien/weeds)) //oh hey turns out energy blades CAN cut steel- I mean space vines.
