/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	bubble_icon = "robot"
	designation = "Default" ///used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1
	hud_type = /datum/hud/robot
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	var/custom_name = ""
	var/braintype = "Cyborg"
	var/obj/item/mmi/mmi = null

	var/throwcooldown = FALSE /// Used to determine cooldown for spin.

	var/shell = FALSE
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action = new

	/// the last health before updating - to check net change in health
	var/previous_health

	//Hud stuff
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null
	var/obj/screen/thruster_button = null
	var/obj/screen/hands = null

	var/shown_robot_modules = 0	///Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/obj/item/module_active = null
	held_items = list(null, null, null) //we use held_items for the module holding, because that makes sense to do!

	/// For checking which modules are disabled or not.
	var/disabled_modules

	var/mutable_appearance/eye_lights

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = null

	var/opened = FALSE
	var/emagged = FALSE
	var/emag_cooldown = 0
	var/wiresexposed = FALSE

	var/ident = 0
	var/locked = TRUE
	var/list/req_access = list(ACCESS_ROBOTICS)

	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())

	var/speed = 0 /// VTEC speed boost.
	var/magpulse = FALSE /// Magboot-like effect.
	var/ionpulse = FALSE /// Jetpack-like effect.
	var/ionpulse_on = FALSE /// Jetpack-like effect.
	var/datum/effect_system/trail_follow/ion/ion_trail /// Ionpulse effect.

	var/low_power_mode = FALSE ///whether the robot has no charge left.
	var/datum/effect_system/spark_spread/spark_system /// So they can initialize sparks whenever/N

	var/lawupdate = TRUE ///Cyborgs will sync their laws with their AI by default
	var/scrambledcodes = FALSE /// Used to determine if a borg shows up on the robotics console.  Setting to true hides them.
	var/lockcharge ///Boolean of whether the borg is locked down or not

	var/toner = 0
	var/tonermax = 40

	///If the lamp isn't broken.
	var/lamp_functional = TRUE
	///If the lamp is turned on
	var/lamp_enabled = FALSE
	///Set lamp color
	var/lamp_color = COLOR_WHITE
	///Lamp brightness. Starts at 3, but can be 1 - 5.
	var/lamp_intensity = 3
	///Lamp button reference
	var/lamp_cooldown = 0 ///Flag for if the lamp is on cooldown after being forcibly disabled
	var/obj/screen/robot/lamp/lampButton

	var/sight_mode = 0
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD)

	///The reference to the built-in tablet that borgs carry.
	var/obj/item/modular_computer/tablet/integrated/modularInterface
	var/obj/screen/robot/modPC/interfaceButton

	///Flash resistance
	var/sensor_protection = FALSE

	var/list/upgrades = list()

	var/expansion_count = 0
	var/obj/item/hat
	var/hat_offset = -3
	var/list/blacklisted_hats = list( ///Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/welding,
	/obj/item/clothing/mob_holder, ///I am so very upset that this breaks things
	/obj/item/clothing/head/helmet/space,
	)

	can_buckle = TRUE
	buckle_lying = FALSE
	var/static/list/can_ride_typecache = typecacheof(/mob/living/carbon/human)

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/Initialize(mapload)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new /datum/wires/robot(src)
	AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)

	RegisterSignal(src, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = HUD_LAYER	//Objects that appear on screen are on layer ABOVE_HUD_LAYER, UI should be just below it.
	robot_modules_background.plane = HUD_PLANE

	ident = rand(1, 999)

	if(!cell)
		cell = new /obj/item/stock_parts/cell/high(src)

	if(lawupdate)
		make_laws()
		if(!TryConnectToAI())
			lawupdate = FALSE

	update_law_history() //yogs

	radio = new /obj/item/radio/borg(src)
	if(!scrambledcodes && !builtInCamera)
		builtInCamera = new (src)
		builtInCamera.c_tag = real_name
		builtInCamera.network = list("ss13")
		builtInCamera.internal_light = FALSE
		builtInCamera.built_in = src
		if(wires.is_cut(WIRE_CAMERA))
			builtInCamera.status = 0
	module = new /obj/item/robot_module(src)
	module.rebuild_modules()
	update_icons()
	. = ..()

	//If this body is meant to be a borg controlled by the AI player
	if(shell)
		make_shell()

	//MMI stuff. Held togheter by magic. ~Miauw
	else if(!mmi || !mmi.brainmob)
		mmi = new (src)
		mmi.brain = new /obj/item/organ/brain(mmi)
		mmi.brain.name = "[real_name]'s brain"
		mmi.name = "[initial(mmi.name)]: [real_name]"
		mmi.brainmob = new(mmi)
		mmi.brainmob.name = src.real_name
		mmi.brainmob.real_name = src.real_name
		mmi.brainmob.container = mmi
		mmi.update_icon()

	updatename()

	blacklisted_hats = typecacheof(blacklisted_hats)

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)
	aicamera = new/obj/item/camera/siliconcam/robot_camera(src)
	toner = tonermax
	diag_hud_set_borgcell()
	create_modularInterface()
	logevent("System brought online.")

