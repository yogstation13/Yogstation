#define COOLDOWN_MEGAFAUNAFINISHER 5 SECONDS

/obj/item/bloodbook
	name ="philosopher's tome"
	desc ="A grisly book that only opens to spit out magic when it detects a flickering life. These reactions send out a wave of pain whose size and strength is based on \
	the strength of the original target, and can cause chain reactions. The gem on the cover is enchanted to take damaged sustained in a moment and redirect it \
	to whoever is closest."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "grimoire"
	var/blocks = 3
	force = 0
	armour_penetration = 10 //not doing but the other damage thing has 10ap so this just lets victims who give a shit about ap know that it exists
	attack_verb = list("bashed", "schooled", "chopped")
	var/normaldam = 10
	var/otherwisedam = 40
	COOLDOWN_DECLARE(last_bigfinish)
	var/list/orelist = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/uranium, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver, /obj/item/stack/ore/diamond, /obj/item/stack/ore/bluespace_crystal, /obj/item/stack/ore/glass, /obj/item/stack/ore/plasma, /obj/item/stack/ore/titanium)

/obj/item/bloodbook/attack_self(mob/living/user)
	if(blocks <= 0)
		to_chat(user, span_warning("You can't create a shield yet!"))
		return
	user.apply_status_effect(STATUS_EFFECT_SOULSHIELD, src)
	blocks --
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	if(blocks < 3)
		addtimer(CALLBACK(src, PROC_REF(shieldcharge)), 10 SECONDS)
	if(blocks == 0)
		icon_state = "grimoireempty"

/obj/item/bloodbook/afterattack(mob/living/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isliving(target))
		return
	inflict(user, target)

/obj/item/bloodbook/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		var/mob/living/M = hit_atom
		inflict(thrownby, M, 0, FALSE)

/obj/item/bloodbook/proc/tenderize(mob/living/user, mob/living/target, var/damage = 10)
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
	var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 10)
	target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/obj/item/bloodbook/proc/sceneend(mob/living/target, mob/living/user, var/die = FALSE)
	if(die)
		target.adjustBruteLoss(target.health)
	if((target.mobility_flags & MOBILITY_STAND))
		animate(target, transform = null)
	target.color = initial(target.color)
	target.alpha = initial(target.alpha)
	animate(target, pixel_x = 0, pixel_y = 0, transform = matrix().Scale(1))
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.toggle_ai(AI_ON)
	else
		if(target != user)
			tenderize(user, target, 10)

/obj/item/bloodbook/proc/retaliate(mob/living/user, var/retaliatedam)
	var/mob/living/L
	REMOVE_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	if(retaliatedam == 0)
		return
	for(L in view(9, user))
		if(L != user)
			log_combat(user, L, "directed a counter towards", src)
			to_chat(user, span_warning("[user] redirects incoming damage towards [L]!"))
			to_chat(L, span_userdanger("[user] shifts their damage onto you!"))
			inflict(user, L, retaliatedam, FALSE)
			return

/obj/item/bloodbook/proc/blowback(mob/living/carbon/user)
	for(var/mob/living/A in range(user, 1))
		if(A == user)
			continue
		A.visible_message(span_warning("[A] is blown back!"))
		user.dna.species.disarm(user, A)
		

/obj/item/bloodbook/proc/severitycalc(mob/living/target, var/feedback)
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

/obj/item/bloodbook/proc/inflict(mob/living/user, mob/living/target, var/damage = 0, abouttobeslammed = TRUE)
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
	return

/obj/item/bloodbook/proc/shieldcharge()
	if(blocks < 1)
		icon_state = "grimoire"
	blocks++
	return

/obj/item/bloodbook/proc/splosion(mob/living/user, mob/living/target)
	var/magnitude = ((target.maxHealth/150) + 1)
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

/obj/item/bloodbook/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	. += span_notice("It has [blocks] charges available.")

/obj/item/bloodbook/proc/crystallize(mob/living/target)
	if(isanimal(target))
		target.color = "#ff0000"
		target.alpha = 100

