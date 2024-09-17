//both the definition and the default maintenance theme, everything else is relative to this
/datum/generator_theme
	///Weight for use in picking this theme
	var/weight = 50
	///Weighted list of floorings for the generator to choose from
	var/list/weighted_possible_floor_types = list()
	///Weighted list of walls for the generator to choose from
	var/list/weighted_possible_wall_types = list()
	///Weighted list of extra features that spawn against walls.
	var/list/weighted_againstwall_spawn_list = list(
		/obj/machinery/space_heater = 1,
		/obj/structure/closet/emcloset = 2,
		/obj/structure/closet/firecloset = 2,
		/obj/structure/closet/toolcloset = 1,
		list(/obj/structure/table, /obj/effect/spawner/lootdrop/maintenance) = 1, //we do it this way so we can spawn things in groups
		list(/obj/structure/rack, /obj/effect/spawner/lootdrop/maintenance) = 1
	)
	///Weighted list of extra features that spawn out in the open
	var/list/weighted_openfloor_spawn_list = list(
		/obj/structure/grille = 3,
		/obj/structure/grille/broken = 4,
		/obj/structure/girder/displaced = 2,
		/obj/structure/girder = 2,
		/obj/effect/spawner/lootdrop/maintenance = 2
	)
	///Weighted list of extra features that spawn in narrow hallways
	var/list/weighted_hallway_spawn_list = list(
		/obj/structure/grille = 3,
		/obj/structure/grille/broken = 4,
		/obj/structure/girder/displaced = 2,
		/obj/effect/spawner/lootdrop/maintenance = 2
	)

//Library themed
/datum/generator_theme/wooden
	weight = 20
	weighted_possible_floor_types = list(
		/turf/open/floor/carpet = 1
		)

	weighted_possible_wall_types  = list(
		/turf/closed/wall/mineral/wood = 1
		)

	weighted_againstwall_spawn_list = list(
		/obj/machinery/space_heater = 1,
		/obj/structure/closet/emcloset = 2,
		/obj/structure/closet/firecloset = 2,
		/obj/structure/closet/toolcloset = 1,
		list(/obj/structure/table, /obj/effect/spawner/lootdrop/maintenance) = 1,
		list(/obj/structure/rack, /obj/effect/spawner/lootdrop/maintenance) = 1
		)

	weighted_openfloor_spawn_list = list(
		/obj/structure/bookcase/random = 4,
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/item/book/random = 3,
		)

	weighted_hallway_spawn_list = list(
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/item/book/random = 2,
		)

//dungeon themed
/datum/generator_theme/meatlocker
	weight = 10
	weighted_possible_floor_types = list(
		/turf/open/floor/stone = 1
		)

	weighted_possible_wall_types  = list(
		/turf/closed/wall/mineral/iron = 1
		)

	weighted_againstwall_spawn_list = list(
		/obj/machinery/space_heater = 1,
		/obj/structure/closet/emcloset = 2,
		/obj/structure/closet/firecloset = 2,
		/obj/structure/closet/toolcloset = 1,
		list(/obj/structure/table, /obj/effect/spawner/lootdrop/maintenance) = 1,
		list(/obj/structure/rack, /obj/effect/spawner/lootdrop/maintenance) = 1,
		list(/obj/effect/spawner/lootdrop/random_meat, /obj/effect/gibspawner/generic) = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/effect/gibspawner/human = 1,
		)

	weighted_openfloor_spawn_list = list(
		/obj/structure/kitchenspike = 4,
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/effect/spawner/lootdrop/random_meat = 2,
		list(/obj/effect/spawner/lootdrop/random_meat, /obj/effect/gibspawner/generic) = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/effect/gibspawner/human = 1,
		)

	weighted_hallway_spawn_list = list(
		/obj/effect/spawner/lootdrop/maintenance = 3,
		/obj/effect/spawner/lootdrop/random_meat = 2,
		list(/obj/effect/spawner/lootdrop/random_meat, /obj/effect/gibspawner/generic) = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/effect/gibspawner/human = 1,
		)

//jungle themed
/datum/generator_theme/jungle
	weight = 10
	weighted_possible_floor_types = list(
		/turf/open/floor/plating/dirt/jungleland/backrooms = 1
		)

	weighted_possible_wall_types  = list(
		/turf/closed/wall/mineral/bamboo = 1
		)

	weighted_againstwall_spawn_list = list(
		/obj/machinery/space_heater = 3,
		/obj/structure/closet/emcloset = 6,
		/obj/structure/closet/firecloset = 6,
		/obj/structure/closet/toolcloset = 3,
		list(/obj/structure/table, /obj/effect/spawner/lootdrop/maintenance) = 3, //we do it this way so we can spawn things in groups
		list(/obj/structure/rack, /obj/effect/spawner/lootdrop/maintenance) = 3,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/herb/lantern = 1,
	)

	weighted_openfloor_spawn_list = list(
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/tree/jungle = 5
		)

	weighted_hallway_spawn_list = list(
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/herb/lantern = 1,
		)

/turf/open/floor/plating/dirt/jungleland/backrooms //fullbright backrooms? in this economy?
	light_power = 1
	light_range = 2
