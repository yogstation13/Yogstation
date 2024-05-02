#define COOLDOWN_LARIAT 7 SECONDS
#define COOLDOWN_RUSH 7 SECONDS
#define COOLDOWN_SUPLEX 0.8 SECONDS
#define COOLDOWN_RPALM 3 SECONDS


/datum/martial_art/reverberating_palm
	name = "Reverberating Palm"
	id = MARTIALART_REVERBPALM
	no_guns = FALSE
	help_verb = /mob/living/carbon/human/proc/reverberating_palm_help
	COOLDOWN_DECLARE(next_lariat)
	COOLDOWN_DECLARE(next_rush)
	COOLDOWN_DECLARE(next_suplex)
	COOLDOWN_DECLARE(next_palm)
	var/normalharm = TRUE

//proc the moves will use for damage dealing

/datum/martial_art/reverberating_palm/proc/damagefilter(mob/living/user, mob/living/L, animaldam, persondam, borgdam)
	var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
	var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 0)
	if(iscarbon(L))
		L.apply_damage(persondam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
	if(isanimal(L))
		L.apply_damage(animaldam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
	if(issilicon(L))
		L.apply_damage(borgdam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/datum/martial_art/reverberating_palm/proc/crash(atom/movable/ram, turf/Q)
	if(Q.density || (!(Q.reachableTurftestdensity(T = Q))))
		if(isliving(ram))
			var/mob/living/target = ram
			target.adjustBruteLoss(5)
			if(isanimal(target))
				if(target.stat == DEAD)
					target.visible_message(span_warning("[target] crashes and explodes!"))
					target.gib()
		if(ismineralturf(Q))
			var/turf/closed/mineral/M = Q
			M.attempt_drill()
	if(Q.density || (!(Q.reachableTurftestdensity(T = Q))))
		return FALSE
	else 
		ram.forceMove(Q)
		return TRUE

//animation procs

//knocking them down
/datum/martial_art/reverberating_palm/proc/footsies(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = matrix(90, MATRIX_ROTATE), time = 0 SECONDS, loop = 0)
		return

//Check for if someone is allowed to be stood back up
/datum/martial_art/reverberating_palm/proc/wakeup(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = null, time = 0.4 SECONDS, loop = 0)

/datum/martial_art/reverberating_palm/proc/initiate(mob/living/user)
	var/obj/effect/temp_visual/decoy/fading/onesecond/F = new(get_turf(user), user)
	animate(F, alpha = 100, color = "#00d9ff")
	walk_towards(F, user, 0, 1.5)
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)

/datum/martial_art/reverberating_palm/can_use(mob/living/carbon/human/H)
	var/obj/item/bodypart/r_arm/robot/seismic/R = H.get_bodypart(BODY_ZONE_R_ARM)
	if(!isturf(H.loc))
		return FALSE
	if(R)
		if(!istype(R, /obj/item/bodypart/r_arm/robot/seismic))
			return FALSE
		if((R?.bodypart_disabled))
			return FALSE
	if(H.restrained() || H.get_active_held_item() || HAS_TRAIT(H, TRAIT_PACIFISM) || !(H.mobility_flags & MOBILITY_MOVE) || H.stat != CONSCIOUS)
		return FALSE
	return ..()

/datum/martial_art/reverberating_palm/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!(can_use(H)) || (modifiers["shift"] || modifiers["alt"]))
		return
	H.face_atom(target)
	if(H==target)
		if(H.a_intent == INTENT_HELP)
			supercharge(H)
		return
	if(H.a_intent == INTENT_DISARM)
		rush(H)
	if(H.a_intent == INTENT_HARM && isliving(target) && (get_dist(H, target) <= 1))
		suplex(H,target)
	if(H.a_intent == INTENT_GRAB)
		lariat(H)

/datum/martial_art/reverberating_palm/harm_act(mob/living/carbon/human/A, mob/living/D)
	if(normalharm)
		return TRUE // no punching plus slamming please

/datum/martial_art/reverberating_palm/proc/supercharge(mob/living/user)
	if(!COOLDOWN_FINISHED(src, next_palm))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_palm, COOLDOWN_RPALM)
	var/obj/item/melee/overcharged_emitter/B = new()
	user.visible_message(span_userdanger("[user]'s right arm begins crackling loudly!"))
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(user, 2 SECONDS, user, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!user.put_in_r_hand(B))
			to_chat(user, span_warning("You can't do this with your right hand full!"))
		else
			user.visible_message(span_danger("[user]'s arm begins shaking violently!"))
			if(user.active_hand_index % 2 == 1)
				user.swap_hand(0)
		//do cooldown