/mob/living/silicon/robot/proc/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated(src)
	modularInterface.layer = ABOVE_HUD_PLANE
	modularInterface.plane = ABOVE_HUD_PLANE

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	var/atom/T = drop_location()//To hopefully prevent run time errors.
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			if(mmi.brainmob.stat == DEAD)
				mmi.brainmob.stat = CONSCIOUS
				mmi.brainmob.remove_from_dead_mob_list()
				mmi.brainmob.add_to_alive_mob_list()
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, span_boldannounce("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
			ghostize()
			stack_trace("Borg MMI lacked a brainmob")
		mmi.beginReboot()
		mmi = null
	if(modularInterface)
		QDEL_NULL(modularInterface)
	if(connected_ai)
		set_connected_ai(null)
	if(shell)
		GLOB.available_ai_shells -= src
	else
		if(T && istype(radio) && istype(radio.keyslot))
			radio.keyslot.forceMove(T)
			radio.keyslot = null
	qdel(wires)
	qdel(module)
	qdel(eye_lights)
	wires = null
	module = null
	eye_lights = null
	cell = null
	return ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module.type != /obj/item/robot_module)
		return

	if(wires.is_cut(WIRE_RESET_MODULE))
		to_chat(src,span_userdanger("ERROR: Module installer reply timeout. Please check internal connections."))
		return

	var/list/modulelist = list("Standard" = /obj/item/robot_module/standard, \
	"Engineering" = /obj/item/robot_module/engineering, \
	"Medical" = /obj/item/robot_module/medical, \
	"Miner" = /obj/item/robot_module/miner, \
	"Janitor" = /obj/item/robot_module/janitor, \
	"Service" = /obj/item/robot_module/butler)
	if(!CONFIG_GET(flag/disable_peaceborg))
		modulelist["Peacekeeper"] = /obj/item/robot_module/peacekeeper

	var/list/moduleicons = list() //yogs start
	for(var/option in modulelist)
		var/obj/item/robot_module/M = modulelist[option]
		var/is = initial(M.cyborg_base_icon)
		moduleicons[option] = image(icon = 'icons/mob/robots.dmi', icon_state = is)

	var/input_module = show_radial_menu(src, src , moduleicons, radius = 42) //yogs end
	if(!input_module || module.type != /obj/item/robot_module)
		return

	module.transform_to(modulelist[input_module])

/mob/living/silicon/robot/proc/updatename(client/C)
	if(shell)
		return
	if(!C)
		C = client
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	if(changed_name == "" && C && C.prefs.custom_names["cyborg"] != DEFAULT_CYBORG_NAME)
		if(apply_pref_name("cyborg", C))
			return //built in camera handled in proc
	if(!changed_name)
		changed_name = get_standard_name()

	real_name = changed_name
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too

/mob/living/silicon/robot/proc/get_standard_name()
	return "[(designation ? "[designation] " : "")][mmi.braintype]-[ident]"

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, span_userdanger("Alert: You are dead."))
		return //won't work if dead
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	alerts.set_content(dat)
	alerts.open()

/mob/living/silicon/robot/proc/robot_alerts_length()
	var/length = 0
	for (var/cat in alarms)
		var/list/L = alarms[cat]
		length += L.len

	return length
	
/mob/living/silicon/robot/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Robot Commands"
	ai_roster()

/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return

	if(cell.charge <= 10)
		toggle_ionpulse()
		return

	cell.charge -= 10
	return TRUE

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		to_chat(src, span_notice("No thrusters are installed!"))
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	to_chat(src, span_notice("You [ionpulse_on ? null :"de"]activate your ion thrusters."))
	if(ionpulse_on)
		ion_trail.start()
	else
		ion_trail.stop()
	if(thruster_button)
		thruster_button.icon_state = "ionpulse[ionpulse_on]"

/mob/living/silicon/robot/get_status_tab_items()
	. = ..()
	. += ""
	if(cell)
		. += "Charge Left: [cell.charge]/[cell.maxcharge]"
	else
		. += text("No Cell Inserted!")

	if(module)
		for(var/datum/robot_energy_storage/st in module.storages)
			. += "[st.name]: [st.energy]/[st.max_energy]"
	if(connected_ai)
		. += "Master AI: [connected_ai.name]"

