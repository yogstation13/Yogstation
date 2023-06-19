/*
	General idea is it picks from the lists
	If a scale factor is supplied when spawning (i.e. during a battle royale round)
	then all weights are increased by that number and anything above the cull limit number is removed from the list
	this allows stronger items to be included as time goes on, while also removing old items

	weight logic is as such
	5  - round start stuff that only can appear on initial spawn and quickly gets culled
	0  - will start appearing rather quickly and ends up being VERY common by the end
	-5 - won't spawn until literally round end, and is pretty rare even then
*/

GLOBAL_LIST_INIT(battleroyale_armour, list(
		//weight of 5 - mostly just cosmetic stuff, things to both fill weight early, and fill slots for the armor polish to be used on later
		/obj/item/clothing/suit/yogs/bikerjacket = 5,
		/obj/item/clothing/suit/yogs/varsity = 5,
		/obj/item/clothing/suit/yogs/jesus = 5,
		/obj/item/clothing/suit/hooded/spesshoodie = 5,
		/obj/item/clothing/suit/yogs/monkrobes = 5,
		/obj/item/clothing/suit/yogs/blacktrenchcoat = 5,
		/obj/item/clothing/suit/yogs/janitorcoat = 5,
		/obj/item/clothing/suit/yogs/navymiljacket = 5,
		/obj/item/clothing/suit/yogs/desertmiljacket = 5,
		/obj/item/clothing/suit/yogs/denimjacket = 5,
		/obj/item/clothing/suit/yogs/furcoat = 5,
		/obj/item/clothing/suit/yogs/pinksweater = 5,
		/obj/item/clothing/suit/yogs/bluesweater = 5,
		/obj/item/clothing/suit/yogs/blueheart = 5,
		/obj/item/clothing/suit/yogs/mintsweater = 5,
		/obj/item/clothing/suit/yogs/ntsweater = 5,
		/obj/item/clothing/suit/jacket = 5,
		/obj/item/clothing/suit/jacket/puffer/vest = 5,
		/obj/item/clothing/suit/jacket/puffer = 5,
		/obj/item/clothing/suit/jacket/letterman = 5,
		/obj/item/clothing/suit/jacket/letterman_red = 5,
		/obj/item/clothing/suit/space/fragile = 5,
		/obj/item/clothing/head/helmet/space/fragile = 5,
		/obj/item/clothing/suit/hooded/wintercoat = 5,
		/obj/item/clothing/suit/hooded/wintercoat/northern = 5, //it's a donator item, but it's my donator item so i'm adding it
		//Weight of 4 - mostly minor stats, space suits with slowdown
		/obj/item/shield/riot/buckler = 4,
		/obj/item/clothing/head/helmet/space/nasavoid = 4,
		/obj/item/clothing/suit/space/nasavoid = 4,
		/obj/item/clothing/head/helmet/space/nasavoid/old = 4,
		/obj/item/clothing/suit/space/nasavoid/old = 4,
		/obj/item/clothing/head/helmet/space = 4,
		/obj/item/clothing/suit/space = 4,
		/obj/item/clothing/suit/armor/vest/old = 4,
		/obj/item/clothing/suit/armor/vest/durathread = 4,
		/obj/item/clothing/head/beret/durathread = 4,
		//Weight of 3 - decent armour, weaker than security stuff
		/obj/item/clothing/suit/hooded/wintercoat/security = 3,
		/obj/item/clothing/suit/armor/nerd = 3,
		/obj/item/clothing/suit/space/hardsuit/carp = 3,
		/obj/item/clothing/head/helmet/durathread = 3,
		/obj/item/clothing/suit/armor/vest/russian = 3,
		/obj/item/clothing/suit/armor/vest/russian_coat = 3,
		/obj/item/clothing/head/helmet/rus_ushanka = 3,
		/obj/item/clothing/head/helmet/space/cosmonaut = 3,
		/obj/item/clothing/suit/space/cosmonaut = 3,
		//Weight of 2 - things on-par with security gear
		/obj/item/shield/riot/goliath = 2,
		/obj/item/clothing/suit/armor/vest = 2,
		/obj/item/clothing/suit/hooded/explorer = 2,
		/obj/item/armorpolish = 2,
		/obj/item/storage/box/syndie_kit/chameleon = 2,
		/obj/item/clothing/head/helmet = 2,
		/obj/item/clothing/suit/armor/bone = 2,
		/obj/item/clothing/suit/armor/tribalcoat = 2,
		/obj/item/clothing/suit/armor/vest/leather = 2,
		/obj/item/clothing/suit/armor/vest/alt = 2,
		/obj/item/clothing/suit/armor/vest/blueshirt = 2,
		/obj/item/clothing/head/helmet/roman = 2,
		/obj/item/clothing/head/helmet/skull = 2,
		/obj/item/clothing/head/helmet/rus_helmet = 2,
		//weight of 1 - things that are decently strong, but lacking in some way
		/obj/item/clothing/suit/space/hardsuit/ancient = 1,
		/obj/item/clothing/head/helmet/riot = 1,
		/obj/item/clothing/suit/armor/riot = 1,
		/obj/item/clothing/suit/hooded/cloak/goliath = 1,
		/obj/item/clothing/suit/hooded/cloak/goliath/desert = 1,
		/obj/item/clothing/suit/armor/bone/heavy = 1,
		/obj/item/clothing/suit/armor/pathfinder = 1,
		/obj/item/clothing/suit/armor/laserproof = 1,
		/obj/item/clothing/head/helmet/kasa = 1,
		/obj/effect/spawner/lootdrop/knighthelmet = 1,
		/obj/effect/spawner/lootdrop/syndiespacehelm = 1,
		/obj/effect/spawner/lootdrop/syndiespacesuit = 1,
		//weight of 0 - all round good things
		/obj/item/shield/riot = 0,
		/obj/item/clothing/suit/armor/elder_atmosian = 0,
		/obj/item/clothing/head/det_hat/evil = 0,
		/obj/item/clothing/suit/space/hardsuit/mining = 0,
		/obj/item/clothing/suit/armor/bulletproof = 0,
		/obj/item/clothing/head/helmet/space/pirate = 0,
		/obj/item/clothing/head/helmet/space/pirate/bandana = 0,
		/obj/item/clothing/suit/space/pirate = 0,
		/obj/item/clothing/head/helmet/space/freedom = 0,
		/obj/item/clothing/suit/space/freedom = 0,
		//Weight of -1 - pretty good things, leaning towards space-proof, but with decent armour (even if slowdown)
		/obj/item/shield/riot/tele = -1,
		/obj/item/clothing/suit/space/hardsuit/wizard = -1,
		/obj/item/clothing/suit/space/hardsuit/medical = -1,
		/obj/item/clothing/suit/space/hardsuit/security = -1,
		/obj/item/clothing/suit/space/hardsuit/clown = -1,
		/obj/item/clothing/suit/hooded/cloak/drake = -1,
		/obj/item/clothing/head/helmet/thunderdome = -1,
		/obj/item/clothing/head/helmet/swat = -1,
		/obj/item/clothing/suit/space/swat = -1,
		//Weight of -2 - decent armour, space suits, no slowdown or just really good stats (good enough to finish a round with)
		/obj/item/nullrod/staff = -2,
		/obj/item/clothing/suit/space/hardsuit/powerarmor_advanced = -2,
		/obj/item/clothing/suit/space/hardsuit/powerarmor_t45b = -2,
		/obj/item/clothing/suit/space/hardsuit/elder_atmosian = -2,
		/obj/item/clothing/suit/space/hardsuit/syndi = -2,
		/obj/item/clothing/suit/space/hardsuit/syndi/owl = -2,
		/obj/item/clothing/suit/space/hardsuit/swat = -2,
		/obj/item/clothing/head/helmet/space/hostile_environment = -2,
		/obj/item/clothing/suit/space/hostile_environment = -2,
		//Weight of -3 - strong suits with additional utility
		/obj/item/clothing/suit/space/hardsuit/shielded = -3,
		/obj/item/clothing/suit/space/hardsuit/shielded/syndi = -3,
		/obj/item/clothing/suit/wizrobe/armor = -3,
		//Weight of -4 - nukie level shit
		/obj/item/shield/energy = -4,
		/obj/item/clothing/suit/space/hardsuit/syndi/elite = -4,
		/obj/item/clothing/suit/space/hardsuit/carp/dragon = -4,
		//Weight of -5 - ERT level shit
		/obj/item/shield/energy/bananium = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/sec = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/engi = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/med = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/jani = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal = -5,
		//Weight of -8 - you won't see this, but if you do you become a (still-killable) god (weight of 1 after the final ring closes)
		/obj/item/clothing/suit/space/hardsuit/deathsquad = -8,
		/obj/item/clothing/suit/space/hardsuit/shielded/swat = -8,
		/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk = -8,
		))