/datum/martial_art/reverberating_palm/proc/rush(mob/living/user)
	var/jumpdistance = 4
	var/turf/T = get_step(get_turf(user), user.dir)
	if(!COOLDOWN_FINISHED(src, next_rush))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_rush, COOLDOWN_RUSH)
	for(var/mob/living/L in T.contents)
		if(L)
			dashattack(user, user.dir, jumpdistance, 2, L)
			return
	dashattack(user, user.dir, jumpdistance, 2)

/datum/martial_art/reverberating_palm/proc/suplex(mob/living/user, mob/living/target)
	var/simpledam = 20
	var/persondam = 10
	var/borgdam = 12
	var/turf/Z = get_turf(user)
	if(!COOLDOWN_FINISHED(src, next_suplex))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_suplex, COOLDOWN_SUPLEX)
	footsies(target)
	var/turf/Q = get_step(get_turf(user), turn(user.dir,180))
	wakeup(target)
	for(var/mob/living/L in Q.contents)
		damagefilter(user, L, simpledam, persondam, borgdam)
	if(!(crash(target, Q)))
		target.forceMove(Z)
	damagefilter(user, target, simpledam, persondam, borgdam)
	if(isanimal(target))
		if(istype(target, /mob/living/simple_animal/hostile/megafauna/bubblegum))
			var/mob/living/simple_animal/hostile/megafauna/bubblegum/B = target
			var/turf/D = get_step(Q, turn(user.dir,180))
			if(B.charging)
				B.adjustBruteLoss(50)
				B.forceMove(D)
				B.visible_message(span_warning("[B] is caught and thrown behind [user]!"))
				playsound(target, 'sound/effects/explosion1.ogg', 60, 1)
				shake_camera(user, 1, 2)
				return
		if(target.stat == DEAD)
			target.visible_message(span_warning("[target] crashes and explodes!"))
			target.gib()
	to_chat(user, span_warning("[user] suplexes [target] against [Q]!"))
	to_chat(target, span_userdanger("[user] crushes you against [Q]!"))
	playsound(target, 'sound/effects/meteorimpact.ogg', 60, 1)
	playsound(user, 'sound/effects/gravhit.ogg', 20, 1)


/datum/martial_art/reverberating_palm/proc/lariat(mob/living/user)
	var/jumpdistance = 4
	if(!COOLDOWN_FINISHED(src, next_lariat))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_lariat, COOLDOWN_LARIAT)
	dashattack(user, user.dir, jumpdistance, 1) 

