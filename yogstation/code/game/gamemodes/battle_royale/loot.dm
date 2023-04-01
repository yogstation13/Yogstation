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
		/obj/item/clothing/suit/armor/vest = 5,
		/obj/item/clothing/head/helmet = 5,
		/obj/item/clothing/suit/hooded/explorer = 5,
		/obj/item/clothing/suit/space/hardsuit/mining = 5,
		/obj/item/armorpolish = 5,
		/obj/item/storage/box/syndie_kit/chameleon = 5,
		/obj/item/clothing/head/det_hat/evil = 5,
		/obj/item/clothing/suit/armor/riot = 1,
		/obj/item/clothing/head/helmet/riot = 1,
		/obj/item/clothing/suit/space/hardsuit/ert/sec = 1,
		/obj/item/clothing/suit/space/hardsuit/syndi = 1,
		/obj/item/shield/energy = 1,
		/obj/item/shield/riot = 1,
		/obj/item/clothing/suit/space/hardsuit/shielded = -5,
		/obj/item/clothing/suit/space/hardsuit/shielded/syndi = -5,
		/obj/item/clothing/suit/wizrobe/armor = -5,
		/obj/item/clothing/suit/space/hardsuit/wizard = -5,
		/obj/item/clothing/suit/space/hardsuit/carp/dragon = -5,
		/obj/item/clothing/head/helmet/space/hostile_environment = -5,
		/obj/item/clothing/suit/space/hostile_environment = -5,
		/obj/item/clothing/suit/space/hardsuit/powerarmor_advanced = 1,
		/obj/item/clothing/suit/space/hardsuit/powerarmor_t45b = 1,
		/obj/item/clothing/suit/hooded/cloak/drake = 1,
		/obj/item/clothing/suit/armor/elder_atmosian = 1,
		/obj/item/clothing/suit/space/hardsuit/elder_atmosian = -5,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal = -5,))

GLOBAL_LIST_INIT(battleroyale_weapon, list(
		/obj/item/circular_saw = 5,
		/obj/item/kitchen/knife/combat/survival = 5,
		/obj/item/pen/edagger = 5,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/flamethrower/full/tank = 1,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 1,
		/obj/item/melee/transforming/energy/sword = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1,
		/obj/item/gun/energy/laser/retro/old = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/ballistic/automatic/wt550 = 1,
		/obj/item/gun/ballistic/shotgun/riot = 1,
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact = 1,
		/obj/item/gun/ballistic/revolver = 1,
		/obj/item/gun/ballistic/automatic/pistol/deagle = 1,
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/gun/energy/beam_rifle = 1,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/mini_uzi = 1,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/tommygun = 1,
		/obj/item/gun/ballistic/shotgun/automatic/dual_tube = 1,
		/obj/item/gun/ballistic/automatic/sniper_rifle = 1,
		/obj/item/gun/ballistic/automatic/ar = 1,
		/obj/item/gun/ballistic/automatic/m90/unrestricted = 1,
		/obj/item/twohanded/dualsaber = 1,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = 1,
		/obj/item/gun/ballistic/bow/energy/syndicate = 1,
		/obj/item/melee/powerfist = 1,
		/obj/item/melee/fryingpan/bananium = 1,
		/obj/item/autosurgeon/arm/syndicate/syndie_mantis = 1,
		/obj/item/his_grace = -5,
		/obj/item/twohanded/vxtvulhammer = 1,))

GLOBAL_LIST_INIT(battleroyale_healing, list(
		/obj/item/stack/medical/bruise_pack = 5,
		/obj/item/stack/medical/ointment = 5,
		/obj/item/stack/medical/suture/emergency = 5,
		/obj/item/stack/medical/suture = 4,
		/obj/item/stack/medical/mesh = 4,
		/obj/item/stack/medical/suture/medicated = 3,
		/obj/item/stack/medical/mesh/advanced = 3,
		/obj/item/stack/medical/aloe = 3,
		/obj/item/stack/medical/poultice = 3,
		/obj/item/storage/firstaid = 2,
		/obj/item/storage/firstaid/fire = 2,
		/obj/item/storage/firstaid/brute = 2,
		/obj/item/gun/magic/rune/heal_rune = 3,
		/obj/item/reagent_containers/autoinjector/medipen/survival = 1,
		/obj/item/reagent_containers/autoinjector/mixi = 1,
		/obj/item/reagent_containers/autoinjector/derm = 1,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack = 1,
		/obj/item/reagent_containers/autoinjector/medipen/stimpack/traitor = 1,
		/obj/item/storage/firstaid/tactical = -5, //has combat defib, one of the few stun weapons
		/obj/item/organ/heart/cursed/wizard = 1,
		/obj/item/storage/pill_bottle/gummies/omnizine = 1,
		/obj/item/slimecross/stabilized/purple = 1,))

