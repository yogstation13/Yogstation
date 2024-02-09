/**********************Mineral deposits**************************/

/turf/closed/mineral //wall piece
	name = "rock"
	icon = MAP_SWITCH('icons/turf/smoothrocks.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock"
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MINERAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	opacity = TRUE
	density = TRUE
	// We're a BIG wall, larger then 32x32, so we need to be on the game plane
	// Otherwise we'll draw under shit in weird ways
	plane = GAME_PLANE
	layer = EDGED_TURF_LAYER
	base_icon_state = "smoothrocks"

	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())

	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	initial_temperature = TCMB

	var/environment_type = "asteroid"
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/obj/item/stack/ore/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/scan_state = "" //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = FALSE
	var/hardness = 1 //how hard the material is, we'll have to have more powerful stuff if we want to blast harder materials.
	
/turf/closed/mineral/Initialize(mapload)
	. = ..()
	// Mineral turfs are big, so they need to be on the game plane at a high layer
	// But they're also turfs, so we need to cut them out from the light mask plane
	// So we draw them as if they were on the game plane, and then overlay a copy onto
	// The wall plane (so emissives/light masks behave)
	// I am so sorry
	var/static/mutable_appearance/wall_overlay = mutable_appearance('icons/turf/mining.dmi', "rock", appearance_flags = RESET_TRANSFORM)
	wall_overlay.plane = MUTATE_PLANE(WALL_PLANE, src)
	overlays += wall_overlay
	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in GLOB.cardinals)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/closed/mineral/random))
					Spread(T)

/turf/closed/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()

/turf/closed/mineral/attackby(obj/item/I, mob/user, params)
	if (!user.IsAdvancedToolUser())
		to_chat(usr, span_warning("You don't have the dexterity to do this!"))
		return

	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		if(DOING_INTERACTION(user, src))//prevents message spam
			return
		to_chat(user, span_notice("You start picking..."))

		if(I.use_tool(src, user, 40, volume=50))
			if(ismineralturf(src))
				to_chat(user, span_notice("You finish cutting into the rock."))
				attempt_drill(user)
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
	else
		return attack_hand(user)

/turf/closed/mineral/proc/gets_drilled(mob/user, triggered_by_explosion = FALSE, override_bonus = FALSE)
	if (mineralType && (mineralAmt > 0))
		if(triggered_by_explosion && !override_bonus)
			mineralAmt *= 2 //bonus if it was exploded, USE EXPLOSIVES WOOO
		new mineralType(src, mineralAmt)
		SSblackbox.record_feedback("tally", "ore_mined", mineralAmt, mineralType)
	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)
	var/flags = NONE
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	if(iscarbon(user)) 	//yogs - rock and stone + diggy diggy hole
		var/mob/living/carbon/C = user
		if(prob(1) && C.dna?.check_mutation(DWARFISM))
			var/picked_phrase = pick(list("Rock and stone!","Rock and rollin' stone!","For rock and stone!","Rock solid!","Diggy Diggy Hole!"))
			C.say(picked_phrase)

/turf/closed/mineral/proc/attempt_drill(mob/user,triggered_by_explosion = FALSE, power = 1)
	hardness -= power
	if(hardness <= 0)
		gets_drilled(user,triggered_by_explosion)
	else
		update_appearance()

/turf/closed/mineral/update_overlays()
	. = ..()
	if(hardness != initial(hardness))
		var/mutable_appearance/cracks = mutable_appearance('icons/turf/mining.dmi',"rock_cracks", ON_EDGED_TURF_LAYER)
		var/matrix/M = new
		M.Translate(4,4)
		cracks.transform = M
		. += cracks

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		attempt_drill()
	..()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, span_notice("You start digging into the rock..."))
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M, 4 SECONDS, src))
		to_chat(M, span_notice("You tunnel into the rock."))
		attempt_drill(M)

/turf/closed/mineral/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/item/I = H.is_holding_tool_quality(TOOL_MINING)
		if(I)
			attackby(I, H)
		return
	else if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		if(R.module_active && R.module_active.tool_behaviour == TOOL_MINING)
			attackby(R.module_active, R)
			return
	else
		return

/turf/closed/mineral/acid_melt()
	ScrapeAway()

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				attempt_drill(null,TRUE,2)
			else if(prob(90))
				attempt_drill(null,TRUE,1)
		if(2)
			if (prob(90))
				attempt_drill(null,TRUE,2)
			else
				attempt_drill(null,TRUE,1)
		if(1)
			attempt_drill(null,TRUE,3)
	return

/turf/closed/mineral/Spread(turf/T)
	T.ChangeTurf(type)

