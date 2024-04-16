/datum/action/cooldown/bloodsucker/gangrel
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	background_icon_state = "gangrel_power_off"
	active_background_icon_state = "gangrel_power_on"
	base_background_icon_state = "gangrel_power_off"
	purchase_flags = GANGREL_CAN_BUY
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_AM_COSTLESS_UNCONSCIOUS
	cooldown_time = 10 SECONDS

/datum/action/cooldown/bloodsucker/gangrel/transform
	name = "Transform"
	desc = "Allows you to unleash your inner form and turn into something greater."
	button_icon_state = "power_gangrel"
	power_explanation = "Transform:\n\
		A gangrel only power, will turn you into a feral being depending on your blood sucked.\n\
		May have unforseen consequences if used on low blood sucked, upgrades every 500 units.\n\
		Some forms have special abilites to them depending on what abilites you have.\n\
		Be wary of your blood status when using it, takes 10 seconds of standing still to transform!"
	power_flags = BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	bloodcost = 100

/datum/action/cooldown/bloodsucker/gangrel/transform/ActivatePower()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/human/user = owner
	var/list/radial_display = list()
	//get our options, switches are kinda weird here cause wwe ant to stack them
	if(bloodsuckerdatum) //makes the icons for the options
		var/datum/radial_menu_choice/option = new
		user.setDir(SOUTH)
		var/icon/icon_to_mix = getFlatIcon(user)
		icon_to_mix.Blend(icon('icons/mob/mutant_bodyparts.dmi', "m_ears_cat_FRONT"), ICON_OVERLAY)
		option.image = icon_to_mix
		option.info = "[iscatperson(user) ? "Lizard" : "Felinid"]: Increased agility, speed and interaction speed, but decreased defense."
		radial_display["Lizard/Felinid"] = option //haha yeah
	if(bloodsuckerdatum.total_blood_drank >= 250)
		var/datum/radial_menu_choice/option = new
		var/icon/body = icon('yogstation/icons/mob/human_parts.dmi', "gorilla_r_leg") //procedurally generated icons? don't mind if i do
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_l_leg"), ICON_OVERLAY) //it may seem kinda big but it's worth it ngl
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_r_arm"), ICON_OVERLAY)
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_l_arm"), ICON_OVERLAY)
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_r_hand"), ICON_OVERLAY)
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_l_hand"), ICON_OVERLAY)
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_chest_m"), ICON_OVERLAY)
		body.Blend(icon('yogstation/icons/mob/human_parts.dmi', "gorilla_head_m"), ICON_OVERLAY)
		option.image = body
		option.info = "Gorilla: Increased durability and strength, but less speed and interaction speed."
		radial_display["Gorilla"] = option
	if(bloodsuckerdatum.total_blood_drank >= 750)
		var/datum/radial_menu_choice/option = new
		option.image = icon('icons/mob/bloodsucker_mobs.dmi', "batform")
		option.info = "Turn into a giant bat simple mob with unique abilities."
		radial_display["Bat"] = option
	var/chosen_transform = show_radial_menu(user, user, radial_display)
	if(!chosen_transform || !do_after(user, 10 SECONDS))
		return
	transform(chosen_transform) //actually transform
	return ..()

