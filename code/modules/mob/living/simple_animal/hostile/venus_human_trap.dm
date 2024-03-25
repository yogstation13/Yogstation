/**
  * Kudzu Flower Bud
  *
  * A flower created by flowering kudzu which spawns a venus human trap after a certain amount of time has passed.
  *
  * A flower created by kudzu with the flowering mutation.  Spawns a venus human trap after 2 minutes under normal circumstances.
  * Also spawns 4 vines going out in diagonal directions from the bud.  Any living creature not aligned with plants is damaged by these vines.
  * Once it grows a venus human trap, the bud itself will destroy itself.
  *
  */
/obj/structure/alien/resin/flower_bud_enemy //inheriting basic attack/damage stuff from alien structures
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "flower_bud"
	layer = SPACEVINE_MOB_LAYER
	opacity = FALSE
	canSmoothWith = null
	smoothing_flags = NONE
	density = FALSE
	/// The amount of time it takes to create a venus human trap, in deciseconds
	var/growth_time = 120 SECONDS
	var/growth_icon = 0

	/// Used by countdown to check time, this is when the timer will complete and the venus trap will spawn.
	var/finish_time
	/// The countdown ghosts see to when the plant will hatch
	var/obj/effect/countdown/flower_bud/countdown
	
	var/trait_flags = 0

	var/list/vines = list()

	/// The spawner that actually handles spawning the ghost role in
	//var/obj/effect/mob_spawn/ghost_role/venus_human_trap/spawner

/obj/structure/alien/resin/flower_bud_enemy/Initialize(mapload)
	. = ..()
	countdown = new(src)
	var/list/anchors = list()
	anchors += locate(x-2,y+2,z)
	anchors += locate(x+2,y+2,z)
	anchors += locate(x-2,y-2,z)
	anchors += locate(x+2,y-2,z)

	for(var/turf/T in anchors)
		vines += Beam(T, "vine", maxdistance=5, beam_type=/obj/effect/ebeam/vine)
	finish_time = world.time + growth_time
	addtimer(CALLBACK(src, PROC_REF(bear_fruit)), growth_time)
	countdown.start()

/obj/structure/alien/resin/flower_bud_enemy/Destroy()
	for(var/T in vines)
		qdel(T)
	. = ..()
	
/**
  * Spawns a venus human trap, then qdels itself.
  *
  * Displays a message, spawns a human venus trap, then qdels itself.
  */	
/obj/structure/alien/resin/flower_bud_enemy/proc/bear_fruit()
	visible_message(span_danger("the plant has borne fruit!"))
	new /mob/living/simple_animal/hostile/venus_human_trap(get_turf(src))
	qdel(src)

/obj/effect/ebeam/vine
	name = "thick vine"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A thick vine, painful to the touch."

/obj/effect/ebeam/vine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/ebeam/vine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		if(!isvineimmune(L))
			L.adjustBruteLoss(5)
			to_chat(L, span_alert("You cut yourself on the thorny vines."))

/**
  * Venus Human Trap
  *
  * The result of a kudzu flower bud, these enemies use vines to drag prey close to them for attack.
  *
  * A carnivorious plant which uses vines to catch and ensnare prey.  Spawns from kudzu flower buds.
  * Each one has a maximum of four vines, which can be attached to a variety of things.  Carbons are stunned when a vine is attached to them, and movable entities are pulled closer over time.
  * Attempting to attach a vine to something with a vine already attached to it will pull all movable targets closer on command.
  * Once the prey is in melee range, melee attacks from the venus human trap heals itself for 10% of its max health, assuming the target is alive.
  * Akin to certain spiders, venus human traps can also be possessed and controlled by ghosts.
  *
  */

/mob/living/simple_animal/hostile/venus_human_trap
	name = "venus human trap"
	desc = "Now you know how the fly feels."
	unique_name = TRUE
	icon_state = "venus_human_trap"
	layer = SPACEVINE_MOB_LAYER
	health = 50
	maxHealth = 50
	ranged = TRUE
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 25
	melee_damage_upper = 25
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 1, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	// Real green, cause of course
	lighting_cutoff_red = 10
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 20
	faction = list("hostile","vines","plants")
	initial_language_holder = /datum/language_holder/venus
	del_on_death = TRUE
	/// A list of all the plant's vines
	var/list/vines = list()
	/// The maximum amount of vines a plant can have at one time
	var/max_vines = 4
	/// How far away a plant can attach a vine to something
	var/vine_grab_distance = 5
	/// how long does a vine attached to something last (and its leash) (lasts twice as long on nonliving things)
	var/vine_duration = 2 SECONDS
	/// Whether or not this plant is ghost possessable
	var/playable_plant = TRUE