/mob/living/silicon/robot/restrained(ignore_grab)
	. = 0

/mob/living/silicon/robot/triggerAlarm(class, area/A, O, obj/alarmsource)
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return TRUE
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return TRUE
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)
	return TRUE

/mob/living/silicon/robot/cancelAlarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = FALSE
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = TRUE
				L -= I
	if (cleared)
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)
	return !cleared

/mob/living/silicon/robot/can_interact_with(atom/A)
	if (low_power_mode)
		return FALSE
	var/turf/T0 = get_turf(src)
	var/turf/T1 = get_turf(A)
	if (!T0 || ! T1)
		return FALSE
	return ISINRANGE(T1.x, T0.x - interaction_range, T0.x + interaction_range) && ISINRANGE(T1.y, T0.y - interaction_range, T0.y + interaction_range)

/mob/living/silicon/robot/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && (user.a_intent != INTENT_HARM || user == src))
		user.changeNext_move(CLICK_CD_MELEE)
		if (!getBruteLoss())
			to_chat(user, span_warning("[src] is already in good condition!"))
			return
		if (!W.tool_start_check(user, amount=0)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
			return
		if(src == user)
			if(health > 0)
				to_chat(user, span_warning("You have repaired what you could! Get some help to repair the remaining damage."))
				return
			to_chat(user, span_notice("You start fixing yourself..."))
			if(!W.use_tool(src, user, 50))
				return
			if(health > 0)
				return //safety check to prevent spam clciking and queing

		adjustBruteLoss(-30)
		updatehealth()
		add_fingerprint(user)
		visible_message(span_notice("[user] has fixed some of the dents on [src]."))
		return

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/stack/cable_coil/coil = W
		if (getFireLoss() > 0 || getToxLoss() > 0)
			if(src == user)
				to_chat(user, span_notice("You start fixing yourself..."))
				if(!do_after(user, 5 SECONDS, src))
					return
			if (coil.use(1))
				adjustFireLoss(-30)
				adjustToxLoss(-30)
				updatehealth()
				user.visible_message("[user] has fixed some of the burnt wires on [src].", span_notice("You fix some of the burnt wires on [src]."))
			else
				to_chat(user, span_warning("You need more cable to repair [src]!"))
		else
			to_chat(user, "The wires seem fine, there's no need to fix them.")

	else if(W.tool_behaviour == TOOL_CROWBAR)	// crowbar means open or close the cover
		if(opened)
			to_chat(user, span_notice("You close the cover."))
			opened = 0
			update_icons()
		else
			if(locked)
				to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			else
				to_chat(user, span_notice("You open the cover."))
				opened = 1
				update_icons()

	else if(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, span_warning("Close the cover first!"))
		else if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, span_notice("You insert the power cell."))
		update_icons()
		diag_hud_set_borgcell()

	else if(is_wire_tool(W))
		if (wiresexposed)
			wires.interact(user)
		else
			to_chat(user, span_warning("You can't reach the wiring!"))

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, span_notice("The wires have been [wiresexposed ? "exposed" : "unexposed"]."))
		update_icons()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && opened && cell)	// radio
		if(shell)
			to_chat(user, span_notice("You cannot seem to open the radio compartment."))	//Prevent AI radio key theft
		else if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, span_warning("Unable to locate a radio!"))
		update_icons()

	else if(W.tool_behaviour == TOOL_WRENCH && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			to_chat(user, span_boldannounce("[src]'s bolts spark! Maybe you should lock them down first!"))
			spark_system.start()
			return
		else
			to_chat(user, span_notice("You start to unfasten [src]'s securing bolts..."))
			if(W.use_tool(src, user, 5 SECONDS, volume=50) && !cell)
				user.visible_message("[user] deconstructs [src]!", span_notice("You unfasten the securing bolts, and [src] falls to pieces!"))
				deconstruct()

	else if(istype(W, /obj/item/aiModule))
		var/obj/item/aiModule/MOD = W
		if(!opened)
			to_chat(user, span_warning("You need access to the robot's insides to do that!"))
			return
		if(wiresexposed)
			to_chat(user, span_warning("You need to close the wire panel to do that!"))
			return
		if(!cell)
			to_chat(user, span_warning("You need to install a power cell to do that!"))
			return
		if(shell) //AI shells always have the laws of the AI
			to_chat(user, span_warning("[src] is controlled remotely! You cannot upload new laws this way!"))
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, span_warning("[src] is entirely unresponsive!"))
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	else if(istype(W, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, span_warning("Unable to locate a radio!"))

	else if(W.GetID())			// trying to unlock the interface with an ID card
		if(opened)
			to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] [src]'s cover."))
				to_chat(src, span_notice("[usr] [locked ? "locks" : "unlocks"] your cover."))
				update_icons()
				if(emagged)
					to_chat(user, span_notice("The cover interface glitches out for a split second."))
			else
				to_chat(user, span_danger("Access denied."))

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, span_warning("You must access the borg's internals!"))
		else if(!src.module && U.require_module)
			to_chat(user, span_warning("The borg must choose a module before it can be upgraded!"))
		else if(U.locked)
			to_chat(user, span_warning("The upgrade is locked and cannot be used yet!"))
		else
			if(!user.temporarilyRemoveItemFromInventory(U))
				return
			if(U.action(src))
				to_chat(user, span_notice("You apply the upgrade to [src]."))
				if(U.one_use)
					qdel(U)
				else
					U.forceMove(src)
					upgrades += U
			else
				to_chat(user, span_danger("Upgrade error."))
				U.forceMove(drop_location())

	else if(istype(W, /obj/item/toner))
		if(toner >= tonermax)
			to_chat(user, span_warning("The toner level of [src] is at its highest level possible!"))
		else
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			toner = tonermax
			qdel(W)
			to_chat(user, span_notice("You fill the toner level of [src] to its max capacity."))

	else if(istype(W, /obj/item/light/bulb))
		var/obj/item/light/bulb/B = W //yogs start
		if(B.status)
			to_chat(user, span_warning("[B] is broken!"))
			return
		if(!opened)
			to_chat(user, span_warning("You need to open the panel to repair the headlamp!"))
		else if(lamp_cooldown <= world.time && lamp_functional)
			to_chat(user, span_warning("The headlamp is already functional!"))
		else
			if(!user.temporarilyRemoveItemFromInventory(B))
				to_chat(user, span_warning("[B] seems to be stuck to your hand. You'll have to find a different light."))
				return
			lamp_cooldown = 0
			lamp_functional = TRUE
			qdel(B)
			to_chat(user, span_notice("You replace the headlamp bulb.")) //yogs end
	else
		return ..()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(stat == DEAD)
		return //won't work if dead
	if(locked)
		switch(alert("You cannot lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = FALSE
				update_icons()
				to_chat(usr, span_notice("You unlock your cover."))

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || check_access(H.wear_id))
			return TRUE
	else if(ismonkey(M))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(isitem(george.get_active_held_item()))
			return check_access(george.get_active_held_item())
	return FALSE

/mob/living/silicon/robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return TRUE

	var/list/L = req_access
	if(!L.len) //no requirements
		return TRUE

	if(!istype(I, /obj/item/card/id) && isitem(I))
		I = I.GetID()

	if(!I || !I.access) //not ID or no access
		return FALSE
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return FALSE
	return TRUE

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	icon_state = module.cyborg_base_icon
	if(stat != DEAD && !(IsUnconscious() || IsStun() || IsParalyzed() || low_power_mode)) //Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(lamp_enabled)
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_l"
			eye_lights.color = lamp_color
			eye_lights.plane = 19 //glowy eyes
		else
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
			eye_lights.color = COLOR_WHITE
			eye_lights.plane = -1
		eye_lights.icon = icon
		add_overlay(eye_lights)

	if(opened)
		if(wiresexposed)
			add_overlay("ov-opencover +w")
		else if(cell)
			add_overlay("ov-opencover +c")
		else
			add_overlay("ov-opencover -c")
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head/head.dmi')
		head_overlay.pixel_y += hat_offset
		add_overlay(head_overlay)
	update_fire()

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged || module.syndicate_module)
		if(mmi)
			qdel(mmi)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	gib()

