GLOBAL_LIST_INIT(guardian_frenzy_speedup, list(
	1 = -0.15,
	2 = -0.35,
	3 = -0.5,
	4 = -0.75,
	5 = -1
))

/datum/guardian_ability/major/frenzy
	name = "Frenzy"
	desc = "The guardian is capable of high-speed fighting, and speeding up its owner while manifested, too. REQUIRES RANGE C OR ABOVE."
	cost = 3 // low cost because this stand is pretty much LOUD AS FUCK, and using it is stealthily is pretty hard due to it's loud, unique sounds and abilities
				// also because in order for this to be any good, you need to spread your points real good
	spell_type = /datum/action/cooldown/spell/pointed/guardian/frenzy
	var/next_rush = 0

/datum/guardian_ability/major/frenzy/Apply()
	. = ..()
	guardian.add_movespeed_modifier("frenzy_guardian", update=TRUE, priority=100, multiplicative_slowdown=GLOB.guardian_frenzy_speedup[guardian.stats.potential])

/datum/guardian_ability/major/frenzy/Remove()
	. = ..()
	guardian.remove_movespeed_modifier("frenzy_guardian")

/datum/guardian_ability/major/frenzy/CanBuy(care_about_points = TRUE)
	return ..() && master_stats.range >= 3

/datum/guardian_ability/major/frenzy/Manifest()
	if (guardian.summoner?.current)
		guardian.summoner.current.add_movespeed_modifier("frenzy", update=TRUE, priority=100, multiplicative_slowdown=GLOB.guardian_frenzy_speedup[guardian.stats.potential])

/datum/guardian_ability/major/frenzy/Recall()
	if (guardian.summoner?.current)
		guardian.summoner.current.remove_movespeed_modifier("frenzy")

/datum/guardian_ability/major/frenzy/RangedAttack(atom/target)
	if (isliving(target) && world.time >= next_rush && guardian.is_deployed())
		var/mob/living/L = target
		if (guardian.summoner?.current && get_dist_euclidian(guardian.summoner.current, L) > master_stats.range)
			to_chat(guardian, span_italics(span_danger("[L] is out of your range!")))
			return
		playsound(guardian, 'yogstation/sound/effects/vector_rush.ogg', 100, FALSE)
		guardian.forceMove(get_step(get_turf(L), get_dir(L, guardian)))
		guardian.target = L
		guardian.AttackingTarget()
		next_rush = world.time + 3 SECONDS

/datum/guardian_ability/major/frenzy/StatusTab()
	. = ..()
	if(next_rush > world.time)
		. += "Frenzy Charge Cooldown Remaining: [DisplayTimeText(next_rush - world.time)]"

/datum/action/cooldown/spell/pointed/guardian/frenzy
	name = "Teleport Behind"
	desc = "<i>teleports behind you<i> NANI?"
	button_icon_state = "omae_wa_shinderu"

/datum/action/cooldown/spell/pointed/guardian/frenzy/InterceptClickOn(mob/living/caller_but_not_a_byond_built_in_proc, params, atom/movable/target)
	. = ..()
	if(!.)
		return FALSE
	if (!isguardian(caller_but_not_a_byond_built_in_proc))
		return
	var/mob/living/simple_animal/hostile/guardian/guardian = caller_but_not_a_byond_built_in_proc
	if (!guardian.is_deployed())
		to_chat(guardian, span_italics(span_danger("You are not manifested!")))
		return
	if (!isliving(target))
		to_chat(guardian, span_italics(span_danger("[target] is not a living thing.")))
		return
	if (!guardian.stats)
		return
	if(!guardian.stats.ability)
		return
	if (!istype(guardian.stats.ability, /datum/guardian_ability/major/frenzy))
		return
	var/datum/guardian_ability/major/frenzy/ability = guardian.stats.ability
	if(world.time < ability.next_rush)
		return
	if (get_dist_euclidian(guardian.summoner?.current, target) > guardian.range)
		to_chat(guardian, span_italics(span_danger("[target] is out of your range!")))
		return

	guardian.forceMove(get_step(get_turf(target), turn(target.dir, 180)))
	playsound(guardian, 'yogstation/sound/effects/vector_appear.ogg', 100, FALSE)
	guardian.target = target
	target.visible_message(span_danger("[guardian] suddenly appears behind [target]!"), \
		span_userdanger("[guardian] suddenly appears behind you!"), \
		span_italics("You hear a fast wooosh."))
	guardian.AttackingTarget()
	target.throw_at(get_edge_target_turf(guardian, get_dir(guardian, target)), world.maxx / 6, 5, guardian, TRUE)
	ability.next_rush = world.time + 3 SECONDS
	Finished()