/datum/action/cooldown/bloodsucker/gangrel/transform/proc/transform(chosen_transform)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/human/user = owner
	var/datum/species/user_species = user.dna.species
	switch(chosen_transform)
		if("Lizard/Felinid")
			if(iscatperson(user))
				user.set_species(/datum/species/lizard)
				playsound(user.loc, 'sound/voice/lizard/hiss.ogg', 50)
			else
				user.set_species(/datum/species/human/felinid)
				playsound(user.loc, 'sound/voice/feline/meow1.ogg', 50)
			if(!LAZYFIND(user_species.species_traits, DIGITIGRADE))
				user_species.species_traits += DIGITIGRADE
				user.dna.species.armor -= 20 //careful
				user.dna.species.speedmod = -0.5
				user.dna.species.action_speed_coefficient *= 0.7
				bloodsuckerdatum.AddBloodVolume(75)
		if("Gorilla")
			user.set_species(/datum/species/gorilla)
			playsound(user.loc, 'sound/creatures/gorilla.ogg', 50)
			if(DIGITIGRADE in user_species.species_traits)
				user_species.species_traits -= DIGITIGRADE
			user.dna.species.punchdamagelow += 10
			user.dna.species.punchdamagehigh += 10 //very stronk
			user.dna.species.punchstunthreshold += 10
			user.dna.species.action_speed_coefficient *= 1.3
			user.dna.species.armor += 15
			bloodsuckerdatum.AddBloodVolume(50)
		if("Bat")
			var/mob/living/simple_animal/hostile/bloodsucker/giantbat/gb
			if(!gb || gb.stat == DEAD)
				gb = new /mob/living/simple_animal/hostile/bloodsucker/giantbat(user.loc)
				user.forceMove(gb)
				gb.bloodsucker = user
				user.status_flags |= GODMODE //sad!
				user.mind.transfer_to(gb)
				var/list/bat_powers = list(new /datum/action/cooldown/bloodsucker/gangrel/transform_back, )
				for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
					if(istype(power, /datum/action/cooldown/bloodsucker/targeted/haste))
						bat_powers += new /datum/action/cooldown/bloodsucker/targeted/haste/batdash
					if(istype(power, /datum/action/cooldown/bloodsucker/targeted/mesmerize))
						bat_powers += new /datum/action/cooldown/bloodsucker/targeted/bloodbolt
					if(istype(power, /datum/action/cooldown/bloodsucker/targeted/brawn))
						bat_powers += new /datum/action/cooldown/bloodsucker/gangrel/wingslam
				for(var/datum/action/cooldown/bloodsucker/power in bat_powers)
					power.Grant(gb)
				playsound(gb.loc, 'sound/items/toysqueak1.ogg', 50, TRUE)
			return  //early to not mess with vampire organs proc

	bloodsuckerdatum.heal_vampire_organs() //regives you the stuff

/datum/action/cooldown/bloodsucker/gangrel/transform_back
	name = "Transform"
	desc = "Regress back into a human."
	button_icon_state = "power_gangrel"
	power_explanation = "Transform:\n\
		Regress back to your humanoid form early, requires you to stand still.\n\
		Beware you will not be able to transform again until the night passes!"

/datum/action/cooldown/bloodsucker/gangrel/transform_back/ActivatePower()
	if(!do_after(owner, 10 SECONDS))
		return
	if(istype(owner, /mob/living/simple_animal/hostile/bloodsucker))
		qdel(owner)
	return ..()
/*
////////////////||\\\\\\\\\\\\\\\\
\\           Bat Only           //
//            Powers            \\
\\\\\\\\\\\\\\\\||////////////////
*/
/datum/action/cooldown/bloodsucker/targeted/haste/batdash
	name = "Flying Haste"
	desc = "Propulse yourself into a position of advantage."
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_baste"
	active_background_icon_state = "bat_power_on"
	base_background_icon_state = "bat_power_off"
	power_explanation = "Flying Haste<:\n\
		Makes you dash into the air, creating a smoke cloud at the end.\n\
		Helpful in situations where you either need to run away or engage in a crowd of people, works over tables.\n\
		Created from your Immortal Haste ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bloodsucker/targeted/haste/batdash/CanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/haste/batdash/FireTargetedPower(atom/target_atom)
	. = ..()
	do_smoke(2, owner.loc, smoke_type = /obj/effect/particle_effect/fluid/smoke/transparent) //so you can attack people after hasting

/datum/action/cooldown/bloodsucker/targeted/bloodbolt
	name = "Blood Bolt"
	desc = "Shoot a blood bolt to damage your foes."
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_bolt"
	active_background_icon_state = "bat_power_on"
	base_background_icon_state = "bat_power_off"
	power_explanation = "Blood Bolt<:\n\
		Shoots a blood bolt that does moderate damage to your foes.\n\
		Helpful in situations where you get outranged or just extra damage.\n\
		Created from your Mesmerize ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 12.5 SECONDS

