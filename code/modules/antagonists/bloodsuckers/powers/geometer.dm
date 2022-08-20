//////////////////////////////////////////////
//                                          //
//               SHAPE BLOOD                //
//                                          //
//////////////////////////////////////////////

/datum/action/bloodsucker/shape_blood
	name = "Shape Blood"
	desc = "Shape your blood in a form of various weapons."
	power_explanation = "<b>Shape Blood</b>:\n\
		Activating Shape Blood will allow you to choose and shape a weapon from your blood.\n\
		Higher levels will increase weapon stats and variety."
	icon_icon = 'icons/mob/actions/actions_tremere_bloodsucker.dmi'
	button_icon_state = "power_thaumaturgy"
	cooldown = 8 SECONDS
	bloodcost = 55
	purchase_flags = BLOODSUCKER_CAN_BUY
	power_flags = BP_AM_TOGGLE | BP_AM_COSTLESS_UNCONSCIOUS
	constant_bloodcost = 0
	var/obj/blood_weapon = null

/datum/action/bloodsucker/shape_blood/ActivatePower()
	if(blood_weapon)
		UnregisterSignal(blood_weapon, COMSIG_PARENT_QDELETING)
		qdel(blood_weapon)
		blood_weapon = null
	var/list/guns = list(
		"Blood shield" = image(icon = 'icons/obj/vamp_obj.dmi', icon_state = "blood_shield"),
		)
	if(level_current >= 3)
		guns["Bloodblade"] = image(icon = 'icons/obj/changeling.dmi', icon_state = "arm_blade")
	if(level_current >= 4)
		if(level_current >= 6)
			guns["Bloodbolt"] = image(icon = 'icons/obj/projectiles.dmi', icon_state = "bloodbolt")
		else
			guns["Weak Bloodbolt"] = image(icon = 'icons/obj/projectiles.dmi', icon_state = "bloodbolt")

	var/choice = show_radial_menu(owner, owner, guns, radius = 42)
	if(!choice)
		return
	switch(choice)
		if("Bloodshield")
			give_weapon(/obj/item/shield/bloodsucker)
			constant_bloodcost = 0.1
		if("Weak Bloodbolt")
			give_weapon(/obj/item/bloodhand/weak)
		if("Bloodbolt")
			give_weapon(/obj/item/bloodhand)
		if("Bloodblade")
			give_weapon(/obj/item/melee/blood_blade)
			if(blood_weapon)
				constant_bloodcost = 2 //Seems fine for a fucking armblade
	if(blood_weapon || !QDELETED(blood_weapon))
		RegisterSignal(blood_weapon, COMSIG_PARENT_QDELETING, .proc/on_item_qdeleting)
		return ..()

/datum/action/bloodsucker/shape_blood/proc/give_weapon(type)
	blood_weapon = new type (owner)
	owner.balloon_alert(owner, "shaped a [blood_weapon.name]")
	if(!owner.put_in_hands(blood_weapon))
		qdel(blood_weapon)

/datum/action/bloodsucker/shape_blood/proc/on_item_qdeleting()
	UnregisterSignal(blood_weapon, COMSIG_PARENT_QDELETING)
	blood_weapon = null
	if(active)
		DeactivatePower()

/datum/action/bloodsucker/shape_blood/DeactivatePower()
	. = ..()
	if(blood_weapon && !QDELETED(blood_weapon))
		UnregisterSignal(blood_weapon, COMSIG_PARENT_QDELETING)
		qdel(blood_weapon)
	blood_weapon = null
	constant_bloodcost = initial(constant_bloodcost)

/obj/item/shield/bloodsucker
	name = "blood shield"
	desc = "A shield, made from blood."
	icon = 'icons/obj/vamp_obj.dmi'
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'
	icon_state = "blood_shield"
	item_state = "blood_shield"
	armor = list(MELEE = 15, BULLET = 15, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100) //It is made from blood, so it shouldn't be very good against physical attacks
	force = 13 //Also a weak weapon
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	var/block_cost = 15

/obj/item/shield/bloodsucker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name] form a strange shield from their blood!"))

/obj/item/shield/bloodsucker/examine(mob/user)
	. = ..()
	if(IS_BLOODSUCKER(user))
		.+= span_notice("It costs 15 blood to block an attack with it.")

