/obj/structure/closet/crate/battleroyale
	name = "Supply Crate"
	icon_state = "miningcar"
	light_range = 10
	light_color = LIGHT_COLOR_YELLOW //Let it glow, let it glow

/obj/structure/closet/crate/battleroyale/PopulateContents()
	. = ..()
	if(prob(50)) //Weapons crate
		new /obj/item/gun/ballistic/automatic/pistol(src)
		if(prob(30)) //Common
			var/num = rand(1,6)
			switch(num)
				if(1)
					new /obj/item/circular_saw(src)
					return
				if(2)
					new /obj/item/kitchen/knife/combat/survival(src)
					return
				if(3)
					new /obj/item/pen/edagger(src)
					return
				if(4)
					new /obj/item/grenade/plastic/c4(src)
					return
				if(5)
					new /obj/item/gun/ballistic/automatic/toy/pistol/riot(src)
					return
				if(6)
					new /obj/item/gun/ballistic/shotgun/doublebarrel/improvised(src)
					return
		else if(prob(30))
			var/num = rand(1,8)
			switch(num)
				if(1)
					new /obj/item/flamethrower/full/tank(src)
					return
				if(2)
					new /obj/item/gun/ballistic/shotgun/automatic/combat(src)
					return
				if(3)
					new /obj/item/gun/ballistic/automatic/pistol(src)
					return
				if(4)
					new /obj/item/melee/transforming/energy/sword(src)
					return
				if(5)
					new /obj/item/gun/ballistic/shotgun/doublebarrel(src)
					return
				if(6)
					new /obj/item/gun/energy/laser/retro/old(src)
					return
				if(7)
					new /obj/item/storage/box/syndie_kit/throwing_weapons(src)
					return
				if(8)
					new /obj/item/gun/energy/wormhole_projector/upgraded(src)
					return
		else if(prob(25))
			var/num = rand(1,8)
			switch(num)
				if(1)
					new /obj/item/gun/energy/laser(src)
					return
				if(2)
					new /obj/item/gun/ballistic/automatic/wt550(src)
					return
				if(3)
					new /obj/item/grenade/syndieminibomb(src)
					return
				if(4)
					new /obj/item/storage/backpack/duffelbag/syndie/c4(src)
					return
				if(5)
					new /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot(src)
					return
				if(6)
					new /obj/item/gun/ballistic/shotgun/riot(src)
					return
				if(7)
					new /obj/item/gun/ballistic/revolver/detective(src)
					return
				if(8)
					new /obj/item/gun/ballistic/automatic/pistol/suppressed(src)
					return
		else if(prob(10))
			var/num = rand(1,8)
			switch(num)
				if(1)
					new /obj/item/gun/ballistic/shotgun/automatic/combat/compact(src)
					return
				if(2)
					new /obj/item/gun/ballistic/revolver(src)
					return
				if(3)
					new /obj/item/gun/ballistic/automatic/pistol/deagle(src)
					return
				if(4)
					new /obj/machinery/syndicatebomb(src)
					return
				if(5)
					new /obj/item/shield/energy(src)
					return
				if(6)
					new /obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot(src)
					return
				if(7)
					new /obj/item/gun/energy/laser/captain(src)
					return
				if(8)
					new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
					new /obj/item/ammo_casing/a40mm(src)
					new /obj/item/ammo_casing/a40mm(src)
					return
		else //Legendary
			var/num = rand(1-10)
			switch(num)
				if(1)
					new /obj/item/gun/energy/beam_rifle(src)
					return
				if(2)
					new /obj/item/gun/ballistic/automatic/c20r/unrestricted(src)
					return
				if(3)
					new /obj/item/gun/ballistic/automatic/mini_uzi(src)
					return
				if(4)
					new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src)
					return
				if(5)
					new /obj/item/gun/ballistic/automatic/tommygun(src)
					return
				if(6)
					new /obj/item/gun/ballistic/shotgun/automatic/dual_tube(src)
					return
				if(7)
					new /obj/item/gun/ballistic/rocketlauncher/unrestricted(src)
					new /obj/item/ammo_casing/caseless/rocket(src)
					new /obj/item/ammo_casing/caseless/rocket(src)
					return
				if(8)
					new /obj/item/gun/ballistic/automatic/sniper_rifle(src)
					return
				if(9)
					new /obj/item/gun/ballistic/automatic/ar(src)
					return
				if(10)
					new /obj/item/gun/ballistic/automatic/m90/unrestricted(src)
					return
	else //Item crate, but you still get a gun anyway
		new /obj/item/gun/ballistic/automatic/pistol(src)
		if(prob(30)) //Common
			new /obj/item/storage/firstaid(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/ammo_box/c38(src)
			new /obj/item/clothing/suit/armor/vest(src)
			return
		else if(prob(30))
			new /obj/item/ammo_box/c9mm(src)
			new /obj/item/ammo_box/c10mm(src)
			new /obj/item/ammo_box/c45(src)
			new /obj/item/clothing/suit/armor/vest(src)
			new /obj/item/reagent_containers/autoinjector/mixi(src)
			new /obj/item/storage/firstaid(src)
			new /obj/item/shield/riot(src)
			return
		else if(prob(25))
			new /obj/item/ammo_box/a40mm(src)
			new /obj/item/ammo_box/a762(src)
			new /obj/item/reagent_containers/autoinjector/mixi(src)
			new /obj/item/reagent_containers/autoinjector/derm(src)
			new /obj/item/storage/firstaid/fire(src)
			new /obj/item/clothing/suit/armor/riot(src)
			return
		else if(prob(10))
			new /obj/item/ammo_box/n762(src)
			new /obj/item/ammo_box/foambox/riot
			new /obj/item/clothing/suit/space/hardsuit/ert/sec(src)
			new /obj/item/storage/firstaid(src)
			new /obj/item/storage/firstaid/fire(src)
			return
		else //Legendary
			new /obj/item/ammo_box/a357(src)
			new /obj/item/ammo_box/c38(src)
			new /obj/item/ammo_box/c9mm(src)
			new /obj/item/ammo_box/c10mm(src)
			new /obj/item/ammo_box/c45(src)
			new /obj/item/ammo_box/a40mm(src)
			new /obj/item/ammo_box/a762(src)
			new /obj/item/ammo_box/n762(src)
			new /obj/item/ammo_box/foambox/riot
			new /obj/item/clothing/suit/space/hardsuit/syndi(src)
			new /obj/item/storage/firstaid(src)
			new /obj/item/storage/firstaid/toxin(src)
			return
	new /obj/item/storage/toolbox/mechanical(src) //if by some fucking miracle it didn't spawn anything, give them the best weapon of all.
