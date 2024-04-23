/obj/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a84mm
	name ="\improper HEDP rocket"
	desc = "USE A WEEL GUN."
	icon_state= "84mm-hedp"
	armor_flag = BOMB
	damage = 80
	demolition_mod = 4
	armour_penetration = 100
	dismemberment = 100

/obj/projectile/bullet/a84mm/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 1, 3, 1, 0, flame_range = 4)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a84mm_he
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "missile"
	damage = 30
	demolition_mod = 4
	ricochets_max = 0 //it's a MISSILE

/obj/projectile/bullet/a84mm_he/on_hit(atom/target, blocked=0)
	..()
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, 0, 1, 2, 4)
	else
		explosion(target, 0, 0, 2, 4)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a84mm_br
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "missile"
	damage = 30
	demolition_mod = 4
	ricochets_max = 0 //it's a MISSILE
	var/sturdy = list(
	/turf/closed,
	/obj/mecha,
	/obj/machinery/door/,
	/obj/machinery/door/poddoor/shutters
	)

/obj/item/broken_missile
	name = "\improper broken missile"
	desc = "A missile that did not detonate. The tail has snapped and it is in no way fit to be used again."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "missile_broken"
	w_class = WEIGHT_CLASS_TINY


/obj/projectile/bullet/a84mm_br/on_hit(atom/target, blocked=0)
	..()
	for(var/i in sturdy)
		if(istype(target, i))
			explosion(target, 0, 1, 1, 2)
			return BULLET_ACT_HIT
	//if(istype(target, /turf/closed) || ismecha(target))
	new /obj/item/broken_missile(get_turf(src), 1)

/obj/projectile/bullet/cball
	name = "cannonball"
	icon_state = "cannonball"
	desc = "Not for bowling purposes."
	damage = 30
	demolition_mod = 20 // YARRR

/obj/projectile/bullet/cball/on_hit(atom/target, blocked=0)
	var/atom/throw_target = get_edge_target_turf(target, firer.dir)
	if(ismecha(target) || isliving(target))
		demolition_mod = 5 // woah there let's not one-shot mechs and borgs
	. = ..()
	if(!ismovable(target)) // if it's not movable then don't bother trying to throw it
		return
	var/atom/movable/movable_target = target
	if(!movable_target.anchored && !movable_target.throwing)//avoid double hits
		movable_target.throw_at(throw_target, 2, 4, firer, 3)

/obj/projectile/bullet/bolt
	name = "bolt"
	icon_state = "bolt"
	desc = "A smaller and faster rod."
	damage = 25
