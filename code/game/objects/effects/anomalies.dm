//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.
/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 45

/////////////////////

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	anchored = TRUE
	light_range = 3
	var/obj/item/assembly/signaler/anomaly/aSignal
	var/core_type
	var/area/impact_area

	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we keep on living forever?
	var/immortal = FALSE

/obj/effect/anomaly/Initialize(mapload, new_lifespan)
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	switch(core_type)
		if(ANOMALY_RADIATION)
			aSignal = new /obj/item/assembly/signaler/anomaly/radiation(src)
		if(ANOMALY_HALLUCINATION)
			aSignal = new /obj/item/assembly/signaler/anomaly/hallucination(src)
		if(ANOMALY_FLUX)
			aSignal = new /obj/item/assembly/signaler/anomaly/flux(src)
		if(ANOMALY_GRAVITATIONAL)
			aSignal = new /obj/item/assembly/signaler/anomaly/grav(src)
		if(ANOMALY_PYRO)
			aSignal = new /obj/item/assembly/signaler/anomaly/pyro(src)
		if(ANOMALY_BLUESPACE)
			aSignal = new /obj/item/assembly/signaler/anomaly/bluespace(src)
		if(ANOMALY_VORTEX)
			aSignal = new /obj/item/assembly/signaler/anomaly/vortex(src)

	aSignal.code = rand(1,100)

	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.set_frequency(frequency)

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	if(immortal)
		return // no countdown for forever anomalies
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()

/obj/effect/anomaly/process(delta_time)
	anomalyEffect(delta_time)
	if(death_time < world.time && !immortal)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/Destroy()
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	return ..()

/obj/effect/anomaly/proc/anomalyEffect(delta_time)
	if(DT_PROB(ANOMALY_MOVECHANCE, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity, target)
	if(severity == 1)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)

	for(var/atom/movable/O in src)
		O.forceMove(drop_location())

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER || istype(I, /obj/item/multitool/tricorder))
		to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	core_type = ANOMALY_GRAVITATIONAL
	density = FALSE
	var/boing = 0

/obj/effect/anomaly/grav/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/grav/anomalyEffect()
	..()
	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/O in range(0,src))
		if(!O.anchored)
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 5, 10)

/obj/effect/anomaly/grav/proc/on_entered(datum/source, atom/movable/AM, ...)
	gravShock(AM)

/obj/effect/anomaly/grav/Bump(atom/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bumped(atom/movable/AM)
	gravShock(AM)

/obj/effect/anomaly/grav/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		A.Paralyze(40)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0

/obj/effect/anomaly/grav/high
	var/grav_field

/obj/effect/anomaly/grav/high/Initialize(mapload, new_lifespan)
	. = ..()
	setup_grav_field()

/obj/effect/anomaly/grav/high/proc/setup_grav_field()
	grav_field = make_field(/datum/proximity_monitor/advanced/gravity, list("current_range" = 7, "host" = src, "gravity_value" = rand(0,3)))

/obj/effect/anomaly/grav/high/Destroy()
	QDEL_NULL(grav_field)
	. = ..()

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	core_type = ANOMALY_FLUX
	density = FALSE // so it doesn't awkwardly block movement when it doesn't stun you
	var/canshock = 0
	var/shockdamage = 30
	var/explosive = ANOMALY_FLUX_NO_EXPLOSION

/obj/effect/anomaly/flux/explosion
	explosive = ANOMALY_FLUX_EXPLOSION

/obj/effect/anomaly/flux/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/flux/anomalyEffect(delta_time)
	..()
	canshock = 1
	for(var/mob/living/M in range(0, src))
		mobShock(M)
	if(prob(delta_time * 2)) // shocks everyone nearby
		tesla_zap(src, 5, shockdamage*500, TESLA_MOB_DAMAGE)

/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/AM, ...)
	mobShock(AM)

/obj/effect/anomaly/flux/Bump(atom/A)
	mobShock(A)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	mobShock(AM)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		var/should_stun = !M.IsParalyzed() // stunlock is boring
		var/hit_percent = (100 - M.getarmor(null, ELECTRIC)) / 100
		M.electrocute_act(shockdamage, "[name]", max(hit_percent, 0.33), zone = null, override=TRUE, stun = should_stun) // ignore armor because we're doing our own calculations

