/mob/living/simple_animal/hostile/winter
	faction = list("hostile", "syndicate", "winter")
	speak_chance = 0
	turns_per_move = 5
	speed = 1
	maxHealth = 50
	health = 50
	icon = 'icons/mob/winter_mob.dmi'
	icon_state = "placeholder"
	icon_living = "placeholder"
	icon_dead = "placeholder"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	melee_damage_lower = 3
	melee_damage_upper = 7

/mob/living/simple_animal/hostile/winter/snowman
	name = "snowman"
	desc = "A very angry snowman. Doesn't look like it wants to play around..."
	maxHealth = 75		//slightly beefier to account for it's need to get in your face
	health = 75
	icon_state = "snowman"
	icon_living = "snowman"
	icon_dead = "snowman-dead"
	gold_core_spawnable = HOSTILE_SPAWN


/mob/living/simple_animal/hostile/winter/snowman/death(gibbed)
	if(can_die())
		if(prob(50))	//50% chance to drop candy cane sword on death, if it has one to drop
			loot = list(/obj/item/melee/candy_sword)
		if(prob(20))	//chance to become a stationary snowman structure instead of a corpse
			loot.Add(/obj/structure/snowman)
			deathmessage = "shimmers as its animating magic fades away!"
			del_on_death = 1
	return ..()

/mob/living/simple_animal/hostile/winter/snowman/ranged
	maxHealth = 50
	health = 50
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/snowball
