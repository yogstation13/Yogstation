/obj/machinery/computer/shuttle/clown_ship
	name = "Funny Looking Console"
	desc = "Used to control the clown shuttle."
	circuit = /obj/item/circuitboard/computer/white_ship
	shuttleId = "clownship"
	possible_destinations = "clownship_away;whiteship_home;whiteship_lavaland;spacebar;clownship_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/clownship
	name = "Clown Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the Clown Ship."
	shuttleId = "clownship"
	lock_override = NONE
	shuttlePortId = "clownship_custom"
	jumpto_ports = list("clownship_home" = 1, "whiteship_lavaland" = 1)
	view_range = 10
	x_offset = -6
	y_offset = -10
	designate_time = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/clownship/Initialize(mapload)
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/clownship/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()
