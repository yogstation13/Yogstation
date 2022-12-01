/mob/living/simple_animal/grue_egg
	name = "grue egg"
	desc = "An egg laid by a grue. An embyro hasn't developed yet."
	icon = 'icons/mob/grue.dmi'
	icon_state = "egg_new"
	icon_living= "egg_new"
	icon_dead= "egg_dead"
	maxHealth = 25
	health = 25
	faction = list("grue")

	//allow other mobs to walk onto the same tile
	density = 0
	layer=LYING_MOB_LAYER

	var/mob/living/simple_animal/parent_grue	
	var/grown = 0
	var/hatching = 0 // So we don't spam ghosts.
	var/child_prefix_index = 1
	var/last_ping_time = 0
	var/ping_cooldown = 50

	var/datum/component/light_damage/light_damage = null
	AIStatus = AI_OFF

/mob/living/simple_animal/grue_egg/Life()
	..()
	if (stat!=DEAD)
		if(grown && !hatching)
			hatch()

/mob/living/simple_animal/grue_egg/death()
	name = "grue egg remnants"
	desc = "The remnants of a grue egg."
	gender = "plural"
	..()

/mob/living/simple_animal/grue_egg/Move(atom/newloc, direct, glide_size_override)
	return FALSE

/mob/living/simple_animal/grue_egg/Initialize()
	. = ..()
	last_ping_time = world.time
	addtimer(CALLBACK(src, .proc/grow), rand(30 SECONDS, 45 SECONDS))
	light_damage = AddComponent(/datum/component/light_damage, 0.2, 0.3)
	light_damage.damage_types = list(BURN)


/mob/living/simple_animal/grue_egg/proc/get_candidates()
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a juvenile grue?", ROLE_GRUE, null, null, 15 SECONDS, src)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick(candidates)

		if(parent_grue && parent_grue.mind)
			var/datum/antagonist/grue/G1 = parent_grue.mind.has_antag_datum(/datum/antagonist/grue)
			if(G1)
				G1.spawn_count++

		var/mob/living/simple_animal/hostile/grue/gruespawn/eggborn/G = new(get_turf(src))
		candidate.mind.transfer_to(G, TRUE)
		playsound((src), 'sound/effects/splat.ogg', 50, 1)
		src.visible_message(span_notice("\The [name] bursts open!"))
		death()
	else
		addtimer(CALLBACK(src, .proc/get_candidates), rand(30 SECONDS, 45 SECONDS))

/mob/living/simple_animal/grue_egg/proc/grow()
	if(stat==DEAD)
		return
	grown = 1
	icon_state = "egg_living"
	icon_living= "egg_living"
	desc = "An egg laid by a grue. An embryo floats inside."
	

/mob/living/simple_animal/grue_egg/proc/hatch()
	if(stat==DEAD)
		return
	
	hatching=1
	get_candidates()
