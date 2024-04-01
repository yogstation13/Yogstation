/** 
 * Dungeon room themes determine the style of the generated rooms. If you want to create a new dungeon generator for say, Icemeta,
 * Then you would want to create a new subtype of room theme with maybe snow floor tiles, ice or snow walls and some fitting kind of door. Then from there further subtype
 * into hostile, neutral, beneficial and whatever other types of rooms you want to appear in that area.
 * 
 * TLDR: This datum is basically a box of furniture that randomly generted rooms will pull from to build themselves with a cohesive style
 */
/datum/dungeon_room_theme
	var/datum/dungeon_room/dungeon_room_ref
	///Contains flags pertaining to the qualities of the room, such as ROOM_HAS_FLOORS if it, y'know, has floors
	var/room_flags = 0

	var/room_type = ROOM_TYPE_RANDOM
	
	var/room_danger_level = ROOM_RATING_SAFE
	///Weighted list of floorings for the room to choose from
	var/list/weighted_possible_floor_types = list()
	///Weighted list of walls for the room to choose from
	var/list/weighted_possible_wall_types = list()
	///If you want the theme or rooms to include windows, specify the window type here, be it the basic window obj, or a spawner for a preset window
	var/list/weighted_possible_window_types = list()
	///percent chance of spawning a window instead of a wall
	var/window_weight = 0
	///Weighted list of doors for the room to choose from
	var/list/weighted_possible_door_types = list(/obj/machinery/door/airlock = 1)
	
	///For room themes that call for very specific features appearing. Currently just for handling ruins via their landmark object
	var/special_feature = null
	
	/** 
	 * The number of features spawned in a room is:
	 * (area inside the room * feature_weight as a percent) rounded up
	 * the higher this number, the more features spawned
	 * 
	 * I.E. room with a 4x5 inner area has an area of 20, so with a feature weight of 75 results in 75% of 20, therefore 15 features will be spawned in random open spots 
	 */
	var/feature_weight = 0
	///Weighted list of features you want to spawn. Like unfinished machines, broken mechs, blood splatters. Keep in mind these will be placed randomly
	var/list/weighted_feature_spawn_list = list()
	
	var/list/expanded_weighted_feature_spawn_list = list()
	
	/** 
	 * The upper limit of mobs spawned in a room is determined by a logarithmic function using the interior size of the room. This variable
	 * is the chance that a mob spawns in each iteration of the spawning loop. 
	 * For example if a room has an interior size of 20 and has a limit of 5 mobs for the room, If the spawn chance is 50 then each of those 5 spawn attempts has
	 * a 50% chance to actually spawn a mob, otherwise it will decrease the number of spawnable mobs by 1 and try again.
	 * 
	 */
	var/mob_spawn_chance = 0
	///Weighted list of features you want to spawn. Spiders in a room that has webbing, or possums in a room full of trash. 
	var/list/weighted_mob_spawn_list = list()
	
/** Initialize the new room by sanity checking values and then assigning the bitflags that describe room behavior to the parent room*/
/datum/dungeon_room_theme/New(datum/dungeon_room/_dungeon_room_ref)
	//No negatives pls
	feature_weight = clamp(feature_weight, 0, 100)
	
	mob_spawn_chance = clamp(mob_spawn_chance, 0, 100)

	dungeon_room_ref = _dungeon_room_ref

	if(isemptylist(weighted_possible_floor_types))
		weighted_possible_floor_types = dungeon_room_ref.weighted_open_turf_types
	if(isemptylist(weighted_possible_wall_types))
		weighted_possible_wall_types = dungeon_room_ref.weighted_closed_turf_types
	
/** 
 * Any sort of room specific logic you need to do before running the Initialize() that will assign room flags. For example if you want to generate a list
 * using subtypes or typesof, which is something you can't do from the base definition and needs to be done in a proc.
 */
/datum/dungeon_room_theme/proc/pre_initialize()	
	return

/** 
 * Room flags are assigned based on which lists have any elements. 
 * These flags are checked by the room that owns the theme to determine which furnishing procs need to be called 
 */
