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

/obj/structure/closet/crate/battleroyale
	name = "Supply Crate"
	icon_state = "miningcar"
	light_range = 10
	light_color = LIGHT_COLOR_YELLOW //Let it glow, let it glow
	var/scale_factor = 0 //number to increase all weight by
	var/cull_limit = 5 //anything with a weight above this is culled rather than spawned
	var/list/armour = list( //it's spelled the correct way
		/obj/item/clothing/suit/armor/vest = 5,
		/obj/item/clothing/suit/armor/riot = 1,
		/obj/item/clothing/suit/space/hardsuit/ert/sec = 1,
		/obj/item/clothing/suit/space/hardsuit/syndi = 1,
		/obj/item/shield/energy = 1,
		/obj/item/shield/riot = 1,
		/obj/item/clothing/suit/space/space_ninja = -5,
	)
	var/list/weapon = list(
		/obj/item/circular_saw = 5,
		/obj/item/kitchen/knife/combat/survival = 5,
		/obj/item/pen/edagger = 5,
		/obj/item/gun/ballistic/shotgun/doublebarrel/improvised = 5,
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
		/obj/item/energy_katana -4,
		/obj/item/autosurgeon/arm/syndicate/syndie_mantis = 1,
	)

	var/list/healing = list(//healing, so people don't always need to ransack medbay in order to not just die
		/obj/item/storage/firstaid = 4,
		/obj/item/storage/firstaid/fire = 4,
		/obj/item/storage/firstaid/brute = 4,
		/obj/item/reagent_containers/autoinjector/mixi = 1,
		/obj/item/reagent_containers/autoinjector/derm = 1,
	)

	var/list/utility = list(//bombs, explosives, anything that's not an explicit weapon, clothing piece, or healing item really
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
		/obj/item/autosurgeon/limb/head/robot = 1,
		/obj/item/autosurgeon/limb/chest/robot = 1,
		/obj/item/autosurgeon/limb/l_arm/robot = 1,
		/obj/item/autosurgeon/limb/r_arm/robot = 1,
		/obj/item/autosurgeon/limb/l_leg/robot = 1,
		/obj/item/autosurgeon/limb/r_leg/robot = 1,
		/obj/item/multisurgeon/airshoes = 1,
		/obj/item/spellbook = -3,
		/obj/item/book/granter/martial/cqc = 1,
		/obj/item/book/granter/martial/carp = 1,
		/obj/item/battleroyale/martial = 1,
		/obj/item/battleroyale/martial/lizard = 1,
		/obj/item/battleroyale/martial/preternis = 1,
		/obj/item/battleroyale/martial/phytosian = 1,
		/obj/item/battleroyale/martial/plasmaman = 1,
	)

/obj/structure/closet/crate/battleroyale/Initialize(mapload, scaling = 0)
	. = ..()
	scale_factor = scaling

/obj/structure/closet/crate/battleroyale/PopulateContents()
	. = ..()
	if(scale_factor)//remove things based on round progression
		ItemCull()

	var/selected
	var/type = rand(1,4)//for a couple different themes
	switch(type)
		if(1)//weapon focus (to fuel the fight)
			name = "Weapons Supply Crate"
			light_color LIGHT_COLOR_BLOOD_MAGIC

			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)

		if(2)//armour focus (so people can select what they want)
			name = "Armour Supply Crate"
			light_color LIGHT_COLOR_BLUE

			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)

		if(3)//allrounder
			name = "Misc Supply Crate"

			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(weapon)
			new selected(src)
			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)

		if(4)//KABOOOM AHAHAHAHAHA (better hope the armour is explosion resistant)
			name = "Utility Supply Crate"
			light_color LIGHT_COLOR_PURPLE

			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)

		if(5)//https://www.youtube.com/watch?v=Z0Uh3OJCx3o
			name = "Healing Supply Crate"
			light_color LIGHT_COLOR_GREEN

			selected = pickweightnegative(armour)
			new selected(src)
			selected = pickweightnegative(utility)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)
			selected = pickweightnegative(healing)
			new selected(src)


/obj/structure/closet/crate/battleroyale/proc/ItemCull()
	for(var/item in armour)
		armour[item] += scale_factor
		if(armour[item] > cull_limit)
			armour -= item

	for(var/item in weapon)
		weapon[item] += scale_factor
		if(weapon[item] > cull_limit)
			weapon -= item

	for(var/item in healing)
		healing[item] += scale_factor
		if(healing[item] > cull_limit)
			healing -= item

	for(var/item in utility)
		utility[item] += scale_factor
		if(utility[item] > cull_limit)
			utility -= item

/obj/structure/closet/crate/battleroyale/open(mob/living/user)
	. = ..()
	addtimer(CALLBACK(src, .proc/qdel, src), 2 MINUTES, TIMER_UNIQUE)//to remove clutter after a bit


/obj/item/battleroyale
	name = "This item is created and used by the battle royale gamemode"
	desc = "This shouldn't have been spawned"

/obj/item/battleroyale/martial //can you feel my bias
	name = "IPC martial mutator"
	desc = "Transforms you into a blood-fueled killing machine."
	var/martial = /datum/martial_art/ultra_violence
	var/species = /datum/species/ipc

/obj/item/battleroyale/martial/attack_self(mob/user)
	. = ..()
	var/datum/martial_art/MA = new martial
	if(user.mind.has_martialart(initial(MA.id)))
		to_chat(user,span_warning("You already know [MA.name]!"))
		qdel(MA)
		return

	if(do_after(user, 5 SECONDS, user))
		user.set_species(species)
		MA.teach(user)

/obj/item/battleroyale/martial/lizard
	name = "Lizard martial mutator"
	desc = "Transforms you into a scaled menace."
	var/martial = /datum/martial_art/flyingfang
	var/species = /datum/species/lizard

/obj/item/battleroyale/martial/preternis
	name = "Preternis martial mutator"
	desc = "Transforms you into a durable worker cyborg."
	var/martial = /datum/martial_art/preternis_stealth
	var/species = /datum/species/preternis
	
/obj/item/battleroyale/martial/phytosian
	name = "Phytosian martial mutator"
	desc = "Transforms you into a feral plant creature."
	var/martial = /datum/martial_art/gardern_warfare
	var/species = /datum/species/pod

/obj/item/battleroyale/martial/plasmaman
	name = "Plasmaman martial mutator"
	desc = "Transforms you into terrifying always-burning skeleton."
	var/martial = /datum/martial_art/explosive_fist
	var/species = /datum/species/plasmaman

/obj/item/battleroyale/martial/plasmaman/attack_self(mob/user)
	. = ..()
	if(isplasmaman(user))//otherwise the poor sap suffocates
		var/obj/item/lungs/debug/based = new /obj/item/lungs/debug()
		based.Insert(user)