/obj/item/bloodbook/proc/shatter(mob/living/simple_animal/target)
	var/ore = pick(orelist)
	if(!isanimal(target))
		if(target.mind)
			return
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/goat/king))
		return //cant trap people in the room forever
	if((!istype(target, /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion)))
		for(var/i =1 to 3)
			new ore(target.loc)
	if(istype(target, /mob/living/simple_animal/hostile/megafauna/legion))
		target.adjustBruteLoss(target.health)
		return
	playsound(target, "shatter", 70, 1)
	if(ismegafauna(target))
		var/mob/living/simple_animal/hostile/megafauna/L = target
		for(var/V in L.guaranteed_butcher_results)
			new V(target.loc)
		L.guaranteed_butcher_results = null
		for(var/V in L.butcher_results)
			new V(target.loc)
		L.butcher_results = null
		if(target.stat == DEAD)
			target.gib()
			return //no double dipping
		target.dust(TRUE, FALSE, TRUE)
		return
	if(isanimal(target))
		target.drop_loot()
		target.loot = null
	target.gib()

//animation stuff


/obj/item/bloodbook/proc/animatepick(mob/living/user, mob/living/target, var/severity)
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.toggle_ai(AI_OFF)
	if(severity == 1)
		if(ismegafauna(target))
			if(istype(target, /mob/living/simple_animal/hostile/megafauna/legion))
				headmassage(user,target)
				return
			if(istype(target, /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner))
				if(prob(75))
					workphobia(user,target)
					return
			pick(mash(user, target), spiritbomb(user, target))
			return
		damnedfang(user,target)
		//pick(tantrum(user, target), falling(user, target), damnedfang(user, target), dunk(user, target), shrink(user, target), redshot(user, target), vortex(user, target))
		return
	if(severity > 1)
		pick(inducingemission(user,target), concavehead(user,target))
		return

//kill animations

/obj/item/bloodbook/proc/tantrum(mob/living/user, mob/living/target, var/phase = 1, obj/hand, list/slamming)
	switch(phase)
		if(1)
			var/list/wrecking = list()
			var/obj/structure/killhand/B = new(target.loc)
			B.setDir(get_dir(user, target))
			animate(B, transform = matrix(90, MATRIX_ROTATE))
			wrecking |= B
			wrecking |= target
			target.visible_message(span_warning("A grisly hand latches around [target]!"))
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, B, wrecking), 0.2 SECONDS)
			return
		if(2)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.1 SECONDS)
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 15, time = 0.1 SECONDS, easing = LINEAR_EASING)
			target.forceMove(hand.loc)
			return
		if(3)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.3 SECONDS)
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 0, time = 0.1 SECONDS, easing = LINEAR_EASING)
			playsound(target,'sound/effects/meteorimpact.ogg', 10, 1)
			animate(target, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			return
		if(4)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.2 SECONDS)
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 25, time = 0.1 SECONDS, easing = LINEAR_EASING)
			target.forceMove(hand.loc)
			return
		if(5)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.3 SECONDS)
			animate(target, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 0, time = 0.1 SECONDS, easing = LINEAR_EASING)
			playsound(target,'sound/effects/meteorimpact.ogg', 20, 1)
			animate(target, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			return
		if(6)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.2 SECONDS)
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 35, time = 0.1 SECONDS, easing = LINEAR_EASING)
			target.forceMove(hand.loc)
			return
		if(7)
			phase++
			addtimer(CALLBACK(src, PROC_REF(tantrum), user, target, phase, hand, slamming), 0.1 SECONDS)
			for(var/atom/movable/S in slamming)
				animate(S,  pixel_y = 0, time = 0.1 SECONDS, easing = LINEAR_EASING)
			playsound(target,'sound/effects/meteorimpact.ogg', 10, 1)
			return
		if(8)
			splosion(user, target)
			shatter(target)
			qdel(hand)
	if(target)
		sceneend(target, user, TRUE)

