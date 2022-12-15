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
	spell_type = /obj/effect/proc_holder/spell/targeted/guardian/frenzy
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
		L.throw_at(get_edge_target_turf(L, get_dir(guardian, L)), world.maxx / 4, 4, guardian, TRUE)
		next_rush = world.time + 3 SECONDS

/datum/guardian_ability/major/frenzy/StatusTab()
	. = ..()
	if(next_rush > world.time)
		. += "Frenzy Charge Cooldown Remaining: [DisplayTimeText(next_rush - world.time)]"

/obj/effect/proc_holder/spell/targeted/guardian/frenzy
	name = "Teleport Behind"
	desc = "<i>teleports behind you<i> NANI?"
	action_icon_state = "omae_wa_shinderu"

/obj/effect/proc_holder/spell/targeted/guardian/frenzy/InterceptClickOn(mob/living/caller, params, atom/movable/target)
	if (!isguardian(caller))
		revert_cast()
		return
	var/mob/living/simple_animal/hostile/guardian/guardian = caller
	if (!guardian.is_deployed())
		to_chat(guardian, span_italics(span_danger("You are not manifested!")))
		revert_cast()
		return
	if (!isliving(target))
		to_chat(guardian, span_italics(span_danger("[target] is not a living thing.")))
		revert_cast()
		return
	if (!guardian.stats)
		revert_cast()
		return
	if (get_dist_euclidian(guardian.summoner?.current, target) > guardian.range)
		to_chat(guardian, span_italics(span_danger("[target] is out of your range!")))
		revert_cast()
		return
	remove_ranged_ability()
	guardian.forceMove(get_step(get_turf(target), turn(target.dir, 180)))
	playsound(guardian, 'yogstation/sound/effects/vector_appear.ogg', 100, FALSE)
	guardian.target = target
	target.visible_message(span_danger("[guardian] suddenly appears behind [target]!"), \
		span_userdanger("[guardian] suddenly appears behind you!"), \
		span_italics("You hear a fast wooosh."))
	guardian.AttackingTarget()
	target.throw_at(get_edge_target_turf(guardian, get_dir(guardian, target)), world.maxx / 6, 5, guardian, TRUE)
