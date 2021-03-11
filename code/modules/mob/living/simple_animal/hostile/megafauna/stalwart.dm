/mob/living/simple_animal/hostile/megafauna/stalwart
	name = "stalwart"
	desc = "A graceful, floating automaton. It emits a soft hum."
	health = "3000"
	maxHealth = "3000"
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
	del_on_death = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/stalwart
	loot = list(/obj/structure/closet/crate/sphere/stalwart)
	deathmessage = "erupts into blue flame, and screeches before violently shattering."
	deathsound = 'borg_deathsound.ogg'
	internal_type = /obj/item/gps/internal/stalwart

	attack_action_types = list(/datum/action/innate/megafauna_attack/lava_nade,
							   /datum/action/innate/megafauna_attack/energy_pike,
							   /datum/action/innate/megafauna_attack/charge,
							   /datum/action/innate/megafauna_attack/backup)

/mob/living/simple_animal/hostile/megafauna/stalwart/OpenFire()
	ranged_cooldown = world.time + 120
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	if(prob(20+anger_modifier)) //Major attack
		lava_nade()
	else if(prob(20))
		charge()
	else
		if(prob(70))
			backup()
		else
			energy_pike()

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#6CA4E3", 1)
			shake_camera(M, 4, 3)

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

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/energy_pike()
	ranged_cooldown = world.time + 20
	var/turf/target_turf = get_turf(target)
	playsound(src, 'sound/effects/pop_exl.ogg', 200, 1, 2)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = Get_Angle(src, target_turf)
	if(isnum(set_angle))
		angle_to_target = set_angle
	var/static/list/stalwart_pike_angles = list(7.5, 2.5, -2.5, -7.5)
	for(var/i in stalwart_pike_angles)
		shoot_projectile(target_turf, angle_to_target + i)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/backup()
	visible_message("<span class='danger'>[src] constructs a flock of mini mechanoid!</span>")
	for(var/turf/open/H in range(src, 10))
		if(prob(25))
			new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone(H.loc)

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
	damage = 0

/mob/living/simple_animal/hostile/megafauna/stalwart/devour(mob/living/L)
	visible_message("<span class='danger'>[src] melts [L]!</span>")
	L.dust()
