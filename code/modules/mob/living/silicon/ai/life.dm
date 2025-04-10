#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

/mob/living/silicon/ai/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if (stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes

		update_gravity(mob_has_gravity())

		handle_status_effects()

		if(dashboard)
			dashboard.tick(2 SECONDS * 0.1)

		process_hijack() // yogs
		process_integrate()


		if(malfhack && malfhack.aidisabled)
			deltimer(malfhacking)
			// This proc handles cleanup of screen notifications and
			// messenging the client
			malfhacked(malfhack)

		if(isvalidAIloc(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
			view_core()

		if(machine)
			machine.check_eye(src)

		// Handle power damage (oxy)
		if(aiRestorePowerRoutine)
			// Lost power
			if (!battery)
				to_chat(src, span_warning("Your backup battery's output drops below usable levels. It takes only a moment longer for your systems to fail, corrupted and unusable."))
				adjustOxyLoss(200)
			else
				battery --
		else
			// Gain Power
			if (battery < 200)
				battery ++

		if(!lacks_power())
			var/area/home = get_area(src)
			if(home.powered(AREA_USAGE_EQUIP))
				home.use_power(1000, AREA_USAGE_EQUIP)

			if(aiRestorePowerRoutine >= POWER_RESTORATION_SEARCH_APC)
				ai_restore_power()
				return

		else if(!aiRestorePowerRoutine)
			ai_lose_power()
		
		if(cameraMemoryTarget)
			if(cameraMemoryTickCount >= AI_CAMERA_MEMORY_TICKS)
				cameraMemoryTickCount = 0
				trackable_mobs()
				var/list/trackeable = track.humans
				var/list/target = list()
				for(var/I in trackeable)
					var/mob/M = trackeable[I]
					if(M.name == cameraMemoryTarget)
						target += M
				if(name == cameraMemoryTarget)
					target += src
				if(target.len)
					to_chat(src, span_userdanger("Tracked target [cameraMemoryTarget] found visible on cameras. Tracking disabled."))
					cameraMemoryTarget = 0
				
			cameraMemoryTickCount++


/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	switch(requires_power)
		if(NONE)
			return FALSE
		if(POWER_REQ_ALL)
			return !T || !A || ((!A.power_equip || isspaceturf(T)) && !is_type_in_list(loc, list(/obj/item, /obj/mecha)))
		if(POWER_REQ_CLOCKCULT)
			for(var/obj/effect/clockwork/sigil/transmission/ST in range(src, SIGIL_ACCESS_RANGE))
				return FALSE
			return !T || !A || (!istype(T, /turf/open/floor/clockwork) && (!A.power_equip || isspaceturf(T)) && !is_type_in_list(loc, list(/obj/item, /obj/mecha)))

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss() - getFireLoss()
	update_stat()
	diag_hud_set_health()
	disconnect_shell()

/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD)
			death()
			return
		else if(stat == UNCONSCIOUS)
			set_stat(CONSCIOUS)
			adjust_blindness(-1)
	diag_hud_set_status()

/mob/living/silicon/ai/update_sight()
	set_invis_see(initial(see_invisible))
	set_sight(initial(sight))
	if(aiRestorePowerRoutine && !available_ai_cores())
		clear_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)

	if(see_override)
		set_invis_see(see_override)
	return ..()


/mob/living/silicon/ai/proc/start_RestorePowerRoutine()
	to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
	end_multicam()
	sleep(5 SECONDS)
	var/turf/T = get_turf(loc)
	var/area/AIarea = get_area(loc)
	if(AIarea && AIarea.power_equip)
		if(!isspaceturf(T))
			ai_restore_power()
			return
	to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
	sleep(2 SECONDS)
	to_chat(src, "Emergency control system online. Verifying connection to power network.")
	sleep(5 SECONDS)
	T = get_turf(loc)
	if(isspaceturf(T))
		to_chat(src, "Unable to verify! No power connection detected!")
		aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
		return
	to_chat(src, "Connection verified. Searching for APC in power network.")
	sleep(5 SECONDS)
	var/obj/machinery/power/apc/theAPC = null

	var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
	for (PRP=1, PRP<=4, PRP++)
		T = get_turf(loc)
		AIarea = get_area(loc)
		if(AIarea)
			for (var/obj/machinery/power/apc/APC in AIarea)
				if (!(APC.stat & BROKEN))
					theAPC = APC
					break
		if (!theAPC)
			switch(PRP)
				if(1)
					to_chat(src, "Unable to locate APC!")
				else
					to_chat(src, "Lost connection with the APC!")
			aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
			return
		if(AIarea.power_equip)
			if(!isspaceturf(T))
				ai_restore_power()
				return
		switch(PRP)
			if (1)
				to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
			if (2)
				to_chat(src, "Best route identified. Hacking offline APC power port.")
			if (3)
				to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
			if (4)
				to_chat(src, "Transfer complete. Forcing APC to execute program.")
				sleep(5 SECONDS)
				to_chat(src, "Receiving control information from APC.")
				sleep(0.2 SECONDS)
				to_chat(src, "<A href=byond://?src=[REF(src)];emergencyAPC=[TRUE]>APC ready for connection.</A>")
				apc_override = theAPC
				apc_override.ui_interact(src)
				aiRestorePowerRoutine = POWER_RESTORATION_APC_FOUND
		sleep(5 SECONDS)
		theAPC = null

/mob/living/silicon/ai/proc/ai_restore_power()
	if(aiRestorePowerRoutine)
		if(aiRestorePowerRoutine == POWER_RESTORATION_APC_FOUND)
			to_chat(src, "Alert cancelled. Power has been restored.")
			if(apc_override)
				to_chat(src, "<span class='notice'>APC backdoor has been closed.</span>") //Fluff for why we have to hack every time.
		else
			to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
		aiRestorePowerRoutine = POWER_RESTORATION_OFF
		set_blindness(0)
		apc_override = null
		update_sight()

/mob/living/silicon/ai/proc/ai_lose_power()
	disconnect_shell()
	aiRestorePowerRoutine = POWER_RESTORATION_START
	if(!available_ai_cores())
		blind_eyes(1)
	
	update_sight()
	to_chat(src, "You've lost power!")
	addtimer(CALLBACK(src, PROC_REF(start_RestorePowerRoutine)), 20)

#undef POWER_RESTORATION_OFF
#undef POWER_RESTORATION_START
#undef POWER_RESTORATION_SEARCH_APC
#undef POWER_RESTORATION_APC_FOUND
