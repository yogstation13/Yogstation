#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	health_doll_icon = "megacarp"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 2)
	greyscale_config = /datum/greyscale_config/carp
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	spacewalk = TRUE

	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_vis_effect = ATTACK_EFFECT_BITE
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")

	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	movement_type = FLYING
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN

	var/random_color = TRUE //if the carp uses random coloring
	var/rarechance = 1 //chance for rare color variant

	/// Weighted list of colours a carp can be
	/// Weighted list of usual carp colors
	var/static/list/carp_colors = list(
		COLOR_CARP_PURPLE = 7,
		COLOR_CARP_PINK = 7,
		COLOR_CARP_GREEN = 7,
		COLOR_CARP_GRAPE = 7,
		COLOR_CARP_SWAMP = 7,
		COLOR_CARP_TURQUOISE = 7,
		COLOR_CARP_BROWN = 7,
		COLOR_CARP_TEAL = 7,
		COLOR_CARP_LIGHT_BLUE = 7,
		COLOR_CARP_RUSTY = 7,
		COLOR_CARP_RED = 7,
		COLOR_CARP_YELLOW = 7,
		COLOR_CARP_BLUE = 7,
		COLOR_CARP_PALE_GREEN = 7,
		COLOR_CARP_SILVER = 1, // The rare silver carp
	)

/mob/living/simple_animal/hostile/carp/loan
	faction = list("hostile")

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	apply_color()

/// Set a random colour on the carp, override to do something else
/mob/living/simple_animal/hostile/carp/proc/apply_color()
	if (!greyscale_config)
		return
	set_greyscale(colors = list(pickweight(carp_colors)))

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	greyscale_config = null //no current config for holocarps :(
	maxbodytemp = INFINITY
	gold_core_spawnable = NO_SPAWN
	del_on_death = 1
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp_greyscale"
	icon_living = "megacarp_greyscale"
	icon_dead = "megacarp_dead_greyscale"
	icon_gib = "megacarp_gib"
	health_doll_icon = "megacarp"
	maxHealth = 20
	health = 20
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE
	greyscale_config = /datum/greyscale_config/carp_mega

	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 20

	var/regen_cooldown = 0

/mob/living/simple_animal/hostile/carp/megacarp/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(30,60)
	move_to_delay = rand(3,7)

/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/simple_animal/hostile/carp/megacarp/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(regen_cooldown < world.time)
		heal_overall_damage(4)

/// Boosted chance for Cayenne to be silver
#define RARE_CAYENNE_CHANCE 10

/mob/living/simple_animal/hostile/carp/cayenne
	name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	gender = FEMALE
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	faction = list(ROLE_SYNDICATE)
	AIStatus = AI_OFF
	rarechance = 10

/mob/living/simple_animal/hostile/carp/cayenne/apply_color()
	if (prob(RARE_CAYENNE_CHANCE))
		set_greyscale(colors = list(COLOR_CARP_SILVER))
	else
		return ..()

#undef RARE_CAYENNE_CHANCE
#undef REGENERATION_DELAY