/mob/living/silicon/robot/proc/UnlinkSelf()
	set_connected_ai(null)
	lawupdate = FALSE
	lockcharge = FALSE
	mobility_flags |= MOBILITY_FLAGS_DEFAULT
	scrambledcodes = TRUE
	//Disconnect it's camera so it's not so easily tracked.
	if(!QDELETED(builtInCamera))
		QDEL_NULL(builtInCamera)
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(incapacitated())
		return
	var/obj/item/W = get_active_held_item()
	if(W)
		W.attack_self(src)


/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_LOCKDOWN))
		state = TRUE
	if(state)
		throw_alert("locked", /obj/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	update_mobility()

/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	module.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert("hacked", /obj/screen/alert/hacked)
	else
		clear_alert("hacked")

/mob/living/silicon/robot/verb/outputlaws()
	set category = "Robot Commands"
	set name = "State Laws"

	if(usr.stat == DEAD)
		return //won't work if dead
	checklaws()

/mob/living/silicon/robot/verb/set_automatic_say_channel() //Borg version of setting the radio for autosay messages.
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for stating your laws."
	set category = "Robot Commands"

	if(usr.stat == DEAD)
		return //won't work if dead
	set_autosay()

/**
  * Handles headlamp smashing
  *
  * When called (such as by the shadowperson lighteater's attack), this proc will break the borg's headlamp
  * and then call toggle_headlamp to disable the light. It also plays a sound effect of glass breaking, and
  * tells the borg what happened to its chat. Broken lights can be repaired by using a flashlight on the borg.
  */
/mob/living/silicon/robot/proc/smash_headlamp()
	if(!lamp_functional)
		return
	lamp_functional = FALSE
	playsound(src, 'sound/effects/glass_step.ogg', 50)
	toggle_headlamp(TRUE)
	to_chat(src, "<span class='danger'>Your headlamp is broken! You'll need a human to help replace it.</span>")

/**
  * Handles headlamp toggling, disabling, and color setting.
  *
  * The initial if statment is a bit long, but the gist of it is that should the lamp be on AND the update_color
  * arg be true, we should simply change the color of the lamp but not disable it. Otherwise, should the turn_off
  * arg be true, the lamp already be enabled, any of the normal reasons the lamp would turn off happen, or the
  * update_color arg be passed with the lamp not on, we should set the lamp off. The update_color arg is only
  * ever true when this proc is called from the borg tablet, when the color selection feature is used.
  *
  * Arguments:
  * * arg1 - turn_off, if enabled will force the lamp into an off state (rather than toggling it if possible)
  * * arg2 - update_color, if enabled, will adjust the behavior of the proc to change the color of the light if it is already on.
  */
/mob/living/silicon/robot/proc/toggle_headlamp(turn_off = FALSE, update_color = FALSE)
	//if both lamp is enabled AND the update_color flag is on, keep the lamp on. Otherwise, if anything listed is true, disable the lamp.
	if(!(update_color && lamp_enabled) && (turn_off || lamp_enabled || update_color || !lamp_functional || stat || low_power_mode))
		if(lamp_functional && stat != DEAD)
			set_light(l_power = TRUE) //If the lamp isn't broken and borg isn't dead, doomsday borgs cannot disable their light fully.
			set_light(l_color = "#FF0000") //This should only matter for doomsday borgs, as any other time the lamp will be off and the color not seen
			set_light(l_range = 1) //Again, like above, this only takes effect when the light is forced on by doomsday mode.
		set_light(l_power = FALSE)
		lamp_enabled = FALSE
		lampButton?.update_icon()
		update_icons()
		return
	set_light(l_range = lamp_intensity)
	set_light(l_color = lamp_color)
	set_light(l_power = TRUE)
	lamp_enabled = TRUE
	lampButton?.update_icon()
	update_icons()

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if(istype(module, /obj/item/robot_module/janitor))
		new /obj/vehicle/ridden/janicart(T) // Janiborg deconstructs into a janicart. So brave.
		new /obj/item/key/janitor(T)
	else
		new /obj/item/robot_suit(T)
		new /obj/item/bodypart/l_leg/robot(T)
		new /obj/item/bodypart/r_leg/robot(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/bodypart/chest/robot(T)
		new /obj/item/bodypart/l_arm/robot(T)
		new /obj/item/bodypart/r_arm/robot(T)
		new /obj/item/bodypart/head/robot(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/assembly/flash/handheld/F = new /obj/item/assembly/flash/handheld(T)
			F.burn_out()
		if (cell) //Sanity check.
			cell.forceMove(T)
			cell = null
	qdel(src)

/mob/living/silicon/robot/modules
	var/set_module = null

/mob/living/silicon/robot/modules/Initialize()
	. = ..()
	module.transform_to(set_module)

/mob/living/silicon/robot/modules/standard
	set_module = /obj/item/robot_module/standard

/mob/living/silicon/robot/modules/medical
	set_module = /obj/item/robot_module/medical
	icon_state = "medical"

/mob/living/silicon/robot/modules/engineering
	set_module = /obj/item/robot_module/engineering
	icon_state = "engineer"

/mob/living/silicon/robot/modules/security
	set_module = /obj/item/robot_module/security
	icon_state = "sec"

/mob/living/silicon/robot/modules/clown
	set_module = /obj/item/robot_module/clown
	icon_state = "clown"

/mob/living/silicon/robot/modules/peacekeeper
	set_module = /obj/item/robot_module/peacekeeper
	icon_state = "peace"

/mob/living/silicon/robot/modules/miner
	set_module = /obj/item/robot_module/miner
	icon_state = "miner"

/mob/living/silicon/robot/modules/janitor
	set_module = /obj/item/robot_module/janitor
	icon_state = "janitor"

/mob/living/silicon/robot/modules/syndicate
	icon_state = "synd_sec"
	faction = list(ROLE_SYNDICATE)
	bubble_icon = "syndibot"
	req_access = list(ACCESS_SYNDICATE)
	lawupdate = FALSE
	scrambledcodes = TRUE // These are rogue borgs.
	ionpulse = TRUE
	sensor_protection = TRUE	//Your funny lightbulb won't save you now. Prepare to die!

	var/playstyle_string = "<span class='big bold'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/syndicate

/mob/living/silicon/robot/modules/syndicate/Initialize()
	. = ..()
	cell = new /obj/item/stock_parts/cell/hyper(src, 25000)
	radio = new /obj/item/radio/borg/syndicate(src)
	laws = new /datum/ai_laws/syndicate_override()
	addtimer(CALLBACK(src, .proc/show_playstyle), 5)

/mob/living/silicon/robot/modules/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/syndicate(src)
	return ..()

/mob/living/silicon/robot/modules/syndicate/proc/show_playstyle()
	if(playstyle_string)
		to_chat(src, playstyle_string)

/mob/living/silicon/robot/modules/syndicate/ResetModule()
	return

/mob/living/silicon/robot/modules/syndicate/medical
	icon_state = "synd_medical"
	sensor_protection = FALSE	//Not a direct combat module like the assault borg (usually)
	playstyle_string = "<span class='big bold'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/syndicate_medical

/mob/living/silicon/robot/modules/syndicate/saboteur
	icon_state = "synd_engi"
	sensor_protection = FALSE	//DEFINITELY not a direct combat module
	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
						<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your destination tagger will allow you to stealthily traverse the disposal network across the station \
						Your welder will allow you to repair the operatives' exosuits, but also yourself and your fellow cyborgs \
						Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
						Be aware that almost any physical contact or incidental damage will break your camouflage \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/robot_module/saboteur

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(NEW_BORG) //New Cyborg
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(NEW_MODULE) //New Module
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.")]<br>")
		if(RENAME) //New Name
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].")]<br>")
		if(AI_SHELL) //New Shell
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg shell detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(DISCONNECT) //Tampering with the wires
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Remote telemetry lost with [name].")]<br>")

