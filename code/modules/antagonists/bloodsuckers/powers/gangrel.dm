/datum/action/bloodsucker/gangrel
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	background_icon_state = "gangrel_power_off"
	background_icon_state_on = "gangrel_power_on"
	background_icon_state_off = "gangrel_power_off"
	purchase_flags = GANGREL_CAN_BUY
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_AM_COSTLESS_UNCONSCIOUS
	cooldown = 10 SECONDS

/datum/action/bloodsucker/gangrel/transform
	name = "Transform"
	desc = "Allows you to unleash your inner form and turn into something greater."
	button_icon_state = "power_gangrel"
	power_explanation = "<b>Transform</b>:\n\
		A gangrel only power, will turn you into a feral being depending on your blood sucked.\n\
		May have unforseen consequences if used on low blood sucked, upgrades every 500 units.\n\
		Some forms have special abilites to them depending on what abilites you have.\n\
		Be wary of your blood status when using it, takes 10 seconds of standing still to transform!"
	power_flags = BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	bloodcost = 100

/datum/action/bloodsucker/gangrel/transform/ActivatePower()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/human/user = owner
	var/datum/species/user_species = user.dna.species
	var/minortransformdone = FALSE
	var/mediumtransformdone = FALSE
	user.Immobilize(10 SECONDS)
	if(!do_mob(user, user, 10 SECONDS, 1))
		return
	switch(bloodsuckerdatum.total_blood_drank)
		if(0 to 500)
			if(!minortransformdone)
				if(iscatperson(user))
					user.set_species(/datum/species/lizard)
					playsound(user.loc, 'sound/voice/lizard/hiss.ogg', 50)
				else
					user.set_species(/datum/species/human/felinid)
					playsound(user.loc, 'sound/voice/feline/meow1.ogg', 50)
					if(DIGITIGRADE in user_species.species_traits)
						user_species.species_traits -= DIGITIGRADE
				minortransformdone = TRUE
				user.dna.species.punchdamagelow += 5.0
				user.dna.species.punchdamagehigh += 5.0 //stronk
				user.dna.species.punchstunthreshold += 5.0
				user.dna.species.armor += 30
				to_chat(user, span_notice("You aren't strong enough to morph into something stronger! But you do certainly feel more feral and stronger than before."))
			else
				to_chat(user, span_notice("You still haven't evolved your ability yet."))
				bloodsuckerdatum.AddBloodVolume(75)
		if(500 to 1000)
			if(!mediumtransformdone)
				user.set_species(/datum/species/gorilla)
				playsound(user.loc, 'sound/creatures/gorilla.ogg', 50)
				if(DIGITIGRADE in user_species.species_traits)
					user_species.species_traits -= DIGITIGRADE
				mediumtransformdone = TRUE
				user.dna.species.punchdamagelow += 7.5
				user.dna.species.punchdamagehigh += 7.5 //very stronk
				user.dna.species.punchstunthreshold += 7.5
				user.dna.species.armor += 35
				to_chat(owner, span_notice("You transform into a gorrila-ey beast, you feel stronger!"))
			else
				to_chat(owner, span_notice("You still haven't evolved your ability yet."))
				bloodsuckerdatum.AddBloodVolume(50)
		if(1500 to INFINITY)
			var/mob/living/simple_animal/hostile/bloodsucker/giantbat/gb
			if(!gb || gb.stat == DEAD)
				gb = new /mob/living/simple_animal/hostile/bloodsucker/giantbat(user.loc)
				user.forceMove(gb)
				gb.bloodsucker = user
				user.status_flags |= GODMODE //sad!
				user.mind.transfer_to(gb)
				var/list/bat_powers = list(new /datum/action/bloodsucker/gangrel/transform_back,)
				for(var/datum/action/bloodsucker/power in bloodsuckerdatum.powers)
					if(istype(power, /datum/action/bloodsucker/targeted/haste))
						bat_powers += new /datum/action/bloodsucker/targeted/haste/batdash
					if(istype(power, /datum/action/bloodsucker/targeted/mesmerize))
						bat_powers += new /datum/action/bloodsucker/targeted/bloodbolt
					if(istype(power, /datum/action/bloodsucker/targeted/brawn))
						bat_powers += new /datum/action/bloodsucker/gangrel/wingslam
				for(var/datum/action/bloodsucker/power in bat_powers) 
					power.Grant(gb)
				QDEL_IN(gb, 2 MINUTES)
				playsound(gb.loc, 'sound/items/toysqueak1.ogg', 50, TRUE)
			to_chat(owner, span_notice("You transform into a fatty beast!"))
			return ..() //early to not mess with vampire organs proc
	bloodsuckerdatum.HealVampireOrgans() //regives you the stuff
	. = ..()

