#define TIME_LEFT (SSshuttle.emergency.timeLeft())
#define ENGINES_START_TIME 100
#define ENGINES_STARTED (SSshuttle.emergency.mode == SHUTTLE_IGNITING)
#define IS_DOCKED (SSshuttle.emergency.mode == SHUTTLE_DOCKED || (ENGINES_STARTED))

/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()

/obj/machinery/computer/emergency_shuttle/attackby(obj/item/I, mob/user,params)
	if(istype(I, /obj/item/card/id))
		say("Please equip your ID card into your ID slot to authenticate.")
	. = ..()

/obj/machinery/computer/emergency_shuttle/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(isalienqueen(user))
		var/mob/living/carbon/alien/humanoid/royal/queen/queenuser = user
		queenuser.kill_shuttle_timer()
		balloon_alert(user, "shuttle ready to launch!")

/obj/machinery/computer/emergency_shuttle/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/computer/emergency_shuttle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmergencyShuttleConsole", name)
		ui.open()

/obj/machinery/computer/emergency_shuttle/ui_data()
	var/list/data = list()

	data["timer_str"] = SSshuttle.emergency.getTimerStr()
	data["engines_started"] = ENGINES_STARTED
	data["authorizations_remaining"] = max((auth_need - authorized.len), 0)
	var/list/A = list()
	for(var/i in authorized)
		var/obj/item/card/id/ID = i
		var/name = ID.registered_name
		var/job = ID.assignment

		if(obj_flags & EMAGGED)
			name = Gibberish(name)
			job = Gibberish(job)
		A += list(list("name" = name, "job" = job))
	data["authorizations"] = A

	data["enabled"] = (IS_DOCKED && !ENGINES_STARTED)
	data["emagged"] = obj_flags & EMAGGED ? 1 : 0
	return data

/obj/machinery/computer/emergency_shuttle/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(ENGINES_STARTED) // past the point of no return
		return
	if(!IS_DOCKED) // shuttle computer only has uses when onstation
		return

	var/mob/user = usr
	. = FALSE

	var/obj/item/card/id/ID = user.get_idcard(TRUE)

	if(!ID)
		to_chat(user, span_warning("You don't have an ID."))
		return

	if(!(ACCESS_COMMAND in ID.access))
		to_chat(user, span_warning("The access level of your card is not high enough."))
		return

	var/old_len = authorized.len

	switch(action)
		if("authorize")
			. = authorize(user)

		if("repeal")
			// yogs start - added spam protection
			if(ID in authorized)// if you have already submitted your authorization:
				if(last_early_auth + SHUTTLE_EARLY_AUTHORIZATION_COOLDOWN_TIME > world.time) // this action was performed before cooldown expired
					to_chat(user, span_warning("The emergency shuttle console is recharging, please wait [((last_early_auth + SHUTTLE_EARLY_AUTHORIZATION_COOLDOWN_TIME) - world.time)*0.1] seconds."))
					return
				authorized -= ID
				// Record this time so we can remember how long ago this repeal occured, and restrict announcement spam.
				last_early_auth = world.time
			// yogs end

		if("abort")
			if(authorized.len)
				// Abort. The action for when heads are fighting over whether
				// to launch early.
				// yogs start - added spam protection
				if(last_early_auth + SHUTTLE_EARLY_AUTHORIZATION_COOLDOWN_TIME > world.time) // this action was performed before cooldown expired
					to_chat(user, span_warning("The emergency shuttle console is recharging, please wait [((last_early_auth + SHUTTLE_EARLY_AUTHORIZATION_COOLDOWN_TIME) - world.time)*0.1] seconds."))
					return
				// Record this time so we can remember how long ago this abortion occured, and restrict announcement spam.
				last_early_auth = world.time
				// yogs end
				authorized.Cut()
				. = TRUE

	if((old_len != authorized.len) && !ENGINES_STARTED)
		var/alert = (authorized.len > old_len)
		var/repeal = (authorized.len < old_len)
		var/remaining = max(0, auth_need - authorized.len)
		if(authorized.len && remaining)
			minor_announce("[remaining] authorizations needed until shuttle is launched early", null, alert)
		if(repeal)
			minor_announce("Early launch authorization revoked, [remaining] authorizations needed")

