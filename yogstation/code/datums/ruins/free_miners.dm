/datum/map_template/ruin/space/freeminer_asteroid
	id = "freeminer_asteroid"
	prefix = "_maps/RandomRuins/SpaceRuins/"
	suffix = "freeminer_asteroid.dmm"
	name = "Free Miner Asteroid"
	description = "Some space miners still cling to the old way of getting that \
		sweet, sweet plasma - painstakingly digging it out of free-floating asteroids\
		instead of flying down to the hellscape of lavaland."
	allow_duplicates = FALSE
	always_spawn_with = list(/datum/map_template/ruin/space/whiteshipdock = PLACE_SPACE_RUIN)

/datum/map_template/ruin/space/freeminer_asteroid/load(turf/T, centered = FALSE)
	. = ..()
	if(.)
		SSmapping.config.shuttles["whiteship"] = "whiteship_miner"


/obj/machinery/computer/shuttle/white_ship/miner
	name = "Free Miner Ship Console"
	desc = "Used to control the Free Miner Ship."
	circuit = /obj/item/circuitboard/computer/white_ship/miner
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_mining0;whiteship_mining1;whiteship_mining2;whiteship_custom"
	req_access = list(ACCESS_FREEMINER_CAPTAIN)

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/miner
	name = "Free Miner Navigation Computer"
	desc = "Used to designate a precise transit location for the Free Miner Ship."
	jumpto_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_mining0" = 1, "whiteship_mining1" = 1, "whiteship_mining2" = 1)
	x_offset = -4
	y_offset = -7

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/miner/Initialize(mapload)
	. = ..()
	for(var/V in SSshuttle.stationary)
		var/obj/docking_port/stationary/S = V
		if(jumpto_ports[S.id])
			z_lock |= S.z


/obj/effect/mob_spawn/human/free_miner
	name = "Free Miner"
	id_job = "Free Miner"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a free miner, making a living mining the asteroids that were left behind when Nanotrasen moved from asteroid mining to lavaland. Try to make a profit and show those corporates who the real miners are!"
	short_desc = "You are a free miner."
	assignedrole = "Free Miner"
	outfit = /datum/outfit/freeminer
	prompt_name = "a free miner"

/obj/effect/mob_spawn/human/free_miner/check_allowed(mob/M)
	var/area/A = get_area(src)
	if(A)
		var/obj/effect/mob_spawn/human/free_miner/captain/cap = locate(/obj/effect/mob_spawn/human/free_miner/captain) in A
		if(cap)
			if(alert("The ship needs a captain before it can have a crew. Would you like to play as the captain instead?",,"Yes","No") == "Yes")
				cap.attack_ghost(M)
			return FALSE
	return TRUE

/datum/outfit/freeminer
	name = "Free Miner"
	uniform = /obj/item/clothing/under/rank/miner
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/industrial
	l_pocket = /obj/item/mining_voucher
	r_pocket = /obj/item/storage/bag/ore
	belt = /obj/item/pickaxe
	id = /obj/item/card/id/freeminer
	backpack_contents = list(/obj/item/radio)


/obj/effect/mob_spawn/human/free_miner/engi
	name = "Free Miner Engineer"
	id_job = "Free Miner Engineer"
	flavour_text = "You are a free miner, making a living mining the asteroids that were left behind when Nanotrasen moved from asteroid mining to lavaland. Try to make a profit and show those corporates who the real miners are! After years of saving, you finally have just enough parts to put your own mech together. Salvage the wreckage with a welder and a crowbar to get them."
	short_desc = "You are a free miner engineer."
	l_pocket = null
	r_pocket = null
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full/engi
	assignedrole = "Free Miner Engineer"
	outfit = /datum/outfit/freeminer/engi
	prompt_name = "a free miner engineer"

/datum/outfit/freeminer/engi
	uniform = /obj/item/clothing/under/overalls
	l_pocket = null
	r_pocket = null
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full/engi
	id = /obj/item/card/id/freeminer/engi

/obj/effect/mob_spawn/human/free_miner/captain
	name = "Free Miner Captain"
	id_job = "Free Miner Captain"
	flavour_text = "You are a free miner, making a living mining the asteroids that were left behind when Nanotrasen moved from asteroid mining to lavaland. Try to make a profit and show those corporates who the real miners are! Your ID and the ship pilot IDs in the cockpit are the only way to move your ship. Try not to lose them!"
	short_desc = "You are a free miner captain."
	assignedrole = "Free Miner Captain"
	outfit = /datum/outfit/freeminer/captain
	prompt_name = "the free miner captain"

/obj/effect/mob_spawn/human/free_miner/captain/check_allowed(mob/M)
	return TRUE

/datum/outfit/freeminer/captain
	uniform = /obj/item/clothing/under/rank/vice
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/melee/classic_baton/telescopic
	r_pocket = null
	belt = null
	id = /obj/item/card/id/freeminer/captain


/obj/item/card/id/freeminer
	name = "Free Miner Crewman ID"
	access = list(ACCESS_MINERAL_STOREROOM, ACCESS_FREEMINER, ACCESS_MECH_FREEMINER)

/obj/item/card/id/freeminer/engi
	name = "Free Miner Engineer ID"
	access = list(ACCESS_MINERAL_STOREROOM, ACCESS_FREEMINER, ACCESS_MECH_FREEMINER, ACCESS_FREEMINER_ENGINEER)

/obj/item/card/id/freeminer/captain
	name = "Free Miner Ship Pilot ID"
	access = list(ACCESS_MINERAL_STOREROOM, ACCESS_FREEMINER, ACCESS_MECH_FREEMINER, ACCESS_FREEMINER_ENGINEER, ACCESS_FREEMINER_CAPTAIN)

/obj/item/storage/box/ids/free_miners
	name = "box of spare IDs"
	desc = "Spare IDs for promotions and new hires."
	illustration = "id"

/obj/item/storage/box/ids/free_miners/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/card/id/freeminer(src)
	for(var/i in 1 to 2)
		new /obj/item/card/id/freeminer/captain(src)
