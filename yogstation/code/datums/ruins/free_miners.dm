/datum/map_template/ruin/space/freeminer_asteroid
	id = "freeminer_asteroid"
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
	l_pocket = null
	r_pocket = null
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full
	assignedrole = "Free Miner Engineer"
	outfit = /datum/outfit/freeminer/engi
	prompt_name = "a free miner engineer"

/datum/outfit/freeminer/engi
	l_pocket = null
	r_pocket = null
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full


/obj/effect/mob_spawn/human/free_miner/captain
	name = "Free Miner Captain"
	id_job = "Free Miner Captain"
	flavour_text = "You are a free miner, making a living mining the asteroids that were left behind when Nanotrasen moved from asteroid mining to lavaland. Try to make a profit and show those corporates who the real miners are! Your ID and the ship pilot IDs in the cockpit are the only way to move your ship. Try not to lose them!"
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
	access = list(ACCESS_MINERAL_STOREROOM, ACCESS_FREEMINER)

/obj/item/card/id/freeminer/captain
	name = "Free Miner Ship Pilot ID"
	access = list(ACCESS_MINERAL_STOREROOM, ACCESS_FREEMINER, ACCESS_FREEMINER_CAPTAIN)

/obj/item/storage/box/ids/free_miners
	name = "box of spare IDs"
	desc = "Spare IDs for promotions and new hires."
	illustration = "id"

/obj/item/storage/box/ids/free_miners/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/card/id/freeminer(src)
	for(var/i in 1 to 2)
		new /obj/item/card/id/freeminer/captain(src)

/****************Free Miner Vendor**************************/

/obj/machinery/mineral/equipment_vendor/free_miner
	name = "free miner ship equipment vendor"
	desc = "a vendor sold by nanotrasen to profit off small mining contractors."
	prize_list = list(
		new /datum/data/mining_equipment("Kinetic Accelerator", 		/obj/item/gun/energy/kinetic_accelerator,						750),
		new /datum/data/mining_equipment("Mining Hardsuit",				/obj/item/clothing/suit/space/hardsuit/mining,					2000),
		new /datum/data/mining_equipment("Mecha Plasma Generator",		/obj/item/mecha_parts/mecha_equipment/generator,				1500),
		new /datum/data/mining_equipment("Diamond Mecha Drill",			/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,		2000),
		new /datum/data/mining_equipment("Mecha Plasma Cutter",			/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma,		3000),
		new /datum/data/mining_equipment("Stimpack",					/obj/item/reagent_containers/hypospray/medipen/stimpack,		50),
		new /datum/data/mining_equipment("Stimpack Bundle",				/obj/item/storage/box/medipens/utility,							200),
		new /datum/data/mining_equipment("Advanced Scanner",			/obj/item/t_scanner/adv_mining_scanner,							800),
		new /datum/data/mining_equipment("Hivelord Stabilizer",			/obj/item/hivelordstabilizer,									400),
		new /datum/data/mining_equipment("Shelter Capsule",				/obj/item/survivalcapsule,										400),
		new /datum/data/mining_equipment("GAR Meson Scanners",				/obj/item/clothing/glasses/meson/gar,						500),
		new /datum/data/mining_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/medipen/survival,		500),
		new /datum/data/mining_equipment("Brute First-Aid Kit",			/obj/item/storage/firstaid/brute,								600),
		new /datum/data/mining_equipment("Fire First-Aid Kit",			/obj/item/storage/firstaid/fire,								600),
		new /datum/data/mining_equipment("Toxin First-Aid Kit",			/obj/item/storage/firstaid/toxin,								600),
		new /datum/data/mining_equipment("Resonator",          			 /obj/item/resonator,											800),
		new /datum/data/mining_equipment("Lazarus Injector",    		/obj/item/lazarus_injector,										800),
		new /datum/data/mining_equipment("Silver Pickaxe",				/obj/item/pickaxe/silver,										750),
		new /datum/data/mining_equipment("Jetpack Upgrade",				/obj/item/tank/jetpack/suit,									2000),
		new /datum/data/mining_equipment("Space Cash",    				/obj/item/stack/spacecash/c1000,								2000),
		new /datum/data/mining_equipment("Diamond Pickaxe",				/obj/item/pickaxe/diamond,										1500),
		new /datum/data/mining_equipment("Super Resonator",     		/obj/item/resonator/upgraded,									2000),
		new /datum/data/mining_equipment("Plasma Cutter" ,				/obj/item/gun/energy/plasmacutter,								2500),
		new /datum/data/mining_equipment("Point Transfer Card", 		/obj/item/card/mining_point_card,								500),
		new /datum/data/mining_equipment("Minebot",						/mob/living/simple_animal/hostile/mining_drone,					800),
		new /datum/data/mining_equipment("Minebot Melee Upgrade",		/obj/item/mine_bot_upgrade,										400),
		new /datum/data/mining_equipment("Minebot Armor Upgrade",		/obj/item/mine_bot_upgrade/health,								400),
		new /datum/data/mining_equipment("Minebot Cooldown Upgrade",	/obj/item/borg/upgrade/modkit/cooldown/minebot,					600),
		new /datum/data/mining_equipment("Minebot AI Upgrade",			/obj/item/slimepotion/slime/sentience/mining,					1000),
		new /datum/data/mining_equipment("KA Minebot Passthrough",		/obj/item/borg/upgrade/modkit/minebot_passthrough,				100),
		new /datum/data/mining_equipment("KA White Tracer Rounds",		/obj/item/borg/upgrade/modkit/tracer,							100),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds",	/obj/item/borg/upgrade/modkit/tracer/adjustable,				150),
		new /datum/data/mining_equipment("KA Super Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod,						250),
		new /datum/data/mining_equipment("KA Hyper Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod/orange,				300),
		new /datum/data/mining_equipment("KA Range Increase",			/obj/item/borg/upgrade/modkit/range,							1000),
		new /datum/data/mining_equipment("KA Damage Increase",			/obj/item/borg/upgrade/modkit/damage,							1000),
		new /datum/data/mining_equipment("KA Cooldown Decrease",		/obj/item/borg/upgrade/modkit/cooldown,							1000),
		new /datum/data/mining_equipment("KA AoE Damage",				/obj/item/borg/upgrade/modkit/aoe/mobs,							2000)
		)

/obj/machinery/mineral/equipment_vendor/free_miner/New()
	..()
	var/obj/item/circuitboard/machine/B = new /obj/item/circuitboard/machine/mining_equipment_vendor/free_miner(null)
	B.apply_default_parts(src)

/obj/machinery/mineral/equipment_vendor/free_miner/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/list/items = list("Kinetic Accelerator", "Resonator Kit", "Minebot Kit", "Crusher Kit", "Advanced Scanner")

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in items
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Kinetic Accelerator")
			new /obj/item/gun/energy/kinetic_accelerator(drop_location)
		if("Resonator Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/resonator(drop_location)
		if("Minebot Kit")
			new /mob/living/simple_animal/hostile/mining_drone(drop_location)
			new /obj/item/weldingtool/hugetank(drop_location)
			new /obj/item/clothing/head/welding(drop_location)
			new /obj/item/borg/upgrade/modkit/minebot_passthrough(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/twohanded/required/kinetic_crusher(drop_location)
		if("Advanced Scanner")
			new /obj/item/t_scanner/adv_mining_scanner(drop_location)

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/obj/item/circuitboard/machine/mining_equipment_vendor/free_miner
	name = "circuit board (Free Miner Ship Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor/free_miner