/turf/closed/mineral/random
	var/list/mineralSpawnChanceList = list(/turf/closed/mineral/uranium = 5, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 10,
		/turf/closed/mineral/silver = 12, /turf/closed/mineral/plasma = 20, /turf/closed/mineral/iron = 40, /turf/closed/mineral/titanium = 11,
		/turf/closed/mineral/gibtonite = 4, /turf/closed/mineral/bscrystal = 1)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13
	var/display_icon_state = "rock"

/turf/closed/mineral/random/Initialize(mapload)

	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)

	if (display_icon_state)
		icon_state = display_icon_state
	. = ..()
	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/stored_flags = 0
		if(turf_flags & NO_RUINS)
			stored_flags |= NO_RUINS
		var/turf/T = ChangeTurf(path,null,CHANGETURF_IGNORE_AIR)
		T.flags_1 |= stored_flags

		if(T && ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.mineralAmt = rand(1, 5) + max(0,((hardness - 1) * 2)) //2 bonus ore for every hardness above 1
			M.environment_type = src.environment_type
			M.turf_type = src.turf_type
			M.baseturfs = src.baseturfs
			src = M
			M.levelupdate()
		else
			src = T
			T.levelupdate()

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 35, /turf/closed/mineral/diamond = 30, /turf/closed/mineral/gold = 45, /turf/closed/mineral/titanium = 45,
		/turf/closed/mineral/dilithium = 25, // Yogs -- Adds Dilthium, for Cold Fusion 'n shit
		/turf/closed/mineral/silver = 50, /turf/closed/mineral/plasma = 50, /turf/closed/mineral/bscrystal = 20)

/turf/closed/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 35, /turf/closed/mineral/diamond/volcanic = 30, /turf/closed/mineral/gold/volcanic = 45, /turf/closed/mineral/titanium/volcanic = 45,
		/turf/closed/mineral/silver/volcanic = 50, /turf/closed/mineral/plasma/volcanic = 50, /turf/closed/mineral/bscrystal/volcanic = 20,/turf/closed/mineral/gem/volcanic = 20)

/turf/closed/mineral/random/high_chance/snow
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	defer_change = TRUE
	environment_type = "snow"
	turf_type = /turf/open/floor/plating/asteroid/snow/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/ice/icemoon = 35, /turf/closed/mineral/diamond/ice/icemoon = 25, /turf/closed/mineral/gold/ice/icemoon = 40, /turf/closed/mineral/titanium/ice/icemoon = 45,
		/turf/closed/mineral/silver/ice/icemoon = 50, /turf/closed/mineral/plasma/ice/icemoon = 50, /turf/closed/mineral/bscrystal/ice/icemoon = 15, /turf/closed/mineral/dilithium/ice/icemoon = 15)

/turf/closed/mineral/random/high_chance/snow/top_layer
	light_range = 2
	light_power = 0.1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/ice/icemoon/top_layer = 35, /turf/closed/mineral/diamond/ice/icemoon/top_layer = 25, /turf/closed/mineral/gold/ice/icemoon/top_layer = 40, /turf/closed/mineral/titanium/ice/icemoon/top_layer = 45,
		/turf/closed/mineral/silver/ice/icemoon/top_layer = 50, /turf/closed/mineral/plasma/ice/icemoon/top_layer = 50, /turf/closed/mineral/bscrystal/ice/icemoon/top_layer = 15, /turf/closed/mineral/dilithium/ice/icemoon/top_layer = 15)

/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 2, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 4, /turf/closed/mineral/titanium = 4,
		/turf/closed/mineral/silver = 6, /turf/closed/mineral/plasma = 15, /turf/closed/mineral/iron = 40,
		/turf/closed/mineral/gibtonite = 2, /turf/closed/mineral/bscrystal = 1)


/turf/closed/mineral/random/low_chance_air
	icon_state = "rock_lowchance"
	mineralChance = 8
	mineralSpawnChanceList = list(
		/turf/closed/mineral/gold = 2, /turf/closed/mineral/titanium = 1,
		/turf/closed/mineral/silver = 2, /turf/closed/mineral/plasma = 5, /turf/closed/mineral/iron = 40,
		/turf/closed/mineral/bscrystal = 1)
	baseturfs = /turf/open/floor/plating/asteroid


/turf/closed/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE


	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 5, /turf/closed/mineral/diamond/volcanic = 1, /turf/closed/mineral/gold/volcanic = 10, /turf/closed/mineral/titanium/volcanic = 11,
		/turf/closed/mineral/silver/volcanic = 12, /turf/closed/mineral/plasma/volcanic = 20, /turf/closed/mineral/iron/volcanic = 40,
		/turf/closed/mineral/dilithium/volcanic = 2, // Yogs -- Adds Dilthium, for Cold Fusion 'n shit
		/turf/closed/mineral/gibtonite/volcanic = 4, /turf/closed/mineral/bscrystal/volcanic = 1, /turf/closed/mineral/gem/volcanic = 1)