/datum/action/bloodsucker/gangrel/transform_back
	name = "Transform"
	desc = "Regress back into a human."
	button_icon_state = "power_gangrel"
	power_explanation = "<b>Transform</b>:\n\
		Regress back to your humanoid form early, requires you to stand still.\n\
		Beware you will not be able to transform again until the night passes!"
		
/datum/action/bloodsucker/gangrel/transform_back/ActivatePower()
	var/mob/living/user = owner
	if(!do_mob(user, user, 10 SECONDS))
		return
	var/mob/living/simple_animal/hostile/bloodsucker/bs
	qdel(owner)
	qdel(bs)
	. = ..()
/*
////////////////||\\\\\\\\\\\\\\\\
\\           Bat Only           //
//            Powers            \\
\\\\\\\\\\\\\\\\||////////////////
*/
/datum/action/bloodsucker/targeted/haste/batdash
	name = "Flying Haste"
	desc = "Propulse yourself into a position of advantage."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_baste"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Flying Haste</b>:\n\
		Makes you dash into the air, creating a smoke cloud at the end.\n\
		Helpful in situations where you either need to run away or engage in a crowd of people, works over tables.\n\
		Created from your Immortal Haste ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 15 SECONDS

/datum/action/bloodsucker/targeted/haste/batdash/CheckCanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/haste/batdash/FireTargetedPower(atom/target_atom)
	. = ..()
	do_smoke(2, owner.loc, smoke_type = /obj/effect/particle_effect/smoke/transparent) //so you can attack people after hasting

/datum/action/bloodsucker/targeted/bloodbolt
	name = "Blood Bolt"
	desc = "Shoot a blood bolt to damage your foes."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_bolt"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Blood Bolt</b>:\n\
		Shoots a blood bolt that does moderate damage to your foes.\n\
		Helpful in situations where you get outranged or just extra damage.\n\
		Created from your Mesmerize ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 12.5 SECONDS

/datum/action/bloodsucker/targeted/bloodbolt/CheckCanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	to_chat(user, span_warning("You fire a blood bolt!"))
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target_atom, user))
	var/obj/item/projectile/magic/arcane_barrage/bloodsucker/magic_9ball = new(user.loc)
	magic_9ball.bloodsucker_power = src
	magic_9ball.firer = user
	magic_9ball.def_zone = ran_zone(user.zone_selected)
	magic_9ball.preparePixelProjectile(target_atom, user)
	INVOKE_ASYNC(magic_9ball, /obj/item/projectile.proc/fire)
	playsound(user, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	PowerActivatedSuccessfully()

/obj/item/projectile/magic/arcane_barrage/bloodsucker
	name = "blood bolt"
	icon_state = "bloodbolt"
	damage_type = BURN
	damage = 30
	var/datum/action/bloodsucker/targeted/bloodbolt/bloodsucker_power

/obj/item/projectile/magic/arcane_barrage/bloodsucker/on_hit(target)
	if(ismob(target))
		qdel(src)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.Knockdown(0.1)
		return BULLET_ACT_HIT
	. = ..()

/datum/action/bloodsucker/gangrel/wingslam
	name = "Wing Slam"
	desc = "Slams all foes next to you."
	button_icon_state = "power_wingslam"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Wing Slam</b>:\n\
		Knocksback and immobilizes people adjacent to you.\n\
		Has a low recharge time and may be helpful in meelee situations!\n\
		Created from your Brawn ability."
	check_flags = NONE
	bloodcost = 0

/datum/action/bloodsucker/gangrel/wingslam/ActivatePower()
	var/mob/living/user = owner
	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1, user))
		choices += C

	if(!choices.len)
		return

	for(var/mob/living/carbon/M in range(1, user))
		if(!M || !M.Adjacent(user))
			return
		if(M.loc == user)
			continue
		M.visible_message(
			span_danger("[user] flaps their wings viciously, sending [M] flying away!"), \
			span_userdanger("You were sent flying by the flap of [user]'s wings!"),
		)
		to_chat(user, span_warning("You flap your wings, sending [M] flying!"))
		playsound(user.loc, 'sound/weapons/punch4.ogg', 60, 1, -1)
		M.adjustBruteLoss(10)
		M.Knockdown(40)
		user.do_attack_animation(M, ATTACK_EFFECT_SMASH)
		var/send_dir = get_dir(user, M)
		var/turf/turf_thrown_at = get_ranged_target_turf(M, send_dir, 5)
		M.throw_at(turf_thrown_at, 5, TRUE, user)

