/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	var/light_emp_radius = 1
	var/heavy_emp_radius = 0.5	//Effectively 1 but doesnt spread to adjacent tiles

/obj/item/projectile/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, heavy_emp_radius, light_emp_radius)
	return BULLET_ACT_HIT

/obj/item/projectile/ion/weak
	light_emp_radius = 0
	heavy_emp_radius = 0

/obj/item/projectile/ion/light
	light_emp_radius = 1
	heavy_emp_radius = 0

/obj/item/projectile/ion/heavy
	light_emp_radius = 2
	heavy_emp_radius = 2
