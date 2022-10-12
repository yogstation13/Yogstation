#define UNREGISTER_BOMB_SIGNALS(A) \
	do { \
		UnregisterSignal(A, boom_signals); \
		UnregisterSignal(A, COMSIG_PARENT_EXAMINE); \
	} while (0)

GLOBAL_LIST_INIT(guardian_bomb_life, list(
	1 = 15 SECONDS,
	2 = 25 SECONDS,
	3 = 40 SECONDS,
	4 = 1.5 MINUTES,
	5 = 3 MINUTES
))

/datum/guardian_ability/major/explosive
	name = "Explosive"
	desc = "The guardian can, with a single touch, turn any inanimate object into a bomb."
	cost = 4
	action_types = list(/datum/action/guardian/detonate_bomb)
	var/bomb_cooldown = 0
	var/list/bombs = list()
	var/static/list/boom_signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND)

/datum/guardian_ability/major/explosive/Attack(atom/target)
	if (prob(40) && isliving(target))
		var/mob/living/M = target
		if (!M.anchored && M != guardian.summoner?.current && !guardian.hasmatchingsummoner(M))
			new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
			do_teleport(M, M, 10, channel = TELEPORT_CHANNEL_WORMHOLE)
			for(var/mob/living/L in range(1, M))
				if (guardian.hasmatchingsummoner(L)) //if the summoner matches don't hurt them
					continue
				if (L != guardian && L != guardian.summoner?.current)
					L.apply_damage(15, BRUTE)
			new /obj/effect/temp_visual/explosion(get_turf(M))

/datum/guardian_ability/major/explosive/AltClickOn(atom/target)
	if (!istype(target))
		return
	if (!guardian.is_deployed())
		to_chat(guardian, span_bolddanger("You must be manifested to create bombs!"))
		return
	if (isobj(target) && guardian.Adjacent(target))
		if (bomb_cooldown <= world.time && !guardian.stat)
			to_chat(guardian, span_bolddanger("Success! Bomb armed!"))
			bomb_cooldown = world.time + 200
			RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/display_examine)
			RegisterSignal(target, boom_signals, .proc/kaboom)
			addtimer(CALLBACK(src, .proc/disable, target), GLOB.guardian_bomb_life[guardian.stats.potential], TIMER_UNIQUE|TIMER_OVERRIDE)
			bombs += target
		else
			to_chat(guardian, span_bolddanger("Your powers are on cooldown! You must wait 20 seconds between bombs."))

/datum/guardian_ability/major/explosive/proc/kaboom(atom/source, mob/living/explodee)
	if (!istype(explodee))
		return
	if (explodee == guardian || explodee == guardian.summoner?.current || guardian.hasmatchingsummoner(explodee))
		return
	to_chat(explodee, span_bolddanger("[source] was boobytrapped!"))
	to_chat(guardian, span_bolddanger("Success! Your trap caught [explodee]"))
	var/turf/T = get_turf(source)
	playsound(T,'sound/effects/explosion2.ogg', 200, 1)
	new /obj/effect/temp_visual/explosion(T)
	explodee.ex_act(EXPLODE_HEAVY)
	bombs -= source
	UNREGISTER_BOMB_SIGNALS(source)

/datum/guardian_ability/major/explosive/proc/disable(atom/A)
	to_chat(src, span_bolddanger("Failure! Your trap didn't catch anyone this time."))
	bombs -= A
	UNREGISTER_BOMB_SIGNALS(A)

/datum/guardian_ability/major/explosive/proc/display_examine(datum/source, mob/user, text)
	text += span_holoparasite("It glows with a strange <font color=\"[guardian.namedatum.color]\">light</font>!")

/datum/action/guardian/detonate_bomb
	name = "Detonate Bomb"
	desc = "Detonate an armed bomb manually."
	button_icon_state = "killer_queen"

/datum/action/guardian/detonate_bomb/on_use(mob/living/simple_animal/hostile/guardian/user)
	var/datum/guardian_ability/major/explosive/ability = user.has_ability(/datum/guardian_ability/major/explosive)
	var/picked_bomb = input(user, "Pick which bomb to detonate", "Detonate Bomb") as null|anything in ability.bombs
	if (picked_bomb)
		ability.bombs -= picked_bomb
		UnregisterSignal(picked_bomb, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND));
		UnregisterSignal(picked_bomb, COMSIG_PARENT_EXAMINE);
		explosion(picked_bomb, -1, 1, 1, 1)
		to_chat(user, span_bolddanger("Bomb detonated."))

#undef UNREGISTER_BOMB_SIGNALS
