///Time before being allowed to select a new cult leader again
#define CULT_POLL_WAIT (240 SECONDS)

/// Returns either the error landmark or the location of the room. Needless to say, if this is used, it means things have gone awry.
#define GET_ERROR_ROOM ((locate(/obj/effect/landmark/error) in GLOB.landmarks_list) || locate(4,4,1))

/proc/get_area_name(atom/X, format_text = FALSE, is_sensor = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	var/name = A.name
	if (is_sensor && !A.show_on_sensors)
		name = Gibberish(name, TRUE, 90)
	return format_text ? format_text(name) : name

//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2) //A squared + B squared = C squared

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms


/proc/circleviewturfs(center=usr,radius=3) //Is there even a diffrence between this proc and circle_range_turfs()? // Yes

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

//This is the new version of recursive_mob_check, used for say().
//The other proc was left intact because morgue trays use it.
//Sped this up again for real this time
/proc/recursive_hear_check(O)
	var/list/processing_list = list(O)
	. = list()
	var/i = 0
	while(i < length(processing_list))
		var/atom/A = processing_list[++i]
		if(A.flags_1 & HEAR_1)
			. += A
		processing_list += A.contents

/** recursive_organ_check
  * inputs: O (object to start with)
  * outputs:
  * description: A pseudo-recursive loop based off of the recursive mob check, this check looks for any organs held
  *				 within 'O', toggling their frozen flag. This check excludes items held within other safe organ
  *				 storage units, so that only the lowest level of container dictates whether we do or don't decompose
  */
/proc/recursive_organ_check(atom/O)

	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/index = 1
	var/obj/item/organ/found_organ

	while(index <= length(processing_list))

		var/atom/A = processing_list[index]

		if(istype(A, /obj/item/organ))
			found_organ = A
			found_organ.organ_flags ^= ORGAN_FROZEN

		else if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/Q = A
			for(var/organ in Q.internal_organs)
				found_organ = organ
				found_organ.organ_flags ^= ORGAN_FROZEN

		for(var/atom/B in A)	//objects held within other objects are added to the processing list, unless that object is something that can hold organs safely
			if(!processed_list[B] && !istype(B, /obj/structure/closet/crate/freezer) && !istype(B, /obj/structure/closet/secure_closet/freezer))
				processing_list+= B

		index++
		processed_list[A] = A

	return

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)


/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in GLOB.cardinals)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(key)
	var/ckey = ckey(key)
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(M.ckey == ckey)
			return M
	return null

/proc/considered_alive(datum/mind/M, enforce_human = TRUE)
	if(M && M.current)
		if(enforce_human)
			var/mob/living/carbon/human/H
			if(ishuman(M.current))
				H = M.current
			return M.current.stat != DEAD && !issilicon(M.current) && !isbrain(M.current) && (!H || H.dna.species.id != "memezombies")
		else if(isliving(M.current))
			if(isAI(M.current))
				var/mob/living/silicon/ai/AI = M.current
				if(AI.is_dying)
					return FALSE
			return M.current.stat != DEAD
	return FALSE

/proc/considered_afk(datum/mind/M)
	return !M || !M.current || !M.current.client || M.current.client.is_afk()

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))
		O = new /atom/movable/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/// Adds an image to a client's `.images`. Useful as a callback.
/proc/add_image_to_client(image/image_to_remove, client/add_to)
	add_to?.images += image_to_remove

/// Like add_image_to_client, but will add the image from a list of clients
/proc/add_image_to_clients(image/image_to_remove, list/show_to)
	for(var/client/add_to in show_to)
		add_to.images += image_to_remove

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image_to_remove, client/remove_from)
	remove_from?.images -= image_to_remove

/// Like remove_image_from_client, but will remove the image from a list of clients
/proc/remove_image_from_clients(image/image_to_remove, list/hide_from)
	for(var/client/remove_from in hide_from)
		remove_from.images -= image_to_remove

/// Add an image to a list of clients and calls a proc to remove it after a duration
/proc/flick_overlay_global(image/image_to_show, list/show_to, duration)
	if(!show_to || !length(show_to) || !image_to_show)
		return
	for(var/client/add_to in show_to)
		add_to.images += image_to_show
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_clients), image_to_show, show_to), duration, TIMER_CLIENT_TIME)

///Flicks a certain overlay onto an atom, handling icon_state strings
/atom/proc/flick_overlay(image_to_show, list/show_to, duration, layer)
	var/image/passed_image = \
		istext(image_to_show) \
			? image(icon, src, image_to_show, layer) \
			: image_to_show

	flick_overlay_global(passed_image, show_to, duration)

/**
 * Helper atom that copies an appearance and exists for a period
*/
/atom/movable/flick_visual