/*  //\\                  //\\    
////////////////||\\\\\\\\\\\\\\\\
\\           Wolf Only          //
//            Powers            \\
\\\\\\\\\\\\\\\\||////////////////
*/  

/datum/action/bloodsucker/targeted/feast
	name = "Feast"
	desc = "DEVOUR THE WEAKLINGS, CAUSE THEM HARM. FEED. ME."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_feast"
	background_icon_state_on = "wolf_power_on"
	background_icon_state_off = "wolf_power_off"
	power_explanation = "<b>Feast</b>:\n\
		Feasting on a dead person will give you a satiation point and gib them.\n\
		Satiation points are essential for overcoming frenzy, after gathering 3 you'll turn back to normal.\n\
		Feasting on someone while they are alive will bite them and make them bleed.\n\
		Has a medium recharge time to be helpful in combat.\n\
		There might be some consequences after coming back from frenzy though.." 
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 10 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "WHOM SHALL BE DEVOURED."

/datum/action/bloodsucker/targeted/feast/FireTargetedPower(atom/target_atom)
	if(isturf(target_atom))
		return
	owner.face_atom(target_atom)
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/user = owner
	var/mob/living/carbon/human/target = target_atom
	if(target.stat == DEAD)
		user.devour(target)
		PowerActivatedSuccessfully()
		return
	user.do_attack_animation(target, ATTACK_EFFECT_BITE)
	var/affecting = pick(BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	playsound(get_turf(target), 'sound/weapons/bite.ogg', 60, 1, -1)
	target.apply_damage(35, BRUTE, affecting, target.run_armor_check(affecting, "melee", armour_penetration = 10), sharpness = SHARP_EDGED)
	target.visible_message(span_danger("[user] takes a large bite out of [target]!"), \
					  span_userdanger("[user] takes a large bite out of you!"))
	PowerActivatedSuccessfully()

/datum/action/bloodsucker/gangrel/wolfortitude
	name = "Wolftitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_wort"
	background_icon_state_on = "wolf_power_on"
	background_icon_state_off = "wolf_power_off"
	power_explanation = "<b>Fortitude</b>:\n\
		Activating Wolftitude will provide more attack damage, and more overall health.\n\
		It will give you a minor health buff while it stands, but slow you down severely.\n\
		It has a decent cooldown time to allow yourself to turn it off and run away for a while.\n\
		Created from your Fortitude ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 8 SECONDS

/datum/action/bloodsucker/gangrel/wolfortitude/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("Your fur and claws harden, becoming as hard as steel."))
	var/mob/living/simple_animal/hostile/A = owner
	A.maxHealth *= 1.2
	A.health *= 1.2
	A.set_varspeed(initial(A.speed) + 2) // slower
	A.harm_intent_damage += 10
	A.melee_damage_lower += 10
	A.melee_damage_upper += 10

/datum/action/bloodsucker/gangrel/wolfortitude/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/A = owner
	A.maxHealth /= 1.2
	A.health /= 1.2
	A.set_varspeed(initial(A.speed))
	A.harm_intent_damage -= 10
	A.melee_damage_lower -= 10
	A.melee_damage_upper -= 10

/datum/action/bloodsucker/targeted/pounce
	name = "Pounce"
	desc = "GRAPPLE THEM TO THE GROUND AND BITE THEIR ORGANS OUT."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_pounce"
	background_icon_state_on = "wolf_power_on"
	background_icon_state_off = "wolf_power_off"
	power_explanation = "<b>Pounce</b>:\n\
		Click any player to instantly dash at them, knocking them down and paralyzing them for a short while.\n\
		Additionally if they are dead you'll consume their corpse to gain satiation and get closer to leaving frenzy.\n\
		Created from your Predatory Lunge ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 10 SECONDS
	target_range = 6
	power_activates_immediately = FALSE