/obj/item/bloodbook/proc/falling(mob/living/user, mob/living/target, var/phase = 1, var/obj/portalb, var/obj/portalo)
	switch(phase)
		if(1)
			var/obj/structure/propportal/O = new(target.loc)
			O.icon_state = "portal1"
			animate(O, pixel_y = 120, transform = matrix().Scale(1, 0.7))
			var/obj/structure/propportal/B = new(target.loc)
			animate(B, transform = matrix().Scale(1, 0.7))
			animate(target, pixel_y = 120)
			target.visible_message(span_warning("Portals appear above and below [target]!"))
			phase++
			addtimer(CALLBACK(src, PROC_REF(falling), user, target, phase, B, O), 0.1 SECONDS)
			return
		if(2)
			target.forceMove(portalo.loc)
			phase++
			addtimer(CALLBACK(src, PROC_REF(falling), user, target, phase, portalb, portalo), 0.45 SECONDS)
			animate(target, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			animate(target,  pixel_y = 0, time = 0.45 SECONDS, easing = LINEAR_EASING)
			return
		if(3)
			target.forceMove(portalo.loc)
			animate(target, pixel_y = 120, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			phase++
			addtimer(CALLBACK(src, PROC_REF(falling), user, target, phase, portalb, portalo), 0.3 SECONDS)
			animate(target,  pixel_y = 0, time = 0.3 SECONDS, easing = LINEAR_EASING)
			return
		if(4)
			target.forceMove(portalo.loc)
			animate(target, pixel_y = 120, transform = matrix(rand(1, 360), MATRIX_ROTATE))
			phase++
			addtimer(CALLBACK(src, PROC_REF(falling), user, target, phase, portalb, portalo), 0.15 SECONDS)
			animate(target,  pixel_y = 0, time = 0.15 SECONDS, easing = LINEAR_EASING)
			return
		if(5)
			target.visible_message(span_warning("[target] breaks on the ground!"))
			for(var/mob/L in view(10, target))
				shake_camera(L, 2, 2)
			splosion(user, target)
			shatter(target)
			qdel(portalb)
			qdel(portalo)
	if(target)
		sceneend(target, user, TRUE)
		return

/obj/item/bloodbook/proc/damnedfang(mob/living/user, mob/living/target, var/phase = 1, var/cycles = 1, var/obj/orb) //finish
	switch(phase) 
		if(1)
			var/obj/structure/bed/killbubble/B = new(target.loc)
			target.Immobilize(30)
			B.buckle_mob(target)
			B.color = "#1a1111ff"
			playsound(target, 'yogstation/sound/effects/bubbleblender.ogg', 40)
			target.visible_message(span_warning("A blood-red bubble encloses [target] and floats into the air!"))
			phase++
			target.emote("spin")
			addtimer(CALLBACK(src, PROC_REF(damnedfang), user, target, phase, cycles, B), 0.5 SECONDS)
			animate(B,  pixel_y = 30, time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target,  pixel_y = 30, transform = matrix().Scale(0.7),  time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(2)
			phase++
			addtimer(CALLBACK(src, PROC_REF(damnedfang), user, target, phase, cycles, orb), 0.5 SECONDS)
			animate(orb, transform = matrix().Scale(1.5), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(3)
			phase++
			addtimer(CALLBACK(src, PROC_REF(damnedfang), user, target, phase, cycles, orb), 0.5 SECONDS)
			animate(orb, transform = matrix().Scale(0.5), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target, transform = matrix().Scale(0.3),  time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(4)
			phase++
			addtimer(CALLBACK(src, PROC_REF(damnedfang), user, target, phase, cycles, orb), 0.5 SECONDS)
			animate(orb, transform = matrix().Scale(1), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(5)
			orb.icon_state = "leaper_bubble_pop"
			QDEL_IN(orb, 3) 
			splosion(user, target)
			shatter(target)
	if(target)
		addtimer(CALLBACK(src, PROC_REF(sceneend), target, user, TRUE), 0.5 SECONDS)
		return

/obj/item/bloodbook/proc/shrink(mob/living/user, mob/living/target, var/phase = 1, var/obj/orb)
	switch(phase) 
		if(1)
			var/obj/structure/bed/killbubble/B = new(target.loc)
			target.Immobilize(30)
			B.buckle_mob(target)
			target.visible_message(span_warning("A blood-red bubble forms around [target]!"))
			animate(B, transform = matrix().Scale(1.5))
			phase++
			addtimer(CALLBACK(src, PROC_REF(shrink), user, target, phase, B), 0.5 SECONDS)
			return
		if(2)
			phase++
			addtimer(CALLBACK(src, PROC_REF(shrink), user, target, phase, orb), 0.5 SECONDS)
			animate(orb,  transform = matrix().Scale(1.0), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target,  transform = matrix().Scale(0.8), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(3)
			phase++
			addtimer(CALLBACK(src, PROC_REF(shrink), user, target, phase, orb), 0.5 SECONDS)
			animate(orb,  transform = matrix().Scale(0.8), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target,  transform = matrix().Scale(0.6), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(4)
			phase++
			addtimer(CALLBACK(src, PROC_REF(shrink), user, target, phase, orb), 0.5 SECONDS)
			animate(orb,  transform = matrix().Scale(0.6), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target,  transform = matrix().Scale(0.4), time = 0.5 SECONDS, easing = ELASTIC_EASING)
			return
		if(5)
			target.visible_message(span_warning("[target] is crushed!"))
			orb.icon_state = "leaper_bubble_pop"
			QDEL_IN(orb, 3)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user, TRUE)
		return

/obj/item/bloodbook/proc/vortex(mob/living/user, mob/living/target, var/phase = 1, var/obj/structure/bed/killbubble/hole, atom/visual)
	switch(phase) 
		if(1)
			user.setDir(get_dir(user, target))
			var/obj/structure/bed/killbubble/B = new(get_step(get_turf(target), (user.dir)))
			B.icon = 'icons/obj/singularity.dmi'
			B.name = "vortex"
			B.desc = "A bottomless maw."
			B.icon_state = "singularity_s1"
			playsound(target,'sound/magic/charge.ogg', 50, 1)
			animate(B, transform = matrix().Scale(0.3))
			target.Immobilize(15)
			target.visible_message(span_warning("A miniature black hole appears behind [target]!"))
			var/atom/movable/gravity_lens/shockwave = new(get_turf(user))
			shockwave.transform = matrix().Scale(0.5)
			shockwave.pixel_x = -240
			shockwave.pixel_y = -240
			phase++
			addtimer(CALLBACK(src, PROC_REF(vortex), user, target, phase, B, shockwave), 0.5 SECONDS)
			animate(shockwave, alpha = 0, transform = matrix().Scale(20), time = 10 SECONDS, easing = QUAD_EASING)
			return
		if(2)
			hole.vacuum(user)
			phase++
			addtimer(CALLBACK(src, PROC_REF(vortex), user, target, phase, hole, visual), 0.5 SECONDS)
			return
		if(3)
			hole.vacuum(user)
			phase++
			addtimer(CALLBACK(src, PROC_REF(vortex), user, target, phase, hole, visual), 0.5 SECONDS)
			return
		if(4)
			target.visible_message(span_warning("[target] is torn asunder!"))
			QDEL_IN(hole, 1)
			QDEL_IN(visual, 1)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user, TRUE)
		return


/obj/item/bloodbook/proc/dunk(mob/living/user, mob/living/target, var/phase = 1, var/obj/hoop, var/turf/second)
	switch(phase)
		if(1) 
			user.Immobilize(15)
			target.Immobilize(15)
			var/turf/secondspot = target.loc
			var/turf/front = get_step(get_turf(target), (user.dir))
			var/obj/structure/holohoop/H = new(front)
			H.setDir(get_dir(H, user))
			H.alpha = 100
			H.color = "#ff0000"
			target.visible_message(span_warning("A crystalline hoop appears behind [target]!"))
			playsound(target,'sound/effects/meteorimpact.ogg', 30, 1)
			phase++
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, H, secondspot), 0.1 SECONDS)
			return
		if(2)
			phase++
			target.forceMove(user.loc)
			animate(target, pixel_x = 8)
			crystallize(target)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop, second), 0.1 SECONDS)
			return
		if(3)
			phase++
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop, second), 0.1 SECONDS)
			animate(user, pixel_y = 20, time = 0.5 SECONDS, easing = ELASTIC_EASING)
			animate(target, pixel_x = 2, pixel_y = 7)
			return
		if(4)
			phase++
			user.forceMove(second)
			target.forceMove(second)
			animate(target, pixel_x = 2, pixel_y = 12)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop), 0.1 SECONDS)
			return
		if(5)
			phase++
			animate(target, transform = matrix(90, MATRIX_ROTATE), pixel_y = 8)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop), 0.1 SECONDS)
			return
		if(6)
			phase++
			animate(target, transform = matrix(90, MATRIX_ROTATE), pixel_x = -10, pixel_y = 18)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop), 0.1 SECONDS)
			return
		if(7)
			phase++
			animate(target, transform = matrix(90, MATRIX_ROTATE), pixel_x = 0, pixel_y = 26)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop), 0.1 SECONDS)
			return
		if(8)
			phase++
			user.setDir(turn(user.dir,180))
			animate(target, transform = matrix(90, MATRIX_ROTATE), pixel_x = 0, pixel_y = 15)
			addtimer(CALLBACK(src, PROC_REF(dunk), user, target, phase, hoop), 0.1 SECONDS)
			target.visible_message(span_warning("[user] obliterates the hoop by reverse dunking [target]!"))
			return
		if(9)
			splosion(user, target)
			shatter(target)
			qdel(hoop)
			animate(user, pixel_x = 0, pixel_y = 0)
	if(target)
		sceneend(target, user, TRUE)
		return

/obj/item/bloodbook/proc/redshot(mob/living/user, mob/living/target, var/phase = 1, var/obj/structure/killight/red)
	switch(phase)
		if(1) 
			user.Immobilize(5)
			target.Immobilize(30)
			var/obj/structure/killight/B = new(user.loc)
			B.icon_state = "red_1"
			animate(B, pixel_x = 8)
			target.visible_message(span_warning("A small orb appears in front of [user]!"))
			user.setDir(get_dir(user, target))
			B.setDir(get_dir(B, target))
			phase++
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, B), 0.5 SECONDS)
			return
		if(2)
			playsound(target,'sound/effects/gravhit.ogg', 30, 1)
			phase++
			red.forceMove(target.loc)
			red.icon_state = "red_laser"
			animate(red, alpha = 220, pixel_x = 0, transform = matrix().Scale(4))
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(3)
			if(!red.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(redshot), user, target, 8, red), 0.1 SECONDS)
				return
			++phase
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(4)
			if(!red.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(redshot), user, target, 8, red), 0.1 SECONDS)
				return
			++phase
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(5)
			if(!red.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(redshot), user, target, 8, red), 0.1 SECONDS)
				return
			++phase
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(6)
			if(!red.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(redshot), user, target, 8, red), 0.1 SECONDS)
				return
			++phase
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(7)
			++phase
			if(!red.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
				return
			addtimer(CALLBACK(src, PROC_REF(redshot), user, target, phase, red), 0.1 SECONDS)
			return
		if(8)
			QDEL_IN(red, 1)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user, TRUE)
		return
//megafauna animations

//General Megafauna
/obj/item/bloodbook/proc/mash(mob/living/user, mob/living/target, var/phase = 1, var/obj/first, var/obj/second, var/obj/third, list/pillarlist)
	switch(phase)
		if(1) 
			target.visible_message(span_warning("[user] points upward and the ground around [target] begins to crack!"))
			playsound(target,'sound/effects/meteorimpact.ogg', 30, 1)
			target.setDir(get_dir(target, user))
			phase++
			addtimer(CALLBACK(src, PROC_REF(mash), user, target, phase), 0.1 SECONDS)
			return
		if(2)
			user.setDir(get_dir(user, target))
			var/list/rocks = list()
			var/obj/structure/killrock/left = new(get_step(get_step(get_turf(target), turn(target.dir, 270)), turn(target.dir, 270)))
			var/obj/structure/killrock/behind = new(get_step(get_step(get_turf(target), turn(target.dir, 180)), turn(target.dir, 180)))
			var/obj/structure/killrock/right = new(get_step(get_step(get_turf(target), turn(target.dir, 90)), turn(target.dir, 90)))
			phase++
			rocks |= left
			rocks |= behind
			rocks |= right
			addtimer(CALLBACK(src, PROC_REF(mash), user, target, phase, right, behind, left, rocks), 0.4 SECONDS)
			for(var/mob/L in view(10, target))
				shake_camera(L, 1, 1)
			for(var/obj/structure/killrock/V in rocks)
				V.stagechange()
			return
		if(3)
			var/degree = 90
			for(var/obj/structure/killrock/V in pillarlist)
				V.forceMove(get_step(get_turf(target), turn(target.dir, degree)))
				degree = degree + 90
				V.stagechange()
			for(var/mob/L in view(10, target))
				shake_camera(L, 1, 1)
			phase++
			addtimer(CALLBACK(src, PROC_REF(mash), user, target, phase, first, second, third, pillarlist), 0.4 SECONDS)
			return
		if(4)
			for(var/obj/structure/killrock/V in pillarlist)
				V.forceMove(get_turf(target))
				V.stagechange()
			phase++
			for(var/mob/L in view(10, target))
				shake_camera(L, 2, 2)
			addtimer(CALLBACK(src, PROC_REF(mash), user, target, phase, first, second, third, pillarlist), 0.1 SECONDS)
		if(5)
			splosion(user, target)
			shatter(target)
			for(var/obj/V in pillarlist)
				QDEL_IN(V, 1)
	if(target)
		sceneend(target, user)
		return

/obj/item/bloodbook/proc/spiritbomb(mob/living/user, mob/living/target, var/phase = 1, var/obj/floor, var/obj/sky, var/obj/structure/killight/genkidama)
	switch(phase)
		if(1) 
			target.visible_message(span_warning("Runes appear above and below [target]!"))
			var/obj/structure/rune/up = new(target.loc)
			var/obj/structure/rune/down = new(target.loc)
			animate(up, pixel_y = 150, transform = matrix().Scale(1, 0.6))
			down.SpinAnimation(0.5 SECONDS, 1)
			playsound(target,'sound/effects/empulse.ogg', 50, 1)
			phase++
			addtimer(CALLBACK(src, PROC_REF(spiritbomb), user, target, phase, down, up), 0.5 SECONDS)
			return
		if(2)
			var/obj/structure/killight/forming = new(floor.loc)
			forming.icon_state = "plasma"
			forming.name = "quivering energy"
			forming.desc = "An extremely unstable reaction waiting to blow."
			animate(forming, pixel_y = 120)
			animate(forming, transform = matrix().Scale(4), time = 2 SECONDS, easing = ELASTIC_EASING)
			phase++
			addtimer(CALLBACK(src, PROC_REF(spiritbomb), user, target, phase, floor, sky, forming), 1 SECONDS)
			return
		if(3)
			phase++
			addtimer(CALLBACK(src, PROC_REF(spiritbomb), user, target, phase, floor, sky, genkidama), 0.15 SECONDS)
			target.forceMove(floor.loc)
			animate(genkidama, pixel_y = 0, time = 2 SECONDS, easing = ELASTIC_EASING)
			genkidama.icon_state = "seedling"
			return
		if(4)
			for(var/mob/living/L in view(9, target))
				shake_camera(L, 4, 5)
			playsound(target,'sound/effects/explosion3.ogg', 50, 1)
			qdel(genkidama)
			qdel(sky)
			qdel(floor)
			target.visible_message(span_warning("[target] is obliterated!"))
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user)
		return

//Legion
/obj/item/bloodbook/proc/headmassage(mob/living/user, var/mob/living/simple_animal/hostile/megafauna/legion/target, var/phase = 1, obj/hand)
	switch(phase)
		if(1) 
			var/obj/structure/killhand/left = new(target.loc)
			animate(left, transform = matrix().Scale(target.size))
			playsound(target,'sound/effects/wounds/crack2.ogg', 30, 1)
			crystallize(target)
			phase++
			addtimer(CALLBACK(src, PROC_REF(headmassage), user, target, phase, left), 0.5 SECONDS)
			return
		if(2)
			target.forceMove(hand.loc)
			phase++
			addtimer(CALLBACK(src, PROC_REF(headmassage), user, target, phase, hand), 0.5 SECONDS)
		if(3)
			target.visible_message(span_warning("[target] is crushed in a vise grip!"))
			target.forceMove(hand.loc)
			QDEL_IN(hand, 1)
			shatter(target)
			splosion(user, target)
	if(target)
		sceneend(target, user)
		target.resize = target.size * 0.2
		return

//Blood Drunk Miner
/obj/item/bloodbook/proc/workphobia(mob/living/user, mob/living/target, var/phase = 1)
	switch(phase)
		if(1)
			target.visible_message(span_warning("[user] gives [target] [src]!"))
			target.setDir(get_dir(target, user))
			user.Immobilize(30)
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, do_jitter_animation), 25))
			phase++
			addtimer(CALLBACK(src, PROC_REF(workphobia), user, target, phase), 1 SECONDS)
			return
		if(2)
			animate(target, transform = matrix(90, MATRIX_ROTATE))
			target.visible_message(span_warning("[target] violently reacts to the processed mineral on the book's cover!"))
			target.emote("spin")
			crystallize(target)
			phase++
			addtimer(CALLBACK(src, PROC_REF(workphobia), user, target, phase), 2 SECONDS)
			return
		if(3)
			splosion(user, target)
			shatter(target)
	if(target)
		sceneend(target, user)
		return

//nonlethal animations

/obj/item/bloodbook/proc/inducingemission(mob/living/user, mob/living/target, var/phase = 1, var/obj/structure/killight/geometry)
	switch(phase) 
		if(1)
			var/obj/structure/killight/B = new(user.loc)
			target.Immobilize(5)
			B.icon_state = "wipe"
			B.light_range = 0
			B.light_power = 0
			B.color = "#3d0050"
			target.visible_message(span_warning("The tome spits a strange shape at [target]!"))
			B.setDir(get_dir(B, target))
			phase++
			addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, phase, B), 0.1 SECONDS)
			return
		if(2)
			geometry.forceMove(target.loc)
			target.resize = 0.6
			target.update_transform()
			phase++
			addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, phase, geometry), 0.1 SECONDS)
			return
		if(3)
			if(!geometry.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, 5, geometry), 0.1 SECONDS)
				return
			++phase
			addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, phase, geometry), 0.1 SECONDS)
			return
		if(4)
			++phase
			if(!geometry.checknextspace(target))
				addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, phase, geometry), 0.1 SECONDS)
				return
			addtimer(CALLBACK(src, PROC_REF(inducingemission), user, target, phase, geometry), 0.1 SECONDS)
			return
		if(5)
			qdel(geometry)
			splosion(user, target)
	if(target)
		sceneend(target, user)

/obj/item/bloodbook/proc/concavehead(mob/living/user, mob/living/target, var/phase = 1, obj/rend, obj/bowlingball)
	switch(phase)
		if(1)
			var/obj/effect/temp_visual/cult/portal/P = new(target.loc)
			P.density = FALSE
			animate(P, pixel_y = 30, transform = matrix().Scale(1, 0.6))
			target.forceMove(P.loc)
			target.Immobilize(20)
			target.visible_message(span_warning("A rift appears above [target]!"))
			phase++
			addtimer(CALLBACK(src, PROC_REF(concavehead), user, target, phase, P), 0.5 SECONDS)
			return
		if(2)
			target.forceMove(rend.loc)
			var/obj/structure/showmeteor/B = new(target.loc)		
			target.visible_message(span_warning("A meteor appears from the opening!"))
			animate(B, pixel_y = 30)
			B.SpinAnimation(0.15 SECONDS)
			phase++
			addtimer(CALLBACK(src, PROC_REF(concavehead), user, target, phase, rend, B), 0.15 SECONDS)
			animate(B,  pixel_y = 0, time = 0.2 SECONDS, easing = LINEAR_EASING)
			return
		if(3)
			target.visible_message(span_warning("The meteor falls onto [target]'s head!"))
			playsound(target,'sound/effects/meteorimpact.ogg', 10, 1)
			for(var/mob/living/L in view(9, target))
				shake_camera(L, 1, 1)
			qdel(rend)
			qdel(bowlingball)
			splosion(user, target)
	if(target)
		sceneend(target, user)

