GLOBAL_LIST_EMPTY(blob_walls)

/turf/closed/indestructible/riveted/infection
	baseturfs = /turf/open/floor/plating/asteroid

/turf/closed/indestructible/riveted/infection/Initialize(mapload)
	GLOB.blob_walls += src
	..()

/area/infection
	name = "Crater"
	icon_state = "security"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/area/infection/zero
	name = "Crater 0"
	infection_block_level = 0

/area/infection/zero/bunker
	name = "Forward Bunker"
	icon_state = "nuke_storage"

/area/infection/zero/triage
	name = "Triage"
	icon_state = "medbay2"

/area/infection/one
	name = "Crater 1"
	infection_block_level = 1

/area/infection/one/bunker
	name = "Back Bunker"
	icon_state = "nuke_storage"

/area/infection/two
	name = "Crater 2"
	infection_block_level = 2

/area/infection/two/tunnel/big
	name = "Tunnels"
	icon_state = "nuke_storage"

/area/infection/two/tunnel/small
	name = "Tunnels"
	icon_state = "nuke_storage"

/area/infection/three
	name = "Crater 3"
	infection_block_level = 3

/area/infection/three/main_hallway
	name = "Main Hallway"
	icon_state = "teleporter"

/area/infection/three/command
	name = "Command"
	icon_state = "centcom"

/area/infection/three/cargo_combined
	name = "Requisitions"
	icon_state = "quart"

/area/infection/three/science
	name = "Science"
	icon_state = "toxlab"

/area/infection/four
	name = "Crater 4"
	infection_block_level = 4

/area/infection/four/nuke
	name = "Self Destruct Room"
	icon_state = "nuke_storage"

/area/infection/five
	name = "Crater 5"
	infection_block_level = 5

/area/infection/six
	name = "Crater 6"
	infection_block_level = 6

/area/infection/seven
	name = "Crater 7"
	infection_block_level = 7

/area/infection/eight
	name = "Crater 8"
	infection_block_level = 8

/area/infection/nine
	name = "Crater 9"
	infection_block_level = 9

/area/infection/ten
	name = "Crater 10"
	infection_block_level = 10