#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = COLOR_SOFT_RED

	var/list/network = list("ss13")
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/atom/movable/screen/background/cam_background

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_SIGHT

/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	var/map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/security/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_background)
	return ..()

/obj/machinery/computer/security/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in network)
		network -= i
		network += "[port.shuttle_id]_[i]"

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!user.canUseTopic(src, no_dextery = TRUE)) //prevents monkeys from using camera consoles
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
		// Register map objects
		cam_screen.display_to(user)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()

/obj/machinery/computer/security/ui_status(mob/user)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["network"] = network
	data["mapRef"] = cam_screen.assigned_map
	var/list/cameras = get_camera_list(network)
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			ref = REF(C),
		))

	return data

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(.)
		return
	
	if(action == "switch_camera")
		var/obj/machinery/camera/selected_camera = locate(params["camera"]) in GLOB.cameranet.cameras
		active_camera = selected_camera
		playsound(src, get_sfx(SFX_TERMINAL_TYPE), 25, FALSE)

		if(isnull(active_camera))
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Get the camera's turf to correctly gather what's visible from it's turf, in case it's located in a moving object (borgs / mechs)
	var/new_cam_turf = get_turf(active_camera)

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	if(last_camera_turf == new_cam_turf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = new_cam_turf

	//Here we gather what's visible from the camera's POV based on its view_range and xray modifier if present
	var/list/visible_things = active_camera.isXRay(ignore_malf_upgrades = TRUE) ? range(active_camera.view_range, new_cam_turf) : view(active_camera.view_range, new_cam_turf)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	//Get coordinates for a rectangle area that contains the turfs we see so we can then clear away the static in the resulting rectangle area
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/security/ui_close(mob/user)
	. = ..()
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	cam_screen.hide_from(user)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		last_camera_turf = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)

/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// SECURITY MONITORS

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	clockwork = TRUE //it'd look weird
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list("mine", "auxbase")
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "research camera console"
	desc = "Used to access the various cameras in science."
	network = list("rd")
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/hos
	name = "\improper Head of Security's camera console"
	desc = "A custom security console with added access to the labor camp network."
	network = list("ss13", "labor")
	circuit = /obj/item/circuitboard/computer/security/hos

/obj/machinery/computer/security/labor
	name = "labor camp monitoring"
	desc = "Used to access the various cameras on the labor camp."
	network = list("labor")
	circuit = /obj/item/circuitboard/computer/security/labor

/obj/machinery/computer/security/qm
	name = "\improper Quartermaster's camera console"
	desc = "A console with access to the mining, auxiliary base and vault camera networks."
	network = list("mine", "auxbase", "vault")
	circuit = /obj/item/circuitboard/computer/security/qm

// TELESCREENS
/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	icon_keyboard = null
	icon_screen = null
	layer = SIGN_LAYER
	network = list("thunder")
	density = FALSE
	circuit = null
	clockwork = TRUE //it'd look very weird
	light_power = 0

/obj/machinery/computer/security/telescreen/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the Yogs Channel on these things... Nope, just the /tg/ channel! Aww..."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment_blank"
	network = list("thunder")
	density = FALSE
	circuit = null
	interaction_flags_atom = NONE  // interact() is called by BigClick()
	var/icon_state_off = "entertainment_blank"
	var/icon_state_on = "entertainment"

/obj/machinery/computer/security/telescreen/entertainment/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, PROC_REF(BigClick))

// Bypass clickchain to allow humans to use the telescreen from a distance
/obj/machinery/computer/security/telescreen/entertainment/proc/BigClick()
	interact(usr)

/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on)
	if(on && icon_state == icon_state_off)
		say(pick(
			"Feats of bravery live now at the thunderdome!",
			"Two enter, one leaves! Tune in now!",
			"Violence like you've never seen it before!",
			"Spears! Camera! Action! LIVE NOW!"))
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/computer/security/telescreen/rd
	name = "\improper Research Director's telescreen"
	desc = "Used for watching the AI and the RD's goons from the safety of his office."
	network = list("rd", "aicore", "aiupload", "minisat", "xeno", "test")

/obj/machinery/computer/security/telescreen/research
	name = "research telescreen"
	desc = "A telescreen with access to the research division's camera network."
	network = list("rd")

/obj/machinery/computer/security/telescreen/ce
	name = "\improper Chief Engineer's telescreen"
	desc = "Used for watching the engine, telecommunications and the minisat."
	network = list("engine", "singularity", "tcomms", "minisat")

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper Chief Medical Officer's telescreen"
	desc = "A telescreen that connects to the medbay's camera network."
	network = list("medbay")

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = "A telescreen that connects to the vault's camera network."
	network = list("vault")

/obj/machinery/computer/security/telescreen/toxins
	name = "bomb test site monitor"
	desc = "A telescreen that connects to the bomb test site's camera."
	network = list("toxins")

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network."
	network = list("engine")

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = "A telescreen that connects to the turbine's camera."
	network = list("turbine")

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = "A telescreen that connects to the interrogation room's camera."
	network = list("interrogation")

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "A telescreen that connects to the permabrig's camera network."
	network = list("prison")

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxillary base monitor"
	desc = "A telescreen that connects to the auxillary base's camera."
	network = list("auxbase")

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "A telescreen that connects to the minisat's camera network."
	network = list("minisat")

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper AI upload monitor"
	desc = "A telescreen that connects to the AI upload's camera network."
	network = list("aiupload")

#undef DEFAULT_MAP_SIZE