/datum/action/bloodsucker/targeted/pounce/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.icon_state = initial(A.icon_state) + "_pounce"
	A.icon_living = initial(A.icon_state) + "_pounce"
	A.update_body()

/datum/action/bloodsucker/targeted/pounce/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.icon_state = initial(A.icon_state)
	A.icon_living = initial(A.icon_state)
	A.update_body()

/datum/action/bloodsucker/targeted/pounce/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/user = owner
	owner.face_atom(target_atom)
	if(iscarbon(target_atom))
		var/mob/living/carbon/target = target_atom
		var/turf/targeted_turf = get_turf(target)
		var/safety = get_dist(user, targeted_turf) * 3 + 1
		var/consequetive_failures = 0
		while(--safety && !target.Adjacent(user))
			if(!step_to(user, targeted_turf))
				consequetive_failures++
			if(consequetive_failures >= 3) // If 3 steps don't work, just stop.
				break
		if(target.stat == DEAD)
			if(!user.Adjacent(target))
				return
			user.devour(target)
			PowerActivatedSuccessfully()
			return
		target.Knockdown(6 SECONDS)
		target.Paralyze(1 SECONDS)
	PowerActivatedSuccessfully()

/datum/action/bloodsucker/targeted/pounce/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/bloodsucker/targeted/pounce/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE
	return FALSE

/datum/action/bloodsucker/gangrel/howl
	name = "Howl"
	desc = "BREATHE IN AND BREATH OUT AS MUCH AS POSSIBLE. KNOCKDOWNS AND CONFUSES NEARBY WEAKLINGS."
	button_icon_state = "power_howl"
	background_icon_state_on = "wolf_power_on"
	background_icon_state_off = "wolf_power_off"
	power_explanation = "<b>Howl</b>:\n\
		Activating Howl will start up a 2 and a half second charge up.\n\
		After the charge up you'll knockdown anyone adjacent to you.\n\
		Additionally, you'll confuse and deafen anyone in a 3 tile range.\n\
		Created from your Cloak of Darkness ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 15 SECONDS

/datum/action/bloodsucker/gangrel/howl/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.visible_message(span_danger("[A] inhales a ton of air!"), span_warning("You prepare to howl!"))
	if(!do_mob(A, A, 2.5 SECONDS, TRUE))
		return
	playsound(A.loc, 'yogstation/sound/creatures/darkspawn_howl.ogg', 50, TRUE)
	A.visible_message(span_userdanger("[A] let's out a chilling howl!"), span_boldwarning("You howl, confusing and deafening nearby mortals."))
	for(var/mob/target in range(3, A))
		if(target == (A || A.bloodsucker))
			continue
		if(IS_BLOODSUCKER(target) || IS_VASSAL(target))
			continue
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.confused += 15
			M.adjustEarDamage(0, 50)
			if(target.Adjacent(A))
				M.Knockdown(4 SECONDS)
				M.Paralyze(0.1)
		DeactivatePower()

/datum/action/bloodsucker/gangrel/rabidism
	name = "Rabidism"
	desc = "UNLEASHES YOUR POTENTIAL OF AREA DAMAGE, BUT HURTS YOURSELF IN THE PROCESS, DEALS MORE DAMAGE TO STRUCTURES."
	button_icon_state = "power_rabid"
	background_icon_state_on = "wolf_power_on"
	background_icon_state_off = "wolf_power_off"
	power_explanation = "<b>Rabidism</b>:\n\
		Rabidism will deal reduced damage to everyone in range including you.\n\
		During Rabidism's ten second rage you'll deal alot more damage to structures.\n\
		Be aware of it's long cooldown time.\n\
		Created from your Tresspass ability"
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown = 20 SECONDS

/datum/action/bloodsucker/gangrel/rabidism/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.environment_smash = ENVIRONMENT_SMASH_RWALLS
	A.obj_damage *= 3
	addtimer(CALLBACK(src, .proc/DeactivatePower), 10 SECONDS)

/datum/action/bloodsucker/gangrel/rabidism/ContinueActive()
	return TRUE

