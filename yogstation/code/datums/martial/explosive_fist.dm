#define EXPLOSIVE_DISARM_COMBO "DD"
#define LIFEFORCE_TRADE_COMBO "GH"

#define PRIME_EFFECT_DURATION (10 SECONDS)
#define MAX_PRIME_LEVEL 7

//Important note: Plasma man max punch damage is 7, values are based off of this number.
/datum/martial_art/explosive_fist
	name = "Explosive Fist"
	id =  MARTIALART_EXPLOSIVEFIST
	help_verb = /mob/living/carbon/human/proc/explosive_fist_help
	martial_traits = list(TRAIT_RESISTHEAT, TRAIT_IGNOREDAMAGESLOWDOWN)
	var/succ_damage = 2	//Our life suck damage. Increases the longer it's held.

/datum/martial_art/explosive_fist/can_use(mob/living/carbon/human/H)
	if(!H.combat_mode) //gotta be combat mode
		return FALSE
	if(!isplasmaman(H)) //gotta be plasmeme
		return FALSE
	return ..()

/datum/martial_art/explosive_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D)
		return FALSE
	D.apply_status_effect(STATUS_EFFECT_EXPLOSION_PRIME)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE  

/datum/martial_art/explosive_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D)
		return FALSE
	D.apply_status_effect(STATUS_EFFECT_EXPLOSION_PRIME)
	add_to_streak("G",D)
	if(check_streak(A,D)) //if a combo is made no grab upgrade is done
		return TRUE
	return FALSE

/datum/martial_art/explosive_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D)
		return FALSE
	D.apply_status_effect(STATUS_EFFECT_EXPLOSION_PRIME)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	streak = ""
	return detonate(A, D)

/datum/martial_art/explosive_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, EXPLOSIVE_DISARM_COMBO))
		streak = ""
		explosive_disarm(A,D)
		return TRUE
	if(findtext(streak, LIFEFORCE_TRADE_COMBO))	//End life force drain chain
		streak = ""
		lifeforce_trade(A,D)
		return TRUE

/datum/martial_art/explosive_fist/proc/damage(mob/living/carbon/human/target, burn_damage = 0, brute_damage = 0, stamina_damage = 0, zone_selected = BODY_ZONE_CHEST)
	if(!target)
		return
	var/melee_block = target.run_armor_check(zone_selected, MELEE, 0)
	var/burn_block = target.run_armor_check(zone_selected, BOMB, 0)

	target.apply_damage(brute_damage, STAMINA, zone_selected, melee_block)
	target.apply_damage(stamina_damage, STAMINA, zone_selected, melee_block)
	target.apply_damage(burn_damage, BURN, zone_selected, burn_block)
/*---------------------------------------------------------------
	start of disarm section
---------------------------------------------------------------*/
/datum/martial_art/explosive_fist/proc/explosive_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	D.apply_status_effect(STATUS_EFFECT_EXPLOSION_PRIME)

	var/zone_selected = A.zone_selected
	var/punch_damage = A.get_punchdamagehigh()
	damage(D, (punch_damage * 2), 0, 0, zone_selected) //14 burn damage
	D.Knockdown(((punch_damage * 4)/10) SECONDS)	//2.8 seconds (baseline (7*4)/10 seconds)

	playsound(D, get_sfx(SFX_EXPLOSION), 50, TRUE, -1)
	A.do_attack_animation(D, ATTACK_EFFECT_MECHFIRE)
	log_combat(A, D, "blasts(Explosive Fist)")
	D.visible_message(span_danger("[A] blasts [D]!"), span_userdanger("[A] blasts you!"))

	var/atom/throw_target = get_edge_target_turf(D, get_dir(A,D))
	D.throw_at(throw_target, 2, 7, A)

/*---------------------------------------------------------------
	end of Explosive disarm section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of Detonate section
---------------------------------------------------------------*/
/datum/martial_art/explosive_fist/proc/detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE

	var/datum/status_effect/explosion_prime/status = D.has_status_effect(/datum/status_effect/explosion_prime)
	if(!status)
		return FALSE
	var/level = status.level
	qdel(status) //we're done with it now, get rid of it so they can't use it again

	A.do_attack_animation(D, ATTACK_EFFECT_MECHFIRE)
	var/punch_damage = A.get_punchdamagehigh() + level

	var/turf/center = get_turf(D)
	var/range = round(level/2)
	explosion(center, -1, -1, -1, flame_range = (range + 1)) //only fire explosion
	for(var/mob/living/target in view(center, range))
		if(target == A) //no self damage
			continue
		target.adjust_fire_stacks(level)
		target.ignite_mob()
		damage(target, punch_damage) //burn to everyone nearby
	for(var/turf/open/flashy in view(center, range))
		flashy.ignite_turf(level * 5)

	damage(D, 0, punch_damage, punch_damage * 2) //extra brute and stamina damage for the main target
	log_combat(A, D, "detonates(Explosive Fist)")
	D.visible_message(span_danger("[A] detonates [D]!"), span_userdanger("[A] detonates you!"))
	
	streak = ""
	return TRUE

/*---------------------------------------------------------------
	end of Detonate section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of Life force trade section
---------------------------------------------------------------*/
/datum/martial_art/explosive_fist/proc/can_suck_life(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.get_item_by_slot(ITEM_SLOT_HEAD))
		return FALSE
	if(!A.pulling)
		return FALSE
	if(!(A.pulling == D))
		return FALSE
	if(A.grab_state < GRAB_NECK)
		return FALSE
	if(A.stat == DEAD || A.stat == UNCONSCIOUS) //if we're dead or knocked out
		return FALSE
	if(D.stat == DEAD) //if they're dead
		return FALSE
	return TRUE