/turf/closed/mineral/random/volcanic/hard
	name = "hardened basalt"
	icon_state = "rock_hard"
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	mineralChance = 15
	hardness = 2

	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic/hard = 5, /turf/closed/mineral/diamond/volcanic/hard = 1, /turf/closed/mineral/gold/volcanic/hard = 10, /turf/closed/mineral/titanium/volcanic/hard = 11, /turf/closed/mineral/magmite/volcanic/hard = 0.5, /turf/closed/mineral/gem/volcanic/hard = 2,
		/turf/closed/mineral/silver/volcanic/hard = 12, /turf/closed/mineral/plasma/volcanic/hard = 20, /turf/closed/mineral/iron/volcanic/hard = 20, /turf/closed/mineral/dilithium/volcanic/hard = 2, /turf/closed/mineral/gibtonite/volcanic/hard = 4, /turf/closed/mineral/bscrystal/volcanic/hard = 2)

/turf/closed/mineral/random/volcanic/harder
	name = "granite"
	color = "#eb9877"
	mineralChance = 20
	hardness = 3

	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic/harder = 6, /turf/closed/mineral/diamond/volcanic/harder = 2, /turf/closed/mineral/gold/volcanic/harder = 11, /turf/closed/mineral/titanium/volcanic/harder = 12, /turf/closed/mineral/magmite/volcanic/harder = 2, /turf/closed/mineral/gem/volcanic/harder = 2,
		/turf/closed/mineral/silver/volcanic/harder = 13, /turf/closed/mineral/plasma/volcanic/harder = 21, /turf/closed/mineral/iron/volcanic/harder = 10, /turf/closed/mineral/dilithium/volcanic/harder = 4, /turf/closed/mineral/gibtonite/volcanic/harder = 7, /turf/closed/mineral/bscrystal/volcanic/harder = 3)

/// A turf that can't we can't build openspace chasms on or spawn ruins in.
/turf/closed/mineral/random/volcanic/do_not_chasm
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface/no_ruins
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/turf/closed/mineral/random/snow
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	defer_change = TRUE
	environment_type = "snow"
	turf_type = /turf/open/floor/plating/asteroid/snow/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/ice/icemoon = 5, /turf/closed/mineral/diamond/ice/icemoon = 1, /turf/closed/mineral/gold/ice/icemoon = 10, /turf/closed/mineral/titanium/ice/icemoon = 10,
		/turf/closed/mineral/silver/ice/icemoon = 12, /turf/closed/mineral/plasma/ice/icemoon = 19, /turf/closed/mineral/iron/ice/icemoon = 40,
		/turf/closed/mineral/gibtonite/ice/icemoon = 4, /turf/closed/mineral/bscrystal/ice/icemoon = 1, /turf/closed/mineral/dilithium/ice/icemoon = 2)

/turf/closed/mineral/random/snow/singularity_act() //no free infinite singularity energy (however eating minerals will still feed it)
	. = ..()
	return 0

/turf/closed/mineral/random/snow/top_layer
	light_range = 2
	light_power = 0.1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/ice/icemoon/top_layer = 5, /turf/closed/mineral/diamond/ice/icemoon/top_layer = 1, /turf/closed/mineral/gold/ice/icemoon/top_layer = 10, /turf/closed/mineral/titanium/ice/icemoon/top_layer = 10,
		/turf/closed/mineral/silver/ice/icemoon/top_layer = 12, /turf/closed/mineral/plasma/ice/icemoon/top_layer = 19, /turf/closed/mineral/iron/ice/icemoon/top_layer = 40,
		/turf/closed/mineral/gibtonite/ice/icemoon/top_layer = 4, /turf/closed/mineral/bscrystal/ice/icemoon/top_layer = 1, /turf/closed/mineral/dilithium/ice/icemoon/top_layer = 2)

/turf/closed/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 3, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 8, /turf/closed/mineral/titanium = 8,
		/turf/closed/mineral/silver = 20, /turf/closed/mineral/plasma = 30, /turf/closed/mineral/iron = 95,
		/turf/closed/mineral/gibtonite = 2)
	icon_state = "rock_labor"

