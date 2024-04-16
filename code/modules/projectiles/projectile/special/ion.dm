/obj/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	var/ion_severity = EMP_HEAVY // Heavy EMP effects that don't spread to adjacent tiles
	var/ion_range = 1

/obj/projectile/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, ion_severity, ion_range)
	return BULLET_ACT_HIT

/obj/projectile/ion/weak
	ion_severity = EMP_LIGHT // weak ions
	ion_range = 0

/obj/projectile/ion/heavy
	ion_severity = 15 // STRONG ions
	ion_range = 2