/datum/dungeon_room_theme/proc/Initialize()
	pre_initialize()
	if(dungeon_room_ref.room_danger_level & ROOM_RATING_SAFE)
		var/list/blatently_hostile_mob_paths = (typesof(/mob/living/simple_animal/hostile) - typesof(/mob/living/simple_animal/hostile/retaliate))
		for(var/mob_path in weighted_mob_spawn_list)
			if(blatently_hostile_mob_paths.Find(mob_path))
				weighted_mob_spawn_list.Remove(mob_path)
	
	if(weighted_possible_floor_types.len)
		room_flags |= ROOM_HAS_FLOORS
	if(weighted_possible_wall_types.len)
		room_flags |= ROOM_HAS_WALLS
	if(weighted_possible_window_types.len)
		room_flags |= ROOM_HAS_WINDOWS
	if(room_flags & ROOM_HAS_WINDOWS && !(room_flags & ROOM_HAS_WALLS))
		room_flags |= ROOM_HAS_ONLY_WINDOWS
	if(weighted_possible_door_types.len)
		room_flags |= ROOM_HAS_DOORS
	if(special_feature)
		room_flags |= ROOM_HAS_SPECIAL_FEATURES
	if(weighted_feature_spawn_list.len && feature_weight > 0)
		room_flags |= ROOM_HAS_FEATURES
	if(weighted_mob_spawn_list.len && mob_spawn_chance > 0)
		room_flags |= ROOM_HAS_MOBS

///Return a random flooring /turf from the list of flooring options, selected based on weight. Defaults to basic plating if no flooring is found
/datum/dungeon_room_theme/proc/get_random_flooring()
	if(!weighted_possible_floor_types.len)
		return /turf/open/floor/plating
	var/turf/flooring = pickweight(weighted_possible_floor_types)
	return flooring

///Return a random wall /turf from the list of wall options, selected based on weight. Defaults to basic wall if no wall is found
/datum/dungeon_room_theme/proc/get_random_wall()
	if(!weighted_possible_wall_types.len)
		return /turf/closed/wall
	var/wall_path = pickweight(weighted_possible_wall_types)
	return wall_path

///Return a random window /obj from the list of window options, selected based on weight. Defaults to basic window spawner if no window is found
/datum/dungeon_room_theme/proc/get_random_window()
	if(!weighted_possible_window_types.len)
		return /obj/effect/spawner/structure/window
	var/window_path = pickweight(weighted_possible_window_types)
	return window_path

///Return a random door /obj from the list of door options, selected based on weight. Defaults to basic door if no door is found
/datum/dungeon_room_theme/proc/get_random_door()
	if(!weighted_possible_wall_types.len)
		return /obj/machinery/door/airlock
	var/door_path = pickweight(weighted_possible_door_types)
	return door_path

///Return the path for the special feature of the room. Returns null if nothing is found
/datum/dungeon_room_theme/proc/get_special_feature()
	if(!special_feature)
		return null

	return special_feature

///Return a random feature /obj the list of feature options, selected based on weight. Returns null if nothing is found
/datum/dungeon_room_theme/proc/get_random_feature()
	if(!weighted_feature_spawn_list.len)
		return null
	
	var/feature_path = pickweight(weighted_feature_spawn_list)

	// else
	weighted_feature_spawn_list[feature_path]--
	if(!weighted_feature_spawn_list[feature_path])
		weighted_feature_spawn_list.Cut(weighted_feature_spawn_list.Find(feature_path), weighted_feature_spawn_list.Find(feature_path)+1)
	
	return feature_path

/** 
 * Return a random mob /atom the list of mob options, selected based on weight. Returns null if nothing is found
 * The reason it returns an atom rather than a mob specifically is because there are some weird cases where mobs are objects, like specific silicons
 */
/datum/dungeon_room_theme/proc/get_random_mob()
	if(!weighted_mob_spawn_list.len)
		return null
	
	var/mob_path = pickweight(weighted_mob_spawn_list)

	weighted_mob_spawn_list[mob_path]--
	if(!weighted_mob_spawn_list[mob_path])
		weighted_mob_spawn_list.Remove(mob_path)

	return mob_path

/** 
 * If you want to do anything fancy with the mobs or items in the room after you know they exist. 
 * Like renaming items, reassigning factions, calling specific procs from them.
 * Whatever your little heart desires
 */
/datum/dungeon_room_theme/proc/post_generate()	
	return
