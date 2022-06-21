/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 125
	damage_type = STAMINA


/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		paralyze = 0
		nodamage = TRUE			
	return ..()