/turf/closed/mineral/random/snow/underground
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/ice/icemoon = 5, /turf/closed/mineral/diamond/ice/icemoon = 1, /turf/closed/mineral/gold/ice/icemoon = 10, /turf/closed/mineral/titanium/ice/icemoon = 10,
		/turf/closed/mineral/silver/ice/icemoon = 12, /turf/closed/mineral/plasma/ice/icemoon = 19, /turf/closed/mineral/iron/ice/icemoon = 40,
		/turf/closed/mineral/gibtonite/ice/icemoon = 4, /turf/closed/mineral/bscrystal/ice/icemoon = 1, /turf/closed/mineral/dilithium/ice/icemoon = 2)

/turf/closed/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 3, /turf/closed/mineral/diamond/volcanic = 1, /turf/closed/mineral/gold/volcanic = 8, /turf/closed/mineral/titanium/volcanic = 8,
		/turf/closed/mineral/silver/volcanic = 20, /turf/closed/mineral/plasma/volcanic = 30, /turf/closed/mineral/bscrystal/volcanic = 1, /turf/closed/mineral/gibtonite/volcanic = 2,
		/turf/closed/mineral/iron/volcanic = 95)



/turf/closed/mineral/iron
	mineralType = /obj/item/stack/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/closed/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/iron/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/iron/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/iron/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_iron"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE


/turf/closed/mineral/iron/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/iron/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/uranium
	mineralType = /obj/item/stack/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Uranium"

/turf/closed/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/uranium/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/uranium/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/uranium/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_Uranium"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/uranium/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/uranium/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/diamond
	mineralType = /obj/item/stack/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_Diamond"

/turf/closed/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/diamond/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/diamond/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_diamond"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/diamond/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/gold
	mineralType = /obj/item/stack/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_Gold"

/turf/closed/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gold/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/gold/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/gold/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_gold"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gold/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/gold/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/silver
	mineralType = /obj/item/stack/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_Silver"

/turf/closed/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/silver/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/silver/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_silver"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/silver/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/titanium
	mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Titanium"

/turf/closed/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/titanium/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/titanium/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/titanium/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_titanium"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/titanium/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/titanium/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1


/turf/closed/mineral/plasma
	mineralType = /obj/item/stack/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_Plasma"

/turf/closed/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/plasma/volcanic/harder
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/plasma/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_plasma"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/plasma/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/bananium
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_Bananium"

/turf/closed/mineral/bananium/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_Bananium"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bananium/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/bananium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bananium/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/bananium/volcanic/harder
	mineralAmt = 3
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_BScrystal"

/turf/closed/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bscrystal/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/bscrystal/volcanic/harder
	mineralAmt = 3
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/bscrystal/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_BScrystal"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bscrystal/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/bscrystal/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt
	baseturfs = /turf/open/floor/plating/asteroid/basalt
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	defer_change = TRUE

