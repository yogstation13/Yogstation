/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = TRUE	//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself

/obj/effect/spawner/lootdrop/Initialize(mapload)
	..()
	if(loot && loot.len)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			if(lootspawn)
				var/atom/movable/spawned_loot = new lootspawn(loc)
				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/lootdrop/surgery_tool_advanced
	name = "Advanced surgery tool spawner"
	loot = list( // Mail loot spawner. Drop pool of advanced medical tools typically from research. Not endgame content.
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/cautery/advanced,
	)

/obj/effect/spawner/lootdrop/surgery_tool_alien
	name = "Rare surgery tool spawner"
	loot = list( // Mail loot spawner. Some sort of random and rare surgical tool. Alien tech found here.
		/obj/item/scalpel/alien,
		/obj/item/hemostat/alien,
		/obj/item/retractor/alien,
		/obj/item/circular_saw/alien,
		/obj/item/surgicaldrill/alien,
		/obj/item/cautery/alien,
	)

/obj/effect/spawner/lootdrop/memeorgans
	name = "meme organ spawner"
	lootcount = 5
	loot = list(
		/obj/item/organ/ears/penguin,
		/obj/item/organ/ears/cat,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/eyes/snail,
		/obj/item/organ/tongue/bone,
		/obj/item/organ/tongue/fly,
		/obj/item/organ/tongue/snail,
		/obj/item/organ/tongue/lizard,
		/obj/item/organ/tongue/alien,
		///obj/item/organ/tongue/ethereal,
		/obj/item/organ/tongue/robot,
		/obj/item/organ/tongue/zombie,
		/obj/item/organ/appendix,
		/obj/item/organ/liver/fly,
		/obj/item/organ/lungs/plasmaman,
		/obj/item/organ/tail/cat,
		/obj/item/organ/tail/lizard,
	)

/obj/effect/spawner/lootdrop/plushies
	name = "random plushie"
	lootcount = 1
	loot = list( // /obj/item/seeds/random is not a random seed, but an exotic seed.
		/obj/item/toy/plush/bubbleplush,
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/plush/lizardplushie,
		/obj/item/toy/plush/snakeplushie,
		/obj/item/toy/plush/nukeplushie,
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/beeplushie,
		/obj/item/toy/plush/mothplushie,
		/obj/item/toy/plush/pkplushie,
		/obj/item/toy/plush/foxplushie,
		/obj/item/toy/plush/lizard/azeel,
		/obj/item/toy/plush/blahaj,
		/obj/item/toy/plush/cdragon,
		/obj/item/toy/plush/goatplushie,
		/obj/item/toy/plush/teddybear,
		/obj/item/toy/plush/stuffedmonkey,
		/obj/item/toy/plush/inorixplushie,
		/obj/item/toy/plush/flowerbunch,
		/obj/item/toy/plush/goatplushie,
		/obj/item/toy/plush/realgoat
	)

/obj/effect/spawner/lootdrop/techshell
	name = "random techshell spawner"
	lootcount = 1
	loot = list(
		/obj/item/ammo_casing/shotgun/pulseslug,
		/obj/item/ammo_casing/shotgun/dragonsbreath,
		/obj/item/ammo_casing/shotgun/ion,
		/obj/item/ammo_casing/shotgun/frag12,
		/obj/item/ammo_casing/shotgun/laserbuckshot,
		/obj/item/ammo_casing/shotgun/thundershot,
		/obj/item/ammo_casing/shotgun/uraniumpenetrator,
		/obj/item/ammo_casing/shotgun/cryoshot
	)

/obj/effect/spawner/lootdrop/armory_contraband
	name = "armory contraband gun spawner"
	lootdoubles = FALSE

	loot = list(
				/obj/item/gun/ballistic/automatic/pistol = 8,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/ballistic/revolver/mateba,
				/obj/item/gun/ballistic/automatic/pistol/deagle
				)

