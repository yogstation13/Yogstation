/obj/item/projectile/bullet/reusable/kineticspear
	name = "kinetic spear"
	desc = "A spear rigged to deliver a kinetic blast with some effect to fauna"
	damage = 5
	range = 7
	var/fauna_damage_bonus = 20
	icon = 'yogstation/icons/obj/ammo.dmi'
	icon_state = "kineticspear"
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/projectile/bullet/reusable/kineticspear/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.apply_damage(fauna_damage_bonus)
			playsound(L, 'sound/weapons/kenetic_accel.ogg', 100, 1)
	handle_drop()
