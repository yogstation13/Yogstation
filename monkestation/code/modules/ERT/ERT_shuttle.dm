////////////// Areas //////////////
/area/shuttle/ert
	name = "ERT Shuttle"
	requires_power = TRUE
	static_lighting = TRUE
	ambience_index = AMBIENCE_ENGI
	area_limited_icon_smoothing = /area/shuttle/ert

/area/shuttle/ert/bridge
	name = "ERT Shuttle Bridge"

/area/shuttle/ert/engineering
	name = "ERT Shuttle Engineering"

/area/shuttle/ert/armory
	name = "ERT Shuttle Armory"

/area/shuttle/ert/cargo
	name = "ERT Shuttle Cargo Hold"

/area/shuttle/ert/medical
	name = "ERT Shuttle Medbay"

/area/shuttle/ert/clonerybay
	name = "ERT Shuttle Cloner Bay"

/area/shuttle/ert/airlock
	name = "ERT Shuttle Airlock"

/area/shuttle/ert/airlock/secondary

/area/shuttle/ert/powered
	requires_power = FALSE


/area/shuttle/ert/powered/deathsquad
	name = "Deathsquad Shuttle"
	requires_power = FALSE

////////////// Consoles //////////////
/obj/machinery/computer/shuttle/ert
	name = "ERT shuttle console"
	shuttleId = "ertshuttle"
	possible_destinations = "ertshuttle_custom;syndicate_nw"
	req_access = list(ACCESS_CENT_GENERAL)

/obj/machinery/computer/shuttle/ert/deathsquad
	name = "shuttle console"
	req_access = list(ACCESS_CENT_SPECOPS)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/ert
	name = "ERT shuttle navigation computer"
	desc = "Used to designate a precise transit location to travel to."
	shuttleId = "ertshuttle"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "ertshuttle_custom"
	see_hidden = FALSE
	view_range = 4.5

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/ert/deathsquad
	name = "shuttle navigation computer"

/obj/docking_port/mobile/ert
	name = "ERT shuttle"
	shuttle_id = "ertshuttle"
	rechargeTime = 3 MINUTES

////////////// Shuttle Templates //////////////
/datum/map_template/shuttle/ert/generic
	suffix = "generic"
	name = "ERT Shuttle"

/datum/map_template/shuttle/ert/dropship
	suffix = "dropship"
	name = "ERT Dropship"

/datum/map_template/shuttle/ert/dropship/clown
	suffix = "dropship-clown"
	name = "ERT Dropship"

/datum/map_template/shuttle/ert/dropship/janitor
	suffix = "dropship-janitor"
	name = "ERT Dropship"

/datum/map_template/shuttle/ert/dropship/engineer
	suffix = "dropship-engineering"
	name = "ERT Dropship"

/datum/map_template/shuttle/ert/deathsquad
	suffix = "deathsquad"
	name = "Deathsquad Shuttle"