/datum/action/cooldown/bloodsucker/targeted/bloodbolt/CanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	to_chat(user, span_warning("You fire a blood bolt!"))
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target_atom, user))
	var/obj/projectile/magic/arcane_barrage/bloodsucker/magic_9ball = new(user.loc)
	magic_9ball.bloodsucker_power = src
	magic_9ball.firer = user
	magic_9ball.def_zone = ran_zone(user.zone_selected)
	magic_9ball.preparePixelProjectile(target_atom, user)
	INVOKE_ASYNC(magic_9ball, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(user, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	power_activated_sucessfully()

/obj/projectile/magic/arcane_barrage/bloodsucker
	name = "blood bolt"
	icon_state = "bloodbolt"
	damage_type = BURN
	damage = 30
	var/datum/action/cooldown/bloodsucker/targeted/bloodbolt/bloodsucker_power

/obj/projectile/magic/arcane_barrage/bloodsucker/on_hit(target)
	if(ismob(target))
		qdel(src)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.Knockdown(0.1)
		return BULLET_ACT_HIT
	return ..()

/datum/action/cooldown/bloodsucker/gangrel/wingslam
	name = "Wing Slam"
	desc = "Slams all foes next to you."
	button_icon_state = "power_wingslam"
	active_background_icon_state = "bat_power_on"
	base_background_icon_state = "bat_power_off"
	power_explanation = "Wing Slam:\n\
		Knocksback and immobilizes people adjacent to you.\n\
		Has a low recharge time and may be helpful in meelee situations!\n\
		Created from your Brawn ability."
	check_flags = NONE
	bloodcost = 0

/datum/action/cooldown/bloodsucker/gangrel/wingslam/ActivatePower()
	. = ..()
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
		playsound(user.loc, 'sound/weapons/punch4.ogg', 60, TRUE, -1)
		M.adjustBruteLoss(10)
		M.Knockdown(4 SECONDS)
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

/datum/action/cooldown/bloodsucker/targeted/feast
	name = "Feast"
	desc = "DEVOUR THE WEAKLINGS, CAUSE THEM HARM. FEED. ME."
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_feast"
	active_background_icon_state = "wolf_power_on"
	base_background_icon_state = "wolf_power_off"
	power_explanation = "Feast:\n\
		Feasting on a dead person will give you a satiation point and gib them.\n\
		Satiation points are essential for overcoming frenzy, after gathering 3 you'll turn back to normal.\n\
		Feasting on someone while they are alive will bite them and make them bleed.\n\
		Has a medium recharge time to be helpful in combat.\n\
		There might be some consequences after coming back from frenzy though.."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 10 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "WHOM SHALL BE DEVOURED."

/datum/action/cooldown/bloodsucker/targeted/feast/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/feast/CheckCanTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE

/datum/action/cooldown/bloodsucker/targeted/feast/FireTargetedPower(atom/target_atom)
	if(isturf(target_atom))
		return
	owner.face_atom(target_atom)
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/user = owner
	var/mob/living/carbon/human/target = target_atom
	if(target.stat == DEAD)
		user.devour(target)
		power_activated_sucessfully()
		return
	user.do_attack_animation(target, ATTACK_EFFECT_BITE)
	var/affecting = pick(BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	playsound(get_turf(target), 'sound/weapons/bite.ogg', 60, 1, -1)
	target.apply_damage(35, BRUTE, affecting, target.run_armor_check(affecting, MELEE, armour_penetration = 10), sharpness = SHARP_EDGED)
	target.visible_message(span_danger("[user] takes a large bite out of [target]!"), \
					  span_userdanger("[user] takes a large bite out of you!"))
	power_activated_sucessfully()

/datum/action/cooldown/bloodsucker/gangrel/wolfortitude
	name = "Wolftitude"
	desc = "WITHSTAND THEIR ATTACKS. DESTROY. THEM. ALL!"
	button_icon_state = "power_wort"
	active_background_icon_state = "wolf_power_on"
	base_background_icon_state = "wolf_power_off"
	power_explanation = "Fortitude:\n\
		Activating Wolftitude will provide more attack damage, and more overall health.\n\
		It will give you a minor health buff while it stands, but slow you down severely.\n\
		It has a decent cooldown time to allow yourself to turn it off and run away for a while.\n\
		Created from your Fortitude ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 8 SECONDS

/datum/action/cooldown/bloodsucker/gangrel/wolfortitude/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("Your fur and claws harden, becoming as hard as steel."))
	var/mob/living/simple_animal/hostile/A = owner
	A.maxHealth *= 1.2
	A.health *= 1.2
	A.set_varspeed(initial(A.speed) + 2) // slower
	A.melee_damage_lower += 10
	A.melee_damage_upper += 10

/datum/action/cooldown/bloodsucker/gangrel/wolfortitude/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/A = owner
	A.maxHealth /= 1.2
	A.health /= 1.2
	A.set_varspeed(initial(A.speed))
	A.melee_damage_lower -= 10
	A.melee_damage_upper -= 10

/datum/action/cooldown/bloodsucker/targeted/pounce
	name = "Pounce"
	desc = "TACKLE THE LIVING TO THE GROUND. FEAST ON CORPSES."
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_pounce"
	active_background_icon_state = "wolf_power_on"
	base_background_icon_state = "wolf_power_off"
	power_explanation = "Pounce:\n\
		Click any player to instantly dash at them, knocking them down and paralyzing them for a short while.\n\
		Additionally if they are dead you'll consume their corpse to gain satiation and get closer to leaving frenzy.\n\
		Created from your Predatory Lunge ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 10 SECONDS
	target_range = 6
	power_activates_immediately = FALSE

/datum/action/cooldown/bloodsucker/targeted/pounce/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.icon_state = initial(A.icon_state) + "_pounce"
	A.icon_living = initial(A.icon_state) + "_pounce"
	A.update_body()

/datum/action/cooldown/bloodsucker/targeted/pounce/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.icon_state = initial(A.icon_state)
	A.icon_living = initial(A.icon_state)
	A.update_body()

/datum/action/cooldown/bloodsucker/targeted/pounce/FireTargetedPower(atom/target_atom)
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
			power_activated_sucessfully()
			return
		target.Knockdown(6 SECONDS)
		target.Paralyze(1 SECONDS)
	power_activated_sucessfully()

/datum/action/cooldown/bloodsucker/targeted/pounce/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/pounce/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE
	return FALSE

/datum/action/cooldown/bloodsucker/gangrel/howl
	name = "Howl"
	desc = "LET THEM KNOW WHAT HUNTS THEM. KNOCKDOWNS AND CONFUSES NEARBY WEAKLINGS."
	button_icon_state = "power_howl"
	active_background_icon_state = "wolf_power_on"
	base_background_icon_state = "wolf_power_off"
	power_explanation = "Howl:\n\
		Activating Howl will start up a 2 and a half second charge up.\n\
		After the charge up you'll knockdown anyone adjacent to you.\n\
		Additionally, you'll confuse and deafen anyone in a 3 tile range.\n\
		Created from your Cloak of Darkness ability."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bloodsucker/gangrel/howl/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.visible_message(span_danger("[A] inhales a ton of air!"), span_warning("You prepare to howl!"))
	if(!do_after(A, 2.5 SECONDS))
		return
	playsound(A.loc, 'yogstation/sound/creatures/darkspawn_howl.ogg', 50, TRUE)
	A.visible_message(span_userdanger("[A] lets out a chilling howl!"), span_boldwarning("You howl, confusing and deafening nearby mortals."))
	for(var/mob/target in range(3, A))
		if(target == (A || A.bloodsucker))
			continue
		if(IS_BLOODSUCKER(target) || IS_VASSAL(target))
			continue
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.adjust_confusion(15 SECONDS)
			M.adjustEarDamage(0, 50)
			if(target.Adjacent(A))
				M.Knockdown(4 SECONDS)
				M.Paralyze(0.1 SECONDS)
		DeactivatePower()

/datum/action/cooldown/bloodsucker/gangrel/rabidism
	name = "Rabidism"
	desc = "FLAIL WILLDY, INJURING ALL WHO APPROACH AND SAVAGING STRUCTURES."
	button_icon_state = "power_rabid"
	active_background_icon_state = "wolf_power_on"
	base_background_icon_state = "wolf_power_off"
	power_explanation = "Rabidism:\n\
		Rabidism will deal reduced damage to everyone in range including you.\n\
		During Rabidism's ten second rage you'll deal a lot more damage to structures.\n\
		Be aware of it's long cooldown time.\n\
		Created from your Tresspass ability"
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 0
	cooldown_time = 20 SECONDS

/datum/action/cooldown/bloodsucker/gangrel/rabidism/ActivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.environment_smash = ENVIRONMENT_SMASH_RWALLS
	A.obj_damage *= 3
	addtimer(CALLBACK(src, PROC_REF(DeactivatePower)), 10 SECONDS)

/datum/action/cooldown/bloodsucker/gangrel/rabidism/ContinueActive()
	return TRUE

/datum/action/cooldown/bloodsucker/gangrel/rabidism/process()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	for(var/mob/living/all_targets in dview(1, get_turf(A)))
		if(all_targets == A || all_targets == A.bloodsucker)
			continue
		A.UnarmedAttack(all_targets) //byongcontrol

/datum/action/cooldown/bloodsucker/gangrel/rabidism/DeactivatePower()
	. = ..()
	var/mob/living/simple_animal/hostile/bloodsucker/werewolf/A = owner
	A.environment_smash = initial(A.environment_smash)
	A.obj_damage = initial(A.obj_damage)

/datum/action/cooldown/bloodsucker/targeted/tear
	name = "Tear"
	desc = "Ruthlessly tear into an enemy, dealing massive damage to them if successful."
	button_icon_state = "power_tear"
	background_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	active_background_icon_state = "gangrel_power_on"
	base_background_icon_state = "gangrel_power_off"
	power_explanation = "Tear:\n\
		Tear will make your first attack start up a bleeding process.\n\
		Bleeding process will only work if the target stands still.\n\
		When it's done it will damage the target severely."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = GANGREL_CAN_BUY
	bloodcost = 10
	cooldown_time = 7 SECONDS
	var/mob/living/mauled

/datum/action/cooldown/bloodsucker/targeted/tear/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/mob/living/target = target_atom
	user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
	if(iscarbon(target))
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 60, TRUE, -1)
		target.apply_damage(15, BRUTE, affecting, target.run_armor_check(affecting, MELEE, armour_penetration = 10), sharpness = SHARP_EDGED)
		user.visible_message(span_danger("[user] slashes wildly at [target]!"), span_warning("You tear into [target]!"))
	mauled = target
	Mawl(target)

/datum/action/cooldown/bloodsucker/targeted/tear/proc/Mawl(mob/living/target)
	var/mob/living/carbon/user = owner

	if(!do_after(user, 1 SECONDS, target))
		return

	var/datum/status_effect/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	while(!target.stat)
		if(!target.Adjacent(user) || !do_after(user, 0.8 SECONDS, target))
			break
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
		user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 60, TRUE, -1)
		target.apply_damage(5, BRUTE, affecting, target.run_armor_check(affecting, MELEE, armour_penetration = 10), sharpness = SHARP_EDGED)
		user.visible_message(span_danger("[user] slashes wildly at [target]!"), span_warning("You continue to eviscerate [target]..."))
		if(!B)
			B = target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
		else
			B.add_bleed(B.bleed_buildup)

