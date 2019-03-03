/area/metro
	name = "metro"
	noteleport = TRUE			//Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
	hidden = TRUE 			//Hides area from player Teleport function.
	safe = TRUE
	requires_power = FALSE
	ambientsounds = RUINS
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/metro/outside/Initialize()
	START_PROCESSING(SSobj, src)
	..()

/area/metro/outside
	name = "outside metro"

/area/metro/outside/extreme
	name = "harsh outside metro"
	
/area/metro/inside
	name = "inside metro"
