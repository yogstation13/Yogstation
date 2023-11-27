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
		/obj/item/nullrod/staff = 1,
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
		/obj/item/storage/toolbox/mechanical = 5,
		/obj/item/weldingtool/experimental = 5,

		/obj/item/kitchen/knife/combat/survival = 4,
		/obj/item/melee/baseball_bat = 4,
		/obj/item/melee/spear = 4,
		/obj/item/melee/spear/bonespear = 4,

		/obj/item/bigspoon = 3,
		/obj/item/kitchen/knife/combat = 3,
		/obj/item/nullrod/hammer = 3,
		/obj/item/nullrod/tribal_knife = 3,
		/obj/item/nullrod/vibro = 3,

		/obj/item/pen/red/edagger = 2,
		/obj/item/flamethrower/full/tank = 2,
		/obj/item/melee/chainsaw = 2,
		/obj/item/fireaxe/metal_h2_axe = 2,
		/obj/item/nullrod/whip = 2,

		/obj/item/gun/ballistic/shotgun/riot = 1,
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/melee/baseball_bat/homerun = 1,
		/obj/item/fireaxe = 1,
		/obj/item/nullrod/talking = 1,
		/obj/item/clothing/gloves/powerfist/filled = 1,

		/obj/item/melee/vxtvulhammer = 0,
		/obj/item/gun/ballistic/automatic/pistol = 0,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 0,
		/obj/item/melee/transforming/energy/sword = 0,
		/obj/item/gun/energy/laser/retro/old = 0,

		/obj/item/melee/baseball_bat/metal_bat = -1,
		/obj/item/melee/ghost_sword = -1, //snowballer
		/obj/item/gun/ballistic/shotgun/automatic/combat = -1,
		/obj/item/gun/energy/laser = -1,

		/obj/item/gun/ballistic/shotgun/automatic/combat/compact = -2,
		/obj/item/gun/ballistic/automatic/wt550 = -2,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = -2,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = -2,
		/obj/item/fireaxe/energy = -2, //lol, this is the energy fire axe, not the debug energy axe

		/obj/item/gun/ballistic/revolver = -3,
		/obj/item/gun/ballistic/bow/energy = -3,
		/obj/item/gun/energy/laser/captain = -3,

		/obj/item/gun/ballistic/automatic/m90/unrestricted = -3,
		/obj/item/gun/ballistic/automatic/pistol/deagle = -3,
		/obj/item/gun/ballistic/automatic/ar = -3,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = -3,
		/obj/item/gun/ballistic/automatic/mini_uzi = -3,
		/obj/item/gun/ballistic/automatic/tommygun = -3,
		/obj/item/gun/ballistic/rifle/sniper_rifle = -3, //Not a stun anymore
		/obj/item/vibro_weapon = -3, //Strong melee weapon, but not enough to be -5

		/obj/item/autosurgeon/arm/syndicate/syndie_mantis = -4,
		/obj/item/melee/dualsaber = -4,
		/obj/item/battleroyale/itemspawner/breakbow = -4, //Strong melee weapon, along with infinte arrows
		/obj/item/gun/energy/beam_rifle = -4,

		/obj/item/melee/fryingpan/bananium = -5,
		/obj/item/his_grace = -5,
		/obj/item/melee/chainsaw/doomslayer = -5,
		/obj/item/gun/ballistic/bow/energy/ert = -5,
		/obj/item/minigunpack = -5,
		/obj/item/minigunbackpack = -5,
		))

GLOBAL_LIST_INIT(battleroyale_healing, list(//this one doesn't scale because max health doesn't scale, there's also less healing items than other items
		/obj/item/stack/medical/bruise_pack = 5,
		/obj/item/stack/medical/ointment = 5,
		/obj/item/stack/medical/suture/emergency = 5,
		/obj/item/stack/medical/suture = 5,
		/obj/item/stack/medical/mesh = 5,
		/obj/item/storage/firstaid/ancient = 4,
		/obj/item/storage/pill_bottle/gummies/omnizine = 4, //While it does heal the 4 main damage types, these heal rather slowly
		/obj/item/stack/medical/suture/medicated = 4,
		/obj/item/stack/medical/mesh/advanced = 4,
		/obj/item/stack/medical/aloe = 4,
		/obj/item/stack/medical/poultice = 4,
		/obj/item/storage/firstaid = 3,
		/obj/item/storage/firstaid/fire = 3,
		/obj/item/organ/regenerative_core/legion = 3, //These expire after a bit, and take some time to use
		/obj/item/storage/firstaid/brute = 3,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack = 3,
		/obj/item/clothing/mask/cigarette/syndicate = 3,
		/obj/item/storage/firstaid/advanced = 2,
		/obj/item/reagent_containers/autoinjector/medipen/survival = 2,
		/obj/item/organ/heart/cursed/wizard = 2, //Rarely used, albiet the healing is incredibly strong
		/obj/item/reagent_containers/autoinjector/mixi = 2,
		/obj/item/reagent_containers/autoinjector/derm = 2,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack/traitor = 1,
		/obj/item/slimecross/stabilized/purple = 1,
		))

