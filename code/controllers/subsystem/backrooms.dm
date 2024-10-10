SUBSYSTEM_DEF(backrooms)
	name = "Procedural Generation"
	init_order = INIT_ORDER_BACKROOMS
	flags = SS_NO_FIRE

	var/datum/map_generator/dungeon_generator/backrooms_generator
	var/datum/generator_theme/picked_theme = /datum/generator_theme

	//associative list of objects and how much they sell for
	var/list/golden_loot = list( 
		/obj/item/statuebust = 1000,
		/obj/item/reagent_containers/food/snacks/urinalcake = 1000,
		/obj/item/bigspoon = 4000,
		/obj/item/reagent_containers/food/snacks/burger/rat = 1200,
		/obj/item/extinguisher = 2500,
		/obj/item/toy/plush/lizard/azeel = 5000
	)

/datum/controller/subsystem/backrooms/Initialize(timeofday)
	var/noNeed = FALSE
#ifdef LOWMEMORYMODE
	noNeed = TRUE
#endif
#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	noNeed = TRUE
#endif

	if(noNeed) //we do it this way so things can pass linter while in low memory mode or unit tests
		return SS_INIT_NO_NEED

	pick_theme()
	generate_backrooms()
	SEND_GLOBAL_SIGNAL(COMSIG_BACKROOMS_INITIALIZE)
	spawn_loot()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/backrooms/proc/pick_theme()
	var/list/themes = typesof(/datum/generator_theme)
	for(var/datum/generator_theme/possible as anything in themes) //assign the weight
		themes[possible] = initial(possible.weight)

	picked_theme = pickweight(themes)
	picked_theme = new picked_theme

/datum/controller/subsystem/backrooms/proc/generate_backrooms()
	var/list/errorList = list()
	SSmapping.LoadGroup(errorList, "Backrooms", "map_files/generic", "MaintStation.dmm", default_traits = ZTRAITS_BACKROOM_MAINTS, silent = TRUE)
	if(errorList.len)	// failed to load
		message_admins("Backrooms failed to load!")
		log_game("Backrooms failed to load!")

	for(var/area/A as anything in GLOB.areas)
		if(istype(A, /area/procedurally_generated/maintenance/the_backrooms))
			A.RunGeneration()
			backrooms_generator = A.map_generator
			break

	if(backrooms_generator && istype(backrooms_generator))
		var/min_x = backrooms_generator.min_x
		var/max_x = backrooms_generator.max_x
		var/min_y = backrooms_generator.min_y
		var/max_y = backrooms_generator.max_y
		var/z_level = backrooms_generator.z_level

		var/border = /turf/closed/wall
		if(picked_theme && length(picked_theme.weighted_possible_wall_types)) //make sure the wall matches the theme
			border = pickweight(picked_theme.weighted_possible_wall_types)

		for(var/turf/current_turf in block(locate(min_x,min_y,z_level),locate(max_x,max_y,z_level)))
			if(current_turf.x == min_x || current_turf.x == max_x || current_turf.y == min_y || current_turf.y == max_y)
				current_turf.empty(null, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
				var/turf/wall = current_turf.place_on_top(border, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
				wall.resistance_flags |= INDESTRUCTIBLE //make the wall indestructible

/datum/controller/subsystem/backrooms/proc/spawn_loot()
	var/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(!LAZYLEN(backrooms_level))
		return
	var/number = rand(20, 50)
	var/turf/destination
	var/item_path
	var/value
	for(var/i in 1 to number)
		destination = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
		item_path = pick(golden_loot)
		value = golden_loot[item_path]

		var/obj/item/thing = new item_path(destination) //spawn the thing and make it gold
		thing.AddComponent(/datum/component/valuable, value)

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Valuable items-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/export/backrooms
	//cost is irrelevant because we overwrite the proc
	unit_name = "golden object"
	export_types = list(/obj/item) //sell any object so long as it has the component

/datum/export/backrooms/applies_to(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/datum/component/valuable/value = O.GetComponent(/datum/component/valuable)
	if(!value || !istype(value))
		return FALSE
	return ..()
	
/datum/export/backrooms/get_cost(obj/O, allowed_categories = NONE, apply_limit = TRUE)
	var/amount = get_amount(O)
	var/datum/component/valuable/value = O.GetComponent(/datum/component/valuable)
	if(value && istype(value))
		return round(value.cost * amount)
	return 0


/datum/component/valuable
	///how much the item is worth
	var/cost

/datum/component/valuable/Initialize(cost)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.cost = cost

/datum/component/valuable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(isitem(parent))
		var/obj/item/goldplate = parent
		goldplate.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
	
/datum/component/valuable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/valuable/proc/on_examine(atom/eaten_light, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("This looks valuable, it could probably be sold for a lot.")
	return NONE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Entrance and exit portal----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/effect/portal/permanent/backrooms
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"

/obj/effect/spawner/backrooms_portal
	name = "backrooms two way portal spawner"

/obj/effect/spawner/backrooms_portal/Initialize(mapload)
	RegisterSignal(SSdcs, COMSIG_BACKROOMS_INITIALIZE, PROC_REF(spawn_portals))

/obj/effect/spawner/backrooms_portal/proc/spawn_portals()
	var/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(LAZYLEN(backrooms_level))
		var/turf/way_out = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
		create_portal_pair(get_turf(src), way_out, _lifespan = -1, newtype = /obj/effect/portal/permanent/backrooms)
	qdel(src)