/obj/item/shield/bloodsucker/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/bloodsucker/BS = IS_BLOODSUCKER(owner)
	var/kill_me = FALSE
	if(!BS)
		kill_me = TRUE
	else
		if(owner.blood_volume <= block_cost)
			to_chat(owner, span_warning("Your [src] dissolves, as you don't have enough blood to sustain it!"))
			kill_me = TRUE
		else
			BS.AddBloodVolume(-block_cost)
			kill_me = FALSE
	if(kill_me)
		visible_message(span_warning("[src] dissolves in a puddle of blood!"))
		new /obj/effect/decal/cleanable/blood (owner ? get_turf(owner) : get_turf(src))
		qdel(src)
	return ..()

/obj/item/melee/blood_blade
	name = "blood blade"
	desc = "A grotesque blade made out of blood."
	icon = 'icons/obj/changeling.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 20 //We are not a changeling to get a 25 damage blade
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = SHARP_EDGED
	var/can_drop = FALSE
	var/fake = FALSE
	resistance_flags = ACID_PROOF

/obj/item/melee/blood_blade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name] form a strange weapon from their blood!"))

/obj/item/bloodhand
	name = "bloodhand"
	desc = "There is blood floating around it."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = "#B30E08"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	var/projectile_type = /obj/item/projectile/magic/geometer
	var/shoot_cost = 20

/obj/item/bloodhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("Blood begins to chaoticaly float around [loc.name]'s hand.")) //Kinda cringe desc but cry about it

/obj/item/bloodhand/attack()
	return

/obj/item/bloodhand/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	var/datum/antagonist/bloodsucker/BS = IS_BLOODSUCKER(user)
	if(!BS || !iscarbon(user))
		qdel(src)
		return
	if(user.blood_volume <= shoot_cost)
		user.balloon_alert(user, "not enough blood")
		return
	user.changeNext_move(CLICK_CD_RANGE)
	var/obj/item/projectile/magic/geometer/bloodbolt = new projectile_type (user.loc)
	bloodbolt.firer = user
	bloodbolt.def_zone = ran_zone(user.zone_selected)
	bloodbolt.preparePixelProjectile(target, user)
	INVOKE_ASYNC(bloodbolt, /obj/item/projectile.proc/fire)
	playsound(user, pick(list('sound/effects/wounds/blood1.ogg','sound/effects/wounds/blood2.ogg','sound/effects/wounds/blood3.ogg')), 60, TRUE)
	BS.AddBloodVolume(-shoot_cost)

/obj/item/projectile/magic/geometer //Yeah there is already gangreal bloodsucker bolts but fuck them
	name = "blood bolt"
	icon_state = "bloodbolt"
	damage_type = BURN
	damage = 20

/obj/item/projectile/magic/geometer/weak
	damage = 15

/obj/item/bloodhand/weak
	shoot_cost = 15
	projectile_type = /obj/item/projectile/magic/geometer/weak

//////////////////////////////////////////////
//                                          //
//               DRAIN LIFE                 //
//                                          //
//////////////////////////////////////////////

/datum/action/bloodsucker/targeted/life_drain
	name = "Drain Blood"
	desc = "Cleave your targets veins and drain it's blood."
	button_icon_state = "cleave"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	power_explanation = "<b>Drain Blood</b>:\n\
		Click any player to instantly drain their blood and make them bleed.\n\
		If higher then level 3, will additionaly apply a slash wound to your target.\n\
		If higher then level 5, will additionaly heal you and deal some brute damage to the target.\n\
		Higher levels will increase the amount of blood stealed."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	cooldown = 35 SECONDS
	target_range = 6
	power_activates_immediately = FALSE
	var/original_life_drain

/datum/action/bloodsucker/targeted/life_drain/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return iscarbon(target_atom) && iscarbon(owner)

/datum/action/bloodsucker/targeted/life_drain/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/target = target_atom
	var/mob/living/carbon/user = owner

	var/life_to_drain = 20 + 5 * level_current
	var/life_drained = target.blood_volume > life_to_drain ? life_to_drain : target.blood_volume
	target.blood_volume -= life_drained
	bloodsuckerdatum_power.AddBloodVolume(life_drained)
	target.bleed(15)

	if(level_current >= 3)
		var/datum/wound/slash/critical/crit_wound = new
		crit_wound.apply_wound(pick(target.bodyparts))

	if(level_current >= 5)
		target.adjustBruteLoss(10)
		user.adjustBruteLoss(-10)

	to_chat(target, span_userdanger("Your veins sudennly [level_current >= 5 ? "explode" : "torn open"] with pain!"))
	if(prob(life_to_drain)) //Why not
		target.emote("scream")

	to_chat(user, span_notice("You cut [target]'s veins open!"))

	PowerActivatedSuccessfully()