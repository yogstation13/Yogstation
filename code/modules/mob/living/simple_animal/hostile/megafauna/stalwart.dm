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
	rapid = 1 //How many shots per volley.
	rapid_fire_delay = 2 //Time between rapid fire shots
	del_on_death = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/stalwart
	attack_action_types = list(/datum/action/innate/megafauna_attack/spiralpikes,
							   /datum/action/innate/megafauna_attack/cardinalpikes,
							   /datum/action/innate/megafauna_attack/backup,
							   /datum/action/innate/megafauna_attack/stalnade,
							   /datum/action/innate/megafauna_attack/stalnadespiral,
							   /datum/action/innate/megafauna_attack/invulnerable)
	small_sprite_type = /datum/action/small_sprite/megafauna/stalwart
	loot = list(/obj/structure/closet/crate/sphere/stalwart)
	deathmessage = "erupts into blue flame, and screeches before violently shattering."
	deathsound = 'sound/magic/castsummon.ogg'
	internal_type = /obj/item/gps/internal/stalwart
	music_component = /datum/component/music_player/battle
	music_path = /datum/music/sourced/battle/stalwart

/datum/action/innate/megafauna_attack/spiralpikes
	name = "Resonant Spiral"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "shield"
	chosen_message = span_boldannounce("You are now firing in a spiral.")
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/cardinalpikes
	name = "Cardinal Pikes"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "launchpad_target"
	chosen_message = span_boldannounce("You are now firing in 8 directions.")
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/backup
	name = "Warp Mini Mechanoid"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "curse"
	chosen_message = span_boldannounce("You are now summoning allies.")
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/stalnade
	name = "Volatile Orb Cone"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "m_shield"
	chosen_message = span_boldannounce("You are now firing a cone of slow, high damaging projectiles.")
	chosen_attack_num = 4

/datum/action/innate/megafauna_attack/stalnadespiral
	name = "Volatile Orb Spiral"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "shield-old"
	chosen_message = span_boldannounce("You are now firing a spiral of slow, high damaging projectiles.")
	chosen_attack_num = 5

/datum/action/innate/megafauna_attack/invulnerable
	name = "Protective Shield"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "shield-red"
	chosen_message = span_boldannounce("You are now manifesting an impenetrable protective shield around yourself.")
	chosen_attack_num = 6

/mob/living/simple_animal/hostile/megafauna/stalwart/OpenFire()
	if(!client)
		switch(rand(1,4))
			if(1)
				if(health <= 1500)
					invulnerable()
				if(health <= 900)
					telegraph()
					stalnade()
				else
					telegraph()
					energy_pike()
			if(2)
				telegraph()
				sspiral_shoot()
				if(health <= 1500)
					invulnerable()
			if(3)
				telegraph()
				backup()
				if(health <= 1500)
					invulnerable()
			if(4)
				if(health <= 1500)
					invulnerable()
				if(health <= 300)
					telegraph()
					sspiral_shoot_death()
				else
					telegraph()
					sspiral_shoot()

	if(client)
		switch(chosen_attack)
			if(1)
				telegraph()
				sspiral_shoot()
			if(2)
				telegraph()
				energy_pike()
			if(3)
				telegraph()
				backup()
			if(4)
				if(health <= 900)
					telegraph()
					stalnade()
				else
					to_chat(client,span_warning("Your health is too high to use this."))
			if(5)
				if(health <= 300)
					telegraph()
					sspiral_shoot_death()
				else
					to_chat(client,span_warning("Your health is too high to use this."))
			if(6)
				if(health <= 1500)
					invulnerable()
				else
					to_chat(client,span_warning("Your health is too high to use this."))
		return



	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message(span_boldwarning("[src] engages overdrive!"))
			backup2()
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/invulnerable()
	add_atom_colour(rgb(195, 0, 255), TEMPORARY_COLOUR_PRIORITY)
	visible_message(span_boldwarning("[src] forms an impenetrable shield around itself!"))
	move_to_delay = move_to_delay * 100
	src.apply_status_effect(STATUS_EFFECT_DODGING_STALWART)
	SetRecoveryTime(0, 1 MINUTES)
	SLEEP_CHECK_DEATH(100)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#0d00c8", 1)
			shake_camera(M, 4, 3)
	playsound(src, 'sound/machines/sm/accent/delam/14.ogg', 400, 1)
	
