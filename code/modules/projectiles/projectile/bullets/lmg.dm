// C3D (Borgs)

/obj/item/projectile/bullet/c3d
	damage = 20

// Mech LMG

/obj/item/projectile/bullet/lmg
	damage = 20

// Mech FNX-99

/obj/item/projectile/bullet/incendiary/fnx99
	damage = 20

// Turrets

/obj/item/projectile/bullet/manned_turret
	damage = 20

/obj/item/projectile/bullet/syndicate_turret
	damage = 20

// 7.12x82mm (SAW)

/obj/item/projectile/bullet/mm712x82
	name = "7.12x82mm bullet"
	damage = 40
	armour_penetration = 5
	wound_bonus = -40				//hurt a lot but still mostly pointy
	wound_falloff_tile = 0

/obj/item/projectile/bullet/mm712x82/ap
	name = "7.12x82mm armor-piercing bullet"
	damage = 35
	wound_bonus = -45				//they go straight through with little damage to surrounding tissue
	armour_penetration = 60
	bare_wound_bonus = -10			//flesh wont stop these very effectively but armor might make it tumble a bit before it enters

/obj/item/projectile/bullet/mm712x82/hp
	name = "7.12x82mm hollow-point bullet"
	damage = 55
	armour_penetration = -35		//bulletproof armor almost totally stops these, but you're still getting hit in the chest by a supersonic nugget of lead
	sharpness = SHARP_EDGED
	wound_bonus = -35				//odds are you'll be shooting at someone with armor so you don't have a great chance for wounds
	bare_wound_bonus = 35			//but if they aren't protected...

/obj/item/projectile/bullet/incendiary/mm712x82
	name = "7.12x82mm incendiary bullet"
	damage = 27
	fire_stacks = 2