/obj/effect/spawner/lootdrop/armory_contraband/metastation
	loot = list(/obj/item/gun/ballistic/automatic/pistol = 5,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/ballistic/revolver/mateba,
				/obj/item/gun/ballistic/automatic/pistol/deagle,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 3)

/obj/effect/spawner/lootdrop/gambling
	name = "gambling valuables spawner"
	loot = list(
				/obj/item/gun/ballistic/revolver/russian = 5,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
				/obj/item/toy/cards/deck/syndicate = 2
				)

/obj/effect/spawner/lootdrop/seed_rare
	name = "rare seed"
	lootcount = 5
	loot = list( // /obj/item/seeds/random is not a random seed, but an exotic seed.
		/obj/item/seeds/random = 30,
		/obj/item/seeds/liberty = 5,
		/obj/item/seeds/replicapod = 5,
		/obj/item/seeds/reishi = 5,
		/obj/item/seeds/nettle/death = 1,
		/obj/item/seeds/plump/walkingmushroom = 1,
		/obj/item/seeds/cannabis/rainbow = 1,
		/obj/item/seeds/cannabis/death = 1,
		/obj/item/seeds/cannabis/white = 1,
		/obj/item/seeds/cannabis/ultimate = 1,
		/obj/item/seeds/kudzu = 1,
		/obj/item/seeds/angel = 1,
		/obj/item/seeds/glowshroom/glowcap = 1,
		/obj/item/seeds/glowshroom/shadowshroom = 1,
	)

/obj/effect/spawner/lootdrop/grille_or_trash
	name = "maint grille or trash spawner"
	loot = list(/obj/structure/grille = 5,
			/obj/item/cigbutt = 1,
			/obj/item/trash/cheesie = 1,
			/obj/item/trash/candy = 1,
			/obj/item/trash/chips = 1,
			/obj/item/reagent_containers/food/snacks/deadmouse = 1,
			/obj/item/trash/pistachios = 1,
			/obj/item/trash/plate = 1,
			/obj/item/trash/popcorn = 1,
			/obj/item/trash/raisins = 1,
			/obj/item/trash/sosjerky = 1,
			/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
			/obj/item/trash/syndi_cakes = 1,
			/obj/item/broken_bottle = 1)

/obj/effect/spawner/lootdrop/trashbin
	name = "trash spawner"
	loot = list(/obj/item/cigbutt = 1,
			/obj/item/trash/cheesie = 1,
			/obj/item/trash/candy = 1,
			/obj/item/trash/chips = 1,
			/obj/item/reagent_containers/food/snacks/deadmouse = 1,
			/obj/item/trash/pistachios = 1,
			/obj/item/trash/plate = 1,
			/obj/item/trash/popcorn = 1,
			/obj/item/trash/raisins = 1,
			/obj/item/trash/sosjerky = 1,
			/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
			/obj/item/trash/syndi_cakes = 1,
			/obj/item/broken_bottle = 1)

/obj/effect/spawner/lootdrop/donkpockets
	name = "donk pocket box spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
			/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
			/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
			/obj/item/storage/box/donkpockets/donkpocketberry = 1,
			/obj/item/storage/box/donkpockets/donkpockethonk = 1,
		)

/obj/effect/spawner/lootdrop/tanks
	name = "reagent tank spawner"
	icon_state = "random_tanks"
	lootdoubles = FALSE

	loot = list(
			/obj/structure/reagent_dispensers/fueltank = 5,
			/obj/structure/reagent_dispensers/watertank = 5,
			/obj/structure/reagent_dispensers/watertank/high = 3,
			/obj/structure/reagent_dispensers/foamtank = 1,
		)

/obj/effect/spawner/lootdrop/tanks/lowchance
	name = "rare reagent tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 50,
			/obj/structure/reagent_dispensers/fueltank = 5,
			/obj/structure/reagent_dispensers/watertank = 5,
			/obj/structure/reagent_dispensers/watertank/high = 3,
			/obj/structure/reagent_dispensers/foamtank = 1,
		)

