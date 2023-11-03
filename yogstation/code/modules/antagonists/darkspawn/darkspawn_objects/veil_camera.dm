//////////////////////////////////////////////////////////////////////////
//-------------------------Used for veil net----------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/computer/camera_advanced/darkspawn
	name = "dark orb"
	desc = "SEND DUDES"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	special = TRUE
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

/obj/machinery/computer/camera_advanced/darkspawn/can_use(mob/living/user)
	if(user && !is_darkspawn_or_veil(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/darkspawn/CreateEye()
	. = ..()
	eyeobj.nightvision = TRUE

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return