/obj/effect/anomaly/flux/detonate()
	switch(explosive)
		if(ANOMALY_FLUX_EXPLOSION)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(ANOMALY_FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	core_type = ANOMALY_BLUESPACE
	density = TRUE

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(1,src))
		do_teleport(M, locate(M.x, M.y, M.z), 4, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/AM)
	if(isliving(AM))
		do_teleport(AM, locate(AM.x, AM.y, AM.z), 8, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/detonate()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
			// Calculate new position (searches through beacons in world)
		var/obj/item/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/beacon/W in GLOB.teleportbeacons)
			possible += W

		if(possible.len > 0)
			chosen = pick(possible)

		if(chosen)
				// Calculate previous position for transition

			var/turf/FROM = T // the turf of origin we're travelling FROM
			var/turf/TO = get_turf(chosen) // the turf of origin we're travelling TO

			playsound(TO, 'sound/effects/phasein.ogg', 100, 1)
			priority_announce("Massive bluespace translocation detected.", "Anomaly Alert")

			var/list/flashers = list()
			for(var/mob/living/carbon/C in viewers(TO, null))
				if(C.flash_act())
					flashers += C

			var/y_distance = TO.y - FROM.y
			var/x_distance = TO.x - FROM.x
			for (var/atom/movable/A in urange(12, FROM )) // iterate thru list of mobs in the area
				if(istype(A, /obj/item/beacon))
					continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored)
					continue

				var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
				if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					A.forceMove(newloc)

				spawn()
					if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
						var/mob/M = A
						if(M.client)
							var/obj/blueeffect = new /obj(src)
							blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
							blueeffect.icon = 'icons/effects/effects.dmi'
							blueeffect.icon_state = "shieldsparkles"
							blueeffect.layer = FLASH_LAYER
							blueeffect.plane = FULLSCREEN_PLANE
							blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
							M.client.screen += blueeffect
							sleep(2 SECONDS)
							M.client.screen -= blueeffect
							qdel(blueeffect)

/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyro"
	color = "#ffa952"
	core_type = ANOMALY_PYRO
	var/ticks = 0
	/// How many seconds between each gas release
	var/releasedelay = 10
	var/fire_power = 30

/obj/effect/anomaly/pyro/anomalyEffect(delta_time)
	..()
	var/turf/center = get_turf(src)
	center.ignite_turf(delta_time * fire_power)
	for(var/turf/open/T in center.GetAtmosAdjacentTurfs())
		if(prob(5 * delta_time))
			T.ignite_turf(delta_time)

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/center = get_turf(src)
	for(var/turf/open/T in spiral_range_turfs(5, center))
		if(prob(get_dist(center, T) * 15))
			continue
		T.ignite_turf(fire_power * 10) //Make it hot and burny for the new slime
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/S = new(center, new_colour)
	S.rabid = TRUE
	S.amount_grown = SLIME_EVOLUTION_THRESHOLD
	S.Evolve()

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a pyroclastic anomaly slime?", ROLE_PAI, null, null, 100, S, POLL_IGNORE_PYROSLIME)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		S.key = chosen.key
		log_game("[key_name(S.key)] was made into a slime by pyroclastic anomaly at [AREACOORD(center)].")

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	core_type = ANOMALY_VORTEX
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0,3), rand(2,3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in range(2,src))
		if(O == src)
			return //DON'T DELETE YOURSELF GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5)
		else
			SSexplosions.med_mov_atom += O

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				switch(ex_act_force)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += O
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += O
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += O
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if( T && prob(turf_removal_chance) )
		switch(ex_act_force)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T

 /////////////////////////
/obj/effect/anomaly/radiation
	name = "radiation anomaly"
	icon_state = "radiation_anomaly"
	core_type = ANOMALY_RADIATION
	density = TRUE
	var/spawn_goat = ANOMALY_RADIATION_NO_GOAT //For goat spawning

/obj/effect/anomaly/radiation/goat //bussing
	spawn_goat = ANOMALY_RADIATION_YES_GOAT

/obj/effect/anomaly/radiation/anomalyEffect()
	..()
	for(var/i = 1 to 5)
		fire_nuclear_particle()
	radiation_pulse(src, 10000, 5)