GLOBAL_LIST_INIT(battleroyale_utility, list(//bombs, explosives, anything that's not an explicit weapon, clothing piece, or healing item really
		/obj/item/storage/backpack = 5,
		/obj/item/storage/backpack/duffelbag = 5,
		/obj/item/storage/backpack/satchel = 5,
		/obj/item/storage/toolbox/mechanical = 5,

		/obj/item/grenade/plastic/c4 = 4,
		/obj/item/storage/toolbox/mechanical = 4,
		/obj/item/storage/backpack = 4,
		/obj/item/storage/backpack/duffelbag = 4,
		/obj/item/storage/backpack/satchel = 4,

		/obj/item/gun/energy/wormhole_projector/upgraded = 3,
		/obj/item/nullrod/staff = 3,
		/obj/effect/spawner/lootdrop/weakgene = 3,
		/obj/item/grenade/plastic/c4 = 3,

		/obj/item/book/granter/action/spell/smoke/lesser = 2,
		/obj/item/multisurgeon/jumpboots = 2,
		/obj/item/autosurgeon/reviver = 2,
		/obj/item/grenade/plastic/c4 = 2,
		/obj/effect/spawner/lootdrop/weakgene = 2,

		/obj/item/reagent_containers/glass/bottle/potion/flight = 1,
		/obj/item/gun/energy/gravity_gun = 1,
		/obj/item/slimecross/stabilized/red = 1,
		/obj/item/grenade/plastic/c4 = 1,

		/obj/item/teleportation_scroll/apprentice = 0,
		/obj/effect/spawner/lootdrop/ammobox = 0,
		/obj/item/warp_whistle = 0,
		/obj/item/gun/magic/staff/animate = 0, //no clue why you'd want this, but why not
		/obj/item/multisurgeon/wheelies = 0,
		/obj/item/grenade/plastic/c4 = 0, //it's c4 all the way down buddy

		/obj/item/autosurgeon/thermal_eyes = -1,
		/obj/item/autosurgeon/xray_eyes = -1,
		/obj/item/gun/magic/wand/door = -1,
		/obj/item/gun/magic/staff/door = -1,
		/obj/item/storage/backpack/duffelbag/syndie = -1,
		/obj/item/slimecross/stabilized/red = -1,
		/obj/item/autosurgeon/reviver = -1,
		/obj/effect/spawner/lootdrop/ammobox = -1,

		/obj/item/multisurgeon/airshoes = -2,
		/obj/item/grenade/syndieminibomb = -2,
		/obj/item/dragons_blood = -2,
		/obj/item/dragons_blood/refined = -2,
		/obj/item/desynchronizer = -2,
		/obj/item/book/granter/martial/cqc = -2,
		/obj/item/book/granter/action/spell/smoke = -2,
		/obj/item/battleroyale/martial/phytosian = -2,
		/obj/item/battleroyale/martial/plasmaman = -2,
		/obj/item/battleroyale/martial/lizard = -2,
		/obj/item/book/granter/action/spell/summonitem = -2,
		/obj/item/nullrod/hermes = -2,
		/obj/item/nullrod/unrestricted = -2,
		/obj/effect/spawner/lootdrop/ammobox = -2,

		/obj/item/antag_spawner/nuke_ops/borg_tele/medical = -3,
		/obj/item/antag_spawner/nuke_ops/borg_tele/assault = -3,
		/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur = -3,
		/obj/item/storage/box/syndie_kit/augmentation = -3,
		/obj/item/storage/backpack/duffelbag/syndie/c4 = -3, //C4 Is kind of useless when you have AA
		/obj/item/battleroyale/itemspawner/construct = -3,
		/obj/item/stand_arrow = -3, //possibly OP but it's 50/50 to get dusted
		/obj/item/book/granter/action/spell/forcewall = -3,
		/obj/item/antag_spawner/slaughter_demon = -3, //why the hell not
		/obj/item/antag_spawner/slaughter_demon/laughter = -3, //people still get disqualified, but they at least get to come back
		/obj/item/storage/backpack/holding = -3,
		/obj/effect/spawner/lootdrop/stronggene = -3,
		/obj/item/gun/magic/wand/resurrection = -3, //the person revived isn't able to win, but why not, maybe they help
		/obj/item/antag_spawner/contract = -3, //might be a terrible idea to add this
		/obj/item/battleroyale/extraarm = -3,

		/obj/item/guardiancreator/tech/random = -4,
		/obj/item/storage/belt/military/shadowcloak = -4, // Very strong for short bursts
		/obj/item/implanter/empshield = -4, //EMP Shields are fairly useful, especially with the now wealth of xray / thermal eyes, among others
		/obj/item/guardiancreator/carp/random = -4,
		/obj/item/bodypart/l_arm/robot/buster = -4, // Buster is strong, but most people aren't too good with it. Especially useful for closing the gap
		/obj/item/battleroyale/martial/ipc = -4,
		/obj/item/book/granter/martial/carp = -4,
		/obj/item/battleroyale/martial/worldbreaker = -4, // Shaking the ground of Moria
		/obj/item/necromantic_stone = -4,
		/obj/item/slimecross/stabilized/sepia = -4,

		/obj/item/grenade/spawnergrenade/manhacks = -5,
		/obj/item/slimecross/stabilized/bluespace = -5,
		/obj/machinery/syndicatebomb = -5,
		/obj/item/stand_arrow/safe = -5,
		/obj/item/mdrive = -5, //get out of jail free card
		/obj/item/autosurgeon/syndicate/spinalspeed = -5, // No opportunity cost speed boost

		/obj/item/storage/belt/wands/full = -7, //not quite spellbook, but some of these wands are FUCKED

		/obj/item/spellbook = -8, //literally auto-win
		))