GLOBAL_LIST_INIT(battleroyale_weapon, list(
		/obj/item/kitchen/knife/carrotshiv = 5,

		/obj/item/kitchen/knife/combat/survival = 4,
		/obj/item/twohanded/required/baseball_bat = 4,
		/obj/item/twohanded/spear = 4,

		/obj/item/pen/edagger = 3,
		/obj/item/twohanded/bigspoon = 3,

		/obj/item/kitchen/knife/combat = 2,
		/obj/item/twohanded/bonespear = 2,
		/obj/item/nullrod/hammer = 2,
		/obj/item/nullrod/tribal_knife = 2,
		/obj/item/nullrod/vibro = 2,

		/obj/item/flamethrower/full/tank = 1,
		/obj/item/twohanded/required/chainsaw = 1,
		/obj/item/twohanded/fireaxe/metal_h2_axe = 1,
		/obj/item/nullrod/whip = 1,

		/obj/item/twohanded/vxtvulhammer = 0,
		/obj/item/gun/ballistic/shotgun/riot = 0,
		/obj/item/gun/ballistic/shotgun/automatic/dual_tube = 0,
		/obj/item/gun/ballistic/revolver/detective = 0,
		/obj/item/twohanded/required/baseball_bat/homerun = 0,
		/obj/item/twohanded/fireaxe = 0,
		/obj/item/nullrod/talking = 0,

		/obj/item/melee/powerfist = -1,
		/obj/item/gun/ballistic/automatic/pistol = -1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = -1,
		/obj/item/melee/transforming/energy/sword = -1,
		/obj/item/gun/energy/laser/retro/old = -1,
		/obj/item/twohanded/required/baseball_bat/metal_bat = -1,

		/obj/item/gun/ballistic/shotgun/automatic/combat = -2,
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact = -2,
		/obj/item/gun/ballistic/automatic/wt550 = -2,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = -2,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = -2,
		/obj/item/gun/energy/laser = -2,

		/obj/item/gun/ballistic/revolver = -3,
		/obj/item/gun/ballistic/bow/energy = -3,
		/obj/item/gun/energy/laser/captain = -3,

		/obj/item/gun/ballistic/automatic/m90/unrestricted = -3,
		/obj/item/gun/ballistic/automatic/pistol/deagle = -3,
		/obj/item/gun/ballistic/automatic/ar = -3,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = -3,
		/obj/item/gun/ballistic/automatic/mini_uzi = -3,
		/obj/item/gun/ballistic/automatic/tommygun = -3,

		/obj/item/autosurgeon/arm/syndicate/syndie_mantis = -4,
		/obj/item/twohanded/dualsaber = -4,
		/obj/item/gun/energy/beam_rifle = -4,
		/obj/item/gun/ballistic/automatic/sniper_rifle = -4,

		/obj/item/melee/fryingpan/bananium = -5,
		/obj/item/his_grace = -5,
		/obj/item/twohanded/vibro_weapon = -5,
		/obj/item/twohanded/required/chainsaw/doomslayer = -5,
		/obj/item/gun/ballistic/bow/energy/ert = -5,
		))

