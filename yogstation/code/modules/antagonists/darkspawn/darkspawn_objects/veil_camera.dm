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
	jump_action = /datum/action/innate/camera_jump/darkspawn

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	camnet = GLOB.thrallnet

/obj/machinery/computer/camera_advanced/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return

/obj/machinery/computer/camera_advanced/darkspawn/remove_eye_control(mob/living/user)
	. = ..()
	playsound(src, "crawling_shadows_walk", 35, FALSE)

//special ability to replace sound effects
/datum/action/innate/camera_jump/darkspawn
	name = "Jump To Ally"

/datum/action/innate/camera_jump/darkspawn/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/ai_eye/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam as anything in origin.camnet.cameras)
		if(length(origin.z_lock) && !(cam.z in origin.z_lock))
			continue
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network & origin.networks
		if (length(tempnetwork))
			if(!netcam.c_tag)
				continue
			T["[netcam.c_tag][netcam.can_use() ? null : " (Deactivated)"]"] = netcam

	playsound(origin, "crawling_shadows_walk", 25, FALSE)
	var/camera = tgui_input_list(usr, "Ally to view", "Allies", T)
	if(isnull(camera))
		return
	if(isnull(T[camera]))
		return
	var/obj/machinery/camera/final = T[camera]
	playsound(origin, "crawling_shadows_walk", 25, FALSE)
	if(final)
		remote_eye.setLoc(get_turf(final))
		owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
		owner.clear_fullscreen("flash", 1) //Shorter flash than normal since it's an ~~advanced~~ console!

//////////////////////////////////////////////////////////////////////////
//-------------------------Expand the veilnet---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/camera/darkspawn
	name = "void eye"
	use_power = NO_POWER_USE
	max_integrity = 20
	integrity_failure = 20
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "camera"
	special_camera = TRUE
	internal_light = FALSE
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
