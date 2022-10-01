// 5.56mm (M-90gl Carbine)

/obj/item/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	wound_bonus = -40

// 7.62 (Nagant Rifle)

/obj/item/projectile/bullet/a762
	name = "7.62 bullet"
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
