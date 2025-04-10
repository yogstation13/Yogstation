/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || incapacitated())
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()

/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/atom/movable/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(check_click_intercept(params,A))
		return

	if(control_disabled || incapacitated())
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return //So there's no point messaging admins
		message_admins("[ADMIN_LOOKUPFLW(src)] failed can_see on AI click of [A] (Turf Loc: [ADMIN_VERBOSEJMP(pixel_turf)]))")
		log_admin("[key_name(src)] failed can_see on AI click of [A] (Turf Loc: [AREACOORD(pixel_turf)])")
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		if(controlled_mech) //Are we piloting a mech? Placed here so the modifiers are not overridden.
			controlled_mech.click_action(A, src, params) //Override AI normal click behavior.
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"] && CtrlClickOn(A)) // returns whether or not it should be overridden
		return

	if(world.time <= next_move)
		return

	if(aicamera.in_camera_mode)
		aicamera.camera_mode_off()
		aicamera.captureimage(pixel_turf, usr)
		return
	if(waypoint_mode)
		waypoint_mode = 0
		set_waypoint(A)
		return

	A.attack_ai(src, modifiers)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_ai(src, modifiers)
/mob/living/silicon/ai/RangedAttack(atom/A, proximity, modifiers)
	A.attack_ai(src, modifiers)

/atom/proc/attack_ai(mob/user, modifiers)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	A.AICtrlShiftClick(src)

/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)

/mob/living/silicon/ai/CtrlClickOn(atom/A)
	return A.AICtrlClick(src)

/mob/living/silicon/ai/AltClickOn(atom/A)
	A.AIAltClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/
/* Questions: Instead of an Emag check on every function, can we not add to airlocks onclick if emag return? */

/* Atom Procs */
/atom/proc/AICtrlClick()
	return
/atom/proc/AIAltClick(mob/living/silicon/ai/user)
	AltClick(user)
	return
/atom/proc/AIShiftClick()
	return
/atom/proc/AICtrlShiftClick()
	return


/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if((obj_flags & EMAGGED) || (obj_flags & CMAGGED))
		return FALSE

	var/mob/living/silicon/ai/AI = usr
	if(istype(AI) && !AI.has_subcontroller_connection(get_area(src)))
		to_chat(AI, span_warning("No connection to subcontroller detected. Priming servos..."))
		if(!do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
			return TRUE

	toggle_bolt(usr)
	add_hiddenprint(usr)
	return TRUE

/obj/machinery/door/airlock/AIAltClick() // Eletrifies doors.
	if((obj_flags & EMAGGED) || (obj_flags & CMAGGED))
		return

	var/mob/living/silicon/ai/AI = usr
	if(istype(AI) && !AI.has_subcontroller_connection(get_area(src)))
		to_chat(AI, span_warning("No connection to subcontroller detected. Priming servos..."))
		if(!do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
			return

	if(!secondsElectrified)
		shock_perm(usr)
	else
		shock_restore(usr)

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if((obj_flags & EMAGGED) || (obj_flags & CMAGGED))
		return

	var/mob/living/silicon/ai/AI = usr
	if(istype(AI) && !AI.has_subcontroller_connection(get_area(src)))
		to_chat(AI, span_warning("No connection to subcontroller detected. Priming servos..."))
		if(!do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
			return
	user_toggle_open(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AICtrlShiftClick()  // Sets/Unsets Emergency Access Override
	if((obj_flags & EMAGGED) || (obj_flags & CMAGGED))
		return

	var/mob/living/silicon/ai/AI = usr
	if(istype(AI) && !AI.has_subcontroller_connection(get_area(src)))
		to_chat(AI, span_warning("No connection to subcontroller detected. Priming servos..."))
		if(!do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
			return

	toggle_emergency(usr)
	add_hiddenprint(usr)

/* APC */
/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	var/mob/living/silicon/ai/AI = usr
	if(istype(AI) && !AI.has_subcontroller_connection(get_area(src)))
		to_chat(AI, span_warning("No connection to subcontroller detected. Polling APC..."))
		if(!do_after(AI, 1 SECONDS, src, IGNORE_USER_LOC_CHANGE))
			return TRUE
	if(can_use(usr, 1))
		toggle_breaker(usr)
	return TRUE

/* AI Turrets */
/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	if(ailock)
		return
	toggle_lethal(usr)

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	if(ailock)
		return TRUE
	toggle_on(usr)
	return TRUE

/* Holopads */
/obj/machinery/holopad/AIAltClick(mob/living/silicon/ai/user)
	hangup_all_calls()
	add_hiddenprint(usr)

/* Humans (With upgrades) */
/mob/living/carbon/human/AIShiftClick(mob/living/silicon/ai/user)

	if(user.client && (user.client.eye == user.eyeobj || user.client.eye == user.loc))
		if(user.canExamineHumans)
			user.examinate(src)
		if(user.canCameraMemoryTrack)
			if(name == "Unknown")
				to_chat(user, span_warning("Unable to track 'Unknown' persons! Their name must be visible."))
				return
			if(src == user.cameraMemoryTarget)
				to_chat(user, span_warning("Stop tracking this individual? <a href='byond://?src=[REF(user)];stopTrackHuman=1'>\[UNTRACK\]</a>"))
			else
				to_chat(user, span_warning("Track this individual? <a href='byond://?src=[REF(user)];trackHuman=[src.name]'>\[TRACK\]</a>"))
	return

//
// Override TurfAdjacent for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))
