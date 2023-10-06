// Populate the space level list and prepare space transitions
/datum/controller/subsystem/mapping/proc/InitializeDefaultZLevels()
	if (z_list)  // subsystem/Recover or badminnery, no need
		return

	z_list = list()
	z_level_to_plane_offset = list()
	z_level_to_lowest_plane_offset = list()
	var/list/default_map_traits = DEFAULT_MAP_TRAITS

	if (default_map_traits.len != world.maxz)
		log_mapping("More or less map attributes pre-defined ([default_map_traits.len]) than existent z-levels ([world.maxz]). Ignoring the larger.")
		if (default_map_traits.len > world.maxz)
			default_map_traits.Cut(world.maxz + 1)

	for (var/I in 1 to default_map_traits.len)
		var/list/features = default_map_traits[I]
		var/datum/space_level/S = new(I, features[DL_NAME], features[DL_TRAITS])
		manage_z_level(S, filled_with_space = FALSE)
	generate_z_level_linkages() // Default Zs don't use add_new_zlevel() so they don't automatically generate z-linkages.

/// Generates a real, honest to god new z level. Will create the actual space, and also generate a datum that holds info about the new plot of land
/// Accepts the name, traits list, datum type, and if we should manage the turfs we create
/datum/controller/subsystem/mapping/proc/add_new_zlevel(name, traits = list(), z_type = /datum/space_level, contain_turfs = TRUE)
	UNTIL(!adding_new_zlevel)
	adding_new_zlevel = TRUE
	var/new_z = z_list.len + 1
	if (world.maxz < new_z)
		world.incrementMaxZ()
		CHECK_TICK
	// TODO: sleep here if the Z level needs to be cleared
	var/datum/space_level/S = new z_type(new_z, name, traits)
	manage_z_level(S, filled_with_space = TRUE, contain_turfs = contain_turfs)
	generate_linkages_for_z_level(new_z)
	calculate_z_level_gravity(new_z)
	adding_new_zlevel = FALSE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NEW_Z, S)
	return S

/datum/controller/subsystem/mapping/proc/get_level(z)
	if (z_list && z >= 1 && z <= z_list.len)
		return z_list[z]
	CRASH("Unmanaged z-level [z]! maxz = [world.maxz], z_list.len = [z_list ? z_list.len : "null"]")

/datum/controller/subsystem/mapping/proc/generate_backrooms()
	var/datum/space_level/backrooms = add_new_zlevel("The Backrooms", ZTRAITS_BACKROOM_MAINTS, contain_turfs = FALSE)
	backrooms.set_linkage(SELFLOOPING)
	var/area/procedurally_generated/maintenance/the_backrooms/suffer = new()
	suffer.setup("The Backrooms")
	for(var/turf/to_contain as anything in Z_TURFS(backrooms.z_value))
		var/area/old_area = to_contain.loc
		to_contain.ChangeTurf(/turf/open/genturf, flags = CHANGETURF_DEFER_CHANGE)
		to_contain.change_area(old_area, suffer)
	suffer.RunGeneration()