GLOBAL_LIST_INIT(battleroyale_utility, list(//bombs, explosives, anything that's not an explicit weapon, clothing piece, or healing item really
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/storage/backpack/duffelbag/syndie/c4 = 1,
		/obj/machinery/syndicatebomb = 1,
		/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 1, //more of a ranged bomb than a weapon
		/obj/item/gun/ballistic/rocketlauncher/unrestricted = 1,
		/obj/item/gun/energy/wormhole_projector/upgraded = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
		/obj/item/guardiancreator/tech/random = 1,
		/obj/item/guardiancreator/carp/random = 1,
		/obj/item/stand_arrow/safe = -5,
		/obj/item/bodypart/l_arm/robot/buster = -5,
		/obj/item/grenade/spawnergrenade/manhacks = -5,
		/obj/item/autosurgeon/cmo = 1,
		/obj/item/autosurgeon/thermal_eyes = 1,
		/obj/item/autosurgeon/xray_eyes = 1,
		/obj/item/autosurgeon/reviver = 1,
		/obj/item/autosurgeon/syndicate/spinalspeed = 1,
		/obj/item/storage/box/syndie_kit/augmentation = -5,
		/obj/item/multisurgeon/airshoes = 1,
		/obj/item/spellbook = -5,
		/obj/item/book/granter/martial/cqc = 1,
		/obj/item/book/granter/martial/carp = 1,
		/obj/item/battleroyale/martial = 1,
		/obj/item/battleroyale/martial/lizard = 1,
		/obj/item/battleroyale/martial/preternis = 1,
		/obj/item/battleroyale/martial/phytosian = 1,
		/obj/item/battleroyale/martial/plasmaman = 1,
		/obj/item/antag_spawner/nuke_ops/borg_tele/medical = 1,
		/obj/item/antag_spawner/nuke_ops/borg_tele/assault = 1,
		/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur = 1,
		/obj/item/book/granter/spell/smoke = 1,
		/obj/item/book/granter/spell/smoke/lesser = 5,
		/obj/item/book/granter/spell/knock = 1,
		/obj/item/desynchronizer = 1,
		/obj/item/teleportation_scroll/apprentice = 1,
		/obj/item/reagent_containers/glass/bottle/potion/flight = 1,
		/obj/item/battleroyale/itemspawner/construct = 1,
		/obj/item/dragons_blood = 1,
		/obj/item/slimecross/stabilized/sepia = -5,
		/obj/item/slimecross/stabilized/bluespace = -5,
		/obj/item/slimecross/stabilized/red = 1,))

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
			for(var/i in 1 to rand(2,3))
				selected = pickweightAllowZero(GLOB.battleroyale_weapon)
				new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_utility)
			new selected(src)

		if(2)//armour focus (so people can select what they want)
			for(var/i in 1 to rand(2,3))
				selected = pickweightAllowZero(GLOB.battleroyale_armour)
				new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_weapon)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_healing)
			new selected(src)

		if(3)//allrounder
			selected = pickweightAllowZero(GLOB.battleroyale_weapon)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_armour)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_healing)
			new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_utility)
			new selected(src)

		if(4)//KABOOOM AHAHAHAHAHA
			for(var/i in 1 to rand(2,5))
				selected = pickweightAllowZero(GLOB.battleroyale_utility)
				new selected(src)

		if(5)//https://www.youtube.com/watch?v=Z0Uh3OJCx3o
			for(var/i in 1 to rand(2,4))
				selected = pickweightAllowZero(GLOB.battleroyale_healing)
				new selected(src)
			selected = pickweightAllowZero(GLOB.battleroyale_armour)
			new selected(src)

/obj/structure/closet/crate/battleroyale/open(mob/living/user)
	. = ..()
	if(healing_fountain)
		new /obj/structure/healingfountain(get_turf(src))
		qdel(src)
		return
	QDEL_IN(src, 30 SECONDS)//to remove clutter after a bit

/obj/item/battleroyale
	name = "This item is created and used by the battle royale gamemode"
	desc = "This shouldn't have been spawned"

//used to grant species martial arts to other species
/obj/item/battleroyale/martial //can you feel my bias
	name = "IPC martial mutator"
	desc = "Transforms you into a blood-fueled killing machine."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/martial = /datum/martial_art/ultra_violence
	var/species = /datum/species/ipc

/obj/item/battleroyale/martial/attack_self(mob/user)
	. = ..()
	if(user.mind.martial_art.type in subtypesof(/datum/martial_art))//prevents people from learning several martial arts or swapping between them
		to_chat(user,span_warning("You already know [user.mind.martial_art.name]!"))
		return

	if(do_after(user, 6 SECONDS, user))
		var/datum/martial_art/MA = new martial
		user.set_species(species)
		MA.teach(user)
		qdel(src)

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

/obj/item/battleroyale/martial/plasmaman/attack_self(mob/user)
	. = ..()
	if(isplasmaman(user))//otherwise the poor sap suffocates
		var/obj/item/organ/lungs/debug/based = new /obj/item/organ/lungs/debug()
		based.Insert(user)

//used for bundle items
/obj/item/battleroyale/itemspawner
	name = "you shouldn't be seeing this"
	desc = "literally just to spawn multiple items"
	var/list/items = list()

/obj/item/battleroyale/itemspawner/Initialize()
	. = ..()
	for(var/obj/thing in items)
		new thing(src.loc)
	qdel(src)

/obj/item/battleroyale/itemspawner/construct
	items = list(/obj/structure/constructshell,	/obj/item/soulstone/anybody)
