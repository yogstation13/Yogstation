/datum/component/spawner
	/// Time to wait between spawns
	var/spawn_time
	/// Maximum number of atoms we can have active at one time
	var/max_spawned
	/// Visible message to show when something spawns
	var/spawn_text = "emerges from"
	/// List of atom types to spawn, picked randomly
	var/list/spawn_types = list(/mob/living/simple_animal/hostile/carp)
	/// Faction to grant to mobs (only applies to mobs)
	var/list/faction = list(FACTION_MINING)
	/// List of weak references to things we have already created
	var/list/spawned_things = list()
	/// How many mobs can we spawn maximum each time we try to spawn? (1 - max)
	var/max_spawn_per_attempt
	/// Distance from the spawner to spawn mobs
	var/spawn_distance
	/// Distance from the spawner to exclude mobs from spawning
	var/spawn_distance_exclude
	COOLDOWN_DECLARE(spawn_delay)

/datum/component/spawner/Initialize(spawn_types = list(), spawn_time = 30 SECONDS, max_spawned = 5, max_spawn_per_attempt = 2 , faction = list(FACTION_MINING), spawn_text = null, spawn_distance = 1, spawn_distance_exclude = 0)
	if (!islist(spawn_types))
		CRASH("invalid spawn_types to spawn specified for spawner component!")
	src.spawn_time = spawn_time
	src.spawn_types = spawn_types
	src.faction = faction
	src.spawn_text = spawn_text
	src.max_spawned = max_spawned
	src.max_spawn_per_attempt = max_spawn_per_attempt
	src.spawn_distance = spawn_distance
	src.spawn_distance_exclude = spawn_distance_exclude

	RegisterSignals(parent, list(COMSIG_QDELETING), PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force, hint)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L in spawned_things)
		if(L.nest == src)
			L.nest = null
	spawned_things = null

/datum/component/spawner/proc/try_spawn_mob()
	if(!length(spawn_types))
		return
	if(!COOLDOWN_FINISHED(src, spawn_delay))
		return
	if(length(spawned_things) >= max_spawned)
		return
	var/atom/spawner = parent
	COOLDOWN_START(src, spawn_delay, spawn_time)
	var/chosen_mob_type = pick(spawn_types)
	var/mob/living/simple_animal/L = new chosen_mob_type(spawner.loc)
	L.flags_1 |= (spawner.flags_1 & ADMIN_SPAWNED_1)
	spawned_things += L
	L.nest = src
	L.faction = src.faction
	spawner.visible_message(span_danger("[L] [spawn_text] [spawner]."))