/mob/living/silicon/robot/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(stat || lockcharge || low_power_mode)
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, span_warning("You are too far away!"))
		return FALSE
	return TRUE

/mob/living/silicon/robot/updatehealth()
	..()

	/// the current percent health of the robot (-1 to 1)
	var/percent_hp = health/maxHealth
	if(health <= previous_health) //if change in health is negative (we're losing hp)
		if(percent_hp <= 0.5)
			break_cyborg_slot(3)

		if(percent_hp <= 0)
			break_cyborg_slot(2)

		if(percent_hp <= -0.5)
			break_cyborg_slot(1)

	else //if change in health is positive (we're gaining hp)
		if(percent_hp >= 0.5)
			repair_cyborg_slot(3)

		if(percent_hp >= 0)
			repair_cyborg_slot(2)

		if(percent_hp >= -0.5)
			repair_cyborg_slot(1)

	previous_health = health

/mob/living/silicon/robot/movement_delay()
	. = ..()
	var/hd = maxHealth - health
	if(hd > 50)
		if(has_gravity())
			. += hd/100
		else
			. += hd/150

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
			sight = null
		else if(is_secret_level(z))
			sight = initial(sight)
		else
			sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		see_in_dark = 1

	if(sight_mode & BORGMATERIAL)
		sight |= SEE_OBJS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_in_dark = 1

	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = SEE_INVISIBLE_LIVING
		see_in_dark = 8

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_invisible = min(see_invisible, SEE_INVISIBLE_LIVING)
		see_in_dark = 8

	if(see_override)
		see_invisible = see_override

	if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
		sight = null

	sync_lighting_plane_alpha()