/obj/effect/spawner/lootdrop/tanks/midchance
	name = "common reagent tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 15,
			/obj/structure/reagent_dispensers/fueltank = 5,
			/obj/structure/reagent_dispensers/watertank = 5,
			/obj/structure/reagent_dispensers/watertank/high = 3,
			/obj/structure/reagent_dispensers/foamtank = 1,
		)

/obj/effect/spawner/lootdrop/tanks/highchance
	name = "frequent reagent tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 5,
			/obj/structure/reagent_dispensers/fueltank = 5,
			/obj/structure/reagent_dispensers/watertank = 5,
			/obj/structure/reagent_dispensers/watertank/high = 3,
			/obj/structure/reagent_dispensers/foamtank = 1,
		)

/obj/effect/spawner/lootdrop/tanks/highquality
	name = "highcap water/foam tank spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/structure/reagent_dispensers/watertank/high = 5,
			/obj/structure/reagent_dispensers/foamtank = 5,
		)

/obj/effect/spawner/lootdrop/tanks/fuelonly
	name = "guaranteed fuel tank spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/structure/reagent_dispensers/fueltank = 5,
		)

/obj/effect/spawner/lootdrop/tanks/fuelonly/lowchance
	name = "rare fuel tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 50,
			/obj/structure/reagent_dispensers/fueltank = 5,
		)

/obj/effect/spawner/lootdrop/tanks/fuelonly/midchance
	name = "common fuel tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 15,
			/obj/structure/reagent_dispensers/fueltank = 5,
		)

/obj/effect/spawner/lootdrop/tanks/fuelonly/highchance
	name = "frequent fuel tank spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 5,
			/obj/structure/reagent_dispensers/fueltank = 5,
		)

/obj/effect/spawner/lootdrop/effects/
	name = "generic effect spawner"
	icon_state = "x4"
	lootdoubles = FALSE

	loot = list(
			"" = 100,
		)

/obj/effect/spawner/lootdrop/effects/landmines
	name = "stun or explosive landmine spawner"
	icon_state = "landmine_spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 84,
			/obj/effect/mine/explosive = 1,
			/obj/effect/mine/stun = 5,
		)

/obj/effect/spawner/lootdrop/effects/landmines/safe
	name = "stun landmine spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 80,
			/obj/effect/mine/stun = 10,
		)

/obj/effect/spawner/lootdrop/effects/landmines/smart
	name = "smart landmine spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 80,
			/obj/effect/mine/stun/smart = 10,
			/obj/effect/mine/stun/smart/adv = 5,
			/obj/effect/mine/stun/smart/heavy = 5,
		)

/obj/effect/spawner/lootdrop/effects/landmines/unsafe
	name = "dangerous landmine spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 85,
			/obj/effect/mine/explosive = 10,
			/obj/effect/mine/gas/plasma = 5,
			/obj/effect/mine/gas/n2o = 5,
		)

/obj/effect/spawner/lootdrop/effects/landmines/funny
	name = "harmless landmine spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 85,
			/obj/effect/mine/sound = 10,
			/obj/effect/mine/sound/bwoink = 5,
			/obj/effect/mine/gas = 5,
		)

/obj/effect/spawner/lootdrop/effects/landmines/ancient
	name = "stun or ancient explosive landmine spawner"
	icon_state = "landmine_spawner"
	lootdoubles = FALSE

	loot = list(
			"" = 84,
			/obj/effect/mine/explosive/ancient = 1,
			/obj/effect/mine/stun = 5,
		)

