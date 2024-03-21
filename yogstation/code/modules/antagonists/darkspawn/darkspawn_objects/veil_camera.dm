//////////////////////////////////////////////////////////////////////////
//-------------------------Used for veil net----------------------------//
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
	. += emissive_appearance(icon, "panopticon_emissive", src)

/obj/machinery/computer/camera_advanced/darkspawn/can_use(mob/living/user)
	if(user && !is_darkspawn_or_thrall(user))
		to_chat(user, span_velvet("You tamper with forces you do not understand mortal."))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return
