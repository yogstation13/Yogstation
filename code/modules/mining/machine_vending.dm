#define VENDING_WEAPON "Weapons" // such as kinetic accelerators and crushers
#define VENDING_UPGRADE "Kinetic Accelerator Upgrades" //KA mods
#define VENDING_TOOL "Tools" //items that miners can actively use
#define VENDING_MINEBOT "Minebot"
#define VENDING_MECHA "Mecha Equipment" //for free miners
#define VENDING_EQUIPMENT "Equipment" // equipment/clothing that miners can wear
#define VENDING_MEDS "Medicial Items"
#define VENDING_MISC "Miscellaneous" // other

/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor
	var/icon_deny = "mining-deny"
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list( //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
		new /datum/data/mining_equipment("Kinetic Accelerator",			/obj/item/gun/energy/kinetic_accelerator,							750, VENDING_WEAPON),
		new /datum/data/mining_equipment("Kinetic Crusher",				/obj/item/twohanded/required/kinetic_crusher,						750, VENDING_WEAPON),
		new /datum/data/mining_equipment("Resonator",					/obj/item/resonator,												800, VENDING_WEAPON),
		new /datum/data/mining_equipment("Super Resonator",				/obj/item/resonator/upgraded,										2500, VENDING_WEAPON),
		new /datum/data/mining_equipment("Silver Pickaxe",				/obj/item/pickaxe/silver,											1000, VENDING_WEAPON),
		new /datum/data/mining_equipment("Diamond Pickaxe",				/obj/item/pickaxe/diamond,											2000, VENDING_WEAPON),
		new /datum/data/mining_equipment("KA Minebot Passthrough",		/obj/item/borg/upgrade/modkit/minebot_passthrough,					100, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA White Tracer Rounds",		/obj/item/borg/upgrade/modkit/tracer,								100, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds",	/obj/item/borg/upgrade/modkit/tracer/adjustable,					150, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Super Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod,							250, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Hyper Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod/orange,					300, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Range Increase",			/obj/item/borg/upgrade/modkit/range,								1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Damage Increase",			/obj/item/borg/upgrade/modkit/damage,								1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Cooldown Decrease",		/obj/item/borg/upgrade/modkit/cooldown,								1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA AoE Damage",				/obj/item/borg/upgrade/modkit/aoe/mobs,								2000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("Shelter Capsule",				/obj/item/survivalcapsule,											400, VENDING_TOOL),
		new /datum/data/mining_equipment("Luxury Shelter Capsule",		/obj/item/survivalcapsule/luxury,									3000, VENDING_TOOL),
		new /datum/data/mining_equipment("Advanced Scanner",			/obj/item/t_scanner/adv_mining_scanner,								800, VENDING_TOOL),
		new /datum/data/mining_equipment("Fulton Pack",					/obj/item/extraction_pack,											1000, VENDING_TOOL),
		new /datum/data/mining_equipment("Fulton Beacon",				/obj/item/fulton_core,												400, VENDING_TOOL),
		new /datum/data/mining_equipment("Jaunter",						/obj/item/wormhole_jaunter,											750, VENDING_TOOL),
		new /datum/data/mining_equipment("Stabilizing Serum",			/obj/item/hivelordstabilizer,										400, VENDING_TOOL),
		new /datum/data/mining_equipment("Lazarus Injector",			/obj/item/lazarus_injector,											1000, VENDING_TOOL),
		new /datum/data/mining_equipment("1 Marker Beacon",				/obj/item/stack/marker_beacon,										10, VENDING_TOOL),
		new /datum/data/mining_equipment("10 Marker Beacons",			/obj/item/stack/marker_beacon/ten,									100, VENDING_TOOL),
		new /datum/data/mining_equipment("30 Marker Beacons",			/obj/item/stack/marker_beacon/thirty,								300, VENDING_TOOL),
		new /datum/data/mining_equipment("Nanotrasen Minebot",			/mob/living/simple_animal/hostile/mining_drone,						800, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Melee Upgrade",		/obj/item/mine_bot_upgrade,											400, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Armor Upgrade",		/obj/item/mine_bot_upgrade/health,									400, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Cooldown Upgrade",	/obj/item/borg/upgrade/modkit/cooldown/minebot,						600, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot AI Upgrade",			/obj/item/slimepotion/slime/sentience/mining,						1000, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Explorer's Webbing",			/obj/item/storage/belt/mining,										500, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Mining Conscription Kit",		/obj/item/storage/backpack/duffelbag/mining_conscript,				1000, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("GAR Meson Scanners",			/obj/item/clothing/glasses/meson/gar,								500, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Jump Boots",					/obj/item/clothing/shoes/bhop,										2500, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Mining Hardsuit",				/obj/item/clothing/suit/space/hardsuit/mining,						2000, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Jetpack Upgrade",				/obj/item/tank/jetpack/suit,										2000, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/medipen/survival,			500, VENDING_MEDS),
		new /datum/data/mining_equipment("Brute First-Aid Kit",			/obj/item/storage/firstaid/brute,									600, VENDING_MEDS),
		new /datum/data/mining_equipment("Tracking Implant Kit", 		/obj/item/storage/box/minertracker,									600, VENDING_MEDS),
		new /datum/data/mining_equipment("Point Transfer Card",			/obj/item/card/mining_point_card,									500, VENDING_MISC),
		new /datum/data/mining_equipment("Alien Toy",					/obj/item/clothing/mask/facehugger/toy,								300, VENDING_MISC),
		new /datum/data/mining_equipment("Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,			100, VENDING_MISC),
		new /datum/data/mining_equipment("Absinthe",					/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,	100, VENDING_MISC),
		new /datum/data/mining_equipment("Cigar",						/obj/item/clothing/mask/cigarette/cigar/havana,						150, VENDING_MISC),
		new /datum/data/mining_equipment("Soap",						/obj/item/soap/nanotrasen,											200, VENDING_MISC),
		new /datum/data/mining_equipment("Laser Pointer",				/obj/item/laser_pointer,											300, VENDING_MISC),
		new /datum/data/mining_equipment("Space Cash",					/obj/item/stack/spacecash/c1000,									2000, VENDING_MISC)
		)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0
	var/category

/datum/data/mining_equipment/New(name, path, pcost, cat)
	equipment_name = name
	equipment_path = path
	cost = pcost
	category = cat

/obj/machinery/mineral/equipment_vendor/power_change()
	..()
	update_icon()

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user)
	. = ..()
	var/dat
	var/list/categories = list()
	dat +="<div class='statusDisplay'>"
	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=[REF(src)];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=[REF(src)];choice=insert'>Insert ID.</A><br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		var/list/L = categories[prize.category]
		if(L)
			L += prize
		else
			categories[prize.category] = list(prize)

	for(var/a in categories)
		dat += "<h3>[a]</h3>"
		dat += "<div class='statusDisplay'><ul>"
		for(var/datum/data/mining_equipment/prize in categories[a])
			dat += "<div>[prize.equipment_name] <div style='float:right; display:inline-block'> [prize.cost] <A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A> </div> </div>"
		dat += "</ul></div>"
		dat += "<br>"

	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 350)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/equipment_vendor/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				to_chat(usr, "<span class='notice'>You eject the ID from [src]'s card slot.</span>")
				inserted_id.forceMove(loc)
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/card/id/I = usr.get_active_held_item()
			if(istype(I))
				if(!usr.transferItemToLoc(I, src))
					return
				inserted_id = I
				to_chat(usr, "<span class='notice'>You insert the ID into [src]'s card slot.</span>")
			else
				to_chat(usr, "<span class='warning'>Error: No valid ID!</span>")
				flick(icon_deny, src)
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"]) in prize_list
			if (!prize || !(prize in prize_list))
				to_chat(usr, "<span class='warning'>Error: Invalid choice!</span>")
				flick(icon_deny, src)
				return
			if(prize.cost > inserted_id.mining_points)
				to_chat(usr, "<span class='warning'>Error: Insufficient points for [prize.equipment_name]!</span>")
				flick(icon_deny, src)
			else
				inserted_id.mining_points -= prize.cost
				to_chat(usr, "<span class='notice'>[src] clanks to life briefly before vending [prize.equipment_name]!</span>")
				new prize.equipment_path(src.loc)
				SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
		else
			to_chat(usr, "<span class='warning'>Error: Please insert a valid ID!</span>")
			flick(icon_deny, src)
	updateUsrDialog()
	return

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher))
		RedeemVoucher(I, user)
		return
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = usr.get_active_held_item()
		if(istype(C) && !istype(inserted_id))
			if(!usr.transferItemToLoc(C, src))
				return
			inserted_id = C
			to_chat(usr, "<span class='notice'>You insert the ID into [src]'s card slot.</span>")
			interact(user)
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator Kit", "Minebot Kit", "Extraction and Rescue Kit", "Crusher Kit", "Mining Conscription Kit")

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in items
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/resonator(drop_location)
		if("Minebot Kit")
			new /mob/living/simple_animal/hostile/mining_drone(drop_location)
			new /obj/item/weldingtool/hugetank(drop_location)
			new /obj/item/clothing/head/welding(drop_location)
			new /obj/item/borg/upgrade/modkit/minebot_passthrough(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/extraction_pack(drop_location)
			new /obj/item/fulton_core(drop_location)
			new /obj/item/stack/marker_beacon/thirty(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/twohanded/required/kinetic_crusher(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffelbag/mining_conscript(drop_location)

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)


/****************Golem Point Vendor**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor/golem

/obj/machinery/mineral/equipment_vendor/golem/Initialize()
	. = ..()
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("The Liberator's Legacy",  	/obj/item/storage/box/rndboards,								2000, VENDING_TOOL),
		new /datum/data/mining_equipment("Modification Kit",    		/obj/item/borg/upgrade/modkit/trigger_guard,					1700, VENDING_UPGRADE),
		new /datum/data/mining_equipment("Extra Id",       				/obj/item/card/id/mining, 				                   		250, VENDING_MISC),
		new /datum/data/mining_equipment("Monkey Cube",					/obj/item/reagent_containers/food/snacks/monkeycube,        	300, VENDING_MISC),
		new /datum/data/mining_equipment("Grey Slime Extract",			/obj/item/slime_extract/grey,									1000, VENDING_MISC),
		new /datum/data/mining_equipment("Science Goggles",       		/obj/item/clothing/glasses/science,								250, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Toolbelt",					/obj/item/storage/belt/utility,	    							350, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 								500, VENDING_EQUIPMENT)
		)

/****************Free Miner Vendor**************************/

/obj/machinery/mineral/equipment_vendor/free_miner
	name = "free miner ship equipment vendor"
	desc = "a vendor sold by nanotrasen to profit off small mining contractors."
	prize_list = list(
		new /datum/data/mining_equipment("Kinetic Accelerator", 		/obj/item/gun/energy/kinetic_accelerator,						750, VENDING_WEAPON),
		new /datum/data/mining_equipment("Resonator",          			/obj/item/resonator,											800, VENDING_WEAPON),
		new /datum/data/mining_equipment("Super Resonator",     		/obj/item/resonator/upgraded,									2000, VENDING_WEAPON),
		new /datum/data/mining_equipment("Silver Pickaxe",				/obj/item/pickaxe/silver,										750, VENDING_WEAPON),
		new /datum/data/mining_equipment("Diamond Pickaxe",				/obj/item/pickaxe/diamond,										1500, VENDING_WEAPON),
		new /datum/data/mining_equipment("Plasma Cutter" ,				/obj/item/gun/energy/plasmacutter,								2500, VENDING_WEAPON),
		new /datum/data/mining_equipment("KA Minebot Passthrough",		/obj/item/borg/upgrade/modkit/minebot_passthrough,				100, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA White Tracer Rounds",		/obj/item/borg/upgrade/modkit/tracer,							100, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds",	/obj/item/borg/upgrade/modkit/tracer/adjustable,				150, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Super Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod,						250, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Hyper Chassis",			/obj/item/borg/upgrade/modkit/chassis_mod/orange,				300, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Range Increase",			/obj/item/borg/upgrade/modkit/range,							1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Damage Increase",			/obj/item/borg/upgrade/modkit/damage,							1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA Cooldown Decrease",		/obj/item/borg/upgrade/modkit/cooldown,							1000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("KA AoE Damage",				/obj/item/borg/upgrade/modkit/aoe/mobs,							2000, VENDING_UPGRADE),
		new /datum/data/mining_equipment("Shelter Capsule",				/obj/item/survivalcapsule,										400, VENDING_TOOL),
		new /datum/data/mining_equipment("Advanced Scanner",			/obj/item/t_scanner/adv_mining_scanner,							800, VENDING_TOOL),
		new /datum/data/mining_equipment("Hivelord Stabilizer",			/obj/item/hivelordstabilizer,									400, VENDING_TOOL),
		new /datum/data/mining_equipment("Lazarus Injector",    		/obj/item/lazarus_injector,										800, VENDING_TOOL),
		new /datum/data/mining_equipment("Minebot",						/mob/living/simple_animal/hostile/mining_drone,					800, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Melee Upgrade",		/obj/item/mine_bot_upgrade,										400, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Armor Upgrade",		/obj/item/mine_bot_upgrade/health,								400, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot Cooldown Upgrade",	/obj/item/borg/upgrade/modkit/cooldown/minebot,					600, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Minebot AI Upgrade",			/obj/item/slimepotion/slime/sentience/mining,					1000, VENDING_MINEBOT),
		new /datum/data/mining_equipment("Mecha Plasma Generator",		/obj/item/mecha_parts/mecha_equipment/generator,				1500, VENDING_MECHA),
		new /datum/data/mining_equipment("Diamond Mecha Drill",			/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,		2000, VENDING_MECHA),
		new /datum/data/mining_equipment("Mecha Plasma Cutter",			/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma,		3000, VENDING_MECHA),
		new /datum/data/mining_equipment("GAR Meson Scanners",			/obj/item/clothing/glasses/meson/gar,							500, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Mining Hardsuit",				/obj/item/clothing/suit/space/hardsuit/mining,					2000, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Jetpack Upgrade",				/obj/item/tank/jetpack/suit,									2000, VENDING_EQUIPMENT),
		new /datum/data/mining_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/medipen/survival,		500, VENDING_MEDS),
		new /datum/data/mining_equipment("Stimpack",					/obj/item/reagent_containers/hypospray/medipen/stimpack,		50, VENDING_MEDS),
		new /datum/data/mining_equipment("Brute First-Aid Kit",			/obj/item/storage/firstaid/brute,								600, VENDING_MEDS),
		new /datum/data/mining_equipment("Fire First-Aid Kit",			/obj/item/storage/firstaid/fire,								600, VENDING_MEDS),
		new /datum/data/mining_equipment("Toxin First-Aid Kit",			/obj/item/storage/firstaid/toxin,								600, VENDING_MEDS),
		new /datum/data/mining_equipment("Stimpack Bundle",				/obj/item/storage/box/medipens/utility,							200, VENDING_MEDS),
		new /datum/data/mining_equipment("Point Transfer Card", 		/obj/item/card/mining_point_card,								500, VENDING_MISC),
		new /datum/data/mining_equipment("Space Cash",    				/obj/item/stack/spacecash/c1000,								2000, VENDING_MISC)
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

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data_1"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>You transfer [points] points to [C].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>There's no points left on [src].</span>")
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	..()
	to_chat(user, "There's [points] point\s on the card.")

///Conscript kit
/obj/item/card/mining_access_card
	name = "mining access card"
	desc = "A small card, that when used on any ID, will add mining access."
	icon_state = "data_1"

/obj/item/card/mining_access_card/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(istype(AM, /obj/item/card/id) && proximity)
		var/obj/item/card/id/I = AM
		I.access |=	ACCESS_MINING
		I.access |= ACCESS_MINING_STATION
		I.access |= ACCESS_MECH_MINING
		I.access |= ACCESS_MINERAL_STOREROOM
		I.access |= ACCESS_CARGO
		to_chat(user, "You upgrade [I] with mining access.")
		qdel(src)

/obj/item/storage/backpack/duffelbag/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."

/obj/item/storage/backpack/duffelbag/mining_conscript/PopulateContents()
	new /obj/item/pickaxe/mini(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/encryptionkey/headset_mining(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/card/mining_access_card(src)

#undef VENDING_WEAPON
#undef VENDING_UPGRADE
#undef VENDING_TOOL
#undef VENDING_MINEBOT
#undef VENDING_MECHA
#undef VENDING_EQUIPMENT
#undef VENDING_MEDS
#undef VENDING_MISC