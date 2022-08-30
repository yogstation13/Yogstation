/mob/living/simple_animal/hostile/megafauna/stalwart
	name = "stalwart"
	desc = "A graceful, floating construct. It emits a soft hum."
	health = 3000 //thicc boi
	maxHealth = 3000
	attacktext = "zaps"
	attack_sound = 'sound/weapons/resonator_blast.ogg'
	icon_state = "stalwart"
	icon_living = "stalwart"
	icon_dead = ""
	friendly = "scans"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	speak_emote = list("screeches")
	mob_biotypes = list(MOB_INORGANIC, MOB_ROBOTIC, MOB_EPIC)
	armour_penetration = 40
	melee_damage_lower = 35
	melee_damage_upper = 35
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	del_on_death = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/stalwart
	loot = list(/obj/structure/closet/crate/sphere/stalwart)
	deathmessage = "erupts into blue flame, and screeches before violently shattering."
	deathsound = 'sound/magic/castsummon.ogg'
	internal_type = /obj/item/gps/internal/stalwart
	music_component = /datum/component/music_player/battle
	music_path = /datum/music/sourced/battle/stalwart
	var/charging = FALSE
	var/revving_charge = FALSE

/mob/living/simple_animal/hostile/megafauna/stalwart/OpenFire()
	ranged_cooldown = world.time + 30
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	if(prob(20+anger_modifier)) //Major attack
		stalnade()
	else if(prob(20))
		charge()
	else
		if(prob(50))
			backup()
		else
			energy_pike()

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/telegraph()
	for(var/mob/M in range(10,src))
		shake_camera(M, 4, 3)
	playsound(src, 'sound/machines/sm/accent/delam/14.ogg', 400, 1)
	
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
		telegraph()
		bombsaway(E)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/backup()
	visible_message(span_danger("[src] warps in mini mechanoids!"))
	playsound(src, 'sound/magic/repulse.ogg', 300, 1, 2)
	for(var/turf/open/H in range(src, 3))
		if(prob(25))
			new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone(H.loc)
		if(prob(10))
			new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/ranged(H.loc)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/energy_pike()
	ranged_cooldown = world.time + 20
	dir_shots(GLOB.diagonals)
	dir_shots(GLOB.cardinals)
	SLEEP_CHECK_DEATH(10)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/magic/disable_tech.ogg', 300, 1, 2)
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
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	var/movespeed = 1
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/stalwart/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() // code stolen from chester stolen from bubblegum i am the ultimate shitcoder
	..()

/mob/living/simple_animal/hostile/megafauna/stalwart/death()
	. = ..()
	if(health > 0)
		return
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(maxHealth * MEGAFAUNA_CASH_SCALE)

//Projectiles and such

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone
	name = "mini mechanoid"
	desc = "A tiny creature made of...some kind of gemstone? It seems angry."
	icon = 'icons/mob/drone.dmi'
	speed = 5
	movement_type = GROUND
	maxHealth = 20
	health = 20
	icon_state = "drone_gem"
	icon_living = "drone_gem"
	icon_aggro = "drone_gem"
	attacktext = "rends"
	melee_damage_lower = 6
	melee_damage_upper = 10
	mob_biotypes = list(MOB_INORGANIC, MOB_ROBOTIC)
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/weapons/pierce_slow.ogg'
	speak_emote = list("buzzes")
	faction = list("mining")
	weather_immunities = list("lava","ash")

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/death), 300)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/ranged
	ranged = 1
	ranged_message = "blasts"
	icon_state = "drone_scout"
	icon_living = "drone_scout"
	icon_aggro = "drone_scout"
	ranged_cooldown_time = 30
	projectiletype = /obj/item/projectile/stalpike/weak
	projectilesound = 'sound/magic/repulse.ogg'

/obj/item/gps/internal/stalwart
	icon_state = null
	gpstag = "Ancient Signal"
	desc = "Bzz bizzop boop blip beep"
	invisibility = 100

/obj/item/projectile/stalpike
	name = "energy pike"
	icon_state = "arcane_barrage_greyscale"
	damage = 20
	armour_penetration = 100
	speed = 4
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	color = "#4851ce"

/obj/item/projectile/stalpike/weak
	name = "lesser energy pike"
	icon_state = "arcane_barrage_greyscale"
	damage = 5
	armour_penetration = 100
	speed = 6
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	color = "#9a9fdb"

/obj/item/projectile/stalnade
	name = "volatile orb"
	icon_state = "wipe"
	damage = 300
	armour_penetration = 100
	speed = 6
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/stalnade/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/temp_visual/hierophant/wall/stalwart(location)

/obj/effect/temp_visual/hierophant/wall/stalwart
	name = "azure barrier"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	duration = 100
	smooth = SMOOTH_FALSE

/mob/living/simple_animal/hostile/megafauna/stalwart/devour(mob/living/L)
	visible_message(span_danger("[src] atomizes [L]!"))
	L.dust()
