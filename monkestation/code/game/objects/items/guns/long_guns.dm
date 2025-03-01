// Lever gun
/obj/item/gun/ballistic/shotgun/leveraction
	name = "brush gun"
	desc = "While lever-actions have been horribly out of date for hundreds of years now, \
	putting a nicely sized hole in a man-sized target with a .45 Long round has stayed relatively timeless."
	icon_state = "brushgun"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	bolt_wording = "Lever"
	cartridge_wording = "bullet"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/levergun
	projectile_wound_bonus = 10
	projectile_damage_multiplier = 1.4
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 = CONDUCT_1
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	pb_knockback = 0

// Revolver
/obj/item/gun/ballistic/revolver/r45l
	name = "\improper .45 Long Revolver"
	desc = "A cheap .45 Long Revolver. Pray the timing keeps."
	icon_state = "45revolver"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45l
	obj_flags = UNIQUE_RENAME

	unique_reskin = list("Default" = "45revolver",
						"Cowboy" = "357colt",
						"Lucky" = "lucky" //Well do ya?
						)

// .45 (Lever Rifle and Long Revolver)

/obj/projectile/bullet/g45l/rubber
	name = ".45 Long rubber bullet"
	damage = 5
	stamina = 35
	weak_against_armour = TRUE
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/g45l
	name = ".45 Long bullet"
	damage = 25
	weak_against_armour = TRUE // High fire rate
	wound_bonus = -10
	sharpness = SHARP_EDGED
	embedding = list(embed_chance=25, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=1 SECONDS)

// .45 (Lever Rifle and Long Revolver)

/obj/item/ammo_casing/g45l
	name = ".45 Long bullet casing "
	desc = "A .45 Long bullet casing."
	caliber = CALIBER_45L
	projectile_type = /obj/projectile/bullet/g45l

/obj/item/ammo_casing/g45l/rubber
	name = ".45 Long rubber bullet casing"
	desc = "A .45 Long rubber bullet casing."
	caliber = CALIBER_45L
	projectile_type = /obj/projectile/bullet/g45l/rubber

/obj/item/ammo_box/g45l
	name = "ammo box (.45 Long Lethal)"
	desc = "This box contains .45 Long lethal cartridges."
	ammo_type = /obj/item/ammo_casing/g45l
	icon_state = "45box"
	max_ammo = 24

/obj/item/ammo_box/g45l/rubber
	name = "ammo box (.45 Long Rubber)"
	desc = "Brought to you at great expense,this box contains .45 Long rubber cartridges."
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/g45l/rubber
	max_ammo = 24

/obj/item/ammo_box/magazine/internal/cylinder/rev45l
	name = ".45 Long revolver cylinder"
	ammo_type = /obj/item/ammo_casing/g45l
	caliber = CALIBER_45L
	max_ammo = 6