/obj/effect/spawner/lootdrop/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
			/obj/item/reagent_containers/food/snacks/soup/beet,
			/obj/item/reagent_containers/food/snacks/soup/sweetpotato,
			/obj/item/reagent_containers/food/snacks/soup/stew,
			/obj/item/reagent_containers/food/snacks/soup/hotchili,
			/obj/item/reagent_containers/food/snacks/soup/nettle,
			/obj/item/reagent_containers/food/snacks/soup/meatball)
	var/salads = list(
			/obj/item/reagent_containers/food/snacks/salad/herbsalad,
			/obj/item/reagent_containers/food/snacks/salad/validsalad,
			/obj/item/reagent_containers/food/snacks/salad/fruit,
			/obj/item/reagent_containers/food/snacks/salad/jungle,
			/obj/item/reagent_containers/food/snacks/salad/aesirsalad)
	var/mains = list(
			/obj/item/reagent_containers/food/snacks/bearsteak,
			/obj/item/reagent_containers/food/snacks/enchiladas,
			/obj/item/reagent_containers/food/snacks/stewedsoymeat,
			/obj/item/reagent_containers/food/snacks/burger/bigbite,
			/obj/item/reagent_containers/food/snacks/burger/superbite,
			/obj/item/reagent_containers/food/snacks/burger/fivealarm)

/obj/effect/spawner/lootdrop/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

//Start of Yogstation change: Refactors maintenance loot.

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)

	loot = GLOB.maintenance_loot_makeshift

	switch(rand(1,10000))
		if(1)
			loot = GLOB.maintenance_loot_serious
			lootcount = 1
		if(2 to 10)
			loot = GLOB.maintenance_loot_major
			lootcount = 1
		if(11 to 100)
			loot = GLOB.maintenance_loot_moderate
			lootcount = 1
		if(101 to 1000)
			loot = GLOB.maintenance_loot_minor
			lootcount = rand(lootcount,lootcount*2)
		if(1001 to 5000)
			loot = GLOB.maintenance_loot_makeshift
			lootcount = rand(lootcount,lootcount*2)
		if(5001 to 10000)
			loot = GLOB.maintenance_loot_traditional

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		lootcount = CEILING(lootcount * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		lootcount = CEILING(lootcount * 0.5, 1)

	. = ..()
//End of Yogstation change: Refactors maintenance loot.

/obj/effect/spawner/lootdrop/maintenance/two
	name = "2 x maintenance loot spawner"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "3 x maintenance loot spawner"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/four
	name = "4 x maintenance loot spawner"
	lootcount = 4

/obj/effect/spawner/lootdrop/maintenance/five
	name = "5 x maintenance loot spawner"
	lootcount = 5

/obj/effect/spawner/lootdrop/maintenance/six
	name = "6 x maintenance loot spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/maintenance/seven
	name = "7 x maintenance loot spawner"
	lootcount = 7

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "8 x maintenance loot spawner"
	lootcount = 8

/obj/effect/spawner/lootdrop/crate_spawner
	name = "lootcrate spawner" //USE PROMO CODE "SELLOUT" FOR 20% OFF!
	lootdoubles = FALSE

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80
				)

/obj/effect/spawner/lootdrop/organ_spawner
	name = "organ spawner"
	loot = list(
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/gas = 7, //Yogstation change: plasma -> gas
		/obj/item/organ/heart/gland/pop = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
		/obj/item/organ/regenerative_core = 2)
	lootcount = 3

/obj/effect/spawner/lootdrop/two_percent_xeno_egg_spawner
	name = "2% chance xeno egg spawner"
	loot = list(
		/obj/effect/decal/remains/xeno = 49,
		/obj/effect/spawner/xeno_egg_delivery = 1)

/obj/effect/spawner/lootdrop/costume
	name = "random costume spawner"

/obj/effect/spawner/lootdrop/costume/Initialize()
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/bundle/costume))
		loot[path] = TRUE
	. = ..()

// Minor lootdrops follow

/obj/effect/spawner/lootdrop/minor/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/bowler = 1,
		/obj/item/clothing/head/that = 1)

