/mob/living/simple_animal/hostile/corruption
	name = "The Corruption Avatar"
	desc = "A sinister, unholy creature, spreading coruption arround itself."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	maxHealth = 120
	health = 120
	melee_damage_lower = 21
	melee_damage_upper = 26
	obj_damage = 40
	attacktext = "claws"
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow = 2)
	response_help  = "thinks better at touching"
	response_disarm = "shoves"
	response_harm   = "kicks"
	spacewalk = TRUE
	gold_core_spawnable = FALSE
	faction = list("corruption")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0 "min_n2" = 0, "max_n2" = 0)
	var/rust_last_time_used

/mob/living/simple_animal/hostile/corruption/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/disease/corruption/disease = new()
		disease.corruption_avatar = src
		disease.try_infect(H, make_copy = FALSE)
	if(rust_last_time_used + 5 SECONDS < world.time)
		rust_last_time_used = world.time
		playsound(user, 'sound/items/welder.ogg', 75, TRUE)
		target.rust_heretic_act()

/mob/living/simple_animal/hostile/corruption/Life(seconds, times_fired)
	. = ..()
	var/turf/turfo = get_turf(src)
	if(istype(turfo, /turf/open/floor/plating/rust))
		heal_bodypart_damage(2)
	else if(prob(30))
		turfo.rust_heretic_act()
		playsound(user, 'sound/items/welder.ogg', 75, TRUE)



