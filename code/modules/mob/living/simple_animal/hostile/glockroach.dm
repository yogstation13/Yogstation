/obj/item/projectile/glockroachbullet
	damage = 10 //same damage as a hivebot
	damage_type = BRUTE


/obj/item/ammo_casing/glockroach
	name = "0.9mm bullet casing"
	desc = "A... 0.9mm bullet casing? What?"
	projectile_type = /obj/item/projectile/glockroachbullet

/mob/living/simple_animal/hostile/glockroach //copypasted from cockroach.dm so i could use the shooting code in hostile.dm
	name = "glockroach"
	desc = "HOLY SHIT, THAT COCKROACH HAS A GUN!"
	icon_state = "glockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	loot = list(/obj/effect/decal/cleanable/insectguts)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	speak_emote = list("chitters")
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	projectilesound = 'sound/weapons/shot.ogg'
	projectiletype = /obj/item/projectile/glockroachbullet
	casingtype = /obj/item/ammo_casing/glockroach
	ranged = 1
	var/squish_chance = 50
	del_on_ = 1

/mob/living/simple_animal/hostile/glockroach/(gibbed)
	if(SSticker.mode && SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/simple_animal/hostile/glockroach/Crossed(var/atom/movable/AM)
	. = ..()
	if(ismob(AM))
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL && !(A.movement_type & FLYING))
				if(prob(squish_chance))
					A.visible_message(span_notice("[A] squashed [src]."), span_notice("You squashed [src]."))
					adjustBruteLoss(1) //kills a normal cockroach
				else
					visible_message(span_notice("[src] avoids getting crushed."))
	else
		if(isstructure(AM))
			if(prob(squish_chance))
				AM.visible_message(span_notice("[src] was crushed under [AM]."))
				adjustBruteLoss(1)
			else
				visible_message(span_notice("[src] avoids getting crushed."))

/mob/living/simple_animal/hostile/glockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return
