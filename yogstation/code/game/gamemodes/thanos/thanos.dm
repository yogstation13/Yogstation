
#define NO_GEMS 0
#define SPACE_GEM (1<<0)
#define TIME_GEM (1<<1)
#define MIND_GEM (1<<2)
#define SOUL_GEM (1<<3)
#define POWER_GEM (1<<4)
#define REALITY_GEM (1<<5)
#define ALL_GEMS (SPACE_GEM | TIME_GEM | MIND_GEM | SOUL_GEM | POWER_GEM | REALITY_GEM)

/datum/game_mode
	var/list/datum/mind/balance_seekers = list()

/datum/game_mode/thanos
	name = "thanos"
	config_tag = "thanos"
	report_type = "thanos"
	antag_flag = ROLE_THANOS
	required_players = 30
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 14
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "A mad titan with a powerful gauntlet is gathering the gems, and all are on Space Station 13!\n\
	<span class='danger'>Titan and minions</span>: Accomplish your objective at all costs!\n\
	<span class='notice'>Crew</span>: Eliminate the mad titan before they can succeed!"
	var/max_thanos_members = 4 //one thanos and three minions
	var/list/pre_thanos = list()

	var/datum/team/thanos/thanos_team

	var/thanos_antag_datum_type = /datum/antagonist/thanos
	var/thanos_minion_datum_type = /datum/antagonist/thanos/minion


/datum/game_mode/thanos/pre_setup()
	var/n_thanos = min(round((num_players()-10) / 20), antag_candidates.len, max_thanos_members)
	if(n_thanos >= required_enemies)
		for(var/i = 0, i < n_thanos, ++i)
			var/datum/mind/new_thanos = pick_n_take(antag_candidates)
			pre_thanos += new_thanos
			new_thanos.assigned_role = ROLE_THANOS
			new_thanos.special_role = ROLE_THANOS
		return TRUE

/datum/game_mode/thanos/post_setup()
	//Assign leader
	var/datum/mind/thanos_mind = pre_thanos[1]
	var/datum/antagonist/thanos/T = thanos_mind.add_antag_datum(thanos_antag_datum_type) //this is what handles giving space gem to thanos
	thanos_team = T.thanos_team
	if(pre_thanos.len>1)
		//Assign the minions
		for(var/i = 2 to pre_thanos.len)
			var/datum/mind/minion_mind = pre_thanos[i]
			minion_mind.add_antag_datum(thanos_minion_datum_type)
	spawn_infinity_gems(ALL_GEMS - SPACE_GEM)
	return ..()

/datum/game_mode/thanos/check_win()
	if (snapped)
		return TRUE
	return ..()

/datum/game_mode/thanos/generate_report()
	return "A nanotrasen research base studying an artifact with unusual bluespace properties was raided by an individual reported to be wielding a strange gauntlet. \
			Similar anomalous artifacts have been found; their anomalous properties make them difficult to track, but it is believed they are in your area.\
			If you find any, keep them safe and away from anyone who might try to steal them."

/datum/outfit/thanos
	name = "Gauntlet-bearer"

	uniform = /obj/item/clothing/under/color/lightpurple //would you believe this is the only purple one
	suit = /obj/item/clothing/suit/space/hardsuit/wizard
	gloves = /obj/item/storage/infinity_gauntlet/space_only
	shoes = /obj/item/clothing/shoes/plate //i can't into sprites so sorry i'm just grabbing things from other places
	back = /obj/item/storage/backpack

/datum/outfit/thanos_minion
	name = "Gauntlet-child"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/armor/plate/crusader
	shoes = /obj/item/clothing/shoes/plate
	back = /obj/item/storage/backpack

/proc/spawn_infinity_gems(gem_flags = ALL_GEMS)
	var/list/gems = list()
	if(gem_flags & SPACE_GEM)
		gems |= new /obj/item/infinity_gem/space_gem()
	if(gem_flags & TIME_GEM)
		gems |= new /obj/item/infinity_gem/time_gem()
	if(gem_flags & MIND_GEM)
		gems |= new /obj/item/infinity_gem/mind_gem()
	if(gem_flags & SOUL_GEM)
		gems |= new /obj/item/infinity_gem/soul_gem()
	if(gem_flags & POWER_GEM)
		gems |= new /obj/item/infinity_gem/power_gem()
	if(gem_flags & REALITY_GEM)
		gems |= new /obj/item/infinity_gem/reality_gem()
	for(var/gem in gems)
		var/targetturf = find_safe_turf()
		if(!targetturf)
			if(GLOB.blobstart.len > 0)
				targetturf = get_turf(pick(GLOB.blobstart))
			else
				CRASH("Unable to find a blobstart landmark")
		var/atom/movable/AM = gem
		AM.forceMove(targetturf)
	return TRUE

#undef NO_GEMS
#undef SPACE_GEM
#undef TIME_GEM
#undef MIND_GEM
#undef SOUL_GEM
#undef POWER_GEM
#undef REALITY_GEM
#undef ALL_GEMS
