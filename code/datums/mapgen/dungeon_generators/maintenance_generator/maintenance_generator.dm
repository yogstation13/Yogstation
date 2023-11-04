/datum/map_generator/dungeon_generator/maintenance
	weighted_open_turf_types = list(
		/turf/open/floor/plating = 10, 
		/turf/open/floor/plating/rust = 1,
		)
	weighted_closed_turf_types = list(/turf/closed/wall = 5, /turf/closed/wall/rust = 2 )
	room_datum_path = /datum/dungeon_room/maintenance
	room_theme_path = /datum/dungeon_room_theme/maintenance
	
	//var/list/used_spawn_points = list()

/datum/map_generator/dungeon_generator/maintenance/build_dungeon()
	. = ..()
	add_firelocks()
	add_apcs()
	wire_apcs()
	add_maint_loot()

/datum/map_generator/dungeon_generator/maintenance/proc/add_firelocks()
	///we only want to look to place firedoors every 5 tiles, so we don't place too many
	var/step_increment = 5
	var/consecutive_firedoor_limit = 3
	var/list/fire_door_spawn_points = list()
	var/fire_doors_path = /obj/effect/mapping_helpers/firedoor_border_spawner
	for(var/y in min_y to max_y step step_increment)
		fire_door_spawn_points = list()
		for(var/turf/current_turf in block(locate(min_x,y,z_level),locate(max_x,y,z_level)))
			if(working_turfs.Find(current_turf) && !current_turf.is_blocked_turf(TRUE))
				fire_door_spawn_points |= current_turf
			if(current_turf.is_blocked_turf(TRUE) && fire_door_spawn_points.len <= consecutive_firedoor_limit)
				for(var/turf/spawn_point in fire_door_spawn_points)
					new fire_doors_path(spawn_point)
					fire_door_spawn_points -= spawn_point
			if(fire_door_spawn_points.len > consecutive_firedoor_limit && current_turf.is_blocked_turf(TRUE))
				fire_door_spawn_points = list()
	
	fire_doors_path = /obj/effect/mapping_helpers/firedoor_border_spawner/horizontal
	for(var/x in min_x to max_x step step_increment)
		fire_door_spawn_points = list()
		for(var/turf/current_turf in block(locate(x,min_y,z_level),locate(x,max_y,z_level)))
			if(working_turfs.Find(current_turf) && !current_turf.is_blocked_turf(TRUE))
				fire_door_spawn_points |= current_turf
			if(current_turf.is_blocked_turf(TRUE) && fire_door_spawn_points.len <= consecutive_firedoor_limit)
				for(var/turf/spawn_point in fire_door_spawn_points)
					new fire_doors_path(spawn_point)
					fire_door_spawn_points -= spawn_point
			if(fire_door_spawn_points.len > consecutive_firedoor_limit && current_turf.is_blocked_turf(TRUE))
				fire_door_spawn_points = list()

