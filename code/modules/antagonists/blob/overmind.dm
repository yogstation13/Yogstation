//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs) //complete list of all blobs made.
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(overminds)
GLOBAL_LIST_EMPTY(blob_nodes)


/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	// Vivid blue green, would be cool to make this change with strain
	lighting_cutoff_red = 0
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 20
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	hud_type = /datum/hud/blob_overmind
	var/obj/structure/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/datum/blobstrain/blobstrain
	var/list/blob_mobs = list()
	var/list/resource_blobs = list()
	var/free_strain_rerolls = 1 //one free strain reroll
	var/last_reroll_time = 0 //time since we last rerolled, used to give free rerolls
	var/nodes_required = 1 //if the blob needs nodes to place resource and factory blobs
	var/placed = 0
	var/manualplace_min_time = 600 //in deciseconds //a minute, to get bearings
	var/autoplace_max_time = 3600 //six minutes, as long as should be needed
	var/list/blobs_legit = list()
	var/max_count = 0 //The biggest it got before death
	var/blobwincount = 400
	var/victory_in_progress = FALSE
	var/rerolling = FALSE
	var/announcement_size = 75
	var/announcement_time
	var/has_announced = FALSE
	var/basemodifier = 1
	var/contained = FALSE

/mob/camera/blob/Initialize(mapload, starting_points = 60, pointmodifier = 1, announcement_delay = 6000)
	validate_location()
	if(starting_points > max_blob_points)
		max_blob_points = starting_points
	blob_points = starting_points
	basemodifier = pointmodifier
	manualplace_min_time += world.time
	autoplace_max_time += world.time
	GLOB.overminds += src
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/datum/blobstrain/BS = pick(GLOB.valid_blobstrains)
	set_strain(BS)
	color = blobstrain.complementary_color
	if(blob_core)
		blob_core.update_appearance(UPDATE_ICON)
	SSshuttle.registerHostileEnvironment(src)
	announcement_time = world.time + announcement_delay
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/camera/blob/proc/validate_location()
	var/turf/T = get_turf(src)
	if(!is_valid_turf(T) && LAZYLEN(GLOB.blobstart))
		var/list/blobstarts = shuffle(GLOB.blobstart)
		for(var/_T in blobstarts)
			if(is_valid_turf(_T))
				T = _T
				break
	if(!T)
		CRASH("No blobspawnpoints and blob spawned in nullspace.")
	forceMove(T)

