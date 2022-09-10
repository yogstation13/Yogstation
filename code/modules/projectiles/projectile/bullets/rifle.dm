// 5.56mm (M-90gl Rifle + NT ARG)

/obj/item/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	wound_bonus = -40

/obj/item/projectile/bullet/a556/ap
	name = "5.56mm armor-piercing bullet"
	damage = 31
	armour_penetration = 50

/obj/item/projectile/bullet/incendiary/a556
	name = "5.56mm incendiary bullet"
	damage = 23
	fire_stacks = 2

/obj/item/projectile/bullet/a556/rubber
	name = "5.56mm rubber bullet"
	damage = 10
	stamina = 47

// .308 (LWT-650 DMR)

/obj/item/projectile/bullet/m308
	name = ".308 bullet"
	speed = 0.3
	damage = 42
	wound_bonus = -40
	wound_falloff_tile = 0

/obj/item/projectile/bullet/m308/pen
	name = ".308 penetrator bullet"
	damage = 35
	armour_penetration = 35

/obj/item/projectile/bullet/m308/pen/on_hit(atom/target)
	. = ..()
	if(ismob(target))
		return BULLET_ACT_FORCE_PIERCE

// 7.62 (Nagant Rifle)

/obj/item/projectile/bullet/a762
	name = "7.62 bullet"
	speed = 0.3
	damage = 60
	wound_bonus = -35
	wound_falloff_tile = 0

/obj/item/projectile/bullet/a762_enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80

/obj/item/projectile/bullet/a762_enchanted/prehit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			qdel(src)
			return FALSE