/turf/closed/mineral/volcanic/lava_land_surface/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/volcanic/lava_land_surface/harder
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = MAP_SWITCH('icons/turf/walls/rock_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock2"
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ashplanet/rocky
	defer_change = TRUE

/turf/closed/mineral/ash_rock/airless
	turf_type = /turf/open/floor/plating/asteroid/airless
	baseturfs = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/closed/mineral/snowmountain
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	baseturfs = /turf/open/floor/plating/asteroid/snow
	initial_gas_mix = FROZEN_ATMOS
	environment_type = "snow"
	turf_type = /turf/open/floor/plating/asteroid/snow
	defer_change = TRUE

/// Near exact same subtype as parent, just used in ruins to prevent other ruins/chasms from spawning on top of it.
/turf/closed/mineral/snowmountain/do_not_chasm
	turf_type = /turf/open/floor/plating/asteroid/snow/icemoon/do_not_chasm
	baseturfs = /turf/open/floor/plating/asteroid/snow/icemoon/do_not_chasm
	turf_flags = NO_RUINS

/turf/closed/mineral/snowmountain/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/// This snowy mountain will never be scraped away for any reason what so ever.
/turf/closed/mineral/snowmountain/icemoon/unscrapeable
	turf_flags = IS_SOLID | NO_CLEARING
	turf_type = /turf/open/floor/plating/asteroid/snow/icemoon/do_not_scrape
	baseturfs = /turf/open/floor/plating/asteroid/snow/icemoon/do_not_scrape

/turf/closed/mineral/snowmountain/cavern
	name = "ice cavern rock"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "icerock"
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	environment_type = "snow_cavern"
	turf_type = /turf/open/floor/plating/asteroid/snow/ice

/turf/closed/mineral/snowmountain/cavern/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

//GIBTONITE

/turf/closed/mineral/gibtonite
	mineralAmt = 1
	MAP_SWITCH(, icon_state = "rock_Gibtonite_inactive")
	spreadChance = 0
	spread = 0
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/closed/mineral/gibtonite/Initialize(mapload)
	scan_state = pick("rock_Uranium", "rock_Gold", "rock_Diamond", "rock_Silver", "rock_Plasma", "rock_BScrystal", "rock_Titanium", "rock_Iron", "rock_Gibtonite") //YOGS - stealth gibtonite, hides it as another mineral
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()

/turf/closed/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/t_scanner/adv_mining_scanner/goat_scanner) && stage == 1)
		user.visible_message(span_notice("[user] holds [I] to [src]..."), span_notice("[I] locates where to cut off the chain reaction and stops it."))
		defuse(force_perfect = TRUE)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message(span_notice("[user] holds [I] to [src]..."), span_notice("You use [I] to locate where to cut off the chain reaction and attempt to stop it..."))
		defuse(force_perfect = FALSE)
	if(istype(I, /obj/item/clothing/gloves/gauntlets))
		user.visible_message(span_notice("[user] punches [src]..."), span_notice("The [I] shatter the chain reaction stopping it instantly..."))
		defuse(force_perfect = FALSE)
	..()

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_inactive", ON_EDGED_TURF_LAYER) //shows in gaps between pulses if there are any
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message(span_danger("There was gibtonite inside! It's going to explode!"), blind_message = span_danger("You hear an evil hissing!")) 

		var/notify_admins = 0
		if(z != 5)
			notify_admins = TRUE

		if(!triggered_by_explosion)
			log_bomber(user, "has trigged a gibtonite deposit reaction via", src, null, notify_admins)
		else
			log_bomber(null, "An explosion has triggered a gibtonite deposit reaction via", src, null, notify_admins)

		countdown(notify_admins)

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineralAmt >= 1)
		flick_overlay_view(mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER + 0.1), 0.5 SECONDS) //makes the animation pulse one time per tick
		det_time--
		sleep(0.5 SECONDS)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/closed/mineral/gibtonite/proc/defuse(force_perfect = FALSE)
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(force_perfect)
			det_time = 0
			visible_message(span_notice("The chain reaction was stopped at its highest potency!"))
			return
		if(det_time < 0)
			det_time = 0
		visible_message(span_notice("The chain reaction was stopped! The gibtonite had [det_time] reactions left till the explosion!"))

/turf/closed/mineral/gibtonite/attempt_drill(mob/user, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == GIBTONITE_ACTIVE && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = GIBTONITE_DETONATE
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/melee/gibtonite/G = new (src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	var/flags = NONE
	var/old_type = type
	if(defer_change)
		flags = CHANGETURF_DEFER_CHANGE
	var/turf/open/mined = ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange), flags, old_type), 1, TIMER_UNIQUE)
	mined.update_visuals()

/turf/closed/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gibtonite/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/gibtonite/volcanic/harder
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/gibtonite/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_Gibtonite"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gibtonite/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/gibtonite/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/closed/mineral/magmite
	mineralType = /obj/item/magmite
	spread = 0
	scan_state = "rock_Magmite"

/turf/closed/mineral/magmite/gets_drilled(mob/user, triggered_by_explosion = FALSE)
	if(!triggered_by_explosion)
		mineralAmt = 0
	..(user,triggered_by_explosion,TRUE)

/turf/closed/mineral/magmite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/magmite/volcanic/hard
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/magmite/volcanic/harder
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/gem
	mineralType = /obj/item/gem/random
	spread = 0
	mineralAmt = 1
	scan_state = "rock_Gem"

/turf/closed/mineral/gem/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gem/volcanic/hard
	mineralAmt = 2
	icon = MAP_SWITCH('icons/turf/smoothrocks_hard.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "smoothrocks_hard"
	hardness = 2

/turf/closed/mineral/gem/volcanic/harder
	mineralAmt = 3
	color = "#eb9877"
	hardness = 3

//yoo RED ROCK RED ROCK

/turf/closed/mineral/asteroid
	name = "iron rock"
	icon = MAP_SWITCH('icons/turf/walls/red_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "redrock"
	base_icon_state = "red_wall"

/turf/closed/mineral/random/stationside/asteroid
	name = "iron rock"
	icon = MAP_SWITCH('icons/turf/walls/red_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "red_wall"

/turf/closed/mineral/random/stationside/asteroid/porus
	name = "porous iron rock"
	desc = "This rock is filled with pockets of breathable air."
	baseturfs = /turf/open/floor/plating/asteroid

/turf/closed/mineral/asteroid/porous
	name = "porous rock"
	desc = "This rock is filled with pockets of breathable air."
	baseturfs = /turf/open/floor/plating/asteroid
