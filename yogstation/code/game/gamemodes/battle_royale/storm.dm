/datum/weather/royale
	telegraph_message = null //don't clutter chat at the start
	weather_message = null
	protected_areas = list(/area/shuttle/arrival)
	area_type = /area
	weather_overlay = "ash_storm"
	telegraph_overlay = "light_ash"
	end_message = null
	telegraph_duration = 10 SECONDS //actually give them a brief moment to react
	end_duration = 1
	immunity_type = "fuckno"
	telegraph_sound = 'yogstation/sound/effects/battleroyale/stormclosing.ogg'
	end_sound = 'yogstation/sound/effects/battleroyale/stormalert.ogg'
	weather_duration = INFINITY
	weather_duration_lower = INFINITY
	weather_duration_upper = INFINITY
	var/list/areasToWeather = list()//if you want a specific area targeted
	var/list/areaTypesToWeather = list()//if you want an entire area type targeted
	var/list/areaIgnore = list()//if you want areaTypesToWeather to ignore something specific, because mappers can't be consistent with that type of area the thing should be

/datum/weather/royale/weather_act(mob/living/L)
	L.adjustFireLoss(GLOB.stormdamage, TRUE, TRUE)

/datum/weather/royale/New()
	.=..()
	if(areaTypesToWeather.len)//so multiple entire area types can be used instead of relying on selecting specific areas
		for(var/A in areaTypesToWeather)
			var/list/areas = get_areas(A)
			for(var/B in areas)
				var/area/place = B
				if(areaIgnore.len && (place.type in areaIgnore))
					continue
				areasToWeather |= place.type

	if(areasToWeather.len)
		protected_areas = get_areas(/area)
		for(var/A in protected_areas)
			var/area/B = A
			if(B.type in areasToWeather)
				protected_areas -= B

// ROYALE WEATHER TYPES
/datum/weather/royale/start
	name = "royale start" //roundstart wave, just hits solars, toxins test area, space, and any shuttles
	areasToWeather = list(/area/science/test_area)
	areaTypesToWeather = list(/area/solar, /area/space, /area/shuttle)
	areaIgnore = list(/area/shuttle/supply)//but not the supply shuttle just yet

/datum/weather/royale/maint
	name = "royale maint" //First wave, hits maintenance
	telegraph_message = span_narsiesmall("<i>The storm is closing, get away from maintenance!</i>")
	area_type = /area/maintenance

/datum/weather/royale/security
	name = "royale security" //North wave, takes out security, EVA, dorms and associated areas.
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from security!</i>")
	areasToWeather = list(/area/crew_quarters/heads/hos)
	areaTypesToWeather = list(/area/security, /area/lawoffice)
	areaIgnore = list(/area/security/checkpoint/science, /area/security/checkpoint/engineering, //ignore all department security offices
	/area/security/checkpoint/medical, /area/security/checkpoint/supply, /area/ai_monitored/security/armory)

/datum/weather/royale/science
	name = "royale science" //takes out science
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from science!</i>")
	areasToWeather = list(/area/crew_quarters/heads/hor, /area/security/checkpoint/science)
	areaTypesToWeather = list(/area/science, /area/ai_monitored)

/datum/weather/royale/engineering
	name = "royale engineering" //takes out engineering and atmos
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from engineering and storage!</i>")
	areasToWeather = list(/area/crew_quarters/heads/chief, /area/security/checkpoint/engineering)
	areaTypesToWeather = list(/area/engine, /area/tcommsat, /area/construction, /area/storage)

/datum/weather/royale/service //this one is more annoying because head offices are considered a type of crew_quarters
	name = "royale service" //takes out service
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from service!</i>")
	areasToWeather = list(/area/security/checkpoint/service)
	areaTypesToWeather = list(/area/chapel, /area/library, /area/hydroponics, /area/holodeck, /area/janitor, /area/crew_quarters, /area/clerk)
	areaIgnore = list(/area/crew_quarters/heads/hos, /area/crew_quarters/heads/hor, /area/crew_quarters/heads/cmo, //ignore all the head offices
	/area/crew_quarters/heads/chief, /area/crew_quarters/heads/hop, /area/crew_quarters/heads/captain)

/datum/weather/royale/medbay
	name = "royale medbay" //takes out medbay
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from medbay!</i>")
	areasToWeather = list(/area/crew_quarters/heads/cmo, /area/security/checkpoint/medical)
	areaTypesToWeather = list(/area/medical)

/datum/weather/royale/cargo
	name = "royale cargo" //takes out arrivals and cargo (shuttle included)
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from cargo and any vacant rooms!</i>")
	areasToWeather = list(/area/security/checkpoint/supply)
	areaTypesToWeather = list(/area/quartermaster, /area/vacant_room, /area/shuttle)

/datum/weather/royale/bridge
	name = "royale the bridge"
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get away from the bridge!</i>")
	areasToWeather = list(/area/teleporter, /area/crew_quarters/heads/captain, /area/crew_quarters/heads/hop)
	areaTypesToWeather = list(/area/bridge)

/datum/weather/royale/hallway
	name = "royale hallway"
	telegraph_duration = 30 SECONDS //hallway's a bit bigger
	telegraph_message = span_narsiesmall("<i>The storm is closing in, get out of the hallways!</i>")
	areaTypesToWeather = list(/area/hallway)

/datum/weather/royale/hallway/telegraph() //message changes depending on which one is left
	if(GLOB.final_zone) 
		telegraph_message = span_narsiesmall("<i>The storm is closing in, it all ends in [GLOB.final_zone]!</i>")
	. = ..()

/datum/weather/royale/final
	name = "royale centre" //final wave, takes out the centre ring.
	telegraph_duration = 30 SECONDS //the zone annihilates people, give some time for them to "make their final stand"
	telegraph_message = span_narsiesmall("<i>The eye of the storm is closing, make your final stand!</i>")