GLOBAL_LIST_INIT(battleroyale_healing, list(//this one doesn't scale because max health doesn't scale, there's also less healing items than other items
		/obj/item/stack/medical/bruise_pack = 5,
		/obj/item/stack/medical/ointment = 5,
		/obj/item/stack/medical/suture/emergency = 5,
		/obj/item/stack/medical/suture = 5,
		/obj/item/stack/medical/mesh = 5,
		/obj/item/storage/firstaid/ancient = 4,
		/obj/item/stack/medical/suture/medicated = 4,
		/obj/item/stack/medical/mesh/advanced = 4,
		/obj/item/stack/medical/aloe = 4,
		/obj/item/stack/medical/poultice = 4,
		/obj/item/gun/magic/rune/heal_rune = 4, //for team play
		/obj/item/storage/firstaid = 3,
		/obj/item/storage/firstaid/fire = 3,
		/obj/item/storage/firstaid/brute = 3,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack = 3,
		/obj/item/storage/firstaid/advanced = 2,
		/obj/item/reagent_containers/autoinjector/medipen/survival = 2,
		/obj/item/organ/regenerative_core/legion = 2,
		/obj/item/reagent_containers/autoinjector/mixi = 2,
		/obj/item/reagent_containers/autoinjector/derm = 2,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack/traitor = 1,
		/obj/item/organ/heart/cursed/wizard = 1,
		/obj/item/storage/pill_bottle/gummies/omnizine = 1,
		/obj/item/slimecross/stabilized/purple = 1,
		))