/datum/map_generator/dungeon_generator/maintenance/proc/add_maint_loot()
	//Gax maints typically ends up being about 2000 turfs, so this would end up being ~200 items, structures, and decals to decorate maint with
	var/list/valid_spawn_points = typecache_filter_list(working_turfs, typecacheof(/turf/open/floor))
	var/items_to_spawn = ROUND_UP(valid_spawn_points.len * 0.15)
	var/max_attempts = 5
	var/attempts = max_attempts

	while(items_to_spawn>0 && attempts>0 && valid_spawn_points.len > 0)
		attempts--
		var/turf/spawn_point = pick_n_take(valid_spawn_points)
		var/against_wall = FALSE
		var/blocking_passage = FALSE
		var/brazil = FALSE
		var/blocked_directions = 0
		if(spawn_point?.is_blocked_turf() || spawn_point.contents.len>0)	
			continue
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(spawn_point, direction)
			if(neighbor?.is_blocked_turf(TRUE, ignore_atoms = list(/obj/structure), type_list = TRUE))
				blocked_directions |= direction
		
		if( blocked_directions )
			//probably
			against_wall = TRUE
		
		if( ((blocked_directions & (NORTH|SOUTH)) == (NORTH|SOUTH)) || ((blocked_directions & (EAST|WEST)) == (EAST|WEST)) )
			//definitely
			blocking_passage = TRUE
		
		if( (blocked_directions & (NORTH|SOUTH|EAST|WEST)) == (NORTH|SOUTH|EAST|WEST) )
			//what the fuck how did you get here
			brazil = TRUE

		if(brazil)
			new /obj/item/toy/plush/lizard/azeel(spawn_point)
			items_to_spawn--
		
		else if(blocking_passage)
			switch(rand(1,10))
				if(1 to 6)
					new /obj/structure/grille/broken(spawn_point)
					
				else
					new /obj/structure/grille(spawn_point)
			items_to_spawn--
		else if(against_wall)
			switch(rand(1,10))
				if(1 to 3)
					if(prob(50))
						new /obj/structure/table(spawn_point)
					else
						new /obj/structure/rack(spawn_point)
					items_to_spawn--
					new /obj/effect/spawner/lootdrop/maintenance(spawn_point)
				if(4 to 5)
					new /obj/machinery/space_heater(spawn_point)
				if(6 to 7)
					new /obj/structure/closet/emcloset(spawn_point)
				if(8 to 9)
					new /obj/structure/closet/firecloset(spawn_point)
				if(10)
					new /obj/structure/closet/toolcloset(spawn_point)
			items_to_spawn--
		else
			switch(rand(1,10))
				if(1 to 3)
					new /obj/structure/grille/broken(spawn_point)
				if(4 to 6)
					new /obj/structure/girder/displaced(spawn_point)
				if(7 to 9)
					new /obj/structure/grille(spawn_point)
				else
					new /obj/effect/spawner/lootdrop/maintenance(spawn_point)
			items_to_spawn--
		//used_spawn_points += spawn_point
		attempts = max_attempts

/datum/map_generator/dungeon_generator/maintenance/proc/add_apcs()
	for(var/area/current_area in areas_included)
		var/list/available_turfs = (working_turfs & typecache_filter_list(current_area.contents, typecacheof(/turf/open/floor)))
		if(current_area.get_apc() || available_turfs.len <= 0)
			continue
		var/obj/machinery/power/apc/apc_placed = null
		var/attempts = 10
		while(!apc_placed && attempts>0)
			var/turf/apc_spot = pick(available_turfs)
			for(var/direction in GLOB.cardinals)
				var/turf/neighbor = get_step(apc_spot, direction)
				if(istype(neighbor, /turf/closed/wall) && !apc_placed)
					switch(direction)
						if(NORTH)
							apc_placed = new /obj/machinery/power/apc/auto_name/north(apc_spot)
						if(SOUTH)
							apc_placed = new /obj/machinery/power/apc/auto_name/south(apc_spot)
						if(EAST)
							apc_placed = new /obj/machinery/power/apc/auto_name/east(apc_spot)
						if(WEST)
							apc_placed = new /obj/machinery/power/apc/auto_name/west(apc_spot)
			attempts--
		
		//We're not actually building these so they can break if Init doesn't trigger right like using a generator mid round
		if(!apc_placed.area)
			apc_placed.area = get_area(apc_placed.loc)

