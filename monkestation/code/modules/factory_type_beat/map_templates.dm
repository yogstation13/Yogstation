
/datum/map_template/ruin/icemoon/underground/vent
	name = "Icemoon Ore Vent"
	id = "ore_vent_i"
	description = "A vent that spews out ore. Seems to be a natural phenomenon." //Make this a subtype that only spawns medium and large vents. Some smalls will go to the top level.
	suffix = "icemoon_underground_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE

/datum/map_template/ruin/icemoon/ruin/vent
	name = "Surface Icemoon Ore Vent"
	id = "ore_vent_i"
	description = "A vent that spews out ore. Seems to be a natural phenomenon. Smaller than the underground ones."
	suffix = "icemoon_surface_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE

/datum/map_template/ruin/lavaland/vent
	name = "Ore Vent"
	id = "ore_vent"
	description = "A vent that spews out ore. Seems to be a natural phenomenon."
	suffix = "lavaland_surface_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE
