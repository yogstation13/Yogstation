#define COOLDOWN_SOULSHIELD 0.5 SECONDS
#define COOLDOWN_HANDSAREFULLOFBLOOD 1 SECONDS

/obj/item/midasgaunt
	name ="midas gauntlet"
	desc ="Draw stones from blood.</b>"
	icon = 'icons/obj/traitor.dmi'
	icon_state = "powerfist"
	item_state = "powerfist"
	var/blocks = 3
	attack_verb = list("slapped", "punched", "jabbed")
	var/normaldam = 10
	var/otherwisedam = 40
	var/list/orelist = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/uranium, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver, /obj/item/stack/ore/diamond, /obj/item/stack/ore/bluespace_crystal, /obj/item/stack/ore/glass, /obj/item/stack/ore/plasma, /obj/item/stack/ore/bananium, /obj/item/stack/ore/titanium)
	COOLDOWN_DECLARE(last_soulshield)
	COOLDOWN_DECLARE(last_finisher)


/obj/item/midasgaunt/attack_self(mob/living/user)
	var/cd = 0
	if(blocks <= 0)
		to_chat(user, span_warning("You can't create a shield yet!"))
		return
	user.apply_status_effect(STATUS_EFFECT_SOULSHIELD, src)
	blocks --
	if(!COOLDOWN_FINISHED(src, last_soulshield))
		to_chat(user, span_warning("You can't produce another shield yet!"))
		return
	cd = COOLDOWN_SOULSHIELD
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	COOLDOWN_START(src, last_soulshield, cd)
	if(blocks < 3)
		addtimer(CALLBACK(src, PROC_REF(gauntcharge)), 10 SECONDS)
		return

/obj/item/midasgaunt/afterattack(mob/living/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isliving(target))
		return
	inflict(user, target)

/obj/item/midasgaunt/proc/tenderize(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 10)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/obj/item/midasgaunt/proc/sceneend(mob/living/target, mob/living/user)
	if((target.mobility_flags & MOBILITY_STAND))
		animate(target, transform = null)
	animate(target, pixel_y = 0)
	animate(target, pixel_x = 0)
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.toggle_ai(AI_ON)
	else
		tenderize(user, target, 10) 


/obj/item/midasgaunt/proc/retaliate(mob/living/user, var/retaliatedam)
	var/mob/living/L
	REMOVE_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	if(retaliatedam == 0)
		return
	for(L in view(9, user))
		if(L != user)
			to_chat(user, span_warning("[user] redirects incoming damage towards [L]!"))
			to_chat(L, span_userdanger("[user] shifts their damage onto you!"))
			inflict(user, L, retaliatedam, FALSE)
			return

/obj/item/midasgaunt/proc/blowback(mob/living/user)
	var/turf/T = get_turf(user)
	for(var/mob/living/A in range(user, 1))
		if(A == user)
			continue
		A.visible_message(span_warning("[A] is blown back!"))
		var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(A, T)))
		A.safe_throw_at(throwtarget, 2, 1)

/obj/item/midasgaunt/proc/severitycalc(mob/living/target, var/feedback)
	if((target.health - feedback) <= (0))
		if(iscarbon(target) && (target.stat == DEAD))
			return FALSE
		return 1
	if(target.health >= target.maxHealth*0.6)
		if((target.health - feedback) <= (target.maxHealth*0.6))
			return 2
	if((target.health >= target.maxHealth*0.3) && (target.health <= target.maxHealth*0.6))
		if((target.health - feedback) <= (target.maxHealth*0.3))
			return 3
	return FALSE

/obj/item/midasgaunt/proc/inflict(mob/living/user, mob/living/target, var/damage = 0, abouttobeslammed = TRUE)
	var/hurt
	if(target == user)
		return
	if(isanimal(target))
		hurt = (otherwisedam+damage)
	else
		hurt = (normaldam+damage)
		if(hurt >= 20)
			hurt = 20
	var/result = (severitycalc(target,hurt))
	new /obj/effect/temp_visual/cleave(get_turf(target))//chaaaaaaaaaaaaaaaaaaaaaaange
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion))
		addtimer(CALLBACK(src, PROC_REF(splosion), user, target))
		crystallize(target)
		target.Immobilize(1)
		addtimer(CALLBACK(src, PROC_REF(shatter), target), 0.1 SECONDS)
		return
	if(result && abouttobeslammed == TRUE)
		addtimer(CALLBACK(src, PROC_REF(animatepick), user, target, result))
	if((result == 1) && (!abouttobeslammed))
		crystallize(target)
		addtimer(CALLBACK(src, PROC_REF(shatter), target), 0.2 SECONDS)
		return
	if(result != 1)
		tenderize(user, target, hurt) 
	return //also consider amping up the damage for each parry 

/obj/item/midasgaunt/proc/gauntcharge()
	blocks++
	return

/obj/item/midasgaunt/proc/splosion(mob/living/user, mob/living/target)
	var/magnitude = ((target.maxHealth/100) + 1)
	for(var/turf/closed/mineral/mine in range(target, magnitude))
		mine.attempt_drill()
	for(var/mob/living/collateral in view(target, magnitude))
		var/explosiondam = target.maxHealth/10
		if((collateral == user) || (collateral == target))
			continue
		if(!isanimal(collateral) && explosiondam >= 20)
			explosiondam = 20
		var/result = (severitycalc(collateral, explosiondam+1))
		addtimer(CALLBACK(src, PROC_REF(inflict), user, collateral, explosiondam, FALSE))
		if(result)
			addtimer(CALLBACK(src, PROC_REF(splosion), user, collateral))

/obj/item/midasgaunt/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	. += span_notice("It has [blocks] uses available.")

/obj/item/midasgaunt/proc/crystallize(mob/living/target)
	if(isanimal(target))
		target.color = "#ff0000"
		target.alpha = 100

/obj/item/midasgaunt/proc/shatter(mob/living/simple_animal/target)
	var/ore = pick(orelist)
	if(!isanimal(target))
		return
	if(istype(target, /mob/living/simple_animal/hostile/megafauna/legion))
		var/mob/living/simple_animal/hostile/megafauna/legion/L = target
		if(L.size != 1)
			playsound(L, "shatter", 50, 1)
			L.death()
			return
	if((!istype(target, /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion)))
		for(var/i =1 to 5)
			new ore(target.loc)
	if(isanimal(target))
		target.drop_loot()
		playsound(target, "shatter", 70, 1)
		if(ismegafauna(target))
			target.dust(force = TRUE)
			return
		target.gib()

//animation stuff


/obj/item/midasgaunt/proc/animatepick(mob/living/user, mob/living/target, var/severity)
	var/smackcd = 0
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.toggle_ai(AI_OFF)
	if(!COOLDOWN_FINISHED(src, last_finisher))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	smackcd = COOLDOWN_HANDSAREFULLOFBLOOD
	COOLDOWN_START(src, last_finisher, smackcd)
	if(severity == 1)
		if(ismegafauna(target))
			if(istype(target, /mob/living/simple_animal/hostile/megafauna/legion))
				headbutt(user,target)
				return
			if(istype(target, /mob/living/simple_animal/hostile/megafauna/dragon))
				stab(user,target)
				return
		pick(harpyslam(user,target), firework(user,target), backbreaker(user,target))
		return
	if(severity > 1)
		spike(user,target)
		return

//killer animations
		
/obj/item/midasgaunt/proc/harpyslam(mob/living/user, mob/living/target, var/phase = 1)
	var/turf/behind = get_step(get_turf(user), turn(user.dir,180))
	var/turf/current = user.loc
	user.Immobilize(7)
	switch(phase)
		if(1)
			if(behind.density)
				target.forceMove(current)
			else
				target.forceMove(behind)
			if(target.mobility_flags & MOBILITY_STAND)
				animate(target, transform = matrix(90, MATRIX_ROTATE))
			playsound(target, 'sound/effects/meteorimpact.ogg', 40)
			user.setDir(turn(user.dir, 180))
			phase++
			addtimer(CALLBACK(src, PROC_REF(harpyslam), user, target, phase), 0.3 SECONDS)
			return
		if(2)
			if(behind.density)
				target.forceMove(current)
			else
				target.forceMove(behind)
			if(target.mobility_flags & MOBILITY_STAND)
				animate(target, transform = matrix(180, MATRIX_ROTATE))
			crystallize(target)
			playsound(target, 'sound/effects/meteorimpact.ogg', 30)
			playsound(target, 'sound/effects/glass_step.ogg', 60)
			user.setDir(turn(user.dir, 180))
			phase++
			addtimer(CALLBACK(src, PROC_REF(harpyslam), user, target, phase), 0.3 SECONDS)
			return
		if(3)
			if(behind.density)
				target.forceMove(current)
			else
				target.forceMove(behind)
			playsound(target, 'sound/effects/meteorimpact.ogg', 40)
			user.setDir(turn(user.dir, 180))
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user)

/obj/item/midasgaunt/proc/backbreaker(mob/living/user, mob/living/target, var/phase = 1)
	switch(phase)
		if(1)
			target.forceMove(user.loc)
			target.visible_message(span_warning("[user] throws [target] over [user.p_their()] shoulders and breaks [target.p_them()]!"))
			if(target.mobility_flags & MOBILITY_STAND)
				animate(target, transform = matrix(90, MATRIX_ROTATE), pixel_y = 20)
			crystallize(target)
			phase++
			addtimer(CALLBACK(src, PROC_REF(backbreaker), user, target, phase), 0.1 SECONDS)
			return
		if(2)
			animate(user, pixel_y = 30)
			animate(target, pixel_y = 50)
			phase++
			addtimer(CALLBACK(src, PROC_REF(backbreaker), user, target, phase), 0.1 SECONDS)
			return
		if(3)
			animate(user, pixel_y = 40)
			animate(target, pixel_y = 60)
			phase++
			addtimer(CALLBACK(src, PROC_REF(backbreaker), user, target, phase), 0.1 SECONDS)
			return
		if(4)
			animate(user, pixel_y = 30)
			animate(target, pixel_y = 50)
			phase++
			addtimer(CALLBACK(src, PROC_REF(backbreaker), user, target, phase), 0.1 SECONDS)
			return
		if(5)
			animate(user, pixel_y = 0)
			animate(target, pixel_y = 20)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user)

/obj/item/midasgaunt/proc/firework(mob/living/user, mob/living/target, var/phase = 1)
	switch(phase) //add shadows here maybe
		if(1)
			target.visible_message(span_warning("[user] throws [target] into the air where [target.p_they()] shatters!"))
			target.forceMove(user.loc)
			crystallize(target)
			phase++
			addtimer(CALLBACK(src, PROC_REF(firework), user, target, phase), 0.1 SECONDS)
			return
		if(2)
			animate(target, pixel_y = 50)
			phase++
			target.SpinAnimation(2 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(firework), user, target, phase), 0.1 SECONDS)
			return
		if(3)
			animate(target, pixel_y = 60)
			phase++
			addtimer(CALLBACK(src, PROC_REF(firework), user, target, phase), 0.1 SECONDS)
			return
		if(4)
			animate(target, pixel_y = 70)
			phase++
			addtimer(CALLBACK(src, PROC_REF(firework), user, target, phase), 0.1 SECONDS)
			return
		if(5)
			animate(target, pixel_y = 80)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user)

//megafauna animations

//Legion
/obj/item/midasgaunt/proc/headbutt(mob/living/user, mob/living/target, var/phase = 1)
	switch(phase)
		if(1)
			target.visible_message(span_warning("[user] grabs [target] and headbutts [target.p_them()] into a million pieces!"))
			target.forceMove(user.loc)
			animate(target, pixel_y = 15)
			crystallize(target)
			phase++
			addtimer(CALLBACK(src, PROC_REF(headbutt), user, target, phase), 0.3 SECONDS)
			return
		if(2)
			splosion(user, target)
			shatter(target)
			return

//Ash Drake
/obj/item/midasgaunt/proc/stab(mob/living/user, mob/living/target, var/phase = 1)
	switch(phase)
		if(1)
			target.visible_message(span_warning("[user] jabs [target] through the chest!"))
			target.setDir(get_dir(target, user))
			user.Immobilize(10)
			crystallize(target)
			playsound(target,'sound/effects/tendril_destroyed.ogg', 50, 1)
			phase++
			addtimer(CALLBACK(src, PROC_REF(stab), user, target, phase), 0.8 SECONDS)
			return
		if(2)
			splosion(user, target)
			shatter(target)
			return

//nonlethal animations

/obj/item/midasgaunt/proc/spike(mob/living/user, mob/living/target, var/phase = 1)
	var/turf/front = get_step(get_turf(user), (user.dir))
	var/turf/twosteps = get_step(front, (user.dir))
	switch(phase) //add shadows here maybe
		if(1)
			target.visible_message(span_warning("[user] leaps into the air and sends [target] hurtling towards the ground!"))
			target.forceMove(user.loc)
			phase++
			addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
			return
		if(2)
			animate(user, pixel_y = 30)
			animate(target, pixel_x = -5, pixel_y = 50)
			phase++
			addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
			return
		if(3)
			animate(user, pixel_y = 40)
			phase++
			if(front.reachableTurftestdensity(T = front))
				target.forceMove(front)
				addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
				target.SpinAnimation(0.7 SECONDS)
				return
			addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
			target.SpinAnimation(0.7 SECONDS)
			return
		if(4)
			phase++
			animate(target, pixel_y = 30)
			if(twosteps.reachableTurftestdensity(T = twosteps) && front.reachableTurftestdensity(T = front))
				target.forceMove(twosteps)
				addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
				return
			addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
			return
		if(5)
			animate(user, pixel_y = 20)
			animate(target, pixel_y = 0)
			for(var/mob/living/Q in view(9, target))
				shake_camera(Q, 4, 3) 
			phase++
			addtimer(CALLBACK(src, PROC_REF(spike), user, target, phase), 0.1 SECONDS)
			return
		if(6)
			animate(user, pixel_y = 0)
			splosion(user, target)
	if(target)
		sceneend(target, user)


