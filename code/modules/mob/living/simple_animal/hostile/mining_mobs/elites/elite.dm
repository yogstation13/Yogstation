#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list("boss")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	obj_damage = 5
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station, we'll make sure they can smash minerals fine below.
	harm_intent_damage = 0 //Punching elites gets you nowhere
	stat_attack = UNCONSCIOUS
	layer = LARGE_MOB_LAYER
	sentience_type = SENTIENCE_BOSS
	hud_type = /datum/hud/lavaland_elite
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/can_talk = FALSE
	var/obj/loot_drop = null


//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.
/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/elite_remove = alert("Re-enter the tumor?", "Despawn yourself?", "Yes", "No")
			if(elite_remove == "No" || !src || QDELETED(src))
				return
			T.mychild = null
			T.activity = TUMOR_INACTIVE
			T.icon_state = "advanced_tumor"
			qdel(src)
			return FALSE
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.attempt_drill()

//Elites can't talk (normally)!
/mob/living/simple_animal/hostile/asteroid/elite/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(can_talk)
		. = ..()
		return TRUE
	return FALSE

/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent accross the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	icon_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = ""
	background_icon_state = "bg_default"
	var/mob/living/simple_animal/hostile/asteroid/elite/M
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		M = L
		return ..()
	return FALSE

/datum/action/innate/elite_attack/Activate()
	M.chosen_attack = chosen_attack_num
	to_chat(M, chosen_message)

/mob/living/simple_animal/hostile/asteroid/elite/updatehealth()
	. = ..()
	update_health_hud()

/mob/living/simple_animal/hostile/asteroid/elite/update_health_hud()
	if(hud_used)
		var/severity = 0
		var/healthpercent = (health/maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				hud_used.healths.icon_state = "elite_health0"
			if(80 to 100)
				severity = 1
			if(60 to 80)
				severity = 2
			if(40 to 60)
				severity = 3
			if(20 to 40)
				severity = 4
			if(10 to 20)
				severity = 5
			if(1 to 20)
				severity = 6
			else
				severity = 7
		hud_used.healths.icon_state = "elite_health[severity]"
		if(severity > 0)
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

//The Pulsing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You feel compelled to reach out and touch it..."
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE
	var/activity = TUMOR_INACTIVE
	var/times_won = 0
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
								/mob/living/simple_animal/hostile/asteroid/elite/pandora,
								/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
								/mob/living/simple_animal/hostile/asteroid/elite/herald)
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	light_color = LIGHT_COLOR_RED
	light_range = 3
	anchored = TRUE
	density = FALSE
	var/obj/item/gps/internal

/obj/structure/elite_tumor/attack_hand(mob/user)
	. = ..()
	if(ishuman(user))
		switch(activity)
			if(TUMOR_PASSIVE)
				activity = TUMOR_ACTIVE
				visible_message(span_boldwarning("[src] convulses as your arm enters its radius.  Your instincts tell you to step back."))
				activator = user
				addtimer(CALLBACK(src, .proc/return_elite), 30)
				INVOKE_ASYNC(src, .proc/arena_checks)
			if(TUMOR_INACTIVE)
				activity = TUMOR_ACTIVE
				visible_message(span_boldwarning("[src] begins to convulse.  Your instincts tell you to step back."))
				activator = user
				addtimer(CALLBACK(src, .proc/spawn_elite), 3 SECONDS)

obj/structure/elite_tumor/proc/spawn_elite()
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	icon_state = "tumor_popped"
	INVOKE_ASYNC(src, .proc/arena_checks)

obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	//AddComponent(/datum/component/gps, "Menacing Signal")
	internal = new /obj/item/gps/internal/elite(src)
	START_PROCESSING(SSobj, src)

/obj/item/gps/internal/elite
	icon_state = null
	gpstag = "Menacing Signal"
	desc = "Something strange sleeps beneath the planet."
	invisibility = 100

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	mychild = null
	activator = null
	return ..()

/obj/structure/elite_tumor/process()
	if(isturf(loc))
		for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
			if(elitehere == mychild && activity == TUMOR_PASSIVE)
				mychild.adjustHealth(-mychild.maxHealth*0.05)
				var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(mychild))
				H.color = "#FF0000"

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, .proc/fighters_check)  //Checks to see if our fighters died.
	INVOKE_ASYNC(src, .proc/arena_trap)  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, .proc/border_check)  //Checks to see if our fighters got out of the arena somehow.
	addtimer(CALLBACK(src, .proc/arena_checks), 50)

/obj/structure/elite_tumor/proc/fighters_check()
	if(activator != null && activator.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(activator))
		onEliteWon()
	if(mychild != null && mychild.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(mychild))
		onEliteLoss()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/T = get_turf(src)
	if(loc == null)
		return
	for(var/t in RANGE_TURFS(12, T))
		if(get_dist(t, T) == 12)
			var/obj/effect/temp_visual/elite_tumor_wall/newwall
			newwall = new /obj/effect/temp_visual/elite_tumor_wall(t, src)
			newwall.activator = src.activator
			newwall.ourelite = src.mychild

/obj/structure/elite_tumor/proc/border_check()
	if(activator != null && get_dist(src, activator) >= 12)
		activator.forceMove(loc)
		visible_message(span_boldwarning("[activator] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= 12)
		mychild.forceMove(loc)
		visible_message(span_boldwarning("[mychild] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)

obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message(span_boldwarning("[src] begins to convulse violently before beginning to dissipate."))
	visible_message(span_boldwarning("As [src] closes, something is forced up from down below."))
	var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
	if(mychild.loot_drop) //holding this to check if the herald's loot needs to be nerfed/reworked
		new mychild.loot_drop(lootbox)
	mychild = null
	activator = null
	qdel(src)

obj/structure/elite_tumor/proc/onEliteWon()
	activity = TUMOR_PASSIVE
	activator = null
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland.  Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers.  Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "screwdriver_head"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5

/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS || !E.key)
			user.visible_message(span_notice("It appears [E] is unable to be revived right now.  Perhaps try again later."))
			return
		E.faction = list("neutral")
		E.revive(full_heal = TRUE, admin_revive = TRUE)
		user.visible_message(span_notice("[user] stabs [E] with [src], reviving it."))
		E.playsound_local(get_turf(E), 'sound/effects/magic.ogg', 40, 0)
		to_chat(E, "<span class='userdanger'>You have been revived by [user].  While you can't speak to them, you owe [user] a great debt.  Assist [user.p_them()] in achieving [user.p_their()] goals, regardless of risk.</span")
		to_chat(E, "<span class='big bold'>Note that you now share the loyalties of [user].  You are expected not to intentionally sabotage their faction unless commanded to!</span>")
		E.maxHealth = E.maxHealth * 0.25
		E.health = E.maxHealth
		E.desc = "[E.desc]  However, this one appears appears less wild in nature, and calmer around people."
		E.sentience_type = SENTIENCE_ORGANIC
		qdel(src)
	else
		to_chat(user, span_info("[src] only works on the corpse of a sentient lavaland elite."))

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "wall"
	duration = 50
	smooth = SMOOTH_TRUE
	layer = BELOW_MOB_LAYER
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/ourelite = null
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_RED

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	queue_smooth_neighbors(src)
	queue_smooth(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	queue_smooth_neighbors(src)
	activator = null
	ourelite = null
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover == ourelite || mover == activator)
		return FALSE
