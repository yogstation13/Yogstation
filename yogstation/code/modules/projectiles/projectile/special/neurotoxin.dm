/obj/item/projectile/bullet/neurotoxin
	knockdown = 100

/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		knockdown = 0
		nodamage = TRUE
	return ..()
