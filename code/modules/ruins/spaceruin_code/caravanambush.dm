//caravan ambush

/obj/item/wrench/caravan
	name = "experimental wrench"
	desc = "A prototype of a new wrench design, allegedly the orange color scheme makes it go faster."
	icon = 'icons/obj/tools.dmi'
	icon_state = "expwrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "expwrench"
	toolspeed = 0.3

/obj/item/screwdriver/caravan
	name = "experimental screwdriver"
	desc = "A prototype of a new screwdriver design, allegedly the orange color scheme makes it go faster."
	icon = 'icons/obj/tools.dmi'
	icon_state = "expscrewdriver"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "expscrewdriver"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/wirecutters/caravan
	name = "experimental wirecutters"
	desc = "A prototype of a new wirecutter design, allegedly the orange color scheme makes it go faster."
	icon = 'icons/obj/tools.dmi'
	icon_state = "expcutters"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "expcutters"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/crowbar/red/caravan
	name = "experimental crowbar"
	desc = "A prototype of a new crowbar design, allegedly the orange color scheme makes it go faster."
	icon = 'icons/obj/tools.dmi'
	icon_state = "expcrowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "expcrowbar"
	toolspeed = 0.3

/obj/machinery/computer/shuttle/caravan

/obj/item/circuitboard/computer/caravan
	build_path = /obj/machinery/computer/shuttle/caravan

/obj/item/circuitboard/computer/caravan/trade1
	build_path = /obj/machinery/computer/shuttle/caravan/trade1

/obj/item/circuitboard/computer/caravan/pirate
	build_path = /obj/machinery/computer/shuttle/caravan/pirate

/obj/item/circuitboard/computer/caravan/syndicate1
	build_path = /obj/machinery/computer/shuttle/caravan/syndicate1

/obj/item/circuitboard/computer/caravan/syndicate2
	build_path = /obj/machinery/computer/shuttle/caravan/syndicate2

/obj/item/circuitboard/computer/caravan/syndicate3
	build_path = /obj/machinery/computer/shuttle/caravan/syndicate3

/obj/machinery/computer/shuttle/caravan/trade1
	name = "Small Freighter Shuttle Console"
	desc = "Used to control the Small Freighter."
	circuit = /obj/item/circuitboard/computer/caravan/trade1
	shuttleId = "caravantrade1"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;caravantrade1_custom;caravantrade1_ambush"

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/Initialize()
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/trade1
	name = "Small Freighter Navigation Computer"
	desc = "Used to designate a precise transit location for the Small Freighter."
	shuttleId = "caravantrade1"
	lock_override = NONE
	shuttlePortId = "caravantrade1_custom"
	jumpto_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "caravantrade1_ambush" = 1)
	view_range = 6.5
	x_offset = -5
	y_offset = -5
	designate_time = 100

/obj/machinery/computer/shuttle/caravan/pirate
	name = "Pirate Cutter Shuttle Console"
	desc = "Used to control the Pirate Cutter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/caravan/pirate
	shuttleId = "caravanpirate"
	possible_destinations = "caravanpirate_custom;caravanpirate_ambush"

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/pirate
	name = "Pirate Cutter Navigation Computer"
	desc = "Used to designate a precise transit location for the Pirate Cutter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	shuttleId = "caravanpirate"
	lock_override = NONE
	shuttlePortId = "caravanpirate_custom"
	jumpto_ports = list("caravanpirate_ambush" = 1)
	view_range = 6.5
	x_offset = 3
	y_offset = -6

/obj/machinery/computer/shuttle/caravan/syndicate1
	name = "Syndicate Fighter Shuttle Console"
	desc = "Used to control the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	circuit = /obj/item/circuitboard/computer/caravan/syndicate1
	shuttleId = "caravansyndicate1"
	possible_destinations = "caravansyndicate1_custom;caravansyndicate1_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/syndicate1
	name = "Syndicate Fighter Navigation Computer"
	desc = "Used to designate a precise transit location for the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	shuttleId = "caravansyndicate1"
	lock_override = NONE
	shuttlePortId = "caravansyndicate1_custom"
	jumpto_ports = list("caravansyndicate1_ambush" = 1, "caravansyndicate1_listeningpost" = 1)
	view_range = 0
	x_offset = 2
	y_offset = 0

/obj/machinery/computer/shuttle/caravan/syndicate2
	name = "Syndicate Fighter Shuttle Console"
	desc = "Used to control the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/caravan/syndicate2
	shuttleId = "caravansyndicate2"
	possible_destinations = "caravansyndicate2_custom;caravansyndicate2_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/syndicate2
	name = "Syndicate Fighter Navigation Computer"
	desc = "Used to designate a precise transit location for the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	shuttleId = "caravansyndicate2"
	lock_override = NONE
	shuttlePortId = "caravansyndicate2_custom"
	jumpto_ports = list("caravansyndicate2_ambush" = 1, "caravansyndicate1_listeningpost" = 1)
	view_range = 0
	x_offset = 0
	y_offset = 2

/obj/machinery/computer/shuttle/caravan/syndicate3
	name = "Syndicate Drop Ship Console"
	desc = "Used to control the Syndicate Drop Ship."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/caravan/syndicate3
	shuttleId = "caravansyndicate3"
	possible_destinations = "caravansyndicate3_custom;caravansyndicate3_ambush;caravansyndicate3_listeningpost"

/obj/machinery/computer/camera_advanced/shuttle_docker/caravan/syndicate3
	name = "Syndicate Drop Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the Syndicate Drop Ship."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	shuttleId = "caravansyndicate3"
	lock_override = NONE
	shuttlePortId = "caravansyndicate3_custom"
	jumpto_ports = list("caravansyndicate3_ambush" = 1, "caravansyndicate3_listeningpost" = 1)
	view_range = 2.5
	x_offset = -1
	y_offset = -3
	
/obj/item/paper/fluff/ruins/caravanambush/admiral
	info = "Please deliever these new sets of clothes to centcom as our admiral has lost theirs"