/obj/effect/spawner/lootdrop/minor/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/kitty = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/pirate = 1,
		/obj/item/clothing/head/pirate/bandana = 1)

/obj/effect/spawner/lootdrop/minor/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	loot = list(
		/obj/item/clothing/mask/gas/cyborg = 25,
		"" = 75)

/obj/effect/spawner/lootdrop/aimodule_harmless // These shouldn't allow the AI to start butchering people
	name = "harmless AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/asimov,
				/obj/item/aiModule/core/full/asimovpp,
				/obj/item/aiModule/core/full/crewsimov,
				/obj/item/aiModule/core/full/hippocratic,
				/obj/item/aiModule/core/full/paladin_devotion,
				/obj/item/aiModule/core/full/paladin,
				/obj/item/aiModule/core/full/chapai,
				/obj/item/aiModule/core/full/silicop,
				/obj/item/aiModule/core/full/mother,
				/obj/item/aiModule/core/full/druid
				)

/obj/effect/spawner/lootdrop/aimodule_neutral // These shouldn't allow the AI to start butchering people without reason
	name = "neutral AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/ceo,
				/obj/item/aiModule/core/full/maintain,
				/obj/item/aiModule/core/full/drone,
				/obj/item/aiModule/core/full/peacekeeper,
				/obj/item/aiModule/core/full/reporter,
				/obj/item/aiModule/core/full/robocop,
				/obj/item/aiModule/core/full/liveandletlive,
				/obj/item/aiModule/core/full/hulkamania,
				/obj/item/aiModule/core/full/cowboy,
				/obj/item/aiModule/core/full/metaexperiment,
				/obj/item/aiModule/core/full/spotless,
				/obj/item/aiModule/core/full/construction,
				/obj/item/aiModule/core/full/researcher,
				/obj/item/aiModule/core/full/clown,
				/obj/item/aiModule/core/full/detective
				)

/obj/effect/spawner/lootdrop/aimodule_harmful // These will get the shuttle called
	name = "harmful AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/antimov,
				/obj/item/aiModule/core/full/balance,
				/obj/item/aiModule/core/full/tyrant,
				/obj/item/aiModule/core/full/thermurderdynamic,
				/obj/item/aiModule/core/full/siliconcollective,
				/obj/item/aiModule/core/full/damaged
				)

// Tech storage circuit board spawners

/obj/effect/spawner/lootdrop/techstorage
	name = "generic circuit board spawner"
	lootdoubles = FALSE
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/lootdrop/techstorage/service
	name = "service circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/arcade/battle,
				/obj/item/circuitboard/computer/arcade/orion_trail,
				/obj/item/circuitboard/machine/autolathe,
				/obj/item/circuitboard/computer/mining,
				/obj/item/circuitboard/machine/ore_redemption,
				/obj/item/circuitboard/machine/mining_equipment_vendor,
				/obj/item/circuitboard/machine/microwave,
				/obj/item/circuitboard/machine/chem_dispenser/drinks,
				/obj/item/circuitboard/machine/chem_dispenser/drinks/beer,
				/obj/item/circuitboard/computer/slot_machine
				)

/obj/effect/spawner/lootdrop/techstorage/rnd
	name = "RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aifixer,
				/obj/item/circuitboard/machine/rdserver,
				/obj/item/circuitboard/machine/mechfab,
				/obj/item/circuitboard/machine/circuit_imprinter/department,
				/obj/item/circuitboard/computer/teleporter,
				/obj/item/circuitboard/machine/destructive_analyzer,
				/obj/item/circuitboard/computer/rdconsole,
				/obj/item/circuitboard/computer/nanite_chamber_control,
				/obj/item/circuitboard/computer/nanite_cloud_controller,
				/obj/item/circuitboard/machine/nanite_chamber,
				/obj/item/circuitboard/machine/nanite_programmer,
				/obj/item/circuitboard/machine/nanite_program_hub
				)

