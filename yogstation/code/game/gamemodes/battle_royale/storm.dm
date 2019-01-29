/datum/weather/royale
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from the edge!</i></span>"
	weather_message = null
	protected_areas = list(/area/shuttle/arrival)
	area_type = /area
	weather_overlay = "acid_rain"
	end_message = null
	telegraph_duration = 1
	end_duration = 1
	immunity_type = "fuckno"
	telegraph_sound = 'yogstation/sound/effects/battleroyale/stormclosing.ogg'
	end_sound = 'yogstation/sound/effects/battleroyale/stormalert.ogg'
	weather_duration = INFINITY
	weather_duration_lower = INFINITY
	weather_duration_upper = INFINITY
	var/list/areasToWeather = list()

/datum/weather/royale/weather_act(mob/living/L)
	L.adjustFireLoss(3)

/datum/weather/royale/New()
	.=..()
	if(areasToWeather.len)
		protected_areas = get_areas(/area)
		for(var/A in protected_areas)
			var/area/B = A
			if(B.type in areasToWeather)
				protected_areas -= B

// ROYALE WEATHER TYPES
/datum/weather/royale/zero
	name = "royale start" //roundstart wave, just hits solars and the toxins test area
	areasToWeather = list(/area/solar/starboard/fore, /area/solar/starboard/aft, /area/solar/port/fore, /area/solar/port/aft, /area/science/test_area)

/datum/weather/royale/one
	name = "royale maint" //First wave, hits maintenance
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from maintenance!</i></span>"
	area_type = /area/maintenance

/datum/weather/royale/two
	name = "royale north" //North wave, takes out security, EVA, dorms and associated areas.
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from the north!</i></span>"
	areasToWeather = list(/area/security/execution/transfer, /area/security/prison, /area/security/processing, /area/ai_monitored/security/armory, /area/security/main, /area/crew_quarters/heads/hos,
	/area/security/warden, /area/security/brig, /area/security/courtroom, /area/vacant_room/office/office_b, /area/lawoffice, /area/ai_monitored/storage/eva, /area/crew_quarters/dorms, /area/crew_quarters/toilet,
	/area/crew_quarters/fitness, /area/holodeck/rec_center, /area/hallway/primary/fore)

/datum/weather/royale/three
	name = "royale east" //East wave, takes out medical, service and science
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from the east!</i></span>"
	areasToWeather = list(/area/science/lab, /area/science/explab, /area/crew_quarters/heads/hor, /area/science/mixing, /area/science/misc_lab, /area/science/nanite, /area/science/xenobiology, /area/science/storage,
	/area/science/research, /area/security/checkpoint/science, /area/science/server, /area/science/robotics/lab, /area/science/robotics/mechbay, /area/medical/genetics, /area/medical/paramedic,
	/area/medical/morgue, /area/security/checkpoint/medical, /area/crew_quarters/heads/cmo, /area/medical/virology, /area/medical/sleeper, /area/medical/chemistry, /area/medical/medbay/central,
	/area/chapel/main, /area/chapel/office, /area/library, /area/hydroponics, /area/crew_quarters/bar, /area/crew_quarters/theatre, /area/hallway/secondary/service, /area/hallway/secondary/exit, /area/hallway/primary/starboard, /area/crew_quarters/kitchen)

/datum/weather/royale/four
	name = "royale south" //South wave, takes out engineering and atmos
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from the south!</i></span>"
	areasToWeather = list(/area/storage/tech, /area/janitor, /area/construction, /area/engine/atmos, /area/engine/gravity_generator, /area/security/checkpoint/engineering, /area/engine/break_room, /area/crew_quarters/heads/chief,
	/area/engine/engine_smes, /area/engine/engineering, /area/engine/supermatter, /area/tcommsat/entrance, /area/tcommsat/computer, /area/tcommsat/server, /area/hallway/primary/aft)

/datum/weather/royale/five
	name = "royale west" //West wave, takes out arrivals and cargo
	telegraph_message = "<span class='userdanger'><i>The storm is closing, get away from the west!</i></span>"
	areasToWeather = list(/area/construction/mining/aux_base, /area/security/checkpoint/auxiliary, /area/hydroponics/garden, /area/storage/primary, /area/ai_monitored/nuke_storage, /area/clerk, /area/vacant_room,
	/area/crew_quarters/toilet/locker, /area/crew_quarters/locker, /area/storage/art, /area/storage/emergency/port, /area/storage/tools, /area/security/detectives_office, /area/quartermaster/warehouse,
	/area/quartermaster/sorting, /area/quartermaster/storage, /area/quartermaster/office, /area/quartermaster/qm, /area/quartermaster/miningdock, /area/security/checkpoint/supply, /area/hallway/secondary/entry, /area/hallway/primary/port)

/datum/weather/royale/six
	name = "royale centre" //final wave, takes out the centre ring.
	telegraph_message = "<span class='userdanger'><i>The storm is closing, make your final stand!</i></span>"
	areasToWeather = list(/area/hallway/primary/central, /area/crew_quarters/heads/hop, /area/bridge/meeting_room, /area/bridge, /area/crew_quarters/heads/captain, /area/teleporter, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai)