//plants and shit
/datum/dungeon_room_theme/maintenance/botany
	weighted_possible_floor_types = list(
		/turf/open/floor/plating = 3, 
		/turf/open/floor/grass = 5, 
		/turf/open/floor/wood = 5
		)
	
	weighted_feature_spawn_list = list(
		/obj/machinery/hydroponics/soil = 4,
		/obj/structure/closet/secure_closet/hydroponics = 2,
		/obj/item/queen_bee = 1,
		/obj/item/seeds/random = 3,
		list(/obj/structure/table, /obj/item/reagent_containers/glass/bottle/nutrient/ez, /obj/item/reagent_containers/glass/bottle/nutrient/rh) = 1,
		list(/obj/structure/table, /obj/item/cultivator, /obj/item/hatchet) = 1,
		/obj/item/reagent_containers/glass/bottle/ammonia = 1,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 1,
		)

	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/butterfly = 3,
		/mob/living/simple_animal/cow = 2, 
		/mob/living/simple_animal/chick = 1,
		/mob/living/simple_animal/chicken = 1,
		/mob/living/simple_animal/sheep = 1
		)

/datum/dungeon_room_theme/maintenance/botany/pre_initialize()
	. = ..()
	for(var/i in 1 to 5)
		weighted_feature_spawn_list |= pick(subtypesof(/obj/item/seeds) - /obj/item/seeds/lavaland)

///mineral loot room
/datum/dungeon_room_theme/maintenance/material_storeroom
	weighted_feature_spawn_list = list(
		/obj/item/stack/rods/fifty = 2,
		/obj/item/stack/cable_coil/random = 2,
		/obj/item/stack/sheet/metal/fifty = 2,
		/obj/item/stack/sheet/glass/fifty = 2,
		/obj/item/stack/sheet/mineral/wood = 2,
		/obj/item/stack/sheet/mineral/plasma/ten = 2,
		/obj/machinery/power/port_gen/pacman = 1,
		/obj/structure/frame/machine = 2,
		/obj/structure/frame/computer = 1,
		)

/datum/dungeon_room_theme/maintenance/material_storeroom/pre_initialize()
	. = ..()
	for(var/i in 1 to 3)
		if(prob(10))
		//if i include all types of every stock part and subtype, it gets super bogged down, so one from each pool
			weighted_feature_spawn_list[/obj/item/storage/toolbox/syndicate]++
		else
			weighted_feature_spawn_list[/obj/item/storage/toolbox/mechanical]++

/datum/dungeon_room_theme/maintenance/material_storeroom/post_generate()
	. = ..()
	for(var/obj/item/stack/stack_to_randomize in dungeon_room_ref.features)
		if(stack_to_randomize.amount == 1)
			stack_to_randomize.amount = rand(1, 25)

///you work out bro?
/datum/dungeon_room_theme/maintenance/gym
	weighted_feature_spawn_list = list(
		/obj/item/reagent_containers/glass/beaker/waterbottle = 5,
		/obj/item/reagent_containers/food/snacks/bearsteak = 1,
		/obj/structure/punching_bag = 1,
		/obj/structure/weightmachine/stacklifter = 2,
		/obj/structure/closet/boxinggloves = 1,
		/obj/item/reagent_containers/glass/rag = 1,
		/obj/structure/holohoop = 1,
		/obj/item/toy/beach_ball/holoball = 1,
		//steroids are based
		/obj/item/dnainjector/strong = 1,
		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/carp = 1,
		/mob/living/simple_animal/mouse = 2,
		)

/datum/dungeon_room_theme/maintenance/gym/post_generate()
	. = ..()
	for(var/datum/weakref/mob_ref as anything in dungeon_room_ref.mobs)
		var/mob/living/simple_animal/gym_mob = mob_ref.resolve()
		if(gym_mob)
			gym_mob.faction |= "gym"
			if(istype(gym_mob, /mob/living/simple_animal/hostile/carp))
				gym_mob.name = "\improper Gym Shark"
				gym_mob.desc = "The only thing this up and coming shark hits harder than the weights is anyone who interrupts their sets."
			if(istype(gym_mob, /mob/living/simple_animal/mouse))
				gym_mob.name = "\improper Gym Rat"
				gym_mob.desc = "He's not about to settle for Gouda-nough."
				
///one man's junk is another mans... also junk
/datum/dungeon_room_theme/maintenance/junk
	weighted_feature_spawn_list = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 1,
		)
	
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 3, 
		/mob/living/simple_animal/hostile/glockroach = 2,
		/mob/living/simple_animal/mouse = 3, 
		/mob/living/simple_animal/opossum = 1,
		/mob/living/simple_animal/hostile/retaliate/goat = 1,
		)

/datum/dungeon_room_theme/maintenance/junk/pre_initialize()
	. = ..()
	weighted_feature_spawn_list |= subtypesof(/obj/item/trash)

/datum/dungeon_room_theme/maintenance/junk/post_generate()
	. = ..()
	for(var/datum/weakref/mob_ref in dungeon_room_ref.mobs)
		var/mob/living/simple_animal/trash_animal = mob_ref.resolve()
		if(trash_animal)
			trash_animal.faction |= "trash"

///doctor!
/datum/dungeon_room_theme/maintenance/medical
	weighted_possible_floor_types = list(
		/turf/open/floor/plasteel = 5,
		/turf/open/floor/plating = 4, 
		)
	weighted_feature_spawn_list = list(
		/obj/structure/bed/roller = 2,
		/obj/structure/table/optable = 1,
		/obj/machinery/iv_drip = 2,
		/obj/machinery/stasis = 1,
		/obj/machinery/sleeper = 1,
	)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/zombie = 3,
		/mob/living/simple_animal/bot/medbot = 1
		)

/datum/dungeon_room_theme/maintenance/medical/pre_initialize()
	. = ..()
	var/list/pills_here = list(
		/obj/structure/table, 
		pick(subtypesof(/obj/item/reagent_containers/pill)), 
		pick(subtypesof(/obj/item/reagent_containers/pill)), 
		pick(subtypesof(/obj/item/reagent_containers/pill)))
	weighted_feature_spawn_list += list(pills_here)

	var/list/operating_table = list(/obj/structure/table)
	switch(rand(1,20))
		if(1 to 2)
			//full set with the drip
			operating_table += /obj/item/storage/backpack/duffelbag/med/surgery
		if(3 to 5)
			//come on baby give me the mini e-sword
			operating_table += pick(/obj/item/scalpel/advanced, /obj/item/retractor/advanced, /obj/item/cautery/advanced)
		if(6 to 10)
			//everything you need
			operating_table |= list(/obj/item/scalpel, /obj/item/retractor, /obj/item/cautery, /obj/item/circular_saw, /obj/item/bonesetter)
		if(11 to 20)
			//the absolute basics and sterilizine for when you try to cut open their skull with a scalpel
			operating_table |= list(/obj/item/scalpel, /obj/item/retractor, /obj/item/cautery, /obj/item/reagent_containers/medspray/sterilizine)
	
	weighted_feature_spawn_list += list(operating_table)

/datum/dungeon_room_theme/maintenance/medical/post_generate()
	. = ..()
	for(var/datum/weakref/mob_ref in dungeon_room_ref.mobs)
		var/mob/living/simple_animal/medical_professional = mob_ref.resolve()
		if(medical_professional)
			//I AM A SURGEON DR HAN
			medical_professional.faction |= "surgeon"
			if(istype(medical_professional, /mob/living/simple_animal/hostile/zombie) && prob(1))
				medical_professional.desc = "Oh my god he IS a surgeon..."

///we can rebuild him.
/datum/dungeon_room_theme/maintenance/robotics
	weighted_feature_spawn_list = list(
		/obj/effect/decal/cleanable/robot_debris = 2, 
		/obj/effect/decal/cleanable/oil = 3,
		/obj/item/stack/cable_coil/random = 2,
		/obj/item/weldingtool/largetank = 1,
		/obj/structure/frame/machine = 1,
		/obj/structure/frame/computer = 1,
		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/hivebot = 5, 
		/mob/living/simple_animal/hostile/hivebot/range = 2,
		/mob/living/simple_animal/hostile/hivebot/rapid = 1,
		)

/datum/dungeon_room_theme/maintenance/robotics/pre_initialize()
	. = ..()
	if(prob(25))
		//if i include all types of every stock part and subtype, it gets super bogged down, so one from each pool
		weighted_feature_spawn_list |= pick(typesof(/obj/item/storage/part_replacer/bluespace)) 
	else
		weighted_feature_spawn_list |= list(/obj/item/storage/part_replacer = 1)
	
	weighted_feature_spawn_list |= pick( (subtypesof(/mob/living/simple_animal/bot) - /mob/living/simple_animal/bot/secbot/grievous) )
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/borg/upgrade) - typesof(/obj/item/borg/upgrade/modkit))
	//all wrecks except the god damn ones that explode upon existing
	weighted_feature_spawn_list |= pick(subtypesof(/obj/structure/mecha_wreckage) - list(/obj/structure/mecha_wreckage/gygax/dark, /obj/structure/mecha_wreckage/mauler))
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/stock_parts/capacitor))
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/stock_parts/scanning_module))
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/stock_parts/manipulator))
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/stock_parts/micro_laser))
	weighted_feature_spawn_list |= pick(subtypesof(/obj/item/stock_parts/matter_bin))

///this is the best room, unless you hate spiders, then it's the worst.
/datum/dungeon_room_theme/maintenance/spiders
	weighted_feature_spawn_list = list(
		/obj/structure/spider/stickyweb = 5, 
		/obj/structure/spider/cocoon = 5,
		/obj/structure/spider/spiderling = 2,
		)
	
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/poison/giant_spider = 10,
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter = 4,
		/mob/living/simple_animal/hostile/poison/giant_spider/ice = 2,
		)

///powergamers... even in the backrooms...
/datum/dungeon_room_theme/maintenance/xenobio
	weighted_possible_floor_types = list(
		/turf/open/floor/plasteel/dark = 3,
		/turf/open/floor/plasteel = 5,
		/turf/open/floor/plating = 3, 
		)
	
	weighted_feature_spawn_list = list(
		/obj/machinery/processor/slime = 1,
		/obj/item/extinguisher = 2,
		list(/obj/structure/table, /obj/item/slime_extract/grey, /obj/item/storage/box/monkeycubes, /obj/item/reagent_containers/syringe/plasma) = 1,
		list(/obj/structure/table, /obj/item/reagent_containers/glass/beaker/waterbottle, /obj/item/reagent_containers/food/snacks/monkeycube) = 1,
		/obj/structure/frame/machine = 1,
		/obj/structure/frame/computer = 1,	
		)
	
	weighted_mob_spawn_list = list(
		/mob/living/carbon/monkey = 2,
		)
	
/datum/dungeon_room_theme/maintenance/xenobio/pre_initialize()
	. = ..()
	switch(rand(1,10))
		if(1)
			weighted_feature_spawn_list += pick(subtypesof(/obj/item/slimecross))
		if(2)
			weighted_feature_spawn_list += /obj/item/slime_extract/rainbow
		if(3)
			weighted_feature_spawn_list += pick(subtypesof(/obj/item/slime_extract))
		if(4 to 7)
			for(var/x in 1 to 3)
				weighted_feature_spawn_list += pick(
					/obj/item/slime_extract/grey, 
					/obj/item/slime_extract/orange, 
					/obj/item/slime_extract/purple, 
					/obj/item/slime_extract/blue,
					/obj/item/slime_extract/metal)
		else
			weighted_feature_spawn_list[/obj/item/slime_extract/grey] = 2
	
	for(var/x in 1 to 3)
		if(prob(10))
			weighted_mob_spawn_list[/mob/living/simple_animal/slime/random]++
		else
			weighted_mob_spawn_list[/mob/living/simple_animal/slime]++

///domo arigato
/datum/dungeon_room_theme/maintenance/machine_parts
	weighted_feature_spawn_list = list(
		/obj/effect/decal/cleanable/robot_debris = 2, 
		/obj/effect/decal/cleanable/oil = 3,
		/obj/item/stack/cable_coil/random = 5,
		/obj/structure/frame/machine = 3,
		/obj/structure/frame/computer = 2,
		/obj/effect/spawner/lootdrop/random_anomaly_core = 1,
		/obj/effect/mine/stun
		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/hivebot = 5, 
		/mob/living/simple_animal/hostile/hivebot/range = 2,
		/mob/living/simple_animal/hostile/hivebot/rapid = 1,
		)

/datum/dungeon_room_theme/maintenance/machine_parts/pre_initialize()
	. = ..()
	if(prob(75))
		weighted_feature_spawn_list |= pick(typesof(/obj/item/circuitboard))
	if(prob(75))
		weighted_feature_spawn_list |= pick(typesof(/obj/item/circuitboard))
	if(prob(75))
		weighted_feature_spawn_list |= pick(typesof(/obj/item/circuitboard))
	if(prob(75))
		weighted_feature_spawn_list |= pick(typesof(/obj/item/circuitboard))
	if(prob(75))
		weighted_feature_spawn_list |= pick(typesof(/obj/item/circuitboard))
	

///dead money reference except I couldnt add father elijah
/datum/dungeon_room_theme/maintenance/bank
	weighted_feature_spawn_list = list(
		/obj/structure/safe = 1, 
		/obj/item/coin/gold = 5,
		/obj/item/coin/silver = 5,
		/obj/item/stack/sheet/mineral/gold = 10, ///this DLC is about letting go, letting go of poverty!!!
		/obj/item/stack/spacecash/c1000 = 2,
		/obj/item/stack/sheet/mineral/diamond = 5
		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/hivebot/range = 2,
		)

///mama mia
/datum/dungeon_room_theme/maintenance/kitchen
	weighted_feature_spawn_list = list(
		/obj/machinery/griddle = 1,
		/obj/machinery/microwave = 1,
		/obj/structure/closet/secure_closet/freezer/fridge = 1,
		/obj/item/storage/box/donkpockets = 1,
		/obj/item/kitchen/knife = 1,
		/obj/effect/spawner/lootdrop/random_meat = 5

		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/retaliate/goat = 2
		)

///just lik the founding fathers intended
/datum/dungeon_room_theme/maintenance/ancient_armory
	weighted_possible_floor_types = list(
		/turf/open/floor/plasteel/dark = 3,
		/turf/open/floor/plasteel = 5,
		/turf/open/floor/plating = 3, 
		)
	
	weighted_feature_spawn_list = list(
		/obj/structure/filingcabinet/chestdrawer = 1,
		/obj/item/kirbyplants/random  = 2,
		list(/obj/structure/rack , /obj/item/melee/spear/plugged_musket) = 1,
		list(/obj/structure/rack , /obj/item/clothing/suit/armor/vest, /obj/item/clothing/head/helmet/riot) = 1,
		/obj/structure/frame/machine = 1,
		/obj/structure/frame/computer = 1,
		/obj/effect/mine/stun	
		)
	
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/robot/burst = 2,
		)
/datum/dungeon_room_theme/maintenance/ancient_armory/pre_initialize()

	. = ..()
	for(var/i in 1 to 3)
		if(prob(10))
			weighted_feature_spawn_list[/obj/item/kitchen/knife/combat/bone]++
		else
			weighted_feature_spawn_list[/obj/item/melee/spear/bonespear/chitinspear]++

///these don't actually spawn inside the suit storage and I think thats funny
/datum/dungeon_room_theme/maintenance/hardsuit
	weighted_feature_spawn_list = list(
		list(/obj/machinery/suit_storage_unit,/obj/item/clothing/suit/space/hardsuit/mining),
		list(/obj/machinery/suit_storage_unit,/obj/item/clothing/suit/space/hardsuit/ancient),
		list(/obj/machinery/suit_storage_unit,/obj/item/clothing/suit/space/hardsuit/engine),
		list(/obj/machinery/suit_storage_unit,/obj/item/clothing/suit/space/hardsuit/medical)
		)

	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/robot/burst = 2,
		/mob/living/simple_animal/hostile/robot/burst = 2
		)

///this gun blows so much ass using it is actually more likely to get you killed
/datum/dungeon_room_theme/maintenance/lasgun

	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/robot/burst = 2,
		/mob/living/simple_animal/hostile/robot/advanced/ranged = 1
		)

/datum/dungeon_room_theme/maintenance/lasgun/pre_initialize()
	. = ..()
	for(var/i in 1 to 5)
		if(prob(10))
			weighted_feature_spawn_list[/obj/item/gun/energy/laser/scattershot ]++
		else
			weighted_feature_spawn_list[/obj/item/melee/spear/bonespear/chitinspear]++

///lathes, nough said
/datum/dungeon_room_theme/maintenance/autolathe
	weighted_feature_spawn_list = list(
		/obj/machinery/autolathe/hacked = 1,
		/obj/machinery/autolathe = 1,
		/obj/machinery/autolathe = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1,
		/obj/item/stack/sheet/mineral/silver/fifty = 1
		)
///eskimo enemy variety, they came here for the winter
/datum/dungeon_room_theme/maintenance/eskimo
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/skeleton/eskimo = 2,
		/mob/living/simple_animal/hostile/skeleton/eskimo = 1
		)
///I really really really want to include a real chasm but god knows im not strong enough
/datum/dungeon_room_theme/maintenance/chasm_fake
	weighted_possible_floor_types = list(
		/turf/open/floor/fakepit = 3,
		/turf/open/floor/fakepit = 5,
		/turf/open/floor/fakepit= 3, 
		)
///im so adding more mines
/datum/dungeon_room_theme/maintenance/mine_room
	weighted_feature_spawn_list = list(
		/obj/effect/mine/kickmine = 1,
		/obj/effect/mine/creampie = 7,
		/obj/effect/spawner/lootdrop/random_anomaly_core = 1
		)
///mineral room 2 but with danger involved
/datum/dungeon_room_theme/maintenance/mineral_room
	weighted_feature_spawn_list = list(
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/stack/sheet/mineral/plasma = 5,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/silver = 5,
		/obj/item/stack/sheet/mineral/mythril = 1
		)
	
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 1
		)
///sus, amongus.
/datum/dungeon_room_theme/maintenance/sus_room
	weighted_feature_spawn_list = list(
		/obj/item/clothing/gloves/combat = 1,
		/obj/item/kitchen/knife/combat = 1,
		/obj/machinery/atmospherics/components/unary/vent_pump/on = 1
		)
	
	
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/retaliate/goat/suspicious = 1,
		)
///pizza tower, or spiderman 2 reference, depending on the year you time travelled from
/datum/dungeon_room_theme/maintenance/pizza_time
	weighted_feature_spawn_list = list(
		/obj/item/reagent_containers/food/snacks/pizza = 1,
		/obj/item/reagent_containers/food/snacks/pizza = 1,
		/obj/item/circuitboard/machine/griddle = 1,
		/obj/item/clothing/suit/toggle/chef = 1,
		/obj/item/clothing/suit/apron/chef = 1
		)
///cuackles played this once
/datum/dungeon_room_theme/maintenance/oxygen_included
	weighted_feature_spawn_list = list(
		/obj/structure/tank_dispenser  = 1,
		/obj/structure/tank_dispenser  = 1,
		/obj/item/tank/internals/emergency_oxygen = 3,
		/obj/item/tank/internals/emergency_oxygen/double = 1,
		/obj/item/tank/internals/emergency_oxygen/vox = 1
		)
///we couldnt afford the surgery tools
/datum/dungeon_room_theme/maintenance/medical_surgical
	weighted_possible_floor_types = list(
		/turf/open/floor/plasteel/white = 3,
		/turf/open/floor/plasteel = 5,
		/turf/open/floor/plating = 3, 
		)

	weighted_feature_spawn_list = list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/machinery/computer/operating = 1, 
		/obj/structure/table/optable = 1,
		)