/mob/living/simple_animal/hostile/megafauna/stalwart/proc/shoot_projectile(turf/marker, set_angle)
	playsound(src, 'sound/weapons/ionrifle.ogg', 400, 1)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalpike(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/shoot_projectile_spiral(turf/marker, set_angle)
	playsound(src, 'sound/weapons/ionrifle.ogg', 400, 1)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalpike/spiral(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/shoot_projectile_spiral_death(turf/marker, set_angle)
	playsound(src, 'sound/weapons/ionrifle.ogg', 400, 1)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalnade(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/sspiral_shoot(negative = pick(TRUE, FALSE), counter_start = 8)
	var/turf/start_turf = get_step(src, pick(GLOB.alldirs))
	var/counter = counter_start
	for(var/i in 1 to 22)
		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		shoot_projectile_spiral(start_turf, counter * 22.5)
		SLEEP_CHECK_DEATH(1)
	SetRecoveryTime(0, 8 SECONDS)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/sspiral_shoot_death(negative = pick(TRUE, FALSE), counter_start = 8)
	if(health >= 200)
		return
	else
		var/turf/start_turf = get_step(src, pick(GLOB.alldirs))
		var/counter = counter_start
		for(var/i in 1 to 8)
			if(negative)
				counter--
			else
				counter++
			if(counter > 16)
				counter = 1
			if(counter < 1)
				counter = 16
			shoot_projectile_spiral_death(start_turf, counter * 45)
			SLEEP_CHECK_DEATH(1)
		SetRecoveryTime(0, 3 SECONDS)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/bombsaway(turf/marker, set_angle)
	playsound(src, 'sound/weapons/ionrifle.ogg', 400, 1)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/stalnade(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/stalnade(set_angle)
	ranged_cooldown = world.time + 20
	var/turf/target_turf = get_turf(target)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = Get_Angle(src, target_turf)
	if(isnum(set_angle))
		angle_to_target = set_angle
	var/static/list/stalwart_bomb_shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	for(var/i in stalwart_bomb_shot_angles)
		bombsaway(target_turf, angle_to_target + i)
	SetRecoveryTime(0, 1 MINUTES)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/backup()
	visible_message(span_danger("[src] attempts to warp in mini mechanoids!"))
	playsound(src, 'sound/magic/castsummon.ogg', 300, 1, 2)
	for(var/turf/open/H in range(1, target))
		switch(rand(1,2))
			if(1)
				if(prob(20))
					var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/S = new(H.loc)
					S.GiveTarget(target)
					S.friends = friends
					S.faction = faction
			if(2)
				if(prob(10))
					var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/ranged/R = new(H.loc)
					R.GiveTarget(target)
					R.friends = friends
					R.faction = faction
	SetRecoveryTime(0, 7 SECONDS)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/backup2()
	visible_message(span_danger("[src] warps in many mini mechanoids!"))
	playsound(src, 'sound/magic/castsummon.ogg', 300, 1, 2)
	for(var/turf/open/H in range(4, target))
		if(prob(50))
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/S = new(H.loc)
			S.GiveTarget(target)
			S.friends = friends
			S.faction = faction
	SetRecoveryTime(0, 3 SECONDS)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/energy_pike()
	dir_shots(GLOB.diagonals)
	dir_shots(GLOB.cardinals)
	SLEEP_CHECK_DEATH(10)
	SetRecoveryTime(0, 3.5 SECONDS)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/magic/disable_tech.ogg', 300, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/stalwart/proc/enrage(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.mind)
			if(H.mind.martial_art && prob(H.mind.martial_art.deflection_chance))
				. = TRUE
		if(H.mind)
			if(H.dna.species == /datum/species/golem/sand)
				. = TRUE

/mob/living/simple_animal/hostile/megafauna/stalwart/death()
	. = ..()
	if(health > 0)
		return
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(maxHealth * MEGAFAUNA_CASH_SCALE/1.25)

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
	addtimer(CALLBACK(src, .proc/death), 30 SECONDS)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/staldrone/ranged
	ranged = 1
	ranged_message = "blasts"
	icon_state = "drone_scout"
	icon_living = "drone_scout"
	icon_aggro = "drone_scout"
	ranged_cooldown_time = 30
	projectiletype = /obj/item/projectile/stalpike/weak
	projectilesound = 'sound/weapons/ionrifle.ogg'

/obj/item/gps/internal/stalwart
	icon_state = null
	gpstag = "Ancient Signal"
	desc = "Bzz bizzop boop blip beep"
	invisibility = 100

/obj/item/projectile/stalpike
	name = "energy pike"
	icon_state = "arcane_barrage_greyscale"
	damage = 30
	armour_penetration = 100
	speed = 4
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	color = "#00e1ff"
	light_range = 2
	light_power = 6
	light_color = "#00e1ff"

/obj/item/projectile/stalpike/spiral
	name = "resonant energy pike"
	icon_state = "arcane_barrage_greyscale"
	damage = 30
	armour_penetration = 60
	speed = 6
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	color = "#4851ce"
	light_range = 2
	light_power = 6
	light_color = "#4851ce"

/obj/item/projectile/stalpike/weak
	name = "lesser energy pike"
	icon_state = "arcane_barrage_greyscale"
	damage = 10
	armour_penetration = 100
	speed = 5
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	color = "#9a9fdb"
	light_range = 2
	light_power = 6
	light_color = "#9a9fdb"

/obj/item/projectile/stalnade
	name = "volatile orb"
	icon_state = "wipe"
	damage = 100
	armour_penetration = 60
	speed = 10
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	light_range = 6
	light_power = 10
	light_color = "#0077ff"

/obj/item/projectile/stalnade/on_hit(target)
	if(!iscarbon(target))
		return BULLET_ACT_PENETRATE
	. = ..()

/mob/living/simple_animal/hostile/megafauna/stalwart/devour(mob/living/L)
	visible_message(span_danger("[src] atomizes [L]!"))
	L.dust()
