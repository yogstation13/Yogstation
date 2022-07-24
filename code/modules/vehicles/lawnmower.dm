#define MOWER_IDLE	"idle"
#define MOWER_MOVE	"move"
#define MOWER_MOW	"mow"

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
	var/fuelcapacity = 100
	var/list/consumed_reagents_list = list(/datum/reagent/oil, /datum/reagent/toxin/plasma, /datum/reagent/fuel, /datum/reagent/consumable/ethanol) //what can be used as fuel?
	var/fueluserate = 4 //how thirsty is the engine? Smaller makes this go faster. <- this was if it was tied to world.time. 
	var/list/default_mowables = list(/obj/structure/flora, /obj/structure/glowshroom)
	var/list/upgraded_mowables = list(/obj/structure/spacevine, /obj/structure/alien/weeds)
	var/list/mowable //spinning metal can't cut space vines or weeds
	var/datum/looping_sound/mower/soundloop //internal combustion engine go brrrr

/obj/vehicle/ridden/lawnmower/Initialize()
	. = ..()
	mowable = typecacheof(default_mowables)
	create_reagents(100, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/oil, 100)
	// .list_reagents = list(/datum/reagent/oil = 100) 
	// for(var/reagent_id in consumed_reagents_list)	//we don't need to do the check since we control what it inits with
	// 	if(reagents.has_reagent(reagent_id)) //just keeping it for now because i don't know what i'll need later

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
	if(panel_open)
		. += "Its service panel is open!"
		if(reagents.total_volume) // isn't actually telling you its contents at all when opened and examined
			. += "and it looks like the tank has"
			for(var/datum/reagent/reagent_id in reagents.reagent_list)
				. += span_notice("[reagent_id.volume]u of [reagent_id.name]")
			. += "in it."
	if(obj_flags & EMAGGED)
		. += "the safety lights appear to be flickering"

/obj/vehicle/ridden/lawnmower/proc/default_deconstruction_screwdriver(mob/user, obj/item/I)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			to_chat(user, span_notice("You open the service panel of [src]."))
			return
		else
			panel_open = FALSE
			to_chat(user, span_notice("You close the service panel of [src]."))
			return
	return 0

/obj/vehicle/ridden/lawnmower/attackby(obj/item/I, mob/user, params)
	. = ..()
	//reagents.maximum_volume = 0
	//You can only screw open the mower if it's off
	if(active)
		to_chat(user, span_warning("[src] is still running!"))
		return

	if(default_deconstruction_screwdriver(user, I))
		return

	if(!panel_open && user.a_intent != INTENT_HARM) //still hits the mower, but also unlocks it, also still works on other intents.
		to_chat(user, span_notice("You can see the maintenance panel, but you need a screwdriver to open it"))
		return

	if(istype(I, /obj/item/mowerupgrade) && panel_open)
		if(bladeattached)
			to_chat(user, span_warning("[src] already has energy blades!"))
			return
		upgrade()
		bladeattached = TRUE
		qdel(I)
		to_chat(user, span_notice("You upgrade [src] with energy blades."))

	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/vehicle/ridden/lawnmower/proc/UseFuel(var/action) //Turns out you need fuel to make this thing go!
	var/fuelNeeded = 1
	var/fuelEfficiencyCoef = 1
	switch(action)
		if(MOWER_MOW)
			fuelNeeded = 5
		if(MOWER_MOVE)
			fuelNeeded = 3
		else
			fuelNeeded = 1
	if(reagents.has_reagent(/datum/reagent/oil))
		fuelEfficiencyCoef *= 1
		movedelay = 2.2
	if(reagents.has_reagent(/datum/reagent/nitrous_oxide))
		fuelEfficiencyCoef *= 2.2
		movedelay = 0.5
	if(reagents.has_reagent(/datum/reagent/fuel))
		fuelEfficiencyCoef *= 0.5
		movedelay = 1.2
	if(reagents.has_reagent(/datum/reagent/consumable/ethanol))
		fuelEfficiencyCoef *= 2 // alcohol as a fuel sucks ass
		movedelay = 1 //but is more energy dense
	if(reagents.has_reagent(/datum/reagent/toxin/plasma))
		explosion(get_turf(src), 0, 0, 4, flame_range = 3, smoke = TRUE)
		qdel(src)
	reagents.remove_all(fuelNeeded * fuelEfficiencyCoef)
	if(!reagents.total_volume)
		hasfuel = FALSE
	
