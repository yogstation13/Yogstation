// 5.56mm (M-90gl Rifle + NT ARG)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	wound_bonus = -40

/obj/projectile/bullet/a556/ap
	name = "5.56mm armor-piercing bullet"
	damage = 31
	armour_penetration = 50

/obj/projectile/bullet/incendiary/a556
	name = "5.56mm incendiary bullet"
	damage = 23
	fire_stacks = 2

/obj/projectile/bullet/a556/rubber
	name = "5.56mm rubber bullet"
	damage = 10
	stamina = 47
	sharpness = SHARP_NONE

// .308 (LWT-650 DMR)

/obj/projectile/bullet/m308
	name = ".308 bullet"
	speed = 0.3
	damage = 42
	wound_bonus = -40
	wound_falloff_tile = 0

/obj/projectile/bullet/m308/pen
	name = ".308 penetrator bullet"
	damage = 35
	armour_penetration = 35
	penetrations = INFINITY

// 7.62 (Nagant Rifle + K-41s DMR)

/obj/projectile/bullet/a762
	name = "7.62mm bullet"
	speed = 0.3
	damage = 60
	wound_bonus = -35
	wound_falloff_tile = 0
	demolition_mod = 1.2

/obj/projectile/bullet/a762/raze
	name = "7.62mm Raze bullet"
	damage = 40
	irradiate = 300

/obj/projectile/bullet/a762/raze/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.adjustCloneLoss(15)
	return ..()

/obj/projectile/bullet/a762/pen
	name = "7.62mm anti-material bullet"
	damage = 52
	armour_penetration = 40
	penetrations = 2 //Passes through two objects, stops on a mob or on a third object
	penetration_flags = PENETRATE_OBJECTS
	demolition_mod = 1.5 // anti-armor

/obj/projectile/bullet/a762/vulcan
	name = "7.62mm Vulcan bullet"
	damage = 47

/obj/projectile/bullet/a762/vulcan/on_hit(atom/target, blocked = FALSE) //God-forsaken mutant of explosion and incendiary code that makes it so it does an explosion basically without the throwing around
	..()
	var/turf/central_point = get_turf(target)
	playsound(loc, 'sound/effects/explosion1.ogg', 20, TRUE)
	new /obj/effect/hotspot(central_point)
	central_point.hotspot_expose(700, 50, 1)
	for(var/turf/warm_spot in RANGE_TURFS(2, central_point)) //Checks all tiles within two spaces of the center
		if(prob(50) && !isspaceturf(warm_spot) && !warm_spot.density)
			new /obj/effect/hotspot(warm_spot)
			warm_spot.hotspot_expose(700, 50, 1)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a762_enchanted
	name = "enchanted 7.62mm bullet"
	damage = 20
	stamina = 80

/obj/projectile/bullet/a762_enchanted/prehit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic())
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			qdel(src)
			return FALSE
