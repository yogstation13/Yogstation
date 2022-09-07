#define TIMESKIP_SOLID_OBJECT_MULTIPLIER	3

/datum/guardian_ability/major/time
	name = "Time Erasure"
	desc = "The guardian can erase a short period of time."
	cost = 4
	spell_type = /obj/effect/proc_holder/spell/self/erase_time
	arrow_weight = 0.2

/datum/guardian_ability/major/time/Apply()
	. = ..()
	var/obj/effect/proc_holder/spell/self/erase_time/S = spell
	S.length = master_stats.potential * 2 * 10

/datum/guardian_ability/major/time/Manifest()
	if (HAS_TRAIT(guardian, TRAIT_NOINTERACT) && istype(guardian.loc, /obj/effect/dummy/phased_mob/king_crimson))
		var/obj/effect/dummy/phased_mob/king_crimson/jaunt = guardian.loc
		jaunt.forceMove(guardian.summoner.current.loc)
		return TRUE

/obj/effect/proc_holder/spell/self/erase_time
	name = "Erase Time"
	desc = "Erase the very concept of time for a short period of time."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 90 SECONDS
	action_icon_state = "time"
	var/length = 10 SECONDS

/obj/effect/proc_holder/spell/self/erase_time/cast(list/targets, mob/user)
	if (!isturf(user.loc) || !isguardian(user))
		revert_cast()
		return
	var/list/immune = list(user)
	if (isguardian(user))
		var/mob/living/simple_animal/hostile/guardian/G = user
		if (G.summoner?.current)
			immune |= G.summoner.current
			for(var/other in G.summoner.current.hasparasites())
				immune |= other
	for(var/mob/living/L in immune)
		disappear(L, length, immune)
	charge_counter = 0
	addtimer(CALLBACK(src, .proc/start_recharge), length)

/obj/effect/proc_holder/spell/self/erase_time/proc/disappear(mob/living/target, length, list/immune)
	SEND_SOUND(target, sound('yogstation/sound/effects/kingcrimson_start.ogg'))
	target.SetAllImmobility(0)
	target.setStaminaLoss(0, 0)
	target.status_flags |= GODMODE
	var/mob/living/old_pulledby = target.pulledby
	if (old_pulledby)
		target.pulledby.stop_pulling()
	var/mob/living/simple_animal/hostile/illusion/fake
	if (isturf(target.loc))
		fake = new(target.loc)
		fake.setDir(target.dir)
		fake.Copy_Parent(target, INFINITY, 100)
		fake.target = null
		if (old_pulledby)
			old_pulledby.start_pulling(fake, supress_message = TRUE)
	ADD_TRAIT(target, TRAIT_PACIFISM, GUARDIAN_TRAIT)
	ADD_TRAIT(target, TRAIT_NO_STUN_WEAPONS, GUARDIAN_TRAIT)
	ADD_TRAIT(target, TRAIT_NOINTERACT, GUARDIAN_TRAIT) // no touching anything ever
	var/obj/effect/dummy/phased_mob/king_crimson/jaunt = new(target.loc, target)
	target.forceMove(jaunt)
	var/image/invisible = image(icon = 'icons/effects/effects.dmi', icon_state = "nothing", loc = jaunt)
	invisible.override = TRUE
	jaunt.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/king_crimson, "king_crimson", invisible, NONE, immune)
	addtimer(CALLBACK(src, .proc/reappear, target, fake, jaunt), length)

/obj/effect/proc_holder/spell/self/erase_time/proc/reappear(mob/living/target, mob/living/fake, obj/effect/dummy/phased_mob/king_crimson/jaunt)
	if (fake)
		fake.()
	SEND_SOUND(target, sound('yogstation/sound/effects/kingcrimson_end.ogg'))
	target.status_flags &= ~GODMODE
	REMOVE_TRAIT(target, TRAIT_PACIFISM, GUARDIAN_TRAIT)
	REMOVE_TRAIT(target, TRAIT_NO_STUN_WEAPONS, GUARDIAN_TRAIT)
	REMOVE_TRAIT(target, TRAIT_NOINTERACT, GUARDIAN_TRAIT)
	if (target.loc == jaunt)
		target.forceMove(jaunt.loc)
	qdel(jaunt)

/obj/effect/dummy/phased_mob/king_crimson
	name = "disturbed time"
	opacity = FALSE
	mouse_opacity = FALSE
	density = FALSE
	anchored = TRUE
	var/next_animate = 0
	var/next_move = 0

/obj/effect/dummy/phased_mob/king_crimson/Initialize(mapload, mob/living/jaunter)
	. = ..(mapload)
	appearance = jaunter.appearance
	alpha = 128
	dir = jaunter.dir
	var/X,Y,i,rsq
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)
	animate(src, alpha = 127, time = 3 SECONDS, easing = LINEAR_EASING)

/obj/effect/dummy/phased_mob/king_crimson/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/king_crimson/process()
	if (next_animate > world.time)
		return
	var/i,f
	for(i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+(1 SECONDS)
		animate(f, offset=f:offset, time=0 SECONDS, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

/obj/effect/dummy/phased_mob/king_crimson/ex_act()
	return

/obj/effect/dummy/phased_mob/king_crimson/emp_act()
	return

/obj/effect/dummy/phased_mob/king_crimson/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/king_crimson/relaymove(mob/user, direction)
	if (world.time >= next_move)
		setDir(direction)
		var/turf/destination = get_step(src, direction)
		if (istype(destination, /turf/closed/indestructible))
			return
		forceMove(destination)
		var/delay = user.movement_delay()
		if (istype(loc, /turf/closed/wall) || locate(/obj/structure/window) in loc)
			delay *= TIMESKIP_SOLID_OBJECT_MULTIPLIER
		else
			var/obj/machinery/door/door = locate() in loc
			if (door?.density)
				delay *= TIMESKIP_SOLID_OBJECT_MULTIPLIER
		next_move = world.time + delay

/mob/living/simple_animal/hostile/illusion/doppelganger
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	vision_range = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	message = null

/datum/atom_hud/alternate_appearance/basic/king_crimson
	var/list/seers

/datum/atom_hud/alternate_appearance/basic/king_crimson/New(key, image/I, options, list/seers)
	..()
	src.seers = seers
	for(var/mob/M in GLOB.mob_list)
		if (mobShouldSee(M))
			add_hud_to(M)
			M.reload_huds()

/datum/atom_hud/alternate_appearance/basic/king_crimson/mobShouldSee(mob/M)
	if (isobserver(M) || (M in seers))
		return FALSE // they see the actual sprite
	return TRUE