GLOBAL_LIST_INIT(battleroyale_utility, list(//bombs, explosives, anything that's not an explicit weapon, clothing piece, or healing item really
		/obj/item/book/granter/action/spell/knock = 5,

		/obj/item/grenade/plastic/c4 = 4,
		/obj/item/storage/toolbox/mechanical = 4,
		/obj/item/gun/energy/wormhole_projector/upgraded = 3,

		/obj/item/autosurgeon/cmo = 2,
		/obj/item/book/granter/action/spell/smoke/lesser = 2,

		/obj/item/reagent_containers/glass/bottle/potion/flight = 1,
		/obj/item/autosurgeon/reviver = 1,
		/obj/item/nullrod/servoskull = 1,
		/obj/item/nullrod/staff = 1,

		/obj/item/storage/backpack/duffelbag/syndie/c4 = 0,
		/obj/item/teleportation_scroll/apprentice = 0,
		/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 0,
		/obj/item/slimecross/stabilized/red = 0,
		/obj/item/slimecross/stabilized/sepia = 0,
		/obj/item/battleroyale/martial/preternis = 0,

		/obj/item/autosurgeon/thermal_eyes = -1,
		/obj/item/autosurgeon/xray_eyes = -1,
		/obj/item/multisurgeon/airshoes = -1,
		/obj/item/nullrod/hermes = -1,

		/obj/item/storage/box/syndie_kit/augmentation = -2,
		/obj/item/grenade/syndieminibomb = -2,
		/obj/item/dragons_blood = -2,
		/obj/item/desynchronizer = -2,
		/obj/item/book/granter/martial/cqc = -2,
		/obj/item/book/granter/action/spell/smoke = -2,

		/obj/item/antag_spawner/nuke_ops/borg_tele/medical = -3,
		/obj/item/antag_spawner/nuke_ops/borg_tele/assault = -3,
		/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur = -3,
		/obj/item/battleroyale/itemspawner/construct = -3,
		/obj/item/storage/backpack/duffelbag/syndie/c4 = -3,//so they don't get fully rotated out when the 0 weight one does
		/obj/item/spellbook = -3,
		/obj/item/battleroyale/martial/phytosian = -3,
		/obj/item/battleroyale/martial/plasmaman = -3,

		/obj/item/guardiancreator/tech/random = -4,
		/obj/item/guardiancreator/carp/random = -4,
		/obj/item/autosurgeon/syndicate/spinalspeed = -4,
		/obj/item/storage/firstaid/tactical = -4, //has combat defib, one of the few stun weapons
		/obj/item/battleroyale/martial/ipc = -4,
		/obj/item/battleroyale/martial/lizard = -4,
		/obj/item/book/granter/martial/carp = -4,

		/obj/item/grenade/spawnergrenade/manhacks = -5,
		/obj/item/slimecross/stabilized/bluespace = -5,
		/obj/machinery/syndicatebomb = -5,
		/obj/item/bodypart/l_arm/robot/buster = -5,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted = -5,
		/obj/item/stand_arrow/safe = -5,
		))