/mob/living/simple_animal/hostile/venus_human_trap/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/life_draining, damage_overtime = 5, check_damage_callback = CALLBACK(src, PROC_REF(kudzu_need)))
	remove_verb(src, /mob/living/verb/pulled) //no dragging the poor sap into the depths of the vines never to be seen again

/mob/living/simple_animal/hostile/venus_human_trap/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	pull_vines()
	if(kudzu_need(FALSE))
		adjustHealth(-5)
	
/mob/living/simple_animal/hostile/venus_human_trap/proc/weedkiller(damage = 6)
	adjustHealth(damage)
	to_chat(src, span_danger("The chemical reacts with you and starts to melt you away!"))

/mob/living/simple_animal/hostile/venus_human_trap/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD && kudzu_need(FALSE))
			adjustHealth(-maxHealth * 0.2)

/mob/living/simple_animal/hostile/venus_human_trap/OpenFire(atom/the_target)
	for(var/datum/beam/B in vines)
		if(B.target == the_target)
			pull_vines()
			ranged_cooldown = world.time + (ranged_cooldown_time * 0.5)
			return
	if(get_dist(src,the_target) > vine_grab_distance || vines.len >= max_vines)
		return
	for(var/turf/T in getline(src,target))
		if (T.density)
			return
		for(var/obj/O in T)
			if(O.density)
				return
	
	var/datum/beam/new_vine = Beam(the_target, icon_state = "vine", time = vine_duration * (ismob(the_target) ? 1 : 2), beam_type = /obj/effect/ebeam/vine, emissive = FALSE)
	RegisterSignal(new_vine, COMSIG_QDELETING, PROC_REF(remove_vine), new_vine)
	listclearnulls(vines)
	vines += new_vine
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(iscarbon(the_target))
			L.Immobilize(0.25 SECONDS)
			L.Knockdown(2 SECONDS)
		else
			L.Paralyze(2 SECONDS)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/venus_human_trap/Login()
	. = ..()
	to_chat(src, span_boldwarning("You are a venus human trap! Protect the kudzu at all costs, and feast on those who oppose you!"))
	to_chat(src, "Stay near vines to remain healthy.")

/mob/living/simple_animal/hostile/venus_human_trap/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_plant(user)

/**
  * Sets a ghost to control the plant if the plant is eligible
  *
  * Asks the interacting ghost if they would like to control the plant.
  * If they answer yes, and another ghost hasn't taken control, sets the ghost to control the plant.
  * Arguments:
  * * mob/user - The ghost to possibly control the plant
  */
/mob/living/simple_animal/hostile/venus_human_trap/proc/humanize_plant(mob/user)
	if(key || !playable_plant || stat)
		return
	var/plant_ask = tgui_alert(usr,"Become a venus human trap?", "Are you reverse vegan?", list("Yes", "No"))
	if(plant_ask == "No" || QDELETED(src))
		return
	if(key)
		to_chat(user, span_warning("Someone else already took this plant!"))
		return
	key = user.key
	log_game("[key_name(src)] took control of [name].")

/**
  * Manages how the vines should affect the things they're attached to.
  *
  * Pulls all movable targets of the vines closer to the plant
  * If the target is on the same tile as the plant, destroy the vine
  * Removes any QDELETED vines from the vines list.
  */
/mob/living/simple_animal/hostile/venus_human_trap/proc/pull_vines()
	for(var/datum/beam/B in vines)
		if(istype(B.target, /atom/movable))
			var/atom/movable/AM = B.target
			if(!AM.anchored)
				step(AM,get_dir(AM,src))
		if(get_dist(src,B.target) == 0)
			qdel(B)

/**
  * Removes a vine from the list.
  *
  * Removes the vine from our list.
  * Called specifically when the vine is about to be destroyed, so we don't have any null references.
  * Arguments:
  * * datum/beam/vine - The vine to be removed from the list.
  */
/mob/living/simple_animal/hostile/venus_human_trap/proc/remove_vine(datum/beam/vine, force)
	vines -= vine

/**
  * Damages the human trap if they're >3 tiles away from a kudzu
  *
  * Checks if there is a kudzu within 3 tiles
  * Damages the mob if not
  */
/mob/living/simple_animal/hostile/venus_human_trap/proc/kudzu_need(feedback = TRUE)
	for(var/obj/structure/spacevine/vine_found in view(3, src))
		return TRUE
	if(feedback && prob(20))
		to_chat(src, span_danger("You wither away without the support of the kudzu..."))
	return FALSE
