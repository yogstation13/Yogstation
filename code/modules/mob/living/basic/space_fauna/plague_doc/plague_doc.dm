
/mob/living/basic/plague_doc
	name = "The Plague Doctor"
	desc = "A mysterious figure with a birdmask and a long tattered black coat."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE, FACTION_PLAGUE)
	gender = MALE

	response_help_continuous = "tries to poke"
	response_help_simple = "tries to poke"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	speed = 0.5

	basic_mob_flags = DEL_ON_DEATH
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 5
	melee_damage_upper = 10
	obj_damage = 50
	attack_sound = 'sound/hallucinations/growl3.ogg'
	ai_controller = /datum/ai_controller/basic_controller/plague_doc
	///spell to summon minions
	var/datum/action/cooldown/spell/conjure/plague_summon_minions/summon
	icon_gib = "syndicate_gib"

/mob/living/basic/plague_doc/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/decal/remains/human)
	AddElement(/datum/element/death_drops, death_loot)
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/plaguedoctormob)
	grant_abilities()

/mob/living/basic/plague_doc/proc/grant_abilities()
	summon = new(src)
	summon.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_SUMMON_MINIONS, summon)


/datum/ai_controller/basic_controller/plague_doc
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/attack_obstacle_in_path
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability/wizard_summon_minions,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/use_mob_ability/plague_summon_minions
	ability_key = BB_WIZARD_SUMMON_MINIONS
	finish_planning = FALSE



///ripped from paper wizard code