//PROPS

/obj/structure/bed/killbubble
	name = "crimson bubble"
	desc = "A blood-red prison."
	density = FALSE
	anchored = TRUE
	layer = MASSIVE_OBJ_LAYER
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "leaper"
	max_integrity = 500

/obj/structure/bed/killbubble/proc/vacuum(mob/living/user)
	for(var/atom/movable/A in range(src, 5))
		if(A == user)
			continue
		if((!A.anchored))
			var/shove_dir = get_dir(A, src)
			A.Move(get_step(A, shove_dir), shove_dir)

/obj/structure/killrock
	name = "ruby spire"
	desc = "An unrelenting claw."
	anchored = TRUE
	layer = MASSIVE_OBJ_LAYER
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = "bloodstone-enter1"
	max_integrity = 500
	var/stage = 1

/obj/structure/killrock/proc/stageupdate(var/stagechange = 0)
	stage = stage + stagechange
	icon_state = "bloodstone-enter[stage]"
	return

/obj/structure/killrock/proc/stagechange(var/phase = 0)
	switch(phase)
		if(0)
			++phase
			stageupdate(1)
			addtimer(CALLBACK(src, PROC_REF(stagechange), phase), 0.1 SECONDS)
		if(1)
			++phase
			stageupdate(1)
			addtimer(CALLBACK(src, PROC_REF(stagechange), phase), 0.1 SECONDS)
			return
		if(2)
			++phase
			stageupdate(-1)
			addtimer(CALLBACK(src, PROC_REF(stagechange), phase), 0.1 SECONDS)
			return
		if(3)
			++phase
			stageupdate(-1)
			addtimer(CALLBACK(src, PROC_REF(stagechange), phase), 0.1 SECONDS)
			return

/obj/structure/killhand
	name = "malevolent hand"
	layer = MASSIVE_OBJ_LAYER
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "cursehand0"
	color = "#ff0000"
	max_integrity = 500

/obj/structure/killight
	name = "crimson light"
	density = FALSE
	anchored = TRUE
	layer = MASSIVE_OBJ_LAYER
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "red_laser"
	light_range = 2
	light_power = 4
	light_color = "#ff2828"
	max_integrity = 500

/obj/structure/killight/proc/checknextspace(mob/living/L)
	var/turf/front = get_step(L.loc, (src.dir))
	if(ismineralturf(front))
		var/turf/closed/mineral/M = front
		M.attempt_drill()
	if(!(front.reachableTurftestdensity(T = front)))
		return FALSE
	src.forceMove(front)
	L.forceMove(front)
	return TRUE

/obj/structure/killight/proc/crashingdown(mob/living/L, var/morphin = 0,var/ymovement = 0)
	L.forceMove(src.loc)
	if(ymovement)
		animate(src, pixel_y = ymovement)
	if(morphin)
		animate(src, transform = matrix().Scale(morphin))

/obj/structure/showmeteor
	name = "meteor"
	density = FALSE
	icon = 'icons/obj/meteor.dmi'	
	max_integrity = 500


/obj/structure/showmeteor/Initialize(mapload)
	. = ..()
	icon_state = pick("dust", "small", "large", "glowing", "flaming", "sharp")


/obj/structure/rune
	name = "giant rune"
	desc = "It radiates a scalding heat."
	icon = 'icons/effects/96x96.dmi'
	density = FALSE
	anchored = TRUE
	icon_state = "rune_large"
	color = RUNE_COLOR_DARKRED
	pixel_x = -32
	pixel_y = -32
	max_integrity = 500

/obj/structure/propportal
	name = "portal"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = FALSE
	anchored = TRUE
