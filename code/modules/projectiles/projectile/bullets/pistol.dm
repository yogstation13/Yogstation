// 9mm (Stechkin APS)

/obj/projectile/bullet/c9mm
	name = "9mm bullet"
	damage = 20
	wound_bonus = -10

/obj/projectile/bullet/c9mm/ap
	name = "9mm armor-piercing bullet"
	damage = 18
	armour_penetration = 40

/obj/projectile/bullet/incendiary/c9mm
	name = "9mm incendiary bullet"
	damage = 13
	fire_stacks = 1

// 10mm (Stechkin)

/obj/projectile/bullet/c10mm
	name = "10mm bullet"
	damage = 30
	wound_bonus = -30

/obj/projectile/bullet/c10mm/cs
	name = "10mm caseless bullet"
	damage = 27
	speed = 0.5

/obj/projectile/bullet/c10mm/ap
	name = "10mm armor-piercing bullet"
	damage = 27
	armour_penetration = 40

/obj/projectile/bullet/c10mm/hp
	name = "10mm hollow-point bullet"
	damage = 45
	armour_penetration = -45
	sharpness = SHARP_EDGED
	wound_bonus = -25 //Do you WANT a gun that can decapitate in 4 shots for traitors?
	bare_wound_bonus = 5

/obj/projectile/bullet/c10mm/sp
	name = "10mm soporific bullet"
	damage = 30
	damage_type = STAMINA
	eyeblur = 20

/obj/projectile/bullet/c10mm/sp/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		if(L.getStaminaLoss() >= 100)
			L.Sleeping(400)
	return ..()

/obj/projectile/bullet/incendiary/c10mm
	name = "10mm incendiary bullet"
	damage = 25
	fire_stacks = 2

/obj/projectile/bullet/c10mm/emp
	name = "10mm EMP bullet"
	damage = 25

/obj/projectile/bullet/c10mm/emp/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, EMP_HEAVY, 1) //Heavy EMP on target, light EMP in tiles around
	
/obj/projectile/bullet/boltpistol
	name = "Bolt round"
	damage = 30
	armour_penetration = 10
	sharpness = SHARP_EDGED
	wound_bonus = 5

/obj/projectile/bullet/boltpistol/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2)
	return BULLET_ACT_HIT

/obj/projectile/bullet/boltpistol/admin
	damage = 100

/obj/projectile/bullet/boltpistol/admin/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message(span_danger("[M] explodes into a shower of gibs!"))
		M.gib() // its ok, its lore accurate
	return BULLET_ACT_HIT