/obj/effect/spawner/lootdrop/techstorage/security
	name = "security circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/secure_data,
				/obj/item/circuitboard/computer/security,
				/obj/item/circuitboard/computer/prisoner
				)

/obj/effect/spawner/lootdrop/techstorage/engineering
	name = "engineering circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/atmos_alert,
				/obj/item/circuitboard/computer/stationalert,
				/obj/item/circuitboard/computer/powermonitor
				)

/obj/effect/spawner/lootdrop/techstorage/tcomms
	name = "tcomms circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/message_monitor,
				/obj/item/circuitboard/machine/telecomms/broadcaster,
				/obj/item/circuitboard/machine/telecomms/bus,
				/obj/item/circuitboard/machine/telecomms/server,
				/obj/item/circuitboard/machine/telecomms/receiver,
				/obj/item/circuitboard/machine/telecomms/processor,
				/obj/item/circuitboard/machine/announcement_system,
				/obj/item/circuitboard/computer/comm_server,
				/obj/item/circuitboard/computer/comm_monitor
				)

/obj/effect/spawner/lootdrop/techstorage/medical
	name = "medical circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/cloning,
				/obj/item/circuitboard/machine/clonepod,
				/obj/item/circuitboard/machine/chem_dispenser,
				/obj/item/circuitboard/computer/scan_consolenew,
				/obj/item/circuitboard/computer/med_data,
				/obj/item/circuitboard/machine/smoke_machine,
				/obj/item/circuitboard/machine/chem_master,
				/obj/item/circuitboard/machine/clonescanner,
				/obj/item/circuitboard/computer/pandemic
				)

/obj/effect/spawner/lootdrop/techstorage/AI
	name = "secure AI circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aiupload,
				/obj/item/circuitboard/computer/ai_upload_download,
				/obj/item/circuitboard/computer/borgupload
				)

/obj/effect/spawner/lootdrop/techstorage/command
	name = "secure command circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/crew,
				/obj/item/circuitboard/computer/communications,
				/obj/item/circuitboard/computer/card
				)

/obj/effect/spawner/lootdrop/techstorage/RnD_secure
	name = "secure RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/mecha_control,
				/obj/item/circuitboard/computer/apc_control,
				/obj/item/circuitboard/computer/robotics
				)

/obj/effect/spawner/lootdrop/twenty_percent_drip_suit
	name = "20% incredibly fashionable outfit spawner"
	lootdoubles = FALSE

	loot = list(
		/obj/item/clothing/under/drip = 20,
		"" = 80)

/obj/effect/spawner/lootdrop/twenty_percent_drip_shoes
	name = "20% fashionable shoes spawner"
	lootdoubles = FALSE

	loot = list(
		/obj/item/clothing/shoes/drip = 20,
		"" = 80)

//Mob spawners
/obj/effect/spawner/lootdrop/mob
	icon = 'icons/mob/animal.dmi'
	icon_state = "random_kitchen"

/obj/effect/spawner/lootdrop/mob/kitchen_animal
	name = "kitchen animal"
	icon = 'icons/mob/animal.dmi'
	icon_state = "random_kitchen"
	lootdoubles = 0
	lootcount = 1
	loot = list(/mob/living/simple_animal/hostile/retaliate/goat/pete = 1,
			/mob/living/simple_animal/cow/betsy = 1,
			/mob/living/simple_animal/sheep = 1,
			/mob/living/simple_animal/sheep/shawn = 1)

/obj/effect/spawner/lootdrop/mob/marrow_weaver
	name = "40% marrow weaver spawner"
	icon = 'yogstation/icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "weaver"
	lootdoubles = 0
	lootcount = 1
	loot = list(/mob/living/simple_animal/hostile/asteroid/marrowweaver = 35,
			/mob/living/simple_animal/hostile/asteroid/marrowweaver/ice = 5,
			"" = 60)
