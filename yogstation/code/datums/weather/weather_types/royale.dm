/datum/weather/royale
	telegraph_message = "<span class='userdanger'><i>The zone is shrinking, get away from the edge!</i></span>"
	weather_message = null
	protected_areas = list(/area/shuttle/arrival)
	area_type = /area
	weather_overlay = "purple"
	end_message = null
	telegraph_duration = 1
	end_duration = 1
	var/list/areasToWeather = list()

/datum/weather/royale/weather_act(mob/living/L)
	L.adjustFireLoss(3)

/datum/weather/royale/telegraph()
	..()
	var/list/affected_spawns = list()
	for(var/S in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/E = S
		if(get_area(E) in impacted_areas)
			affected_spawns += E

	if(affected_spawns.len)
		var/obj/effect/landmark/event_spawn/E = pick(affected_spawns)
		E.spawnroyale(TRUE)

/datum/weather/royale/New()
	..()
	if(areasToWeather.len)
		protected_areas = get_areas(/area)
		protected_areas -= areasToWeather

/datum/weather/royale/update_areas()
	for(var/V in impacted_areas)
		var/area/N = V
		N.layer = overlay_layer
		N.icon = 'yogstation/icons/effects/weather_effects.dmi'
		N.color = weather_color
		switch(stage)
			if(STARTUP_STAGE)
				N.icon_state = telegraph_overlay
			if(MAIN_STAGE)
				N.icon_state = weather_overlay
			if(WIND_DOWN_STAGE)
				N.icon_state = end_overlay
			if(END_STAGE)
				N.color = null
				N.icon_state = ""
				N.icon = 'icons/turf/areas.dmi'
				N.layer = AREA_LAYER //Just default back to normal area stuff since I assume setting a var is faster than initial
				N.set_opacity(FALSE)

// ROYALE WEATHER TYPES
/datum/weather/royale/zero
	name = "royale zero" //roundstart wave, just hits space, solars and the toxins test area
	weather_duration_lower = 18000
	weather_duration_upper = 18000 //30 minutes flat.
	areasToWeather = list(/area/space, /area/space/nearstation, /area/solar/starboard/fore, /area/solar/starboard/aft, /area/solar/port/fore, /area/solar/port/aft, /area/science/test_area)

/datum/weather/royale/one
	name = "royale one" //first wave, hits the space-adjacent areas, except for major hallways.
	weather_duration_lower = 15000
	weather_duration_upper = 15000
	areasToWeather = list(/area/tcommsat/computer, /area/tcommsat/entrance, /area/tcommsat/server, /area/engine/engineering, /area/engine/supermatter, /area/engine/engine_smes, /area/maintenance/disposal/incinerator,
	/area/maintenance/solars/starboard/aft, /area/maintenance/solars/starboard/fore, /area/maintenance/solars/port/aft, /area/maintenance/solars/port/fore, /area/maintenance/starboard/aft, /area/maintenance/starboard,
	/area/hallway/secondary/exit, /area/maintenance/department/electrical, /area/maintenance/fore/secondary, /area/crew_quarters/heads/hos, /area/security/main, /area/ai_monitored/security/armory, /area/security/prison,
	/area/security/execution/transfer, /area/maintenance/port/fore, /area/construction/mining/aux_base, /area/maintenance/disposal, /area/quartermaster/qm, /area/maintenance/port/aft)

/datum/weather/royale/two
	name = "royale two" //second wave, takes out the rest of maint, as well as half of science, all of sec, atmos and half of the arrivals offshoot rooms.
	weather_duration_lower = 12000
	weather_duration_upper = 12000
	areasToWeather = list(/area/crew_quarters/heads/chief, /area/engine/break_room, /area/security/checkpoint/engineering, /area/engine/atmos, /area/maintenance/aft, /area/science/mixing, /area/science/circuit,
	/area/science/explab, /area/science/misc_lab, /area/crew_quarters/heads/hor, /area/science/lab, /area/chapel/main, /area/chapel/office, /area/maintenance/starboard/fore, /area/hallway/secondary/service, /area/crew_quarters/fitness,
	/area/holodeck/rec_center, /area/security/courtroom, /area/security/warden, /area/security/brig, /area/security/vacantoffice/b, /area/maintenance/fore, /area/security/checkpoint/auxiliary, /area/hydroponics/garden,
	/area/security/vacantoffice, /area/maintenance/port, /area/quartermaster/storage, /area/quartermaster/warehouse, /area/quartermaster/miningdock, /area/engine/gravity_generator)

/datum/weather/royale/three
	name = "royale three" //third wave, takes out anything east of medical, anything north of EVA, west of clerk (not including arrivals) and south of tech storage
	weather_duration_lower = 9000
	weather_duration_upper = 9000
	areasToWeather = list(/area/library, /area/hydroponics, /area/crew_quarters/theatre, /area/crew_quarters/toilet, /area/lawoffice, /area/clerk, /area/ai_monitored/nuke_storage, /area/storage/primary,
	/area/crew_quarters/toilet/locker, /area/crew_quarters/locker, /area/storage/art, /area/quartermaster/office, /area/security/checkpoint/supply, /area/construction, /area/medical/virology, /area/crew_quarters/heads/cmo,
	/area/medical/genetics, /area/science/xenobiology, /area/science/storage, /area/science/research, /area/security/checkpoint/science, /area/science/server, /area/science/robotics/lab, /area/science/robotics/mechbay,
	/area/maintenance/department/medical/morgue, /area/medical/paramedic)

/datum/weather/royale/four
	name = "royale four" //fourth wave, takes out everything outside the central ring hallway
	weather_duration_lower = 6000
	weather_duration_upper = 6000
	areasToWeather = list(/area/storage/tech, /area/janitor, /area/medical/sleeper, /area/medical/medbay/central, /area/medical/chemistry, /area/security/checkpoint/medical, /area/medical/morgue, /area/hallway/primary/aft,
	/area/hallway/primary/starboard, /area/crew_quarters/kitchen, /area/crew_quarters/bar, /area/crew_quarters/dorms, /area/hallway/primary/fore, /area/ai_monitored/storage/eva, /area/storage/tools,
	/area/security/detectives_office, /area/quartermaster/sorting, /area/hallway/primary/port, /area/hallway/secondary/entry)

/datum/weather/royale/five
	name = "royale five" //fifth wave, forces them into the bridge horseshoe, and forces them out of AI
	weather_duration_lower = 3000
	weather_duration_upper = 3000
	areasToWeather = list(/area/hallway/primary/central, /area/ai_monitored/turret_protected/ai_upload_foyer, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai,
	/area/maintenance/central)

/datum/weather/royale/six
	weather_duration_lower = INFINITY
	weather_duration_upper = INFINITY
	name = "royale six" //final wave, kills anyone left.