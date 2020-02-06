/mob/living/simple_animal/hostile/yeti
	name = "yeti"
	desc = "It's a horrifyingly enormous yeti, and it seems to resemble something nostalgic"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 100
	health = 100
	see_in_dark = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/killertomato = 2)
	response_harm   = "smacks"
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "slams"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("skeleton")

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = HOSTILE_SPAWN