/obj/structure/closet/crate/battleroyale
	name = "Supply Crate"
	icon_state = "trashcart"
	light_range = 10
	light_color = LIGHT_COLOR_YELLOW //Let it glow, let it glow
	var/healing_fountain //if it's a healing fountain instead of a loot chest

/obj/structure/closet/crate/battleroyale/PopulateContents()
	. = ..()
	var/type = rand(1,5)//for a couple different themes
	
	switch(type)//it's in two blocks so healing fountains still get reskinned but don't get items
		if(1)//weapon focus (to fuel the fight)
			name = "Weapons Supply Crate"
			add_atom_colour(LIGHT_COLOR_BLOOD_MAGIC, FIXED_COLOUR_PRIORITY)
		if(2)//armour focus (so people can select what they want)
			name = "Armour Supply Crate"
			add_atom_colour(LIGHT_COLOR_BLUE, FIXED_COLOUR_PRIORITY)
		if(3)//allrounder
			name = "Misc Supply Crate"
			add_atom_colour(LIGHT_COLOR_YELLOW, FIXED_COLOUR_PRIORITY)
		if(4)//KABOOOM AHAHAHAHAHA
			name = "Utility Supply Crate"
			add_atom_colour(LIGHT_COLOR_PURPLE, FIXED_COLOUR_PRIORITY)
		if(5)//https://www.youtube.com/watch?v=Z0Uh3OJCx3o
			name = "Healing Supply Crate"
			add_atom_colour(LIGHT_COLOR_GREEN, FIXED_COLOUR_PRIORITY)

	if(prob(5))
		healing_fountain = TRUE
		return

	var/selected
	switch(type)
		if(1)//weapon focus (to fuel the fight)
			for(var/i in 1 to 3)
				selected = pickweightAllowZero(GLOB.battleroyale_weapon)
				new selected(src)

		if(2)//armour focus (so people can select what they want)
			for(var/i in 1 to 3)//less than weapons because guns can run out
				selected = pickweightAllowZero(GLOB.battleroyale_armour)
				new selected(src)

		if(3)//allrounder, technically has more items than the others
			selected = pickweightAllowZero(GLOB.battleroyale_weapon)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_armour)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_healing)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_utility)
			new selected(src)

		if(4)//KABOOOM AHAHAHAHAHA
			for(var/i in 1 to 3)
				selected = pickweightAllowZero(GLOB.battleroyale_utility)
				new selected(src)

		if(5)//https://www.youtube.com/watch?v=Z0Uh3OJCx3o
			for(var/i in 1 to 3)
				selected = pickweightAllowZero(GLOB.battleroyale_healing)
				new selected(src)

/obj/structure/closet/crate/battleroyale/open(mob/living/user)
	. = ..()
	if(healing_fountain)
		new /obj/structure/healingfountain(get_turf(src))
		qdel(src)
		return
	QDEL_IN(src, 10 SECONDS)//to remove clutter after a bit

/obj/item/battleroyale
	name = "This item is created and used by the battle royale gamemode"
	desc = "This shouldn't have been spawned"

//used to grant species martial arts to other species
/obj/item/battleroyale/martial
	name = "IPC martial mutator"
	desc = "Transforms you into a blood-fueled killing machine."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/martial = /datum/martial_art/cqc
	var/species = /datum/species/polysmorph //get clowned on