/mob/living/silicon/robot/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			()
			toggle_headlamp(TRUE)
			return
		if(IsUnconscious() || IsStun() || IsKnockdown() || IsParalyzed() || getOxyLoss() > maxHealth*0.5)
			if(stat == CONSCIOUS)
				stat = UNCONSCIOUS
				blind_eyes(1)
				update_mobility()
		else
			if(stat == UNCONSCIOUS)
				stat = CONSCIOUS
				adjust_blindness(-1)
				update_mobility()
	diag_hud_set_status()
	diag_hud_set_health()
	diag_hud_set_aishell()
	update_health_hud()

/mob/living/silicon/robot/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from 
		if(!QDELETED(builtInCamera) && !wires.is_cut(WIRE_CAMERA))
			builtInCamera.toggle_cam(src,0)
		toggle_headlamp(TRUE)
		if(admin_revive)
			locked = TRUE
		notify_ai(NEW_BORG)
		. = 1

/mob/living/silicon/robot/fully_replace_character_name(oldname, newname)
	..()
	if(oldname != real_name)
		notify_ai(RENAME, oldname, newname)
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
	custom_name = newname


/mob/living/silicon/robot/proc/ResetModule()
	uneq_all()
	shown_robot_modules = FALSE
	if(hud_used)
		hud_used.update_robot_modules_display()

	while(expansion_count)
		resize = 0.5
		expansion_count--
		update_transform()
	logevent("Chassis configuration has been reset.")
	icon = initial(icon) //Should fix invisi-donorborgs ~ Kmc
	module.transform_to(/obj/item/robot_module)

	// Remove upgrades.
	for(var/obj/item/borg/upgrade/I in upgrades)
		I.deactivate(src)
		I.forceMove(get_turf(src))
		I.dropped()

	upgrades.Cut()

	speed = 0
	ionpulse = FALSE
	revert_shell()

	return TRUE

