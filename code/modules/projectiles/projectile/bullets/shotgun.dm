/obj/item/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	damage = 46
	sharpness = SHARP_POINTY
	wound_bonus = -30

/obj/item/projectile/bullet/shotgun_slug/syndie
	name = "12g syndicate shotgun slug"
	damage = 60

/obj/item/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	damage = 5
	stamina = 55
	wound_bonus = 20
	sharpness = SHARP_NONE

/obj/item/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	damage = 20

/obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 5

/obj/item/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 100
	stutter = 5
	jitter = 20
	range = 7
	icon_state = "spark"
	color = "#FFFF00"

/obj/item/projectile/bullet/shotgun_meteorslug
	name = "meteorslug"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 20
	paralyze = 80
	wound_bonus = 0
	sharpness = SHARP_NONE
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/shotgun_meteorslug/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovable(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/shotgun_meteorslug/Initialize()
	. = ..()
	SpinAnimation()

/obj/item/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	damage = 25
	wound_bonus = 0

/obj/item/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/pellet
	var/tile_dropoff = 0.45
	var/tile_dropoff_s = 0.35

/obj/item/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 12
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -2.5 // low damage + additional dropoff will already curb wounding potential anything past point blank
	
/obj/item/projectile/bullet/pellet/shotgun_buckshot/syndie
	name = "syndicate buckshot pellet"
	damage = 18
	wound_bonus = 2
	bare_wound_bonus = 2
	wound_falloff_tile = -2.5

/obj/item/projectile/bullet/pellet/shotgun_flechette
	name = "flechette pellet"
	damage = 15
	wound_bonus = 4
	bare_wound_bonus = 4
	armour_penetration = 40
	tile_dropoff = 0.35 //Ranged pellet because I guess?
	wound_falloff_tile = -1

/obj/item/projectile/bullet/pellet/shotgun_clownshot
	name = "clownshot pellet"
	damage = 0
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubbershot pellet"
	damage = 3
	stamina = 14.5
	sharpness = SHARP_NONE

/obj/item/projectile/bullet/pellet/shotgun_cryoshot
	name = "cryoshot pellet"
	damage = 6
	sharpness = SHARP_NONE
	var/temperature = 100

/obj/item/projectile/bullet/pellet/shotgun_cryoshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature((temperature - M.bodytemperature))

/obj/item/projectile/bullet/shotgun_uraniumslug
	name = "depleted uranium slug"
	icon_state = "ubullet"
	damage = 26
	armour_penetration = 60 // he he funny round go through armor
	wound_bonus = -40

/obj/item/projectile/bullet/shotgun_uraniumslug/on_hit(atom/target)
	. = ..()
	if(ismob(target))
		return BULLET_ACT_FORCE_PIERCE

/obj/item/projectile/bullet/pellet/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff
	if(stamina > 0)
		stamina -= tile_dropoff_s
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/item/projectile/bullet/pellet/shotgun_improvised
	name = "improvised pellet"
	damage = 6
	wound_bonus = 0
	bare_wound_bonus = 7.5
	tile_dropoff = 0.35	//Will likely disappear anyway befoer this really matters

/obj/item/projectile/bullet/pellet/shotgun_improvised/Initialize()
	. = ..()
	range = rand(1, 8)

/obj/item/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Mech Scattershot

/obj/item/projectile/bullet/scattershot
	damage = 16

//Breaching Ammo

/obj/item/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy airlocks and windows with only a few shots, but is ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 10 //does shit damage to everything except doors and windows

/obj/item/projectile/bullet/shotgun_breaching/on_hit(atom/target)
	if(istype(target, /obj/structure/window) || istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		damage = 500 //one shot to break a window or 3 shots to breach an airlock door
	..()

/obj/item/projectile/bullet/pellet/shotgun_thundershot
	name = "thundershot pellet"
	damage = 3
	sharpness = SHARP_NONE
	hitsound = 'sound/magic/lightningbolt.ogg'

/obj/item/projectile/bullet/pellet/shotgun_thundershot/on_hit(atom/target)
	..()
	tesla_zap(target, rand(2, 3), 17500, TESLA_MOB_DAMAGE)
	return BULLET_ACT_HIT
	