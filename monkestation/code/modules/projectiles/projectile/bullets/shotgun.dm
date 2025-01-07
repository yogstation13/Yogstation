//NEW AMMO PROJECTILES FOR SHOTGUN AMMOS
/obj/projectile/bullet/pellet/trickshot
	name = "trickshot pellet"
	damage = 6
	tile_dropoff = 0
	ricochets_max = 5
	ricochet_chance = 100
	ricochet_decay_chance = 0
	ricochet_incidence_leeway = 0
	ricochet_decay_damage = 1

/obj/projectile/bullet/uraniumpen
	name ="uranium penetrator"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "uraniumpen"
	damage = 35
	projectile_piercing = (ALL & (~PASSMOB))

/obj/projectile/bullet/pellet/beeshot
	name ="beeshot"
	damage = 6
	ricochets_max = 0
	ricochet_chance = 0
	var/spawner_type = /mob/living/basic/bee/toxin
	var/deliveryamt = 1

/obj/projectile/bullet/pellet/beeshot/on_hit(atom/target, blocked = 0, pierce_hit)			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	. = ..()
	if(!.)
		return
	if(spawner_type && deliveryamt)
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		var/list/spawned = spawn_and_random_walk(spawner_type, T, deliveryamt, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))
		afterspawn(spawned)

	qdel(src)

/obj/projectile/bullet/pellet/beeshot/proc/afterspawn(list/mob/spawned)
	return
