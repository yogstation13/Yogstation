/mob/living/simple_animal/hostile/corruption
	name = "The Corruption Avatar"
	desc = "A sinister, unholy creature, spreading coruption arround itself."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	maxHealth = 120
	health = 120
	melee_damage_lower = 20
	melee_damage_upper = 15
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
	unsuitable_atmos_damage = 5
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/corruption/AttackingTarget()
	. = ..()