/datum/action/cooldown/bloodsucker/targeted/tear/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/tear/CheckCanTarget(atom/target_atom)
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
	body_parts_covered = NECK|HEAD

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
	body_parts_covered = HEAD

/obj/item/clothing/gloves/wolfclaws
	name = "Wolf Claws"
	desc = "Tear them to shreds!"
	icon_state = "claws"
	item_state = "claws"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	body_parts_covered = ARMS|HANDS
	flags_inv = HIDEJUMPSUIT
	var/datum/action/cooldown/bloodsucker/targeted/tear/tearaction = new

/obj/item/clothing/shoes/wolflegs
	name = "Wolf Legs"
	desc = "At least they make you go faster."
	icon_state = "legs"
	item_state = "legs"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	slowdown = SHOES_SLOWDOWN - 0.5
	body_parts_covered = GROIN|LEGS|FEET

/obj/item/clothing/shoes/xeno_wraps/wolfdigilegs
	name = "Wolf Legs"
	desc = "At least they make you go faster. Oh wait you probably didn't mind anyways..."
	icon_state = "digilegs"
	item_state = "digilegs"
	icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	mob_overlay_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	slowdown = SHOES_SLOWDOWN - 0.5
	xenoshoe = YES_DIGIT
	body_parts_covered = GROIN|LEGS|FEET

/obj/item/clothing/neck/wolfcollar/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/radio/headset/wolfears/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))
	make_syndie()

/obj/item/clothing/gloves/wolfclaws/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/shoes/wolflegs/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/shoes/xeno_wraps/wolfdigilegs/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/clothing/gloves/wolfclaws/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!IS_BLOODSUCKER(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		tearaction.Grant(H)

/obj/item/clothing/gloves/wolfclaws/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!IS_BLOODSUCKER(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		tearaction.Remove(H)