/obj/machinery/computer/emergency_shuttle/proc/authorize(mob/user, source)
	var/obj/item/card/id/ID = user.get_idcard(TRUE)

	if(ID in authorized)
		return FALSE
	for(var/i in authorized)
		var/obj/item/card/id/other = i
		if(other.registered_name == ID.registered_name)
			return FALSE // No using IDs with the same name

	authorized += ID

	message_admins("[ADMIN_LOOKUPFLW(user)] has authorized early shuttle launch")
	log_game("[key_name(user)] has authorized early shuttle launch in [COORD(src)]")
	// Now check if we're on our way
	. = TRUE
	process(SSMACHINES_DT)

/obj/machinery/computer/emergency_shuttle/process()
	// Launch check is in process in case auth_need changes for some reason
	// probably external.
	. = FALSE
	if(!SSshuttle.emergency)
		return

	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		authorized.Cut()
		DISABLE_BITFIELD(obj_flags, EMAGGED)

	if(ENGINES_STARTED || (!IS_DOCKED))
		return .

	// Check to see if we've reached criteria for early launch
	if((authorized.len >= auth_need) || (obj_flags & EMAGGED))
		// shuttle timers use 1/10th seconds internally
		SSshuttle.emergency.setTimer(ENGINES_START_TIME)
		var/system_error = obj_flags & EMAGGED ? "SYSTEM ERROR:" : null
		minor_announce("The emergency shuttle will launch in \
			[TIME_LEFT] seconds", system_error, alert=TRUE)
		. = TRUE

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user, obj/item/card/emag/emag_card)
	// How did you even get on the shuttle before it go to the station?
	if(!IS_DOCKED)
		return FALSE

	if(CHECK_BITFIELD(obj_flags, EMAGGED) || ENGINES_STARTED)	//SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LAUNCH IN 10 SECONDS
		to_chat(user, span_warning("The shuttle is already about to launch!"))
		return FALSE

	var/time = TIME_LEFT
	message_admins("[ADMIN_LOOKUPFLW(user.client)] has emagged the emergency shuttle [time] seconds before launch.")
	log_game("[key_name(user)] has emagged the emergency shuttle in [COORD(src)] [time] seconds before launch.")

	ENABLE_BITFIELD(obj_flags, EMAGGED)
	SSshuttle.emergency.movement_force = list("KNOCKDOWN" = 60, "THROW" = 20)//YOUR PUNY SEATBELTS can SAVE YOU NOW, MORTAL
	var/datum/species/S = new
	for(var/i in 1 to 10)
		// the shuttle system doesn't know who these people are, but they
		// must be important, surely
		var/obj/item/card/id/ID = new(src)
		var/datum/job/J = pick(SSjob.occupations)
		ID.registered_name = S.random_name(pick(MALE, FEMALE))
		ID.assignment = J.title
		ID.originalassignment = J.title

		authorized += ID

	process(SSMACHINES_DT)
	return TRUE

/obj/machinery/computer/emergency_shuttle/Destroy()
	// Our fake IDs that the emag generated are just there for colour
	// They're not supposed to be accessible

	for(var/obj/item/card/id/ID in src)
		qdel(ID)
	if(authorized && authorized.len)
		authorized.Cut()
	authorized = null

	. = ..()

/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	shuttle_id = "emergency"
	dir = EAST
	port_direction = WEST
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself

/obj/docking_port/mobile/emergency/Initialize(mapload)
	. = ..()

	//setup_shuttle_events()

/obj/docking_port/mobile/emergency/canDock(obj/docking_port/stationary/S)
	return SHUTTLE_CAN_DOCK //If the emergency shuttle can't move, the whole game breaks, so it will force itself to land even if it has to crush a few departments in the process

/obj/docking_port/mobile/emergency/register()
	. = ..()
	SSshuttle.emergency = src