/datum/martial_art/explosive_fist/proc/lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.get_item_by_slot(ITEM_SLOT_HEAD)) //Helmet on, head go bonk
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)			//BONK
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		var/selected_zone = A.zone_selected
		var/punch_damage = (A.get_punchdamagehigh() * 2.5) +  7.5
		damage(D, 0, punch_damage, punch_damage * 2, selected_zone)

		D.visible_message(span_danger("[A] headbutts [D]!"), span_userdanger("[A] headbutts you!"))
		log_combat(A, D, "headbutts(Explosive Fist)")
	else
		if(A.grab_state < GRAB_NECK)
			A.grab_state = GRAB_NECK
		if(!(A.pulling == D))
			D.grabbedby(A, 1)
		D.visible_message(span_danger("[A] violently grabs [D]'s neck!"), span_userdanger("[A] violently grabs your neck!"))
		log_combat(A, D, "grabs by the neck(Explosive Fist)")
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		playsound(get_turf(D), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		A.adjust_fire_stacks(3)
		D.adjust_fire_stacks(3)
		A.ignite_mob()
		D.ignite_mob()
		succ_damage = initial(succ_damage)	//Reset our succ damage on start
		proceed_lifeforce_trade(A, D)
		streak = ""

/datum/martial_art/explosive_fist/proc/proceed_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)//lifeforce trade loop
	if(!can_suck_life(A, D))
		return
	if(!do_after(A, 1 SECONDS, D))
		return
	if(!can_suck_life(A, D))
		return

	if(prob(35))
		var/list/messages = list(
			"You feel your life force being drained!", 
			"It hurts!", 
			"AAAAAAAAAAAAAAAAAAAAAAAAAAA",
			"You stare into [A]'s expressionless skull and see only fire and death."
			)
		to_chat(D, span_userdanger(pick(messages)))
	if(prob(25))
		D.emote("scream")

	playsound(get_turf(D), 'yogstation/sound/magic/devour_will_form.ogg', 10, TRUE)
	to_chat(A, span_notice("You drain lifeforce from [D]"))

	D.apply_status_effect(STATUS_EFFECT_EXPLOSION_PRIME) //prime them for big boom
	D.adjustFireLoss(succ_damage / 2) //doesn't do much damage, more of a healing tool
	D.adjustStaminaLoss(succ_damage * 2) //YOU ARE HELPLESS TO RESIST THE SPOOKY SKELETON

	A.heal_ordered_damage(succ_damage, list(BURN, BRUTE, STAMINA, OXY), BODYPART_ANY)
	succ_damage *= 1.5	//50% increased damage per succ
	proceed_lifeforce_trade(A, D)

/*---------------------------------------------------------------
	end of Life force trade section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of learn section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/explosive_fist_help()
	set name = "Remember the basics"
	set desc = "You try to remember some basic actions from the explosive fist art."
	set category = "Explosive Fist"

	var/list/combined_msg = list()

	combined_msg += "<b><i>You try to remember some basic actions from the explosive fist art.</i></b>"

	combined_msg += span_notice("<b>All Intents</b> Will <b>prime</b> the target with explosive plasma.")
	combined_msg += span_notice("<b>Harm Intent</b> Will detonate the plasma, creating a fire explosion scaling with how many times the target was <b>primed</b>.")

	combined_msg += "[span_notice("Explosive disarm")]: Disarm Disarm. Deals damage to your target and applies an additional stack of <b>primed</b>. Also throws your target away and knocks them down for a short duration."
	combined_msg += "[span_notice("Life force trade")]: Grab Harm. If wearing headwear, you deal considerable brute and stamina damage to the target. If not wearing headwear, you will instantly grab the target by the neck and start draining life from them."
	
	to_chat(usr, examine_block(combined_msg.Join("\n")))

/*---------------------------------------------------------------
	end of learn section
---------------------------------------------------------------*/
//these aren't needed elsewhere
#undef EXPLOSIVE_DISARM_COMBO
#undef LIFEFORCE_TRADE_COMBO

/atom/movable/screen/alert/status_effect/explosion_prime
	name = "Primed"
	desc = "You've been primed to explode."
	icon_state = "overheating"

/datum/status_effect/explosion_prime
	status_type = STATUS_EFFECT_REFRESH
	duration = PRIME_EFFECT_DURATION
	alert_type = /atom/movable/screen/alert/status_effect/explosion_prime
	/// How potent this effect is
	var/level = 0

/datum/status_effect/explosion_prime/New(list/arguments)
	. = ..()
	increase_level()

/datum/status_effect/explosion_prime/refresh(effect, ...) //when it gets re-applied, make it stronger
	. = ..()
	increase_level()
	
/datum/status_effect/explosion_prime/proc/increase_level()
	var/new_level = clamp(level + 1, 0, MAX_PRIME_LEVEL)
	set_level(new_level)

/datum/status_effect/explosion_prime/proc/set_level(amount)
	if(amount == level)
		return
	level = amount
	update_particles()

/datum/status_effect/explosion_prime/update_particles()
	if(!particle_effect)
		particle_effect = new(owner, /particles/drill_sparks)
	particle_effect.particles.spawning = level

#undef PRIME_EFFECT_DURATION
#undef MAX_PRIME_LEVEL 
