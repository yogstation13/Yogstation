/datum/weather/nuclear
	name = "nuclear detonation"
	desc = "A tactical nuclear detonation has been detected in station airspace."
	telegraph_duration = 280
	telegraph_message = "<span class='boldwarning'>A loud alarm blares in your ears as the sky turns orange, SEEK SHELTER!</span>"
	weather_message = "<span class='userdanger'><i>The air around you grows unbearably hot.</i></span>"
	weather_overlay = "nuclear_heatwave"
	end_overlay = "light_ash"
	telegraph_overlay = "nuclear_light_heatwave"
	weather_duration_lower = 200
	weather_duration_upper = 400
	weather_color = null
	telegraph_sound = 'yogstation/sound/effects/nuclearblast.ogg'
	weather_sound = 'yogstation/sound/effects/nuclearwind.ogg'
	end_duration = 300
	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle)
	target_trait = ZTRAIT_STATION
	end_message = "<span class='notice'>The air around you is filled with ash, it's hard to breathe.</span>"
	immunity_type = null //Are you immune to nukes?
	end_sound = 'yogstation/sound/effects/nuclearallclear.ogg'


/datum/weather/nuclear/update_areas()
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

/datum/weather/nuclear/weather_act(atom/movable/M)
	if(isliving(M))
		if(ishuman(M))
			var/mob/living/carbon/human/L = M
			var/resist = L.getarmor(null, "energy")
			if(prob(max(0,100-resist)))
				if(/obj/item/clothing/suit/fire || /obj/item/clothing/suit/space in L.wear_suit)
					L.adjustToxLoss(3)
					L.IgniteMob()
				else
					to_chat(L, "In an instant flash of heat, you are completely vaporized as your skin melts away.")
					L.dust()
			else
				L.IgniteMob()
		else
			var/mob/living/themob = M
			themob.dust()

/datum/weather/nuclear/telegraph()
	. = ..()
	priority_announce("WARNING: TACTICAL NUCLEAR DETONATION DETECTED IN SS13 AIRSPACE. ALL PERSONNEL ARE ADVISED TO SEEK SHELTER. OFFICIAL INSTRUCTIONS WILL FOLLOW.", "Nanotrasen Emergency Alert System")
	sleep(60)
	priority_announce("Official advice from Nanotrasen citizen's office: Put as much metal between you and the outside as possible. All space-facing zones are likely to be affected by the initial heatwave.", "Nanotrasen Emergency Alert System")

/datum/weather/nuclear/start()
	. = ..()
	for(var/mob/living/L in GLOB.mob_living_list)
		shake_camera(L, 7, 1)
	for(var/obj/machinery/light/T in GLOB.machines)
		T.break_light_tube()
		if(prob(50))
			T.atmos_spawn_air("plasma=20;TEMP=1000")

/datum/weather/nuclear/end()
	if(..())
		return
	priority_announce("ERROR Contacting NTnet. Reverting communications to legacy system.", "Nanotrasen Emergency Alert System")
	sleep(60) //6 seconds
	priority_announce("Warning: Nuclear Fallout imminent. Do not leave shelters.", "Nanotrasen Emergency Alert System")
	sleep(300) //30 seconds
	SSweather.run_weather("nuclear fallout",2) //fallout follows rads

/datum/weather/nuclear_fallout
	name = "nuclear fallout"
	desc = "Radioactive dust falls upon the station, you should get to maint..."
	telegraph_duration = 50
	telegraph_message = "<span class='boldwarning'>Ash falls from the sky, radioactive embers float everywhere.</span>"
	weather_message = "<span class='userdanger'><i>You feel a wave of hot ash fall down on you.</i></span>"
	weather_overlay = "light_ash"
	telegraph_overlay = "light_ash"
	weather_duration_lower = 1100
	weather_duration_upper = 1250
	weather_color = "green"
	telegraph_sound = null
	weather_sound = 'yogstation/sound/effects/falloutwind.ogg'
	end_duration = 100
	area_type = /area
	protected_areas = list(/area/maintenance)
	target_trait = ZTRAIT_STATION
	end_message = "<span class='notice'>The ash stops falling.</span>"
	immunity_type = "rad"

/datum/weather/nuclear_fallout/weather_act(mob/living/L)
	var/resist = L.getarmor(null, "rad")
	if(prob(40))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.dna && !H.has_trait(TRAIT_RADIMMUNE))
				if(prob(max(0,100-resist)))
					H.randmuti()
					if(prob(50))
						if(prob(90))
							H.randmutb()
						else
							H.randmutg()
						H.domutcheck()
		L.rad_act(20)
