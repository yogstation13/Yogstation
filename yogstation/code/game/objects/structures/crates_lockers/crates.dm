/obj/structure/closet/crate/sphere
	desc = "An Advanced Crate that defies all known cargo standards."
	name = "Advanced Crate"
	icon = 'yogstation/icons/obj/crates.dmi'
	icon_state = "round"

/obj/structure/closet/crate/royale/PopulateContents()
	var/droptype = rand(1, 5)
	switch(droptype)
		if(1)
			new /obj/item/ammo_box/magazine/m12g(src)
			new /obj/item/ammo_box/magazine/m12g(src)
			new /obj/item/gun/ballistic/automatic/shotgun/bulldog(src)
			new /obj/item/clothing/suit/armor/riot(src)

		if(2)
			new /obj/item/clothing/suit/fire/firefighter(src)
			new /obj/item/clothing/mask/gas(src)
			new /obj/item/tank/internals/oxygen/red(src)
			new /obj/item/extinguisher(src)
			new /obj/item/clothing/head/hardhat/red(src)
			new /obj/item/flamethrower/full/tank(src)

		if(3)
			new /obj/item/gun/ballistic/revolver/mateba(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/clothing/suit/armor/bulletproof(src)
			new /obj/item/melee/classic_baton/telescopic(src)

		if(4)
			new /obj/item/gun/energy/e_gun(src)
			new /obj/item/gun/energy/e_gun/advtaser(src)
			new /obj/item/clothing/head/helmet/alt(src)
			new /obj/item/clothing/suit/armor/bulletproof(src)

		if(5)
			new /obj/item/reagent_containers/spray/waterflower/lube(src)
			new /obj/item/soap/syndie(src)
			new /obj/item/clothing/shoes/chameleon/noslip(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)