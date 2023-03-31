/datum/weather/royale
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from the edge!</i>")
	weather_message = null
	protected_areas = list(/area/shuttle/arrival)
	area_type = /area
	weather_overlay = "ash_storm"
	telegraph_overlay = "light_ash"
	end_message = null
	telegraph_duration = 1
	end_duration = 1
	immunity_type = "fuckno"
	telegraph_sound = 'yogstation/sound/effects/battleroyale/stormclosing.ogg'
	end_sound = 'yogstation/sound/effects/battleroyale/stormalert.ogg'
	weather_duration = INFINITY
	weather_duration_lower = INFINITY
	weather_duration_upper = INFINITY
	var/list/areasToWeather = list()//if you want a specific area targeted
	var/list/areaTypesToWeather = list()//if you want an entire area type targeted
	var/list/areaIgnore = list()//if you want areaTypesToWeather to ignore something specific

/datum/weather/royale/weather_act(mob/living/L)
	L.adjustFireLoss(3)

/datum/weather/royale/New()
	.=..()
	if(areaTypesToWeather.len)//so multiple entire area types can be used instead of relying on selecting specific areas
		for(var/area/A in areaTypesToWeather)
			var/list/areas = get_areas(A)
			if(areaIgnore.len)
				areas -= areaIgnore
			areasToWeather |= areas

	if(areasToWeather.len)
		protected_areas = get_areas(/area)
		for(var/A in protected_areas)
			var/area/B = A
			if(B.type in areasToWeather)
				protected_areas -= B

// ROYALE WEATHER TYPES
/datum/weather/royale/start
	name = "royale start" //roundstart wave, just hits solars and the toxins test area
	areasToWeather = list(/area/science/test_area)
	areaTypesToWeather = list(/area/solar)

/datum/weather/royale/maint
	name = "royale maint" //First wave, hits maintenance
	telegraph_message = span_userdanger("<i>The storm is closing, get away from maintenance!</i>")
	area_type = /area/maintenance

/datum/weather/royale/security
	name = "royale security" //North wave, takes out security, EVA, dorms and associated areas.
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from security and controlled areas!</i>")
	areasToWeather = list(/area/crew_quarters/heads/hos)
	areaTypesToWeather = list(/area/security, /area/ai_monitored, /area/lawoffice)

/datum/weather/royale/science
	name = "royale science" //takes out science
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from science!</i>")
	areasToWeather = list(/area/crew_quarters/heads/hor)
	areaTypesToWeather = list(/area/science)

/datum/weather/royale/engineering
	name = "royale engineering" //takes out engineering and atmos
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from engineering and storage!</i>")
	areasToWeather = list(/area/crew_quarters/heads/chief)
	areaTypesToWeather = list(/area/engine, /area/tcommsat, /area/construction, /area/storage)

/datum/weather/royale/service //this one is more annoying because head offices are considered a type of crew_quarters
	name = "royale service" //takes out service
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from service!</i>")
	areaTypesToWeather = list(/area/chapel, /area/library, /area/hydroponics, /area/holodeck, /area/janitor, /area/crew_quarters)
	areaIgnore = list(/area/crew_quarters/heads/hos, /area/crew_quarters/heads/hor, /area/crew_quarters/heads/cmo, //ignore all the head offices
	/area/crew_quarters/heads/chief, /area/crew_quarters/heads/hop, /area/crew_quarters/heads/captain)

/datum/weather/royale/medbay
	name = "royale medbay" //takes out medbay
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from medbay!</i>")
	areasToWeather = list(/area/crew_quarters/heads/cmo)
	areaTypesToWeather = list(/area/medical)

/datum/weather/royale/cargo
	name = "royale west" //takes out arrivals and cargo
	telegraph_message = span_userdanger("<i>The storm is closing in, get away from cargo and any vacant rooms!</i>")
	areaTypesToWeather = list(/area/quartermaster, /area/vacant_room)

/datum/weather/royale/hallway//
	name = "royale hallway"
	telegraph_message = span_userdanger("<i>The storm is closing in, get out of the hallways!</i>")
	areaTypesToWeather = list(/area/hallway)

/datum/weather/royale/six
	name = "royale centre" //final wave, takes out the centre ring.
	telegraph_message = span_userdanger("<i>The eye of the storm is closing, make your final stand!</i>")