/// Takes the passed in MA/icon_state, mirrors it onto ourselves, and displays that in world for duration seconds
/// Returns the displayed object, you can animate it and all, but you don't own it, we'll delete it after the duration
/atom/proc/flick_overlay_view(mutable_appearance/display, duration)
	if(!display)
		return null

	var/mutable_appearance/passed_appearance = \
		istext(display) \
			? mutable_appearance(icon, display, layer) \
			: display

	// If you don't give it a layer, we assume you want it to layer on top of this atom
	// Because this is vis_contents, we need to set the layer manually (you can just set it as you want on return if this is a problem)
	if(passed_appearance.layer == FLOAT_LAYER)
		passed_appearance.layer = layer + 0.1
	// This is faster then pooling. I promise
	var/atom/movable/flick_visual/visual = new()
	visual.appearance = passed_appearance
	visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// I hate /area
	var/atom/movable/lies_to_children = src
	lies_to_children.vis_contents += visual
	QDEL_IN_CLIENT_TIME(visual, duration)
	return visual

/area/flick_overlay_view(mutable_appearance/display, duration)
	return

/proc/get_active_player_count(alive_check = 0, afk_check = 0, human_check = 0)
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M && M.client)
			if(alive_check && M.stat)
				continue
			else if(afk_check && M.client.is_afk())
				continue
			else if(human_check && !ishuman(M))
				continue
			else if(isnewplayer(M)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/proc/showCandidatePollWindow(mob/M, poll_time, Question, list/candidates, ignore_category, time_passed, flashwindow = TRUE)
	set waitfor = 0

	SEND_SOUND(M, 'sound/misc/notice3.ogg') //Alerting them to their consideration
	if(flashwindow)
		window_flash(M.client)
	var/list/answers = ignore_category ? list("Yes", "No", "Never for this round") : list("Yes", "No")
	switch(tgui_alert(M, Question, "A limited-time offer!", answers, poll_time, autofocus = FALSE))
		if("Yes")
			to_chat(M, span_notice("Choice registered: Yes."))
			if(time_passed + poll_time <= world.time)
				to_chat(M, span_danger("Sorry, you answered too late to be considered!"))
				SEND_SOUND(M, 'sound/machines/buzz-sigh.ogg')
				candidates -= M
			else
				candidates += M
		if("No")
			to_chat(M, span_danger("Choice registered: No."))
			candidates -= M
		if("Never for this round")
			var/list/L = GLOB.poll_ignore[ignore_category]
			if(!L)
				GLOB.poll_ignore[ignore_category] = list()
			GLOB.poll_ignore[ignore_category] += M.ckey
			to_chat(M, span_danger("Choice registered: Never for this round."))
			candidates -= M
		else
			candidates -= M

/**
  * Poll all ghosts for looking for a candidate
  *
  * Poll all ghosts a question
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * ignore_category: Define, ignore_category: People with this category(defined in poll_ignore.dm) turned off dont get the message
  * * flashwindow: Bool, Flash their window to grab their attention
  */
/proc/pollGhostCandidates(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/G in GLOB.player_list)
		candidates += G

	return pollCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category, flashwindow, candidates)

/**
  * Poll all mentor ghosts for looking for a candidate
  *
  * Poll all mentor ghosts a question
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * ignore_category: Define, ignore_category: People with this category(defined in poll_ignore.dm) turned off dont get the message
  * * flashwindow: Bool, Flash their window to grab their attention
  */
/proc/pollMentorGhostCandidates(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/G in GLOB.player_list)
		if(is_mentor(G))
			candidates += G

	return pollCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category, flashwindow, candidates)

/**
  * Poll all in the group for a candidate
  *
  * Poll group for question
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * ignore_category: Define, ignore_category: People with this category(defined in poll_ignore.dm) turned off dont get the message
  * * flashwindow: Bool, Flash their window to grab their attention
  * * group: List, Group of people to poll. list of datum/minds
  */
/proc/pollCandidates(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE, list/group = null)
	var/time_passed = world.time
	if (!Question)
		Question = "Would you like to be a special role?"
	var/list/result = list()
	for(var/m in group)
		var/mob/M = m
		if(!M.key || !M.client || (ignore_category && GLOB.poll_ignore[ignore_category] && (M.ckey in GLOB.poll_ignore[ignore_category])))
			continue
		if(be_special_flag)
			if(!(M.client.prefs) || !(be_special_flag in M.client.prefs.be_special))
				continue
		if(gametypeCheck)
			if(!gametypeCheck.age_check(M.client))
				continue
		if(jobbanType)
			if(is_banned_from(M.ckey, list(jobbanType, ROLE_SYNDICATE)) || QDELETED(M))
				continue

		showCandidatePollWindow(M, poll_time, Question, result, ignore_category, time_passed, flashwindow)
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off or get deleted during the wait period.
	for(var/mob/M in result)
		if(!M.key || !M.client)
			result -= M

	listclearnulls(result)

	return result

/**
  * Poll ghosts to take control of a mob
  *
  * Poll ghosts for mob control
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * M: Mob, /mob to offer
  * * ignore_category: Unknown
  */