/obj/structure/closet/crate/battleroyale
	name = "Supply Crate"
	icon_state = "trashcart"
	light_range = 5
	light_color = LIGHT_COLOR_YELLOW //Let it glow, let it glow
	dense_when_open = FALSE

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

	if(type != 5)//don't remove healing crates
		addtimer(CALLBACK(src, PROC_REF(declutter)), 6 MINUTES)//remove obsolete outscaled crates after a bit

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

	if(rand(0, 10000) == 1)
		for(var/i = 0, i < 10, i++)
			new /mob/living/simple_animal/hostile/retaliate/clown(src)// you've been clowned

/obj/structure/closet/crate/battleroyale/proc/declutter()
	if(QDELETED(src))
		return
	for(var/obj/loot in contents)
		qdel(loot)
	qdel(src)

/obj/structure/closet/crate/battleroyale/open(mob/living/user)
	. = ..()
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
	martial = /datum/martial_art/liquidator
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

/obj/item/battleroyale/itemspawner/breakbow
	items = list(/obj/item/gun/ballistic/bow/break_bow, /obj/item/storage/belt/quiver/unlimited)

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

/obj/effect/spawner/lootdrop/ammobox
	name = "Random ammo boxes"
	lootcount = 2
	loot = list( //woo i love ammo woooo
		/obj/item/storage/box/lethalshot,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/m10mm/rifle,
		/obj/item/ammo_box/magazine/v38,
		/obj/item/ammo_box/a357,
	)

//genetics lootdrops, to avoid flooding the table
/obj/effect/spawner/lootdrop/weakgene
	name = "Weak Genetics Spawner"
	loot = list(
		/obj/item/dnainjector/dwarf,
		/obj/item/dnainjector/glow,
		/obj/item/dnainjector/radproof,
		/obj/item/dnainjector/radioactive,
		/obj/item/dnainjector/insulated,
		/obj/item/dnainjector/telemut,
		/obj/item/dnainjector/heatmut,
		/obj/item/dnainjector/cryokinesis,
		/obj/item/dnainjector/firebreath,
		/obj/item/dnainjector/strong,
		/obj/item/dnainjector/fierysweat
	)

/obj/effect/spawner/lootdrop/stronggene
	name = "Strong Genetics spawner"
	loot = list( //to add different colours without adding weight
		/obj/item/dnainjector/thermal,
		/obj/item/dnainjector/xraymut,
		/obj/item/dnainjector/hulkmut,
		/obj/item/dnainjector/shock,
		/obj/item/dnainjector/lasereyesmut,
		/obj/item/dnainjector/spacemut,
		/obj/item/dnainjector/chameleonmut,
		/obj/item/dnainjector/thickskin,
		/obj/item/dnainjector/densebones,
	)

/obj/item/battleroyale/extraarm
	name = "Spare arm"
	desc = "Why don't we you give you a hand."
	icon = 'yogstation/icons/mob/human_parts.dmi'
	icon_state = "default_human_l_arm"

/obj/item/battleroyale/extraarm/attack_self(mob/user)
	. = ..()
	var/limbs = user.held_items.len
	user.change_number_of_hands(limbs+1)
	to_chat(user, "You feel more dexterous")
	qdel(src)