/datum/action/bloodsucker/gangrel/rabidism/UsePower(mob/living/user)
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = user
	for(var/mob/living/all_targets in dview(1, get_turf(A)))
		if(all_targets == A && all_targets == A.bloodsucker)
			continue
		A.UnarmedAttack(all_targets) //byongcontrol

/datum/action/bloodsucker/gangrel/rabidism/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.environment_smash = initial(A.environment_smash)
	A.obj_damage = initial(A.obj_damage)

/datum/action/bloodsucker/targeted/tear
	name = "Tear"
	desc = "Tear in specific areas of a mortal's body and inflict great pain on them."
	button_icon_state = "power_tear"
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	background_icon_state_on = "gangrel_power_on"
	background_icon_state_off = "gangrel_power_off"
	power_explanation = "<b>Tear</b>:\n\
		Tear will make your first attack start up a bleeding process.\n\
		Bleeding process will only work if the target stands still.\n\
		When it's done it will damage the target severely."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 10
	cooldown = 7 SECONDS
	var/mob/living/mauled

/datum/action/bloodsucker/targeted/tear/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/mob/living/target = target_atom
	user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
	if(iscarbon(target))
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 60, TRUE, -1)
		target.apply_damage(15, BRUTE, affecting, target.run_armor_check(affecting, "melee", armour_penetration = 10), sharpness = SHARP_EDGED)
	mauled = target
	Mawl(target)

/datum/action/bloodsucker/targeted/tear/proc/Mawl(mob/living/target)
	var/mob/living/carbon/user = owner
	if(!do_mob(user, target, 1 SECONDS))
		return
	var/datum/status_effect/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
	playsound(get_turf(target), 'sound/weapons/slash.ogg', 60, TRUE, -1)
	if(!B)
		target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
	else
		B.add_bleed(B.bleed_buildup)
	spawn(1 SECONDS)
	if(!target.Adjacent(user))
		return
	user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
	playsound(get_turf(target), 'sound/weapons/slash.ogg', 60, TRUE, -1)
	B.add_bleed(B.bleed_buildup)

/datum/action/bloodsucker/targeted/tear/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/bloodsucker/targeted/tear/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE
	return FALSE

/obj/item/clothing/neck/wolfcollar
	name = "Wolf Collar"
	desc = "Hopefully no more neck snaps!"
	icon_state = "collar"
	item_state = "collar"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 100)
	body_parts_covered = NECK

/obj/item/radio/headset/wolfears
	name = "Wolf Ears"
	desc = "If only you had a encoder to speak through the channels."
	icon_state = "ears"
	item_state = "ears"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 100)
	flags_inv = HIDEHAIR|HIDEFACE
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER
	
/obj/item/clothing/gloves/wolfclaws
	name = "Wolf Claws"
	desc = "Tear them to shreds!"
	icon_state = "claws"
	item_state = "claws"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	body_parts_covered = ARMS|HANDS
	flags_inv = HIDEJUMPSUIT
	var/datum/action/bloodsucker/targeted/tear/tearaction = new

/obj/item/clothing/shoes/wolflegs
	name = "Wolf Legs"
	desc = "Atleast they make you go faster."
	icon_state = "legs"
	item_state = "legs"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	slowdown = SHOES_SLOWDOWN - 0.5
	body_parts_covered = GROIN|LEGS|FEET

/obj/item/clothing/shoes/xeno_wraps/wolfdigilegs
	name = "Wolf Legs"
	desc = "Atleast they make you go faster. Oh wait you probably didn't mind anyways..."
	icon_state = "digilegs"
	item_state = "digilegs"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	slowdown = SHOES_SLOWDOWN - 0.5
	xenoshoe = YES_DIGIT
	body_parts_covered = GROIN|LEGS|FEET

/obj/item/clothing/neck/wolfcollar/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/radio/headset/wolfears/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	make_syndie()

/obj/item/radio/headset/wolfears/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(SLOT_EARS))

/obj/item/clothing/gloves/wolfclaws/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/shoes/wolflegs/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/shoes/xeno_wraps/wolfdigilegs/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/gloves/wolfclaws/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!IS_BLOODSUCKER(user))
		return
	if(slot == SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		tearaction.Grant(H)

/obj/item/clothing/gloves/wolfclaws/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!IS_BLOODSUCKER(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_GLOVES) == src)
		tearaction.Remove(H)