/proc/pollCandidatesForMob(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, mob/M, ignore_category = null)
	var/list/L = pollGhostCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	if(!M || QDELETED(M) || !M.loc)
		return list()
	return L

/**
  * Poll mentor ghosts to take control of a mob
  *
  * Poll mentor ghosts for mob control
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * M: Mob, /mob to offer
  * * ignore_category: Unknown
  */
/proc/pollMentorCandidatesForMob(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, mob/M, ignore_category = null)
	var/list/L = pollMentorGhostCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	if(!M || QDELETED(M) || !M.loc)
		return list()
	return L

/**
  * Poll ghosts to take control of a mob
  *
  * Poll ghosts for mob control
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * gametypeCheck: Datum, Check if they have the time required for that role
  * * be_special_flag: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * mobs: List, list of mobs to offer up
  * * ignore_category: Unknown
  */
/proc/pollCandidatesForMobs(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, list/mobs, ignore_category = null)
	var/list/L = pollGhostCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	var/i=1
	for(var/v in mobs)
		var/atom/A = v
		if(!A || QDELETED(A) || !A.loc)
			mobs.Cut(i,i+1)
		else
			++i
	return L

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	G_found.client.prefs.apply_prefs_to(new_character)
	new_character.dna.update_dna_identity()
	new_character.key = G_found.key

	return new_character

/proc/send_to_playing_players(thing) //sends a whatever to all playing players; use instead of to_chat(world, where needed)
	for(var/M in GLOB.player_list)
		if(M && !isnewplayer(M))
			to_chat(M, thing)

/proc/window_flash(client/C, ignorepref = FALSE)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C || (!C.prefs.read_preference(/datum/preference/toggle/window_flashing) && !ignorepref))
		return
	winset(C, "mainwindow", "flash=5")

//Recursively checks if an item is inside a given type, even through layers of storage. Returns the atom if it finds it.
/proc/recursive_loc_check(atom/movable/target, type)
	var/atom/A = target
	if(istype(A, type))
		return A

	while(!istype(A.loc, type))
		if(!A.loc)
			return
		A = A.loc

	return A.loc

/proc/AnnounceArrival(mob/living/carbon/human/character, rank)
	if(!SSticker.IsRoundInProgress() || QDELETED(character))
		return
	var/area/A = get_area(character)
	if(character.mind.role_alt_title)
		rank = character.mind.role_alt_title
	deadchat_broadcast(" has arrived at the station at [span_name("[A.name]")].", "<span class='game'>[span_name("[character.real_name]")] ([rank])", follow_target = character, message_type=DEADCHAT_ARRIVALRATTLE)
	if((!GLOB.announcement_systems.len) || (!character.mind))
		return
	if((character.mind.assigned_role == "Cyborg") || (character.mind.assigned_role == character.mind.special_role))
		return

	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	announcer.announce("ARRIVAL", character.real_name, rank, list()) //make the list empty to make it announce it in common

/proc/lavaland_equipment_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment)
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE
	//YOGS EDIT
	if(pressure >= JUNGLELAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE
	//YOGS END

/proc/ispipewire(item)
	var/static/list/pire_wire = list(
		/obj/machinery/atmospherics,
		/obj/structure/disposalpipe,
		/obj/structure/cable
	)
	return (is_type_in_list(item, pire_wire))

// Find a obstruction free turf that's within the range of the center. Can also condition on if it is of a certain area type.
/proc/find_obstruction_free_location(range, atom/center, area/specific_area)
	var/list/turfs = RANGE_TURFS(range, center)
	var/list/possible_loc = list()

	for(var/turf/found_turf in turfs)
		var/area/turf_area = get_area(found_turf)

		// We check if both the turf is a floor, and that it's actually in the area.
		// We also want a location that's clear of any obstructions.
		if (specific_area)
			if (!istype(turf_area, specific_area))
				continue

		if (!isspaceturf(found_turf))
			if (!found_turf.is_blocked_turf())
				possible_loc.Add(found_turf)

	// Need at least one free location.
	if (possible_loc.len < 1)
		return FALSE

	return pick(possible_loc)

/proc/power_fail(duration_min, duration_max)
	var/list/data_core_areas = list()
	for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores)
		if(!core.valid_data_core())
			continue
		if(!isarea(core.loc))
			continue
		var/area/A = core.loc
		data_core_areas[A.type] = TRUE

	for(var/P in GLOB.apcs_list)
		var/obj/machinery/power/apc/C = P
		if(C.cell && SSmapping.level_trait(C.z, ZTRAIT_STATION))
			var/area/A = C.area
			if(GLOB.typecache_powerfailure_safe_areas[A.type])
				continue
			if(data_core_areas[A.type])
				continue

			C.energy_fail(rand(duration_min,duration_max))

/// For legacy procs using addtimer in callbacks. Don't use this.
/proc/_addtimer_here(callback, time)
	addtimer(callback, time)