/obj/effect/anomaly/radiation/proc/makegoat()
	for(var/i=1 to 15)
		fire_nuclear_particle()
		radiation_pulse(src, 20000, 7)
	if(spawn_goat == ANOMALY_RADIATION_YES_GOAT)
		var/turf/open/T = get_turf(src)
		var/mob/living/simple_animal/hostile/retaliate/goat/radioactive/S = new(T)

		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a radioactive goat?", ROLE_SENTIENCE, null, null, 100, S, POLL_IGNORE_PYROSLIME)
		if(LAZYLEN(candidates))
			var/mob/dead/observer/chosen = pick(candidates)
			S.key = chosen.key
			var/datum/action/cooldown/spell/conjure/radiation_anomaly/spell
			spell.Grant(S)
			log_game("[key_name(S.key)] was made into a radioactive goat by radiation anomaly at [AREACOORD(T)].")

/obj/effect/anomaly/radiation/detonate()
	INVOKE_ASYNC(src, PROC_REF(makegoat))

/////////////////////

/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination_anomaly"
	core_type = ANOMALY_HALLUCINATION
	/// Time passed since the last effect, increased by delta_time of the SSobj
	var/ticks = 0
	/// How many seconds between each hallucination spanwed
	var/release_delay = 5
	/// flavor of hallucination mobs this spawns (cosmetic)
	var/hallucination_set

/obj/effect/anomaly/hallucination/Initialize(mapload, new_lifespan)
	. = ..()
	hallucination_set = pick("syndicate", "cult")
	switch(hallucination_set)
		if("syndicate")
			icon = 'icons/mob/simple_human.dmi'
			icon_state = "syndicate_stormtrooper_sword"
		if("cult")
			icon = 'icons/mob/nonhuman-player/cult.dmi'
			icon_state = "cultist"

/obj/effect/anomaly/hallucination/anomalyEffect(delta_time)
	. = ..()
	ticks += delta_time
	if(ticks < release_delay)
		return
	ticks -= release_delay
	var/turf/open/our_turf = get_turf(src)
	if(istype(our_turf))
		var/mob/living/simple_animal/hostile/newhall = new /mob/living/simple_animal/hostile/hallucination(our_turf)
		switch(hallucination_set)
			if("syndicate")
				newhall.name = "syndicate operative"
				newhall.icon = 'icons/mob/simple_human.dmi'
				newhall.icon_state = "syndicate_space_knife"
				newhall.attacktext = "slashes"
				newhall.attack_sound = 'sound/weapons/bladeslice.ogg'
			if("cult")
				newhall.name = "shade"
				newhall.icon = 'icons/mob/nonhuman-player/cult.dmi'
				newhall.icon_state = "shade_cult"
				newhall.attacktext = "metaphysically strikes"

/obj/effect/anomaly/hallucination/detonate()
	var/mob/living/simple_animal/hostile/hallucination/anomaly/bighall = new(get_turf(src))
	bighall.icon = icon
	bighall.icon_state = icon_state
	switch(hallucination_set)
		if("syndicate")
			bighall.attacktext = "slashes"
			bighall.attack_sound = 'sound/weapons/bladeslice.ogg'
		if("cult")
			bighall.attacktext = "slashes"
			bighall.attack_sound = 'sound/weapons/blade1.ogg'

// Hallucination anomaly spawned mob, attacks deal stamina damage, if it stamcrits someone, they start hallucinating themself dying.
/mob/living/simple_animal/hostile/hallucination
	name = "Unknown"
	desc = "Whoever they are, they look angry, and hard to look at."
	maxHealth = 25
	health = 25
	melee_damage_lower = 15
	melee_damage_upper = 10
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	obj_damage = 0
	digitalinvis = TRUE //silicons can't hallucinate, as they are robots. they also can't take stamina damage.
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 1, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	del_on_death = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/hallucination/anomaly
	name = "hallucination anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	maxHealth = 50
	health = 50
	melee_damage_lower = 30
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/hallucination/CanAttack(atom/the_target)
	. = ..()
	if(!iscarbon(the_target))
		return FALSE

/mob/living/simple_animal/hostile/hallucination/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/carbon/C = target
		C.clear_stamina_regen()
		if(C.getStaminaLoss() >= 100) //congrats you have hallucinated being stabbed now you are hallucinating dying
			if(!C.losebreath)
				to_chat(C, span_notice("You feel your heart slow down..."))
			C.losebreath = min(C.losebreath+2, 10)
			C.silent = min(C.silent+2, 10)
			if(C.getOxyLoss() >= 100) //let's skip the waiting and get to the fun part
				if(C.can_heartattack())
					C.playsound_local(C, 'sound/effects/singlebeat.ogg', 100, 0)
					C.set_heartattack(TRUE)
				else
					C.adjustBruteLoss(10)

#undef ANOMALY_MOVECHANCE
