/*
	General idea is it picks from the lists
	If a scale factor is supplied when spawning (i.e. during a battle royale round)
	then all weights are increased by that number and anything above the cull limit number is removed from the list
	this allows stronger items to be included as time goes on, while also removing old items

	weight logic is as such
	5  - round start stuff that only can appear on initial spawn and quickly gets culled
	0  - will start appearing rather quickly and ends up being VERY common by the end
	-5 - won't spawn until basically round end, and is pretty rare even then
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
	)
	var/list/weapon = list(
		/obj/item/circular_saw = 5,
		/obj/item/kitchen/knife/combat/survival = 5,
		/obj/item/pen/edagger = 5,
		/obj/item/gun/ballistic/automatic/toy/pistol/riot = 5,
		/obj/item/gun/ballistic/shotgun/doublebarrel/improvised = 5,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/flamethrower/full/tank = 1,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 1,
		/obj/item/melee/transforming/energy/sword = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1,
		/obj/item/gun/energy/laser/retro/old = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/ballistic/automatic/wt550 = 1,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot = 1,
		/obj/item/gun/ballistic/shotgun/riot = 1,
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/gun/ballistic/automatic/pistol/suppressed = 1,
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact = 1,
		/obj/item/gun/ballistic/revolver = 1,
		/obj/item/gun/ballistic/automatic/pistol/deagle = 1,
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 1,
		/obj/item/gun/energy/beam_rifle = 1,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/mini_uzi = 1,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/tommygun = 1,
		/obj/item/gun/ballistic/shotgun/automatic/dual_tube = 1,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/sniper_rifle = 1,
		/obj/item/gun/ballistic/automatic/ar = 1,
		/obj/item/gun/ballistic/automatic/m90/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot = 1,
	)

	var/list/healing = list(//healing, so people don't always need to ransack medbay in order to not just die
		/obj/item/storage/firstaid = 4,
		/obj/item/storage/firstaid/fire = 4,
		/obj/item/reagent_containers/autoinjector/mixi = 1,
		/obj/item/reagent_containers/autoinjector/derm = 1,
	)

	var/list/utility = list(//bombs, explosives, anything that's not an explicit weapon, clothing piece, or healing item really
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/storage/backpack/duffelbag/syndie/c4 = 1,
		/obj/machinery/syndicatebomb = 1,
		/obj/item/gun/energy/wormhole_projector/upgraded = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
		/obj/item/stand_arrow/safe = -5,
	)

/* the removed ammo from the old system, i'd rather people grab a new gun instead of stocking up on ammo because of how many ammo types we have but idk
	/obj/item/ammo_casing/a40mm(src)
	/obj/item/ammo_casing/caseless/rocket(src)
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/ammo_box/c9mm(src)
	new /obj/item/ammo_box/c10mm(src)
	new /obj/item/ammo_box/c45(src)
	new /obj/item/ammo_box/no_direct/n762(src)
	new /obj/item/ammo_box/foambox/riot
	new /obj/item/ammo_box/a40mm(src)
	new /obj/item/ammo_box/a762(src)
*/

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
