/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	armor_flag = ENERGY
	var/temperature = 100

/obj/projectile/temp/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_bodytemperature(((100-blocked)/100)*(temperature - L.bodytemperature)) // the new body temperature is adjusted by 100-blocked % of the delta between body temperature and the bullet's effect temperature

/obj/projectile/temp/bounce
	name = "bouncing freeze ball"
	icon_state = "pulse1" // only used by kinetic crusher
	ricochets_max = 5
	ricochet_chance = 100

/obj/projectile/temp/bounce/check_ricochet_flag(atom/A)
	return TRUE //whatever it is, we bounce on it

/obj/projectile/temp/hot
	name = "heat beam"
	temperature = 400

/obj/projectile/temp/cryo
	name = "cryo beam"
	range = 3

/obj/projectile/temp/cryo/on_range()
	var/turf/T = get_turf(src)
	if(isopenturf(T))
		var/turf/open/O = T
		O.freeze_turf()
	return ..()
