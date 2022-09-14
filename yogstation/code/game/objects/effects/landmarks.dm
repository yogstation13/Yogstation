GLOBAL_LIST_EMPTY(chosen_station_templates)

#define EMPTY_SPAWN "empty_spawn"

/obj/effect/landmark/start/yogs
	icon = 'yogstation/icons/mob/landmarks.dmi'

/obj/effect/landmark/start/yogs/mining_medic
	name = "Mining Medic"
	icon_state = "Mining Medic"

/obj/effect/landmark/start/yogs/network_admin
	name = "Network Admin"
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

/obj/effect/landmark/start/yogs/brigphsyician
	name = "Brig Physician"
	icon_state = "Brig Physician"

/obj/effect/landmark/stationroom
	var/list/template_names = list()
	/// Whether or not we can choose templates that have already been chosen
	var/unique = FALSE
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
			if(!SSmapping.station_room_templates[t] && t != EMPTY_SPAWN)
				stack_trace("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				template_names -= t
		template_name = choose()
	if(!template_name)
		stack_trace("Station room spawner [src] at ([T.x], [T.y], [T.z]) has a null template.")
	if(!template_name || template_name == EMPTY_SPAWN)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	GLOB.chosen_station_templates += template_name
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
	var/list/current_templates = template_names
	if(unique)
		for(var/i in GLOB.chosen_station_templates)
			template_names -= i
		if(!template_names.len)
			stack_trace("Station room spawner (type: [type]) has run out of ruins, unique will be ignored")
			template_names = current_templates
	var/chosen_template = pickweight(template_names)
	if(unique && chosen_template == EMPTY_SPAWN)
		template_names -= EMPTY_SPAWN
		if(!template_names.len)
			stack_trace("Station room spawner (type: [type]) has run out of ruins from an EMPTY_SPAWN, unique will be ignored")
			template_names = current_templates
	return chosen_template

/obj/effect/landmark/stationroom/box/bar
	template_names = list("Bar Trek", "Bar Spacious", "Bar Box", "Bar Casino", "Bar Citadel", "Bar Conveyor", "Bar Diner", "Bar Disco", "Bar Purple", "Bar Cheese", "Bar Clock", "Bar Arcade")
	icon = 'yogstation/icons/rooms/box/bar.dmi'
	icon_state = "bar_box"

/obj/effect/landmark/stationroom/box/bar/load(template_name)
	GLOB.stationroom_landmarks -= src
	return TRUE

/obj/effect/landmark/stationroom/box/engine
	template_names = list("Engine SM" = 50, "Engine Singulo And Tesla" = 30, "Engine TEG" = 10, "Engine RBMK" = 10)
	icon = 'yogstation/icons/rooms/box/engine.dmi'

/obj/effect/landmark/stationroom/box/engine/choose()
	. = ..()
	var/enginepicked = CONFIG_GET(number/engine_type)
	switch(enginepicked)
		if(1)
			return "Engine SM"
		if(2)
			return "Engine Singulo And Tesla"
		if(3)
			return . //We let the normal choose() do the work if we want to have all of them in play
		if(4)
			return "Engine TEG"
		if(5)
			return "Engine RBMK"


/obj/effect/landmark/stationroom/box/testingsite
	template_names = list("Bunker Bomb Range","Syndicate Bomb Range","Clown Bomb Range", "Clerk Bomb Range")

/obj/effect/landmark/stationroom/box/medbay/morgue
	template_names = list("Morgue", "Morgue 2", "Morgue 3", "Morgue 4", "Morgue 5")

/obj/effect/landmark/stationroom/box/dorm_edoor
	template_names = list("Dorm east door 1", "Dorm east door 2", "Dorm east door 3", "Dorm east door 4", "Dorm east door 5", "Dorm east door 6", "Dorm east door 7", "Dorm east door 8", "Dorm east door 9")

/obj/effect/landmark/stationroom/box/hydroponics
	template_names = list("Hydroponics 1", "Hydroponics 2", "Hydroponics 3", "Hydroponics 4", "Hydroponics 5", "Hydroponics 6")

/obj/effect/landmark/stationroom/box/execution
	template_names = list("Transfer 1", "Transfer 2", "Transfer 3", "Transfer 4", "Transfer 5", "Transfer 6", "Transfer 7", "Transfer 8", "Transfer 9", "Transfer 10")

/obj/effect/landmark/stationroom/eclipse/bar
	template_names = list("Eclipse Bar Default", "Eclipse Bar Beach", "Eclipse Bar Western", "Eclipse Bar Clock", "Eclipse Bar Disco", "Eclipse Bar Casino")

/obj/effect/landmark/stationroom/maint/
	unique = TRUE

/obj/effect/landmark/stationroom/maint/threexthree
	template_names = list("Maint 2storage", "Maint 9storage", "Maint airstation", "Maint biohazard", "Maint boxbedroom", "Maint boxchemcloset", "Maint boxclutter2", "Maint boxclutter3", "Maint boxclutter4", "Maint boxclutter5", "Maint boxclutter6", "Maint boxclutter8",
	"Maint boxwindow", "Maint bubblegumaltar", "Maint deltajanniecloset", "Maint deltaorgantrade", "Maint donutcapgun", "Maint dronehole", "Maint gibs", "Maint hazmat", "Maint hobohut", "Maint hullbreach", "Maint kilolustymaid", "Maint kilomechcharger", "Maint kilotheatre",
	"Maint medicloset", "Maint memorial", "Maint metaclutter2", "Maint metaclutter4", "Maint metagamergear", "Maint owloffice", "Maint plasma", "Maint pubbyartism", "Maint pubbyclutter1", "Maint pubbyclutter2", "Maint pubbyclutter3", "Maint radspill", "Maint shrine", "Maint singularity",
	"Maint tanning", "Maint tranquility", "Maint wash", "Maint command", "Maint dummy", "Maint spaceart", "Maint containmentcell", "Maint naughtyroom", "Maint vendoraccident", "Maint donut")

/obj/effect/landmark/stationroom/maint/threexfive
	template_names = list("Maint airlockstorage", "Maint boxclutter7", "Maint boxkitchen", "Maint boxmaintfreezers", "Maint canisterroom", "Maint checkpoint", "Maint hank", "Maint junkcloset", "Maint kilomobden", "Maint laststand", "Maint monky", "Maint onioncult", "Maint pubbyclutter5",
	"Maint pubbyclutter6", "Maint pubbyrobotics", "Maint ripleywreck", "Maint churchroach", "Maint mirror", "Maint chromosomes", "Maint clutter", "Maint dissection", "Maint emergencyoxy", "Maint oreboxes", "Maint gaxbotany")

/obj/effect/landmark/stationroom/maint/fivexthree
	template_names = list("Maint boxclutter1", "Maint breach", "Maint cloner", "Maint deltaclutter2", "Maint deltaclutter3", "Maint incompletefloor", "Maint kiloclutter1", "Maint metaclutter1", "Maint metaclutter3", "Maint minibreakroom", "Maint nastytrap", "Maint pills", "Maint pubbybedroom",
	"Maint pubbyclutter4", "Maint pubbyclutter7", "Maint pubbykitchen", "Maint storeroom", "Maint yogsmaintdet", "Maint yogsmaintrpg", "Maint waitingroom", "Maint podmin", "Maint highqualitysurgery", "Maint chestburst", "Maint gloveroom", "Maint magicroom", "Maint spareparts", "Maint smallfish")

/obj/effect/landmark/stationroom/maint/fivexfour
	template_names = list("Maint blasted", "Maint boxbar", "Maint boxdinner", "Maint boxsurgery", "Maint comproom", "Maint deltabar", "Maint deltadetective", "Maint deltadressing", "Maint deltaEVA", "Maint deltagamble", "Maint deltalounge", "Maint deltasurgery", "Maint firemanroom", "Maint icicle",
	"Maint kilohauntedlibrary", "Maint kilosurgery", "Maint medusa", "Maint metakitchen", "Maint metamedical", "Maint metarobotics", "Maint metatheatre", "Maint pubbysurgery", "Maint tinybarbershop", "Maint laundromat", "Maint pass", "Maint boxclutter", "Maint posterstore", "Maint shoestore", "Maint nanitechamber", "Maint oldcryoroom")

/obj/effect/landmark/stationroom/maint/tenxfive
	template_names = list("Maint barbershop", "Maint deltaarcade", "Maint deltabotnis", "Maint deltacafeteria", "Maint deltaclutter1", "Maint deltarobotics", "Maint factory", "Maint maintmedical", "Maint meetingroom", "Maint phage", "Maint skidrow", "Maint transit", "Maint ballpit", "Maint commie", "Maint firingrange", "Maint clothingstore",
	"Maint butchersden", "Maint courtroom", "Maint gaschamber", "Maint oldaichamber", "Maint radiationtherapy", "Maint ratburger", "Maint tank_heaven", "Maint bamboo", "Maint medicalmaint")

/obj/effect/landmark/stationroom/maint/tenxten
	template_names = list("Maint aquarium", "Maint bigconstruction", "Maint bigtheatre", "Maint deltalibrary", "Maint graffitiroom", "Maint junction", "Maint podrepairbay", "Maint pubbybar", "Maint roosterdome", "Maint sanitarium", "Maint snakefighter", "Maint vault", "Maint ward", "Maint assaultpod", "Maint maze", "Maint maze2", "Maint boxfactory",
	"Maint sixsectorsdown", "Maint advbotany", "Maint beach", "Maint botany_apiary", "Maint gamercave", "Maint ladytesla_altar", "Maint olddiner", "Maint smallmagician", "Maint fourshops", "Maint fishinghole", "Maint fakewalls")

/// Type of landmark that find all others of the same type, and only spawns count number of ruins at them
/obj/effect/landmark/stationroom/limited_spawn
	var/choose_result = ""
	var/count = 1

/obj/effect/landmark/stationroom/limited_spawn/choose()
	if(choose_result != "")
		return choose_result
	var/list/landmarks = list()
	for(var/obj/effect/landmark/stationroom/limited_spawn/L in GLOB.stationroom_landmarks)
		if(L.type == src.type)
			landmarks |= L
	
	for(var/i = 0, i < count, i++)
		var/obj/effect/landmark/stationroom/limited_spawn/L = pick_n_take(landmarks)
		L.choose_result = pick(L.template_names)
		var/turf/T = get_turf(L)
		message_admins(span_adminnotice("Spawning limited_spawn landmark at [ADMIN_COORDJMP(T)]"))
		log_game("Spawning limited_spawn landmark at: [AREACOORD(T)]")
	
	for(var/obj/effect/landmark/stationroom/limited_spawn/L in landmarks)
		L.choose_result = EMPTY_SPAWN
	
	return choose_result

/obj/effect/landmark/stationroom/limited_spawn/gax/ai_whale
	template_names = list("AI Whale")

/obj/effect/landmark/start/infiltrator
	name = "infiltrator"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/obj/effect/landmark/start/infiltrator/Initialize()
	..()
	GLOB.infiltrator_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/infiltrator_objective
	name = "infiltrator objective items"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"

/obj/effect/landmark/start/infiltrator_objective/Initialize()
	..()
	GLOB.infiltrator_objective_items += loc
	return INITIALIZE_HINT_QDEL 

#undef EMPTY_SPAWN
