//Aux base construction console
/mob/camera/ai_eye/remote/base_construction
	name = "construction holo-drone"
	move_on_shuttle = 1 //Allows any curious crew to watch the base after it leaves. (This is safe as the base cannot be modified once it leaves)
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	var/area/starting_area
	invisibility = 0 //Not invisible

/mob/camera/ai_eye/remote/base_construction/Initialize(mapload)
	. = ..()
	starting_area = get_area(loc)
	icon_state = "construction_drone" // Overrides /mob/camera/ai_eye/Initialize(mapload) in \modules\mob\living\silicon\ai\freelook\eye

/mob/camera/ai_eye/remote/base_construction/setLoc(turf/destination, force_update = FALSE)
	var/area/curr_area = get_area(destination)
	if(curr_area == starting_area || istype(curr_area, /area/shuttle/auxiliary_base))
		return ..()
	//While players are only allowed to build in the base area, but consoles starting outside the base can move into the base area to begin work.

/mob/camera/ai_eye/remote/base_construction/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	..()

/obj/item/construction/rcd/internal //Base console's internal RCD. Roundstart consoles are filled, rebuilt consoles start empty.
	name = "internal RCD"
	max_matter = 600 //Bigger container and faster speeds due to being specialized and stationary.
	no_ammo_message = span_warning("Internal matter exhausted. Please add additional materials.")
	delay_mod = 0.5

/obj/machinery/computer/camera_advanced/base_construction
	name = "base construction console"
	desc = "An industrial computer integrated with a camera-assisted rapid construction drone."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/base_construction
	off_action = /datum/action/innate/camera_off/base_construction
	jump_action = null
	icon_screen = "mining"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_PINK
	///Area that the eyeobj will be constrained to. If null, eyeobj will be able to build and move anywhere.
	var/area/allowed_area = /area/shuttle/auxiliary_base

	var/obj/item/construction/rcd/internal/RCD //Internal RCD. The computer passes user commands to this in order to avoid massive copypaste.
	var/obj/machinery/computer/auxiliary_base/found_aux_console //Tracker for the Aux base console, so the eye can always find it.
	var/datum/action/innate/aux_base/configure_mode/configure_mode_action = new //Action for switching the RCD's build modes
	var/datum/action/innate/aux_base/build/build_action = new //Action for using the RCD
	var/fans_remaining = 0 //Number of fans in stock.
	var/datum/action/innate/aux_base/place_fan/fan_action = new //Action for spawning fans
	var/turret_stock = 0 //Turrets in stock
	var/datum/action/innate/aux_base/install_turret/turret_action = new //Action for spawning turrets
	

/obj/machinery/computer/camera_advanced/base_construction/Initialize(mapload)
	. = ..()
	RCD = new(src)

/obj/machinery/computer/camera_advanced/base_construction/Initialize(mapload)
	. = ..()
	if(mapload) //Map spawned consoles have a filled RCD and stocked special structures
		RCD.matter = RCD.max_matter
		fans_remaining = 4
		turret_stock = 4

///Find a spawn location for the eyeobj. If no allowed_area is defined, spawn ontop of the console.
/obj/machinery/computer/camera_advanced/base_construction/proc/find_spawn_spot()
	for(var/obj/machinery/computer/auxiliary_base/aux_base_camera as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/auxiliary_base))
		if(istype(get_area(aux_base_camera), allowed_area))
			found_aux_console = aux_base_camera
			break

	if(found_aux_console)
		return get_turf(found_aux_console)
	return get_turf(src)

/obj/machinery/computer/camera_advanced/base_construction/CreateEye()
	var/turf/spawn_spot = find_spawn_spot()
	if (!spawn_spot)
		return FALSE
	eyeobj = new /mob/camera/ai_eye/remote/base_construction(get_turf(spawn_spot))
	eyeobj.origin = src


/obj/machinery/computer/camera_advanced/base_construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_ammo) || istype(W, /obj/item/stack/sheet))
		RCD.attackby(W, user, params) //If trying to feed the console more materials, pass it along to the RCD.
	else
		return ..()

/obj/machinery/computer/camera_advanced/base_construction/Destroy()
	qdel(RCD)
	return ..()

/obj/machinery/computer/camera_advanced/base_construction/GrantActions(mob/living/user)
	..()

	if(configure_mode_action)
		configure_mode_action.target = src
		configure_mode_action.Grant(user)
		actions += configure_mode_action

	if(build_action)
		build_action.target = src
		build_action.Grant(user)
		actions += build_action

	if(fan_action)
		fan_action.target = src
		fan_action.Grant(user)
		actions += fan_action

	if(turret_action)
		turret_action.target = src
		turret_action.Grant(user)
		actions += turret_action

	eyeobj.invisibility = 0 //When the eye is in use, make it visible to players so they know when someone is building.