/datum/map_generator/dungeon_generator/maintenance/proc/wire_apcs()
	var/list/nearby_apcs = list()
	var/list/gen_area_apcs = list()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(apc.z == z_level)
			if(areas_included.Find(get_area(apc)))
				//log_world("[apc] added to gen area apcs")
				gen_area_apcs += apc
			else
				//log_world("[apc] added to nearby apcs")
				nearby_apcs += apc
	if(!nearby_apcs.len)
		return
	for(var/obj/machinery/power/apc/our_apc in gen_area_apcs)
		//log_world("finding path for [our_apc]")
		var/obj/machinery/power/apc/closest_apc = null
		var/min_dist = 0

		for(var/obj/machinery/power/apc/target_apc in nearby_apcs)
			if(!closest_apc)
				closest_apc = target_apc
			if(!min_dist)
				min_dist = get_dist(our_apc, closest_apc)
			if(get_dist(our_apc, target_apc) < min_dist)
				closest_apc = target_apc
				min_dist = get_dist(our_apc, closest_apc)
		
		var/access_card = new /obj/item/card/id/captains_spare
		
		//We have to rawdog the Astar pathfinding and skip the wrapper proc because that's made specifically for mobs
		var/list/cable_path = AStar(
			caller = our_apc,
			_end = closest_apc,
			dist = /turf/proc/Distance_cardinal,
			maxnodes = 0,
			maxnodedepth = 0,
			mintargetdist = 0,
			adjacent = /turf/proc/wiringTurfTest, 
			id = access_card, 
			exclude = null, 
			simulated_only = FALSE, 
			get_best_attempt = TRUE)
		
		if(!cable_path || cable_path.len <= 1)
			//log_world("Cable path for [our_apc] either null or only 1 tile")
			continue
		
		for(var/i in 1 to cable_path.len)
			var/turf/cable_step = cable_path[i]
			var/turf/cable_step_prev
			var/turf/cable_step_next
			var/d1 = 0
			var/d2 = NORTH
			if (i == 1)
				cable_step_next = cable_path[i+1]
				d1 = 0
				d2 = get_dir(cable_step, cable_step_next)
			else if (i == cable_path.len)
				cable_step_prev = cable_path[i-1]
				d1 = 0
				d2 = get_dir(cable_step, cable_step_prev)
			else
				cable_step_prev = cable_path[i-1]
				cable_step_next = cable_path[i+1]
				d1 = get_dir(cable_step, cable_step_prev)
				d2 = get_dir(cable_step, cable_step_next)
				//cables fucking suck and require the smaller direction value be d1 and larger direction value be d2
				if(d1>d2)
					var/tmp_dir = d1
					d1 = d2
					d2 = tmp_dir
			var/reached_existing_powernet = FALSE
			for(var/obj/structure/cable/existing_cable in cable_step)
				//if there's a duplicate cable in the exact position and orientation we're about to use, we have tied into existing cabling on the map and can stop
				if(existing_cable.icon_state == "[d1]-[d2]")
					reached_existing_powernet = TRUE
			if(reached_existing_powernet)
				//this could really be continue or break, but if you continue, it might make more unnecessary cables later to get to the same spot
				break
			var/obj/structure/cable/new_cable = new(cable_step)
			new_cable.icon_state = "[d1]-[d2]"
			if(istype(cable_step, /turf/open/space))
				for(var/obj/structure/lattice/existing_lat in cable_step.contents)
					qdel(existing_lat)
				new /obj/structure/lattice/catwalk(cable_step)
			//create a new powernet with the cable, if needed it will be merged later
			//new_cable.mergeConnectedNetworks(new_cable.d1)

/datum/map_generator/dungeon_generator/maintenance/proc/check_adjacent_turfs(turf/turf_to_check)
	var/against_wall = FALSE
	var/blocking_passage = FALSE
	var/brazil = FALSE
	var/blocked_directions = 0
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(turf_to_check, direction)
		if(neighbor?.is_blocked_turf(TRUE, ignore_atoms = list(/obj/structure), type_list = TRUE))
			blocked_directions |= direction
		
	if( blocked_directions )
		//probably
		against_wall = TRUE
		
	if( ((blocked_directions & (NORTH|SOUTH)) == (NORTH|SOUTH)) || ((blocked_directions & (EAST|WEST)) == (EAST|WEST)) )
		//definitely
		blocking_passage = TRUE
	
	if( (blocked_directions & (NORTH|SOUTH|EAST|WEST)) == (NORTH|SOUTH|EAST|WEST) )
		//what the fuck how did you get here
		brazil = TRUE
	return "blocked directions: [blocked_directions], against a wall: [against_wall], in a one tile hallway: [blocking_passage], brazil: [brazil]"