/obj/vehicle/ridden/lawnmower/proc/ToggleEngine()
	if(active)
		active = FALSE
		soundloop.stop()
		return
	if(!active && hasfuel && key_type && is_key(inserted_key))
		active = TRUE
		START_PROCESSING(SSobj, src)
		soundloop.start() //internal combustion engine go brrrr

///obj/vehicle/ridden/lawnmower/proc/FuelFill()

/obj/vehicle/ridden/lawnmower/process()
	if(active)
		if(!hasfuel || key_type && !is_key(inserted_key))
			//ToggleEngine()
			active = FALSE
			STOP_PROCESSING(SSobj, src)
			soundloop.stop()
			return
		else
			UseFuel(MOWER_IDLE)
	else
		STOP_PROCESSING(SSobj, src)
		return


/obj/vehicle/ridden/lawnmower/update_icon()
	cut_overlays()
	if(bladeattached)
		add_overlay("mower_blade")

/obj/vehicle/ridden/lawnmower/driver_move(mob/user, direction)
	. = ..()
	UseFuel(MOWER_MOVE)
	mow_lawn() //https://www.youtube.com/watch?v=kMxzkBdzTNU

/obj/vehicle/ridden/lawnmower/Bump(atom/A)
	. = ..()
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		//knocked over
		if(obj_flags & EMAGGED)
			C.Paralyze(20) 
		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)

/obj/vehicle/ridden/lawnmower/proc/mow_living(mob/living/L)

	// for(var/mob/living/carbon/H)
	// 	if(ishuman(H))
	// 		H = buckled_mobs
	// for(L in loc)
	if(iscarbon(L))
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!", forced = "recycler grinding")
		add_mob_blood(L)
		if(obj_flags & EMAGGED & !bladeattached)	// Instantly lie down, also go unconscious from the pain, before you die.
			L.Unconscious(100)
			L.apply_damage(150, BRUTE)
		if(obj_flags & EMAGGED & bladeattached)
			L.Unconscious(100)
			L.apply_damage(600, BRUTE)
			var/mob/living/carbon/CM = L
			for(var/obj/item/bodypart/bodypart in CM.bodyparts)
				if(bodypart.body_part != CHEST)
					if(bodypart.dismemberable)
						bodypart.dismember()

/obj/vehicle/ridden/lawnmower/upgraded
	bladeattached = TRUE

/obj/vehicle/ridden/lawnmower/emagged	

/obj/vehicle/ridden/lawnmower/emagged/Initialize(mapload)
	. = ..()
	obj_flags |= EMAGGED

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
		if(!mowed && is_type_in_typecache(S, mowable))
			qdel(S)
			mowed = TRUE //still want this here so I can make it make a different sound for actually mowing
			UseFuel(MOWER_MOW)
	if(obj_flags & EMAGGED)
		var/mob/living/R = buckled_mobs[1]
		for(var/mob/living/D in loc)
			if(D != R)
				mow_living(D)
				mowed = TRUE

/obj/vehicle/ridden/lawnmower/proc/upgrade()
	mowable = typecacheof(default_mowables + upgraded_mowables) //oh hey turns out energy blades CAN cut steel- I mean space vines.

/obj/vehicle/ridden/lawnmower/verb/empty()
	set name = "Empty Fuel Tank"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	if(!panel_open)
		to_chat(usr, span_warning("You can't empty the fuel tank without opening the maintenance panel first!"))
		return
	if (alert(usr, "Are you sure you want to empty the fuel tank?", "Empty Fuel Tank:", "Yes", "No") != "Yes")
		return
	if(isturf(src.loc))
		to_chat(usr, span_notice("You press the fuel tank purge button, emptying [src]'s contents onto the floor."))
		reagents.reaction(src.loc)
		reagents.clear_reagents()

#undef MOWER_IDLE
#undef MOWER_MOVE
#undef MOWER_MOW