/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		// This'll make the shuttle subsystem use the backup shuttle.
		if(src == SSshuttle.emergency)
			// If we're the selected emergency shuttle
			SSshuttle.emergencyDeregister()

	. = ..()

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signalOrigin, reason, set_coefficient=null)
	if(!isnum(set_coefficient))
		set_coefficient = SSsecurity_level.current_security_level.shuttle_call_time_mod
	alert_coeff = set_coefficient

	var/call_time = SSshuttle.emergency_call_time * set_coefficient * engine_coeff
	switch(mode)
		// The shuttle can not normally be called while "recalling", so
		// if this proc is called, it's via admin fiat
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			setTimer(call_time)
		else
			return

	SSshuttle.emergencyCallAmount++

	if(prob(70))
		SSshuttle.emergency_last_call_loc = signalOrigin
	else
		SSshuttle.emergency_last_call_loc = null

	var/emergency_reason = "\nNature of emergency:\n\n[reason]"
	priority_announce("[SSshuttle.emergency] has been called. [SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[html_decode(emergency_reason)][SSshuttle.emergency_last_call_loc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]", null, ANNOUNCER_SHUTTLECALLED, "Priority")

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return
	if(SSshuttle.emergency_no_recall)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergency_last_call_loc = signalOrigin
	else
		SSshuttle.emergency_last_call_loc = null

	priority_announce("[SSshuttle.emergency] has been recalled.[SSshuttle.emergency_last_call_loc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]", null, ANNOUNCER_SHUTTLERECALLED, "Priority")