/mob/living/silicon/robot/proc/has_module()
	if(!module || module.type == /obj/item/robot_module)
		. = FALSE
	else
		. = TRUE

/mob/living/silicon/robot/proc/update_module_innate()
	designation = module.name
	if(hands)
		hands.icon_state = module.moduleselect_icon
	if(module.can_be_pushed)
		status_flags |= CANPUSH
	else
		status_flags &= ~CANPUSH

	if(module.clean_on_move)
		AddComponent(/datum/component/cleaning)
	else
		qdel(GetComponent(/datum/component/cleaning))

	hat_offset = module.hat_offset

	magpulse = module.magpulsing
	updatename()


/mob/living/silicon/robot/proc/place_on_head(obj/item/new_hat)
	if(hat)
		hat.forceMove(get_turf(src))
	hat = new_hat
	new_hat.forceMove(src)
	update_icons()

/mob/living/silicon/robot/proc/make_shell(var/obj/item/borg/upgrade/ai/board)
	if(!board)
		upgrades |= new /obj/item/borg/upgrade/ai(src)
	shell = TRUE
	braintype = "AI Shell"
	name = "[designation] AI Shell [rand(100,999)]"
	real_name = name
	GLOB.available_ai_shells |= src
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	notify_ai(AI_SHELL)

/mob/living/silicon/robot/proc/revert_shell()
	if(!shell)
		return
	undeploy()
	for(var/obj/item/borg/upgrade/ai/boris in src)
	//A player forced reset of a borg would drop the module before this is called, so this is for catching edge cases
		qdel(boris)
	shell = FALSE
	GLOB.available_ai_shells -= src
	name = "Unformatted Cyborg [rand(100,999)]"
	real_name = name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
	diag_hud_set_aishell()

/mob/living/silicon/robot/proc/deploy_init(var/mob/living/silicon/ai/AI)
	real_name = "[AI.real_name] shell [rand(100, 999)] - [designation]"	//Randomizing the name so it shows up separately in the shells list
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	mainframe = AI
	deployed = TRUE
	set_connected_ai(mainframe)
	mainframe.connected_robots |= src
	lawupdate = TRUE
	lawsync()
	if(sensors_on)
		add_sensors()
	if(radio && AI.radio) //AI keeps all channels, including Syndie if it is a Traitor
		if(AI.radio.syndie)
			radio.make_syndie()
		radio.subspace_transmission = TRUE
		radio.channels = AI.radio.channels
		for(var/chan in radio.channels)
			radio.secure_radio_connections[chan] = add_radio(radio, GLOB.radiochannels[chan])

	diag_hud_set_aishell()
	undeployment_action.Grant(src)

/datum/action/innate/undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/undeployment/Trigger()
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/R = owner

	R.undeploy()
	return TRUE


/mob/living/silicon/robot/proc/undeploy()

	if(!deployed || !mind || !mainframe)
		return
	remove_sensors()
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(src)
	if(radio) //Return radio to normal
		radio.recalculateChannels()
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	mainframe.diag_hud_set_deployed()
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe) //Always remind the AI when switching
	mainframe = null