/datum/martial_art/reverberating_palm/proc/dashattack(mob/living/user, dir, distance = 0, type = 0, list/rushed)
	var/turf/Q = get_step(get_turf(user), dir)
	var/list/pirated = list()
	for(var/mob/living/target in rushed)
		wakeup(target)
	if(distance == 0)
		return
	if(distance == 4)
		initiate(user)
	for(var/mob/living/target in rushed)
		(crash(target, Q))
	if(Q.density || (!(Q.reachableTurftestdensity(T = Q))))
		return
	user.forceMove(Q)
	var/turf/R = get_step(Q, dir)
	for(var/mob/living/L in Q.contents)
		if(L == user)
			continue
		switch(type)
			if(1) //lariat
				var/simpledam = 50
				var/persondam = 10
				var/borgdam = 12
				playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
				to_chat(L, span_userdanger("[user] catches you with [user.p_their()] arm and clotheslines you!"))
				user.visible_message(span_warning("[user] hits [L] with a lariat!"))
				L.SpinAnimation(0.5 SECONDS, 1)
				damagefilter(user, L, simpledam, persondam, borgdam)
			if(2) //rush
				wakeup(L)
				var/simpledam = 20
				var/persondam = 4
				var/borgdam = 5
				pirated |= L
				footsies(L)
				to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and drags you down!"))
				user.visible_message(span_warning("[user] hits [L] and drags them through the dirt!"))
				L.Immobilize(0.3 SECONDS)
				wakeup(L)
				damagefilter(user, L, simpledam, persondam, borgdam)
				if(isanimal(L))
					user.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)//guaranteed extended contact with a fauna so i have to make it not a death sentence
					if(L.stat == DEAD)
						L.visible_message(span_warning("[L] is ground into paste!"))
						L.gib()
				playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
				crash(L, R)
	switch(type)
		if(1)
			addtimer(CALLBACK(src, PROC_REF(dashattack), user, dir, distance-1, type), 0.2 SECONDS)
			return
		if(2)
			addtimer(CALLBACK(src, PROC_REF(dashattack), user, dir, distance-1, type, pirated), 0.1 SECONDS)
			return

/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/reverberating_palm_help()
	set name = "Reverberating Palm"
	set desc = "You begin recalling the possibilities of the seismic arm."
	set category = "Reverberating Palm"
	var/list/combined_msg = list()

	combined_msg +=  "[span_notice("Rush")]: Your disarm has been replaced with a move that sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does damage to them and the object and attacking animals makes you momentarily tougher. Has a 7 second cooldown."

	combined_msg +=  "[span_notice("Suplex")]: Your harm has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 1 second cooldown."
	
	combined_msg +=  "[span_notice("Lariat")]: Your grab has been replaced with a lunge forward, clotheslining enemies in your way. Has a 7 second cooldown."

	combined_msg +=  "[span_notice("Rippling Palm")]: Charge up your seismic arm to put a powerful attack in your right hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, sending it flying and taking unanchored obstacles with it. However, your arm is disabled for 15 seconds afterwards."

	combined_msg +=  span_warning("You can't perform any of the moves if you have an occupied hand or limp arm.")

	combined_msg +=  span_warning("Should your moves cease to function altogether, utilize the 'Recalibrate Arm' function.")

	to_chat(usr, examine_block(combined_msg.Join("\n")))



/datum/action/cooldown/seismic_recalibrate
	name = "Recalibrate Arm"
	desc = "You recalibrate the arm to restore missing functionality."
	button_icon = 'icons/obj/implants.dmi'
	button_icon_state = "lighting_bolt"

/datum/action/cooldown/seismic_recalibrate/Activate()
	var/list/combined_msg = list()
	var/datum/martial_art/reverberating_palm/rpalm = usr.mind.martial_art
	combined_msg +=  "<b><i>You fidget with the arm in an attempt to get it working.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))
	rpalm.normalharm = TRUE
	usr.click_intercept = usr.mind.martial_art


/datum/action/cooldown/seismic_deactivate
	name = "Deactivate Arm"
	desc = "Wind down the arm temporarily, restoring your normal capabilities."
	button_icon = 'icons/obj/implants.dmi'
	button_icon_state = "emp"

/datum/action/cooldown/seismic_deactivate/Activate()
	var/list/combined_msg = list()
	var/datum/martial_art/reverberating_palm/rpalm = usr.mind.martial_art
	combined_msg +=  "<b><i>You temporarily power off the arm.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))
	rpalm.normalharm = FALSE
	usr.click_intercept = null



/datum/martial_art/reverberating_palm/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	usr.click_intercept = src 

/datum/martial_art/reverberating_palm/on_remove(mob/living/carbon/human/H)
	usr?.click_intercept = null 
	..()