/mob/camera/blob/proc/set_strain(datum/blobstrain/new_strain)
	if (ispath(new_strain))
		var/hadstrain = FALSE
		if (istype(blobstrain))
			blobstrain.on_lose()
			qdel(blobstrain)
			hadstrain = TRUE
		blobstrain = new new_strain(src)
		blobstrain.on_gain()
		if (hadstrain)
			to_chat(src, "Your strain is now: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
			to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> strain [blobstrain.description]")
			if(blobstrain.effectdesc)
				to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> strain [blobstrain.effectdesc]")


/mob/camera/blob/proc/is_valid_turf(turf/T)
	var/area/A = get_area(T)
	if((A && !A.blob_allowed) || !T || !is_station_level(T.z) || isspaceturf(T))
		return FALSE
	return TRUE

/mob/camera/blob/process()
	if(!blob_core)
		if(!placed)
			if(manualplace_min_time && world.time >= manualplace_min_time)
				to_chat(src, "<b><span class='big'><font color=\"#EE4000\">You may now place your blob core.</font></span></b>")
				to_chat(src, span_big("<font color=\"#EE4000\">You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)].</font>"))
				manualplace_min_time = 0
			if(autoplace_max_time && world.time >= autoplace_max_time)
				place_blob_core(1)
		else
			qdel(src)
	else if(!victory_in_progress && (blobs_legit.len >= blobwincount))
		victory_in_progress = TRUE
		priority_announce("Biohazard has reached critical mass. Station loss is imminent.", "Biohazard Alert")
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		max_blob_points = INFINITY
		blob_points = INFINITY	
		blob_core.max_integrity = 999999
		addtimer(CALLBACK(src, PROC_REF(victory)), 450)
	else if(!free_strain_rerolls && (last_reroll_time + BLOB_REROLL_TIME<world.time))
		to_chat(src, "<b><span class='big'><font color=\"#EE4000\">You have gained another free strain re-roll.</font></span></b>")
		free_strain_rerolls = 1

	if(!victory_in_progress && max_count < blobs_legit.len)
		max_count = blobs_legit.len

	if((world.time >= announcement_time || blobs_legit.len >= announcement_size) && (!has_announced || !contained))
		if(check_containment(blob_core, 5) && !contained && !has_announced)
			priority_announce("Confirmed outbreak of level 5 biohazard containment successfully aboard [station_name()].", "Biohazard Containment Alert", 'sound/misc/notice1.ogg', color_override="green")
			contained = TRUE
			SSshuttle.clearHostileEnvironment(src)
		else if(!check_containment(blob_core, 5) && contained && !has_announced)
			priority_announce("Confirmed outbreak of level 5 biohazard containment breach detected aboard [station_name()], coordinations: x[blob_core.x] y[blob_core.y] z[blob_core.z]. All personnel must attempt to re-contain, otherwise station loss is inevitable.", "Biohazard Containment Alert", 'sound/misc/notice1.ogg', color_override="red")
			contained = FALSE
			has_announced = TRUE
			SSshuttle.registerHostileEnvironment(src)
		else if(!check_containment(blob_core, 5) && !contained && !has_announced)
			priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/ai/default/outbreak5.ogg', color_override="yellow")
			has_announced = TRUE

/mob/camera/blob/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(10 SECONDS)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue

		if(L in GLOB.overminds || (L.pass_flags & PASSBLOB))
			continue

		var/area/Ablob = get_area(T)

		if(!Ablob.blob_allowed)
			continue

		if(!(ROLE_BLOB in L.faction))
			playsound(L, 'sound/effects/splat.ogg', 50, 1)
			L.death()
			new/mob/living/simple_animal/hostile/blob/blobspore(T)
		else
			L.fully_heal()

		for(var/area/A in GLOB.areas)
			if(!(A.type in GLOB.the_station_areas))
				continue
			if(!A.blob_allowed)
				continue
			A.color = blobstrain.color
			A.name = "blob"
			A.icon = 'icons/mob/blob.dmi'
			A.icon_state = "blob_shield"
			A.layer = BELOW_MOB_LAYER
			A.invisibility = 0
			A.blend_mode = 0
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(B)
		var/datum/objective/blob_takeover/main_objective = locate() in B.objectives
		if(main_objective)
			main_objective.completed = TRUE
	to_chat(world, "<B>[real_name] consumed the station in an unstoppable tide!</B>")
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = 1

/mob/camera/blob/Destroy()
	QDEL_NULL(blobstrain)
	for(var/BL in GLOB.blobs)
		var/obj/structure/blob/B = BL
		if(B && B.overmind == src)
			B.overmind = null
			B.update_appearance(UPDATE_ICON) //reset anything that was ours
	for(var/BLO in blob_mobs)
		var/mob/living/simple_animal/hostile/blob/BM = BLO
		if(BM)
			BM.overmind = null
			BM.update_icons()
	GLOB.overminds -= src

	SSshuttle.clearHostileEnvironment(src)
	STOP_PROCESSING(SSobj, src)

	return ..()

/mob/camera/blob/Login()
	..()
	to_chat(src, span_notice("You are the overmind!"))
	blob_help()
	update_health_hud()
	add_points(0)

/mob/camera/blob/examine(mob/user)
	. = ..()
	if(blobstrain)
		. += "Its strain is <font color=\"[blobstrain.color]\">[blobstrain.name]</font>."

/mob/camera/blob/update_health_hud()
	if(blob_core)
		var/current_health = round((blob_core.get_integrity() / blob_core.max_integrity) * 100)
		hud_used?.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>"
		for(var/mob/living/simple_animal/hostile/blob/blobbernaut/B in blob_mobs)
			if(B.hud_used && B.hud_used.blobpwrdisplay)
				B.hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>"

/mob/camera/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	hud_used?.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_points)]</font></div>"

/mob/camera/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	src.log_talk(message, LOG_SAY)

	var/message_a = say_quote(message)
	var/rendered = span_big("<font color=\"#EE4000\"><b>\[Blob Telepathy\] [name](<font color=\"[blobstrain.color]\">[blobstrain.name]</font>)</b> [message_a]</font>")

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/get_status_tab_items()
	. = ..()
	if(blob_core)
		. += "Core Health: [blob_core.get_integrity()]"
		. += "Power Stored: [blob_points]/[max_blob_points]"
		. += "Blobs to Win: [blobs_legit.len]/[blobwincount]"
	if(free_strain_rerolls)
		. += "You have [free_strain_rerolls] Free Strain Reroll\s Remaining"
	if(!placed)
		if(manualplace_min_time)
			. +=  "Time Before Manual Placement: [max(round((manualplace_min_time - world.time)*0.1, 0.1), 0)]"
		. += "Time Before Automatic Placement: [max(round((autoplace_max_time - world.time)*0.1, 0.1), 0)]"

/mob/camera/blob/Move(NewLoc, Dir = 0)
	if(placed)
		var/obj/structure/blob/B = locate() in range("3x3", NewLoc)
		if(B)
			forceMove(NewLoc)
		else
			return 0
	else
		var/area/A = get_area(NewLoc)
		if(isspaceturf(NewLoc) || istype(A, /area/shuttle)) //if unplaced, can't go on shuttles or space tiles
			return 0
		forceMove(NewLoc)
		return 1

/mob/camera/blob/mind_initialize()
	. = ..()
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(!B)
		mind.add_antag_datum(/datum/antagonist/blob)
