#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 2
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	// Oh you KNOW it's gonna be real green
	lighting_cutoff_red = 10
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 15
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/morphed = FALSE
	var/melee_damage_disguised = 0
	var/eat_while_disguised = FALSE
	var/atom/movable/form = null
	var/morph_time = 0
	var/eat_count = 0
	var/corpse_eat_count = 0
	var/static/list/blacklist_typecache = typecacheof(list(
	/atom/movable/screen,
	/obj/singularity,
	/mob/living/simple_animal/hostile/morph,
	/obj/effect))

	var/playstyle_string = "<span class='big bold'>You are a morph,</span></b> an abomination of science created primarily with changeling cells. \
							You may take the form of anything nearby by shift-clicking it. This process will alert any nearby \
							observers, and can only be performed once every five seconds. While morphed, you move faster, but do \
							less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you. \
							You can attack any item or dead creature to consume it - creatures will restore your health. \
							Finally, you can restore yourself to your original form while morphed by shift-clicking yourself.</b>"

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = form.examine(user)
		if(get_dist(user,src)<=3)
			. += span_warning("It doesn't look quite right...")
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/med_hud_set_health()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/med_hud_set_status()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(morphed && !eat_while_disguised)
		to_chat(src, span_warning("You can not eat anything while you are disguised!"))
		return FALSE
	if(A && A.loc != src)
		visible_message(span_warning("[src] swallows [A] whole!"))
		A.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed(A))
			assume(A)
	else
		to_chat(src, span_warning("Your chameleon skin is still repairing itself!"))
		..()

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	if(morphed)
		to_chat(src, span_warning("You must restore to your original form first!"))
		return
	morphed = TRUE
	form = target

	visible_message(span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"), \
					span_notice("You twist your body and assume the form of [target]."))
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)	//fucking chameleons
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)

	//Morphed is weaker
	melee_damage_lower = melee_damage_disguised
	melee_damage_upper = melee_damage_disguised
	speed = 0

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		to_chat(src, span_warning("You're already in your normal form!"))
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = initial(animate_movement)
	maptext = null

	visible_message(span_warning("[src] suddenly collapses in on itself, dissolving into a pile of green flesh!"), \
					span_notice("You reform to your normal body."))
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message(span_warning("[src] twists and dissolves into a pile of green flesh!"), \
						span_userdanger("Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--"))
		restore()
	barf_contents()
	..()

/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/hostile/morph/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/movable/A in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(morphed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(morphed && !melee_damage_disguised)
		to_chat(src, span_warning("You can not attack while disguised!"))
		return
	if(isliving(target)) //Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 3 SECONDS, L))
				if(eat(L))
					eat_count++
					corpse_eat_count++
					adjustHealth(-50)
			return
	else if(isitem(target)) //Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src, 2 SECONDS, I))
				if(eat(I))
					eat_count++
			return
	return ..()

/mob/living/simple_animal/hostile/morph/get_status_tab_items()
	. = ..()
	. += "Things eaten: [eat_count]"
	. += "Corpses eaten: [corpse_eat_count]"
