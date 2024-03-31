GLOBAL_DATUM_INIT(thrallnet, /datum/cameranet/darkspawn, new)
//////////////////////////////////////////////////////////////////////////
//-------------------------Access the veilnet---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/computer/camera_advanced/darkspawn
	name = "dark orb"
	desc = "An unsettling swirling mass of darkness. Gazing into it seems to reveal forbidden knowledge."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "panopticon"
	special_appearance = TRUE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	max_integrity = 200
	integrity_failure = 0
	light_power = -1
	light_color = COLOR_VELVET
	light_system = MOVABLE_LIGHT //it's not movable, but the new system looks nicer for this purpose
	networks = list(ROLE_DARKSPAWN)
	clicksound = "crawling_shadows_walk"

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	camnet = GLOB.thrallnet

/obj/machinery/computer/camera_advanced/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return

//////////////////////////////////////////////////////////////////////////
//-------------------------Expand the veilnet---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/camera/darkspawn
	use_power = NO_POWER_USE
	max_integrity = 20
	integrity_failure = 20
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "camera"
	special_camera = TRUE
	internal_light = FALSE
	alpha = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	flags_1 = NODECONSTRUCT_1

/obj/machinery/camera/darkspawn/Initialize(mapload, obj/structure/camera_assembly/CA)
	. = ..()
	network = list(ROLE_DARKSPAWN)
	change_camnet(GLOB.thrallnet)
	setViewRange(10)

/obj/machinery/camera/darkspawn/emp_act(severity)
	return

/obj/machinery/camera/darkspawn/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/multitool_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/welder_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)