/mob/living/silicon/robot/attack_ai(mob/user)
	if(shell && (!connected_ai || connected_ai == user))
		var/mob/living/silicon/ai/AI = user
		AI.deploy_to_shell(src)

/mob/living/silicon/robot/shell
	shell = TRUE

/mob/living/silicon/robot/MouseDrop_T(mob/living/M, mob/living/user)
	if(!(M in buckled_mobs) && isliving(M) && user && user.can_buckle)
		buckle_mob(M, TRUE)
	 . = ..()

/mob/living/silicon/robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!is_type_in_typecache(M, can_ride_typecache))
		M.visible_message(span_warning("[M] really can't seem to mount [src]..."))
		return
	if(!force)
		return //buckling is called twice if we don't do this which is a mess
	var/datum/component/riding/riding_datum = LoadComponent(/datum/component/riding/cyborg)
	if(has_buckled_mobs())
		if(buckled_mobs.len >= max_buckled_mobs)
			return
		if(M in buckled_mobs)
			return
	if(stat)
		return
	if(incapacitated())
		return
	if(module)
		if(!module.allow_riding)
			M.visible_message(span_boldwarning("Unfortunately, [M] just can't seem to hold onto [src]!"))
			return
	M.visible_message(span_warning("[M] begins to [M == usr ? "climb onto" : "be buckled to"] [src]..."))
	var/_target = usr == M ? src : M
	if(!do_after(usr, 0.75 SECONDS, _target))
		M.visible_message(span_boldwarning("[M] was prevented from buckling to [src]!"))
		return

	if(iscarbon(M) && !M.incapacitated() && !riding_datum.equip_buckle_inhands(M, 1))
		if(M.get_num_arms() <= 0)
			M.visible_message(span_boldwarning("[M] can't climb onto [src] because [M.p_they()] don't have any usable arms!"))
		else
			M.visible_message(span_boldwarning("[M] can't climb onto [src] because [M.p_their()] hands are full!"))
		return
	. = ..(M, force, check_loc)

/mob/living/silicon/robot/unbuckle_mob(mob/user, force=FALSE)
	if(iscarbon(user))
		var/datum/component/riding/riding_datum = GetComponent(/datum/component/riding)
		if(istype(riding_datum))
			riding_datum.unequip_buckle_inhands(user)
			riding_datum.restore_position(user)
	. = ..(user)

/mob/living/silicon/robot/resist() // for unbuckling people
	. = ..()
	if(!buckled_mobs?.len) // Runtimes if noone is on you and you resist without the ?.
		return

	for(var/i in buckled_mobs)
		var/mob/target = i
		unbuckle_mob(target, FALSE)

/mob/living/silicon/robot/proc/TryConnectToAI()
	set_connected_ai(select_active_ai_with_fewest_borgs())
	if(connected_ai)
		lawsync()
		lawupdate = TRUE
		return TRUE
	picturesync()
	return FALSE

/mob/living/silicon/robot/proc/picturesync()
	if(connected_ai && connected_ai.aicamera && aicamera)
		for(var/i in aicamera.stored)
			connected_ai.aicamera.stored[i] = TRUE
		for(var/i in connected_ai.aicamera.stored)
			aicamera.stored[i] = TRUE

/mob/living/silicon/robot/proc/charge(datum/source, amount, repairs)
	if(module)
		module.respawn_consumable(src, amount * 0.005)
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	if(repairs)
		heal_bodypart_damage(repairs, repairs - 1)

/mob/living/silicon/robot/proc/set_connected_ai(new_ai)
	if(connected_ai == new_ai)
		return
	. = connected_ai
	connected_ai = new_ai
	if(.)
		var/mob/living/silicon/ai/old_ai = .
		old_ai.connected_robots -= src
	if(connected_ai)
		connected_ai.connected_robots |= src

/**
  * Records an IC event log entry in the cyborg's internal tablet.
  *
  * Creates an entry in the borglog list of the cyborg's internal tablet, listing the current
  * in-game time followed by the message given. These logs can be seen by the cyborg in their
  * BorgUI tablet app. By design, logging fails if the cyborg is dead.
  *
  * Arguments:
  * arg1: a string containing the message to log.
 */
/mob/living/silicon/robot/proc/logevent(var/string = "")
	if(!string)
		return
	if(stat == DEAD) //Dead borgs log no longer
		return
	if(!modularInterface)
		stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	modularInterface.borglog += "[station_time_timestamp()] - [string]"
	var/datum/computer_file/program/robotact/program = modularInterface.get_robotact()
	if(program)
		program.force_full_update()

/mob/living/silicon/robot/get_eye_protection() 
	return sensor_protection