/obj/docking_port/mobile/emergency/proc/is_hijacked()
	var/has_people = FALSE
	var/hijacker_present = FALSE
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(istype(player.loc, /obj/effect/dummy/crawling))
					continue
				if(issilicon(player)) //Borgs are technically dead anyways
					continue
				if(isanimal(player)) //animals don't count
					continue
				if(isbrain(player)) //also technically dead
					continue
				if(shuttle_areas[get_area(player)])
					has_people = TRUE
					var/location = get_turf(player.mind.current)
					//Non-antag present. Can't hijack.
					if(!(player.mind.has_antag_datum(/datum/antagonist)) && !istype(location, /turf/open/floor/plasteel/shuttle/red) && !istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
						return FALSE
					//Antag present, doesn't stop but let's see if we actually want to hijack
					var/prevent = FALSE
					for(var/datum/antagonist/A in player.mind.antag_datums)
						if(A.can_hijack == HIJACK_HIJACKER)
							hijacker_present = TRUE
							prevent = FALSE
							break //If we have both prevent and hijacker antags assume we want to hijack.
						else if(A.can_hijack == HIJACK_PREVENT)
							prevent = TRUE
					if(prevent)
						return FALSE


	return has_people && hijacker_present

/obj/docking_port/mobile/emergency/proc/is_hijacked_by_xenos()
	var/has_xenos = FALSE
	for(var/mob/living/player in GLOB.alive_mob_list)
		if(issilicon(player)) //Borgs are technically dead anyways
			continue
		if(isanimal(player)) //animals don't count
			continue
		if(isbrain(player)) //also technically dead
			continue
		if(shuttle_areas[get_area(player)])
			//Non-xeno present. Can't hijack.
			if(!isalien(player))
				if(!HAS_TRAIT(player, TRAIT_XENO_HOST) && !player.getorganslot(ORGAN_SLOT_PARASITE_EGG)) //if they are hosts / egged skip them,
					return FALSE																  //checks twice just incase cause the system is wacky
			has_xenos = TRUE

	return has_xenos

/obj/docking_port/mobile/emergency/proc/ShuttleDBStuff()
	set waitfor = FALSE
	if(!SSdbcore.Connect())
		return
	var/datum/DBQuery/query_round_shuttle_name = SSdbcore.NewQuery({"
		UPDATE [format_table_name("round")] SET shuttle_name = :name WHERE id = :round_id
	"}, list("name" = name, "round_id" = GLOB.round_id))
	query_round_shuttle_name.Execute()
	qdel(query_round_shuttle_name)

/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return
	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(initiate_docking(SSshuttle.getDock("emergency_home")) != DOCKING_SUCCESS)
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
				setTimer(SSshuttle.emergency_dock_time)
				send2irc("Server", "The Emergency Shuttle ([name]) has docked with the station.") // yogs - make it say the name of the shuttle
				priority_announce("[SSshuttle.emergency] has docked with the station. You have [timeLeft(600)] minutes to board.", null, ANNOUNCER_SHUTTLEDOCK, "Priority")
				ShuttleDBStuff()


		if(SHUTTLE_DOCKED)
			if(time_left <= ENGINES_START_TIME)
				mode = SHUTTLE_IGNITING
				SSshuttle.checkHostileEnvironment()
				if(mode == SHUTTLE_STRANDED)
					return
				for(var/A in SSshuttle.mobile_docking_ports)
					var/obj/docking_port/mobile/M = A
					if(M.launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
						M.check_transit_zone()

		if(SHUTTLE_IGNITING)
			var/success = TRUE
			SSshuttle.checkHostileEnvironment()
			if(mode == SHUTTLE_STRANDED)
				return

			success &= (check_transit_zone() == TRANSIT_READY)
			for(var/A in SSshuttle.mobile_docking_ports)
				var/obj/docking_port/mobile/M = A
				if(M.launch_status == UNLAUNCHED)
					success &= (M.check_transit_zone() == TRANSIT_READY)
			if(!success)
				setTimer(ENGINES_START_TIME)

			if(time_left <= 50 && !sound_played) //4 seconds left:REV UP THOSE ENGINES BOYS. - should sync up with the launch
				sound_played = 1 //Only rev them up once.
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_WARMUP, areas)

			if(time_left <= 0 && !SSshuttle.emergency_no_escape)
				//move each escape pod (or applicable spaceship) to its corresponding transit dock
				for(var/A in SSshuttle.mobile_docking_ports)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_launch()

				//now move the actual emergency shuttle to its transit dock
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				launch_status = ENDGAME_LAUNCHED
				setTimer(SSshuttle.emergency_escape_time * engine_coeff)
				priority_announce("[SSshuttle.emergency] has left the station. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")

		if(SHUTTLE_STRANDED)
			SSshuttle.checkHostileEnvironment()

		if(SHUTTLE_ESCAPE)
			if(sound_played && time_left <= HYPERSPACE_END_TIME)
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.areas)
					areas += E
				hyperspace_sound(HYPERSPACE_END, areas)
			if(time_left <= PARALLAX_LOOP_TIME)
				var/area_parallax = FALSE
				for(var/place in shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(shuttle_area.parallax_movedir)
						area_parallax = TRUE
						break
				if(area_parallax)
					parallax_slowdown()
					for(var/A in SSshuttle.mobile_docking_ports)
						var/obj/docking_port/mobile/M = A
						if(M.launch_status == ENDGAME_LAUNCHED)
							if(istype(M, /obj/docking_port/mobile/pod))
								M.parallax_slowdown()

			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/A in SSshuttle.mobile_docking_ports)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_dock()

				// now move the actual emergency shuttle to centcom
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked())
					destination_dock = "emergency_syndicate"
					minor_announce("Corruption detected in \
						shuttle navigation protocols. Please contact your \
						supervisor.", "SYSTEM ERROR:", alert=TRUE)
					sound_to_playing_players('sound/misc/announce2.ogg')

				dock_id(destination_dock)
				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	launch_status = ENDGAME_LAUNCHED
	setTimer(SSshuttle.emergency_escape_time)
	priority_announce("[SSshuttle.emergency] is preparing for direct jump. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")


/obj/docking_port/mobile/pod
	name = "escape pod"
	shuttle_id = "pod"
	launch_status = UNLAUNCHED

/obj/docking_port/mobile/pod/request(obj/docking_port/stationary/S)
	var/obj/machinery/computer/shuttle/C = get_control_console()
	if(!istype(C, /obj/machinery/computer/shuttle/pod))
		return ..()
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED || (C && (C.obj_flags & EMAGGED)))
		if(launch_status == UNLAUNCHED)
			launch_status = EARLY_LAUNCHED
			return ..()
	else
		to_chat(usr, span_warning("Escape pods will only launch during \"Code Red\" security alert."))
		return TRUE

/obj/docking_port/mobile/pod/cancel()
	return

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	admin_controlled = TRUE
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	density = FALSE
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/shuttle/pod/Initialize(mapload, obj/item/circuitboard/C)
	AddElement(/datum/element/update_icon_blocker)
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(update_security_level))
	return ..()

/obj/machinery/computer/shuttle/pod/proc/update_security_level(_, datum/security_level/new_level)
	admin_controlled = !new_level.pod_access

/obj/machinery/computer/shuttle/pod/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	ENABLE_BITFIELD(obj_flags, EMAGGED)
	to_chat(user, span_warning("You fry the pod's alert level checking system."))

