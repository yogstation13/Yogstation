/mob/living/simple_animal/hostile/megafauna/stalwart
	name = "stalwart"
	desc = "A graceful, floating automaton. It emits a soft hum."
	health = 3000
	maxHealth = 3000
	attacktext = "zaps"
	attack_sound = 'sound/effects/empulse.ogg'
	icon_state = "stalwart"
	icon_living = "stalwart"
	icon_dead = ""
	friendly = "scans"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	speak_emote = list("screeches")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	del_on_ = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/stalwart
	loot = list(/obj/structure/closet/crate/sphere/stalwart)
	message = "erupts into blue flame, and screeches before violently shattering."
	sound = 'sound/voice/borg_sound.ogg'
	internal_type = /obj/item/gps/internal/stalwart
	var/charging = FALSE
	var/revving_charge = FALSE

/mob/living/simple_animal/hostile/megafauna/stalwart/OpenFire()
	ranged_cooldown = world.time + 50
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	if(prob(20+anger_modifier)) //Major attack
		stalnade()
	else if(prob(20))
		charge()
	else
		if(prob(70))
			backup()
		else
			energy_pike()

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/telegraph()
	for(var/mob/M in range(10,src))
		flash_color(M.client, "#6CA4E3", 1)
		shake_camera(M, 4, 3)
	playsound(src, 'sound/voice/borg_sound.ogg', 200, 1)
	
/mob/living/simple_animal/hostile/megafauna/stalwart/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalpike(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/bombsaway(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalnade(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire()

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/stalnade(turf/marker)
	for(var/d in dir)
		var/turf/E = get_step(src, d)
		bombsaway(E)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/backup()
	visible_message(span_danger("[src] constructs a flock of mini mechanoid!"))
	for(var/turf/open/H in range(src, 2))
		if(prob(25))
			new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone(H.loc)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/energy_pike()
	ranged_cooldown = world.time + 40
	dir_shots(GLOB.diagonals)
	dir_shots(GLOB.cardinals)
	SLEEP_CHECK_(10)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/effects/pop_expl.ogg', 200, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/charge(var/atom/chargeat = target, var/delay = 5)
	if(!chargeat)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, 2)
	if(!T)
		return
	charging = TRUE
	revving_charge = TRUE
	telegraph(src)
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_(delay)
	revving_charge = FALSE
	var/movespeed = 1
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/stalwart/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() // code stolen from chester stolen from bubblegum i am the ultimate shitcoder
	..()
	
//Projectiles and such

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone
	name = "mini mechanoid"
	desc = "It's staring at you intently. Do not taunt."
	icon_state = "drone_gem"
	faction = list("mining")
	weather_immunities = list("lava","ash")

/obj/item/gps/internal/stalwart
	icon_state = null
	gpstag = "Ancient Signal"
	desc = "Bzz bizzop boop blip beep"
	invisibility = 100

/obj/item/projectile/stalpike
	name = "energy pike"
	icon_state = "arcane_barrage"
	damage = 20
	armour_penetration = 100
	speed = 5
	eyeblur = 0
	damage_type = BURN
	pass_flags = PASSTABLE
	color = "#6CA4E3"

/obj/item/projectile/stalnade
	name = "volatile orb"
	icon_state = "wipe"
	damage = 300
	armour_penetration = 100
	speed = 1
	eyeblur = 0
	pass_flags = PASSTABLE

/obj/item/projectile/stalnade/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/temp_visual/hierophant/wall/stalwart(location)

/obj/effect/temp_visual/hierophant/wall/stalwart
	name = "azure barrier"
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	duration = 100
	smooth = SMOOTH_FALSE
	color = "#6CA4E3"

/mob/living/simple_animal/hostile/megafauna/stalwart/devour(mob/living/L)
	visible_message(span_danger("[src] melts [L]!"))
	L.dust()
