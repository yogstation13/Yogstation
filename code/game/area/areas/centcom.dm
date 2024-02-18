
// CENTCOM

/area/centcom
	name = "CentCom"
	icon_state = "centcom"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	blob_allowed = FALSE //Should go without saying, no blobs should take over centcom as a win condition.
	flags_1 = NONE

/area/centcom/control
	name = "CentCom Docks"

/area/centcom/evac
	name = "CentCom Recovery Ship"

/area/centcom/supply
	name = "CentCom Supply Shuttle Dock"

/area/centcom/ferry
	name = "CentCom Transport Shuttle Dock"

/area/centcom/testchamber
	name = "CentCom Test Chamber"


/area/centcom/prison
	name = "Admin Prison"

/area/centcom/holding
	name = "Holding Facility"

/area/centcom/supplypod/flyMeToTheMoon
	name = "Supplypod Shipping lane"
	icon_state = "supplypod_flight"

/area/centcom/supplypod
	name = "Supplypod Facility"
	icon_state = "supplypod"
	static_lighting = FALSE

	base_lighting_alpha = 255

/area/centcom/supplypod/podStorage
	name = "Supplypod Storage"
	icon_state = "supplypod_holding"

/area/centcom/supplypod/loading
	name = "Supplypod Loading Facility"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/supplypod/loading/Initialize(mapload)
	. = ..() 
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/supplypod/loading/one
	name = "Bay #1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Bay #2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Bay #3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Bay #4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "ERT Bay"
	loading_id = "5"
//THUNDERDOME

/area/centcom/tdome
	name = "Thunderdome"
	icon_state = "yellow"
	static_lighting = FALSE

	base_lighting_alpha = 255

/area/centcom/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"

/area/centcom/tdome/arena_source
	name = "Thunderdome Arena Template"
	icon_state = "thunder"

/area/centcom/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/centcom/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "green"

/area/centcom/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/centcom/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"


//ENEMY

//Wizard
/area/centcom/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	flags_1 = NONE

//Abductors
/area/centcom/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	noteleport = TRUE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

//Syndicates
/area/centcom/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	blob_allowed = FALSE //Not... entirely sure this will ever come up... but if the bus makes blobs AND ops, it shouldn't aim for the ops to win.
	flags_1 = NONE
	ambience_index = AMBIENCE_DANGER

/area/centcom/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/centcom/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/centcom/fabric_of_reality
	name = "Tear in the Fabric of Reality"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = TRUE
	noteleport = TRUE
	blob_allowed = FALSE
	var/turf/origin

//CAPTURE THE FLAG

/area/centcom/ctf
	name = "Capture the Flag"
	icon_state = "yellow"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY

/area/centcom/ctf/control_room
	name = "Control Room A"

/area/centcom/ctf/control_room2
	name = "Control Room B"

/area/centcom/ctf/central
	name = "Central"

/area/centcom/ctf/main_hall
	name = "Main Hall A"

/area/centcom/ctf/main_hall2
	name = "Main Hall B"

/area/centcom/ctf/corridor
	name = "Corridor A"

/area/centcom/ctf/corridor2
	name = "Corridor B"

/area/centcom/ctf/flag_room
	name = "Flag Room A"

/area/centcom/ctf/flag_room2
	name = "Flag Room B"

// REEBE

/area/centcom/reebe
	name = "Reebe"
	icon_state = "yellow"
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE

	base_lighting_alpha = 255
	noteleport = TRUE
	hidden = TRUE
	ambience_index = AMBIENCE_REEBE

/area/centcom/reebe/city_of_cogs
	name = "City of Cogs"
	icon_state = "purple"
	static_lighting = FALSE

	base_lighting_alpha = 255
	hidden = FALSE
