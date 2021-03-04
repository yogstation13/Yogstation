/mob/living/simple_animal/hostile/drakeling
	name = "drakeling"
	desc = "A baby dragon! While relatively smaller than an adult, it's still larger than a person."
	maxHealth = 200
	health = 200
	speed = 5
	move_to_delay = 10
	speak_emote = list("roars")
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	a_intent = INTENT_HARM
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "ash_whelp"
	icon_living = "ash_whelp"
	icon_dead ="ash_whelp_dead"
	attacktext = "chomps"
	vision_range = 4
	aggro_vision_range = 7
	melee_damage_lower = 15
	melee_damage_upper = 15
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	speak_chance = 5
	weather_immunities = list("lava", "ash")
	movement_type = FLYING
	faction = list("neutral")
	minbodytemp = 0 //SPACE
	maxbodytemp = INFINITY //DRAGON
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	emote_see = list("flaps its little wings.", "waves its tail.","hops around a few times.", "breathes out a little smoke.", "tilts its head.")
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/stack/ore/diamond = 3) //you MONSTER
	tame = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	var/attack_cooldown = 0
	var/list/food_items = list(/obj/item/reagent_containers/food/snacks/meat/slab/goliath = 20, /obj/item/reagent_containers/food/snacks/meat/steak/goliath = 40)
	var/list/action_types = list(/obj/effect/proc_holder/drakeling/fire_breath, /obj/effect/proc_holder/drakeling/wing_flap)
	var/list/obj/effect/proc_holder/drakeling/dragon_actions = list()
	var/grinding = FALSE
	var/datum/action/drake_ollie/dollie

/mob/living/simple_animal/hostile/drakeling/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8, MOB_LAYER), TEXT_SOUTH = list(0, 8, MOB_LAYER), TEXT_EAST = list(0, 8, MOB_LAYER), TEXT_WEST = list( 0, 8, MOB_LAYER)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)
	D.vehicle_move_delay = 1
	dollie = new
	dollie.dragon = src
	for(var/action_type in action_types)
		var/obj/effect/proc_holder/drakeling/attack_action = new action_type
		AddAbility(attack_action)
		dragon_actions |= attack_action
		attack_action.drake = src
	RegisterSignal(src, COMSIG_MOVABLE_BUCKLE, .proc/give_abilities)
	RegisterSignal(src, COMSIG_MOVABLE_UNBUCKLE, .proc/remove_abilities)

/mob/living/simple_animal/hostile/drakeling/proc/give_abilities(mob/living/drake, mob/living/M, force = FALSE)
	toggle_ai(AI_OFF)
	if(istype(click_intercept, /obj/effect/proc_holder/drakeling))
		var/obj/effect/proc_holder/drakeling/D = click_intercept
		D.remove_ranged_ability()
	dollie.Grant(M)
	for(var/action in dragon_actions)
		var/obj/effect/proc_holder/drakeling/attack_action = action
		RemoveAbility(attack_action)
		M.AddAbility(attack_action)

/mob/living/simple_animal/hostile/drakeling/proc/remove_abilities(mob/living/drake, mob/living/M, force = FALSE)
	toggle_ai(AI_ON)
	if(istype(M.click_intercept, /obj/effect/proc_holder/drakeling))
		var/obj/effect/proc_holder/drakeling/D = M.click_intercept
		D.remove_ranged_ability()
	dollie.Remove(M)
	for(var/action in dragon_actions)
		var/obj/effect/proc_holder/drakeling/attack_action = action
		M.RemoveAbility(attack_action)
		AddAbility(attack_action)

/mob/living/simple_animal/hostile/drakeling/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/clothing/neck/petcollar))
		var/obj/item/clothing/neck/petcollar/P = O
		if(P.tagname)
			fully_replace_character_name(null, "[P.tagname]")
		return

	if(is_type_in_list(O, food_items))
		if(!stat)
			if(health != maxHealth)
				user.visible_message("<span class='notice'>[user] feeds [name] with [O].</span>", "<span class='notice'>You feed [src] with [O], and some of its wounds begin to heal!</span>")
				adjustBruteLoss(-food_items[O.type])
				qdel(O)
			else
				to_chat(user, "<span class='notice'>[src] doesn't look hungry right now.</span>")
	else
		..()

/mob/living/simple_animal/hostile/drakeling/death(gibbed)
	. = ..()
	for(var/mob/living/N in buckled_mobs)
		unbuckle_mob(N)
	can_buckle = FALSE



