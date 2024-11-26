/area/graveyard // For Graveyard
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	sound_environment = SOUND_AREA_LAVALAND
	outdoors = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE

/area/graveyard/surface
	name = "Surface"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "space"

/area/graveyard/surface/randomgen
	map_generator = /datum/map_generator/jungle_generator

/area/graveyard/surface/structures
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	outdoors = FALSE
	ambience_index = AMBIENCE_GENERIC

/area/graveyard/surface/structures/departurepark
	name = "Departures Park"

/area/graveyard/surface/structures/church
	name = "Old Church"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	requires_power = FALSE
	power_light = TRUE
	power_equip = TRUE
	power_environ = TRUE

/area/graveyard/surface/structures/house

/area/graveyard/surface/structures/shack

/area/graveyard/surface/structures/saloon

/area/graveyard/surface/structures/graveyard
	name = "Graveyard" //THEY SAID THE THING!

/area/graveyard/tunnels
	name = "Tunnels"
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	always_unpowered = TRUE
	outdoors = FALSE
	sound_environment = SOUND_AREA_LAVALAND

/area/graveyard/tunnels/mobspawngen // todo get custom generator done for mobs in the tunnels

/area/graveyard/tunnels/safe
	icon_state = "explored"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED

/area/graveyard/tunnels/structures
	always_unpowered = FALSE
	ambient_buzz = null
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/graveyard/tunnels/structures/snackshack
	name = "Tunnel Snack Shack"

/area/graveyard/tunnels/structures/tunnellounge

/area/graveyard/tunnels/structures/miningshack1
	name = "Mining Tool Shed"

/area/graveyard/tunnels/structures/miningshack2
	name = "Mining Tool Shed"

/area/graveyard/tunnels/structures/scimaint
	name = "Central Starboard Maintenance Tunnel"

/area/graveyard/bunker
	name = "Bunker"
	always_unpowered = FALSE
	ambient_buzz = null
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/graveyard/bunker/engineering
	name = "Engineering Bunker"
	icon_state = "engie"

/area/graveyard/bunker/mining
	name = "Mining Bunker"
	icon_state = "mining"

/area/graveyard/bunker/science
	name = "Science Bunker"
	icon_state = "science"

/area/graveyard/bunker/medical
	name = "Medical Bunker"
	icon_state = "medbay"

/area/graveyard/bunker/security
	name = "Security Bunker"
	icon_state = "security"

/area/graveyard/bunker/strange

/area/graveyard/bunker/command
	name = "Command Bunker"
	icon = 'monkestation/code/modules/blueshift/icons/areas/areas_station.dmi'
	icon_state = "secure_bunker"

/area/graveyard/bunker/public
	name = "Public Tunnels Access"