/obj/machinery/computer/shuttle/pod/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(port)
		//Checks if the computer has already added the shuttle destination with the initial id
		//This has to be done because connect_to_shuttle is called again after its ID is updated
		//due to conflicting id names
		var/base_shuttle_destination = ";[initial(port.shuttle_id)]_lavaland"
		var/shuttle_destination = ";[port.shuttle_id]_lavaland"

		var/position = findtext(possible_destinations, base_shuttle_destination)
		if(position)
			if(base_shuttle_destination == shuttle_destination)
				return
			possible_destinations = splicetext(possible_destinations, position, position + length(base_shuttle_destination), shuttle_destination)
			return

		possible_destinations += shuttle_destination

/obj/docking_port/stationary/random
	name = "escape pod"
	shuttle_id = "pod"
	hidden = TRUE
	override_can_dock_checks = TRUE
	/// The area the pod tries to land at
	var/target_area = /area/lavaland/surface/outdoors
	/// Minimal distance from the map edge, setting this too low can result in shuttle landing on the edge and getting "sliced"
	var/edge_distance = 16

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/list/turfs = get_area_turfs(target_area)
	var/original_len = turfs.len
	//YOGS EDIT
	if(!original_len)
		return INITIALIZE_HINT_QDEL // we clearly havent loaded lavaland, and there is no pretty way to do this with jungleland, temporary fix for now at least
	//YOGS END
	while(turfs.len)
		var/turf/T = pick(turfs)
		if(T.x<edge_distance || T.y<edge_distance || (world.maxx+1-T.x)<edge_distance || (world.maxy+1-T.y)<edge_distance)
			turfs -= T
		else
			forceMove(T)
			return

		// Fallback: couldn't find anything
	WARNING("docking port '[shuttle_id]' could not be randomly placed in [target_area]: of [original_len] turfs, none were suitable")
	return INITIALIZE_HINT_QDEL


/obj/docking_port/stationary/random/icemoon
	target_area = /area/icemoon/surface/outdoors/unexplored/danger
//Pod suits/pickaxes


/obj/item/clothing/head/helmet/space/orange
	name = "emergency space helmet"
	icon_state = "emergency"
	item_state = "emergency"

/obj/item/clothing/suit/space/orange
	name = "emergency space suit"
	icon_state = "emergency"
	item_state = "emergency"
	slowdown = 3

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "For extracting yourself from rough landings."

/obj/item/storage/pod
	name = "emergency space suits"
	desc = "A wall mounted safe containing space suits. Will only open in emergencies."
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	var/unlocked = FALSE

/obj/item/storage/pod/PopulateContents()
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/storage/toolbox/emergency(src)

/obj/item/storage/pod/attackby(obj/item/W, mob/user, params)
	if (can_interact(user))
		return ..()

/obj/item/storage/pod/attack_hand(mob/user)
	if (can_interact(user))
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SHOW, user)
	return TRUE

/obj/item/storage/pod/MouseDrop(over_object, src_location, over_location)
	if(can_interact(usr))
		return ..()

/obj/item/storage/pod/AltClick(mob/user)
	if(!can_interact(user))
		return
	..()

/obj/item/storage/pod/can_interact(mob/user)
	if(!..())
		return FALSE
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED || unlocked)
		return TRUE
	to_chat(user, "The storage unit will only unlock during a Red or Delta security alert.")

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	shuttle_id = "backup"
	dir = EAST

/obj/docking_port/mobile/emergency/backup/Initialize(mapload)
	// We want to be a valid emergency shuttle
	// but not be the main one, keep whatever's set
	// valid.
	// backup shuttle ignores `timid` because THERE SHOULD BE NO TOUCHING IT
	var/current_emergency = SSshuttle.emergency
	. = ..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

/obj/docking_port/mobile/emergency/backup/Destroy(force)
	if(SSshuttle.backup_shuttle == src)
		SSshuttle.backup_shuttle = null
	return ..()

/obj/docking_port/mobile/emergency/shuttle_build/postregister()
	. = ..()
	initiate_docking(SSshuttle.getDock("emergency_home"))

#undef TIME_LEFT
#undef ENGINES_START_TIME
#undef ENGINES_STARTED
#undef IS_DOCKED
