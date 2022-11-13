//Bulldog Shotgun

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g syndicate buckshot)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Syndicate buckshot is more damaging than your standard buckshot."
	icon_state = "m12gb-8"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/syndie
	caliber = "shotgun"
	max_ammo = 8
	sprite_designation = "b"

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	if(ammo_count())
		icon_state = "m12g[sprite_designation]-8"
	else
		icon_state = "m12g[sprite_designation]-0"

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Taser slugs stun targets."
	icon_state = "m12gtz-8"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug
	sprite_designation = "tz"

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g syndicate slugs)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Syndicate slugs are more damaging than your standard slug."
	icon_state = "m12gslg-8"
	ammo_type = /obj/item/ammo_casing/shotgun/syndie
	sprite_designation = "slg"

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Dragon's breath is loaded with a spread of fire pellets."
	icon_state = "m12gfir-8"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath
	sprite_designation = "fir"

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Bioterror darts are filled with a mixture of high-level toxins."
	icon_state = "m12gbt-8"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror
	sprite_designation = "bt"

/obj/item/ammo_box/magazine/m12g/frag
	name = "shotgun magazine (12g frag rounds)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Frag rounds blow up on impact."
	icon_state = "m12ghe-8"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12
	sprite_designation = "he"

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12g meteor slugs)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Meteor shot blows open airlocks and knocks over people."
	icon_state = "m12grok-8"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug
	sprite_designation = "rok"

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	desc = "A drum magazine designed for the Bulldog shotgun. \
			Flechette does less damage but penetrate armor better than buckshot. More accurate, too."
	icon_state = "m12gndl-8"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette
	sprite_designation = "ndl"
