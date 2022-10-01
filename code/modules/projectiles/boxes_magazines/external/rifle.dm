//Surplus Carbine

/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus carbine."
	icon_state = "75-8"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon()
	..()
	if(ammo_count())
		icon_state = "75-8"
	else
		icon_state = "75-0"

//M-90gl Rifle

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	desc = "A 30-round toploading magazine filled with 5.56 rounds, designed for the M-90gl Rifle."
	icon_state = "5.56m-30"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30

/obj/item/ammo_box/magazine/m556/update_icon()
	..()
	icon_state = "5.56m[sprite_designation]-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/m556/ap
	name = "toploader magazine (Armor-Piercing 5.56mm)"
	desc = "A 30-round toploading magazine filled with armor-piercing 5.56 rounds, designed for the M-90gl Rifle. \
			These rounds sacrifice some stopping power for bypassing standard protective equipment."
	icon_state = "5.56mA-30"
	ammo_type = /obj/item/ammo_casing/a556/ap
	sprite_designation = "A"

/obj/item/ammo_box/magazine/m556/inc
	name = "toploader magazine (Incendiary 5.56mm)"
	desc = "A 30-round toploading magazine filled with incendiary 5.56 rounds, designed for the M-90gl Rifle. \
			These rounds do less damage but set targets ablaze."
	icon_state = "5.56mI-30"
	ammo_type = /obj/item/ammo_casing/a556/inc
	sprite_designation = "I"

//NT ARG 'Boarder' Rifle

/obj/item/ammo_box/magazine/r556
	name = "rifle magazine (5.56mm)"
	desc = "A standard 30-round magazine for the NT ARG 'Boarder' Rifle. Filled with 5.56 rounds."
	icon_state = "arg556"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30

/obj/item/ammo_box/magazine/r556/update_icon()
	..()
	if(ammo_count())
		icon_state = "arg556[sprite_designation]"
	else
		icon_state = "arg556[sprite_designation]_empty"

/obj/item/ammo_box/magazine/r556/ap
	name = "rifle magazine (Armor-Piercing 5.56mm)"
	desc = "An alternative 30-round magazine for the NT ARG 'Boarder' Rifle. Filled with AP 5.56 rounds. \
			These rounds sacrifice some stopping power for bypassing standard protective equipment."
	icon_state = "arg556A"
	ammo_type = /obj/item/ammo_casing/a556/ap
	sprite_designation = "A"

/obj/item/ammo_box/magazine/r556/inc
	name = "rifle magazine (Incendiary 5.56mm)"
	desc = "An alternative 30-round magazine for the NT ARG 'Boarder' Rifle. Filled with incendiary 5.56 rounds. \
			These rounds do less damage but set targets ablaze."
	icon_state = "arg556I"
	ammo_type = /obj/item/ammo_casing/a556/inc
	sprite_designation = "I"

/obj/item/ammo_box/magazine/r556/rubber
	name = "rifle magazine (Rubber 5.56mm)"
	desc = "An alternative 30-round magazine for the NT ARG 'Boarder' Rifle. Filled with rubber 5.56 rounds. \
			These rounds possess minimal lethality but batter and weaken targets before they collapse from exhaustion."
	icon_state = "arg556R"
	ammo_type = /obj/item/ammo_casing/a556/rubber
	sprite_designation = "R"

//LWT-650 Designated Marksman Rifle

/obj/item/ammo_box/magazine/m308
	name = "rifle magazine (.308)"
	desc = "A standard 15-round magazine for the LWT-650 DMR. Filled with .308 rounds."
	icon_state = "m308"
	ammo_type = /obj/item/ammo_casing/m308
	caliber = "m308"
	max_ammo = 15

/obj/item/ammo_box/magazine/m308/update_icon()
	..()
	if(ammo_count())
		icon_state = "m308[sprite_designation]"
	else
		icon_state = "m308[sprite_designation]_empty"

/obj/item/ammo_box/magazine/m308/pen
	name = "rifle magazine (Penetrator .308)"
	desc = "An alternative 15-round magazine for the LWT-650 DMR. Filled with penetrator .308 rounds. \
			These rounds trade some damage to puncture body armor and bodies alike."
	icon_state = "m308P"
	ammo_type = /obj/item/ammo_casing/m308/pen
	sprite_designation = "P"

/obj/item/ammo_box/magazine/m308/laser
	name = "rifle magazine (Heavy Laser .308)"
	desc = "An alternative 15-round magazine for the LWT-650 DMR. Filled with heavy laser .308 rounds. \
			These rounds fire a heavy laser rather than a standard bullet. The magazine is rechargeable like an energy weapon."
	icon_state = "m308L"
	ammo_type = /obj/item/ammo_casing/m308/laser
	sprite_designation = "L"

/obj/item/ammo_box/magazine/m308/laser/attack_self() //No popping out the "bullets"
	return