/obj/machinery/computer/camera_advanced/base_construction/remove_eye_control(mob/living/user)
	..()
	eyeobj.invisibility = INVISIBILITY_MAXIMUM //Hide the eye when not in use.

/datum/action/innate/aux_base //Parent aux base action
	button_icon = 'icons/mob/actions/actions_construction.dmi'
	var/mob/living/C //Mob using the action
	var/mob/camera/ai_eye/remote/base_construction/remote_eye //Console's eye mob
	var/obj/machinery/computer/camera_advanced/base_construction/B //Console itself

/datum/action/innate/aux_base/Activate()
	if(!target)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	B = target
	if(!B.RCD) //The console must always have an RCD.
		B.RCD = new /obj/item/construction/rcd/internal(src) //If the RCD is lost somehow, make a new (empty) one!

/datum/action/innate/aux_base/proc/check_spot()
//Check a loction to see if it is inside the aux base at the station. Camera visbility checks omitted so as to not hinder construction.
	var/turf/build_target = get_turf(remote_eye)
	var/area/build_area = get_area(build_target)

	if(!istype(build_area, /area/shuttle/auxiliary_base))
		to_chat(owner, span_warning("You can only build within the mining base!"))
		return FALSE

	if(!is_station_level(build_target.z))
		to_chat(owner, span_warning("The mining base has launched and can no longer be modified."))
		return FALSE

	return TRUE

/datum/action/innate/camera_off/base_construction
	name = "Log out"

//*******************FUNCTIONS*******************

/datum/action/innate/aux_base/build
	name = "Build"
	button_icon_state = "build"

/datum/action/innate/aux_base/build/Activate()
	if(..())
		return

	if(!check_spot())
		return

	var/turf/target_turf = get_turf(remote_eye)
	var/atom/rcd_target = target_turf

	//Find airlocks and other shite
	for(var/obj/S in target_turf)
		if(LAZYLEN(S.rcd_vals(owner,B.RCD)))
			rcd_target = S //If we don't break out of this loop we'll get the last placed thing

	owner.changeNext_move(CLICK_CD_RANGE)
	B.RCD.afterattack(rcd_target, owner, TRUE) //Activate the RCD and force it to work remotely!
	playsound(target_turf, 'sound/items/deconstruct.ogg', 60, 1)

/datum/action/innate/aux_base/configure_mode
	name = "Configure RCD"
	button_icon = 'icons/obj/tools.dmi'
	button_icon_state = "rcd"

/datum/action/innate/aux_base/configure_mode/Activate()
	if(..())
		return

	B.RCD.owner = B
	B.RCD.ui_interact(owner)

datum/action/innate/aux_base/place_fan
	name = "Place Tiny Fan"
	button_icon_state = "build_fan"

datum/action/innate/aux_base/place_fan/Activate()
	if(..())
		return

	var/turf/fan_turf = get_turf(remote_eye)

	if(!B.fans_remaining)
		to_chat(owner, span_warning("[B] is out of fans!"))
		return

	if(!check_spot())
		return

	if(fan_turf.density)
		to_chat(owner, span_warning("Fans may only be placed on a floor."))
		return

	new /obj/structure/fans/tiny(fan_turf)
	B.fans_remaining--
	to_chat(owner, span_notice("Tiny fan placed. [B.fans_remaining] remaining."))
	playsound(fan_turf, 'sound/machines/click.ogg', 50, 1)

datum/action/innate/aux_base/install_turret
	name = "Install Plasma Anti-Wildlife Turret"
	button_icon_state = "build_turret"

datum/action/innate/aux_base/install_turret/Activate()
	if(..())
		return

	if(!check_spot())
		return

	if(!B.turret_stock)
		to_chat(owner, span_warning("Unable to construct additional turrets."))
		return

	var/turf/turret_turf = get_turf(remote_eye)

	if(turret_turf.is_blocked_turf())
		to_chat(owner, span_warning("Location is obstructed by something. Please clear the location and try again."))
		return

	var/obj/machinery/porta_turret/aux_base/T = new /obj/machinery/porta_turret/aux_base(turret_turf)
	if(B.found_aux_console)
		B.found_aux_console.turrets += T //Add new turret to the console's control

	B.turret_stock--
	to_chat(owner, span_notice("Turret installation complete!"))
	playsound(turret_turf, 'sound/items/drill_use.ogg', 65, 1)