/obj/item/battleroyale/martial/attack_self(mob/user)
	. = ..()
	if(user.mind.martial_art.type in subtypesof(/datum/martial_art) && !(istype(user.mind.martial_art, /datum/martial_art/cqc/under_siege)))//prevents people from learning several martial arts or swapping between them
		to_chat(user,span_warning("You already know [user.mind.martial_art.name]!"))
		return

	if(do_after(user, 6 SECONDS, user))
		var/datum/martial_art/MA = new martial
		user.set_species(species)
		MA.teach(user)
		ADD_TRAIT(user, TRAIT_NOBREATH, name)//because some species can't breathe normally
		qdel(src)

/obj/item/battleroyale/martial/ipc
	name = "IPC martial mutator"
	desc = "Transforms you into a blood-fueled killing machine."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	martial = /datum/martial_art/ultra_violence
	species = /datum/species/ipc

/obj/item/battleroyale/martial/worldbreaker
	name = "Worldbreaker martial mutator"
	desc = "Transforms you into a lumbering metal juggernaut."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "flaming_moe"
	martial = /datum/martial_art/worldbreaker
	species = /datum/species/preternis

/obj/item/battleroyale/martial/lizard
	name = "Lizard martial mutator"
	desc = "Transforms you into a scaled menace."
	icon = 'icons/obj/library.dmi'
	icon_state = "stone_tablet"
	martial = /datum/martial_art/flyingfang
	species = /datum/species/lizard

/obj/item/battleroyale/martial/preternis
	name = "Preternis martial mutator"
	desc = "Transforms you into a durable worker cyborg."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	martial = /datum/martial_art/stealth
	species = /datum/species/preternis
	
/obj/item/battleroyale/martial/phytosian
	name = "Phytosian martial mutator"
	desc = "Transforms you into a feral plant creature."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	martial = /datum/martial_art/gardern_warfare
	species = /datum/species/pod

/obj/item/battleroyale/martial/plasmaman
	name = "Plasmaman martial mutator"
	desc = "Transforms you into terrifying always-burning skeleton."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	martial = /datum/martial_art/explosive_fist
	species = /datum/species/plasmaman

//used for bundle items
/obj/item/battleroyale/itemspawner
	name = "you shouldn't be seeing this"
	desc = "literally just to spawn multiple items"
	var/list/items = list()

/obj/item/battleroyale/itemspawner/Initialize(mapload)
	. = ..()
	for(var/obj/thing in items)
		new thing(src.loc)
	qdel(src)

/obj/item/battleroyale/itemspawner/construct
	items = list(/obj/structure/constructshell,	/obj/item/soulstone/anybody)

/obj/effect/spawner/lootdrop/knighthelmet
	name = "Random knight helmet spawner"
	loot = list( //to add different colours without adding weight
		/obj/item/clothing/head/helmet/knight,
		/obj/item/clothing/head/helmet/knight/blue,
		/obj/item/clothing/head/helmet/knight/yellow,
		/obj/item/clothing/head/helmet/knight/red,
	)

/obj/effect/spawner/lootdrop/syndiespacehelm
	name = "Random syndie space helmet spawner"
	loot = list( //to add different colours without adding weight
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate/black,
		/obj/item/clothing/head/helmet/space/syndicate/black/med,
		/obj/item/clothing/head/helmet/space/syndicate/black/red,
		/obj/item/clothing/head/helmet/space/syndicate/contract,
		/obj/item/clothing/head/helmet/space/syndicate/black/engie,
	)

/obj/effect/spawner/lootdrop/syndiespacesuit
	name = "Random syndie space suit spawner"
	loot = list( //to add different colours without adding weight
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/suit/space/syndicate/black,
		/obj/item/clothing/suit/space/syndicate/black/med,
		/obj/item/clothing/suit/space/syndicate/black/red,
		/obj/item/clothing/suit/space/syndicate/contract,
		/obj/item/clothing/suit/space/syndicate/black/engie,
	)