/obj/effect/proc_holder/drakeling
	name = "ULTRA DRAGON ATTACK"
	desc = "if you can see this something has probably gone very wrong and you should make a bug report."
	var/mob/living/simple_animal/hostile/drakeling/drake
	var/cooldown = 5 SECONDS
	action_background_icon_state = "bg_demon"
	panel = "Dragon"
	active = FALSE
	var/prepare_message = "<span class='notice'>You prepare %YOUR ULTRA DRAGON ATTACK</span>"
	var/unprepare_message = "<span class='notice'>You decide to spare the mortals for now...</span>"

/obj/effect/proc_holder/drakeling/Click()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	if(can_cast(user))
		fire(user)
	return TRUE

/obj/effect/proc_holder/drakeling/proc/can_cast(mob/living/L)
	. = TRUE
	if(L.stat)
		to_chat(L, "You must be conscious to do this!")
		return FALSE
	if(L.IsStun() || L.IsParalyzed())
		to_chat(L, "You can't [L == drake ? "use your attacks" : "direct your dragon"] while you're stunned!")
		return FALSE
	if(L.restrained())
		to_chat(L, "You can't [L == drake ? "use your attacks" : "direct your dragon"] while you're restrained!")
		return FALSE

/obj/effect/proc_holder/drakeling/fire(mob/living/user)
	var/msg
	if(!active)
		msg = replacetext(prepare_message, "%YOUR", "[user == drake ? "your" : "to direct your dragon's"]")
		add_ranged_ability(usr, msg, TRUE)
	else
		msg = replacetext(unprepare_message, "%YOUR", "[user == drake ? "your" : "to direct your dragon's"]")
		remove_ranged_ability(msg)


/obj/effect/proc_holder/drakeling/InterceptClickOn(mob/living/L, params, atom/A)
	if(..())
		return TRUE
	drake.face_atom(A)
	if(drake.attack_cooldown > world.time)
		to_chat(L, "<span class='warning'>Your[L == drake ? "" : " dragon's"] attack is not ready yet!")
		return TRUE
	if(!can_cast(L))
		remove_ranged_ability(L)
		return  TRUE
	drake.attack_cooldown = cooldown + world.time
	addtimer(CALLBACK(src, .proc/cooldown_over, L), cooldown)
	if(L != drake)
		addtimer(CALLBACK(src, .proc/cooldown_over, drake), cooldown)

/obj/effect/proc_holder/drakeling/proc/cooldown_over(mob/living/L)
	to_chat(L, "<span class='notice'>You[L == drake ? "are" : "r dragon is"] ready for another attack!")

/obj/effect/proc_holder/drakeling/Destroy()
	drake = null
	return ..()

///drakeling fire breath attack: shoots a short line of fire that is very effective against lavaland fauna and not very effective against much else
/obj/effect/proc_holder/drakeling/fire_breath
	name = "Fire Breath"
	desc = "Breathe a short flame that is effective against fauna but worthless off of lavaland."
	action_icon = 'icons/obj/wizard.dmi'
	action_icon_state = "fireball"
	cooldown = 2 SECONDS
	prepare_message = "<span class='notice'>You prepare %YOUR fire breath attack</span>"
	unprepare_message = "<span class='notice'>You decide to refrain from roasting more peasants for the time.</span>"

/obj/effect/proc_holder/drakeling/fire_breath/InterceptClickOn(mob/living/L, params, atom/A)
	if(..())
		return TRUE
	playsound(get_turf(drake),'sound/magic/fireball.ogg', 100, 1)
	var/turf/T = get_turf(drake)
	var/range = is_mining_level(T.z) ? 4 : 1 //1 tile range means it tends to be incapable of firing diagonally but if it's any longer it's "not a melee weapon"
	var/damage = is_mining_level(T.z) ? 20 : 5
	var/list/turfs = list()
	var/list/protected = list(drake, L)
	turfs = drake.line_target(range, A)
	INVOKE_ASYNC(src, .proc/drakeling_fire_line, drake, turfs, damage, protected)

///gets the list of turfs the fire breath attack hits
/mob/living/simple_animal/hostile/drakeling/proc/line_target(var/range, var/atom/at)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y)
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (getline(src, T) - get_turf(src))

///actual bit that shoots fire for the fire breath attack
/obj/effect/proc_holder/drakeling/proc/drakeling_fire_line(var/source, var/list/turfs, var/damage, var/list/protected)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		for(var/mob/living/L in T.contents)
			if((L in hit_list) || (L in protected))
				continue
			hit_list += L
			if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
				L.adjustBruteLoss(damage * 3) //60 damage plus the normal damage against fauna, total of 80 should make it mega competitive vs other weapons
			L.adjustFireLoss(damage)
			to_chat(L, "<span class='userdanger'>You're hit by [source]'s fire breath!</span>")
		sleep(1)

///drakeling wing flap attack: deals relatively minor damage to lavaland fauna and pushes anything it hits away, also breaks rocks on contact like a plasmacutter
/obj/effect/proc_holder/drakeling/wing_flap
	name = "Wing Flap"
	desc = "Causes a large, powerful gust of air to push stuff away, deal damage to fauna, and break rocks."
	action_icon_state = "tornado"
	action_icon = 'icons/obj/wizard.dmi'
	cooldown = 2 SECONDS
	prepare_message = "<span class='notice'>You prepare %YOUR wings.</span>"
	unprepare_message = "<span class='notice'>You stop the flapping.</span>"
	var/shootie = /obj/item/projectile/wing

/obj/effect/proc_holder/drakeling/wing_flap/InterceptClickOn(mob/living/L, params, atom/A)
	if(..())
		return TRUE
	playsound(get_turf(drake),'sound/magic/repulse.ogg', 100, 1)
	var/list/shooties = list()
	shooties += new shootie(get_turf(drake))
	if(drake.dir == SOUTH || drake.dir == NORTH)
		shooties += new shootie(get_step(drake, EAST))
		shooties += new shootie(get_step(drake, WEST))
	else
		shooties += new shootie(get_step(drake, NORTH))
		shooties += new shootie(get_step(drake, SOUTH))
	for(var/S in shooties)
		var/obj/item/projectile/wing/shooted = S
		shooted.firer = L
		shooted.fire(dir2angle(drake.dir))

/obj/item/projectile/wing
	name = "wing blast"
	damage = 0
	range = 5
	hitsound = 'sound/effects/space_wind_big.ogg'
	icon_state = "energy2"
	var/mine_range = 5 //same as an advanced cutter but there's three of them

/obj/item/projectile/wing/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(istype(L, /mob/living/simple_animal/hostile/drakeling))
			return BULLET_ACT_FORCE_PIERCE
		if(!ishuman(target))
			var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
			L.safe_throw_at(throw_target, 2, 2, force = MOVE_FORCE_VERY_STRONG) //pushes goliaths
		else
			var/push_dir = get_dir(loc, L.loc)
			var/turf/target_push_turf = get_step(L.loc, push_dir)
			L.Move(target_push_turf, push_dir)
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.adjustBruteLoss(40)
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE


///dragon ollie, do I have to explain?
/datum/action/drake_ollie
	name = "DRAGON Ollie"
	desc = "This seems like a REALLY COOL IDEA"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "dragon_ollie"
	//cooldown to next jump
	var/next_ollie
	var/mob/living/simple_animal/hostile/drakeling/dragon

/datum/action/drake_ollie/Trigger()
	if(world.time > next_ollie)
		if(dragon.grinding)
			return
		var/mob/living/L = owner
		var/turf/landing_turf = get_step(dragon.loc, dragon.dir)
		L.spin(4, 1)
		animate(L, pixel_y = -6, time = 4)
		animate(dragon, pixel_y = -6, time = 3)
		playsound(dragon, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
		passtable_on(L, VEHICLE_TRAIT)
		passtable_on(dragon, VEHICLE_TRAIT)
		L.Move(landing_turf, dragon.dir)
		passtable_off(L, VEHICLE_TRAIT)
		passtable_off(dragon, VEHICLE_TRAIT)
		if(locate(/obj/structure/table) in dragon.loc.contents)
			addtimer(CALLBACK(dragon, /mob/living/simple_animal/hostile/drakeling.proc/grind), 2)
		next_ollie = world.time + 50 //this gives a "slight" speed boost when used and unlike the skateboard variant doesn't have much of a downside so the cooldown is longer

/mob/living/simple_animal/hostile/drakeling/proc/grind()
	var/turf/T = get_step(src, dir)
	if(!Move(T))
		grinding = FALSE
		return
	if(has_buckled_mobs() && locate(/obj/structure/table) in loc.contents)
		playsound(src, 'sound/vehicles/skateboard_roll.ogg', 50, TRUE)
		addtimer(CALLBACK(src, .proc/grind), 2)
		return
	else
		grinding = FALSE
