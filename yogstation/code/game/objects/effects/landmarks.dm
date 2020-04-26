/obj/effect/landmark/start/yogs
	icon = 'yogstation/icons/mob/landmarks.dmi'

/obj/effect/landmark/start/yogs/mining_medic
	name = "Mining Medic"
	icon_state = "Mining Medic"

/obj/effect/landmark/start/yogs/signal_technician
	name = "Signal Technician"
	icon_state = "Signal Technician"

/obj/effect/landmark/start/yogs/clerk
	name = "Clerk"
	icon_state = "Clerk"

/obj/effect/landmark/start/yogs/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/obj/effect/landmark/start/yogs/psychiatrist
	name = "Psychiatrist"
	icon_state = "Psychiatrist"

/obj/effect/landmark/start/yogs/tourist
	name = "Tourist"
	icon_state = "Tourist"

/obj/effect/landmark/stationroom
	var/list/template_names = list()
	layer = BULLET_HOLE_LAYER

/obj/effect/landmark/stationroom/New()
	..()
	GLOB.stationroom_landmarks += src

/obj/effect/landmark/stationroom/Destroy()
	if(src in GLOB.stationroom_landmarks)
		GLOB.stationroom_landmarks -= src
	return ..()

/obj/effect/landmark/stationroom/proc/load(template_name)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!template_name)
		for(var/t in template_names)
			if(!SSmapping.station_room_templates[t])
				stack_trace("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				template_names -= t
		template_name = choose()
	if(!template_name)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	var/datum/map_template/template = SSmapping.station_room_templates[template_name]
	if(!template)
		return FALSE
	testing("Ruin \"[template_name]\" placed at ([T.x], [T.y], [T.z])")
	template.load(T, centered = FALSE)
	template.loaded++
	GLOB.stationroom_landmarks -= src
	qdel(src)
	return TRUE

// Proc to allow you to add conditions for choosing templates, instead of just randomly picking from the template list.
// Examples where this would be useful, would be choosing certain templates depending on conditions such as holidays,
// Or co-dependent templates, such as having a template for the core and one for the satelite, and swapping AI and comms.git
/obj/effect/landmark/stationroom/proc/choose()
	return safepick(template_names)

/obj/effect/landmark/stationroom/box/bar
	template_names = list("Bar Trek", "Bar Spacious", "Bar Box", "Bar Casino", "Bar Citadel", "Bar Conveyor", "Bar Diner", "Bar Disco", "Bar Purple", "Bar Cheese", "Bar Clock")
	icon = 'yogstation/icons/rooms/box/bar.dmi'
	icon_state = "bar_box"

/obj/effect/landmark/stationroom/box/bar/choose()
	. = ..()
	if(SSevents.holidays && SSevents.holidays["St. Patrick's Day"])
		return "Bar Irish"

/obj/effect/landmark/stationroom/box/engine
	template_names = list("Engine SM", "Engine Singulo And Tesla")
	icon = 'yogstation/icons/rooms/box/engine.dmi'

/obj/effect/landmark/stationroom/box/foreportmaint1
	template_names = list("Maintenance Surgery")

/obj/effect/landmark/stationroom/box/xenobridge
	template_names = list("Xenobiology Bridge", "Xenobiology Lattice")

/obj/effect/landmark/stationroom/box/aftmaint
	template_names = list("Roleplaying Room", "Detective Room")

/obj/effect/landmark/stationroom/box/testingsite
	template_names = list("Bunker Bomb Range","Syndicate Bomb Range","Clown Bomb Range")

/obj/effect/landmark/stationroom/box/medbay/morgue
	template_names = list("Morgue", "Morgue 2", "Morgue 3", "Morgue 4", "Morgue 5")
	
/obj/effect/landmark/stationroom/box/dorm_edoor
	template_names = list("Dorm east door 1", "Dorm east door 2", "Dorm east door 3", "Dorm east door 4", "Dorm east door 5", "Dorm east door 6", "Dorm east door 7", "Dorm east door 8", "Dorm east door 9")

/obj/effect/landmark/stationroom/box/hydroponics
	template_names = list("Hydroponics 1", "Hydroponics 2", "Hydroponics 3", "Hydroponics 4", "Hydroponics 5", "Hydroponics 6")
