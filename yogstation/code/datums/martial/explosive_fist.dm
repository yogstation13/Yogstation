#define EXPLOSIVE_DISARM_COMBO "DD"

#define DETONATE_COMBO "HHDH"
#define PRE_DETONATE_COMBO "HH" 
#define ALMOST_DETONATE_COMBO "HHD" 

#define LIFEFORCE_TRADE_COMBO "DGDG" 
#define PRE_LIFEFORCE_TRADE_COMBO "DG" 
#define ALMOST_LIFEFORCE_TRADE_COMBO "DGD" 


/datum/martial_art/explosive_fist
	name = "Explosive Fist"
	id =  MARTIALART_PRETERNISSTEALTH
	//help_verb = /mob/living/carbon/human/proc/preternis_martial_help
	var/life_force_trade_active = FALSE

/datum/martial_art/explosive_fist/can_use(mob/living/carbon/human/H)
	return isplasmaman(H)

/datum/martial_art/explosive_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		return FALSE
	else
		return FALSE

/datum/martial_art/explosive_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/brute_block = D.run_armor_check(affecting, MELEE, 0)
	var/burn_block = D.run_armor_check(affecting, BOMB, 0)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	D.apply_damage(10, BRUTE, selected_zone, brute_block) 
	D.apply_damage(10, BURN, selected_zone, burn_block) 
	D.visible_message(span_danger("[A] [A.dna.species.attack_verb]s [D]!"), \
					  span_userdanger("[A] [A.dna.species.atk_verb]s you!"))
		log_combat(A, D, "[A.dna.species.atk_verb]s(Explosive Fist)")


/datum/martial_art/explosive_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE  ///Same as with harm_act

/datum/martial_art/explosive_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, EXPLOSIVE_DISARM_COMBO))
		explosive_disarm(A,D)
		return TRUE
	if(findtext(streak, PRE_DETONATE_COMBO))
		detonate(A,D)
		return TRUE
	if(findtext(streak, PRE_LIFEFORCE_TRADE_COMBO))
		lifeforce_trade(A,D)
		return TRUE

/datum/martial_art/explosive_fist/proc/explosive_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(18, BURN, BODY_ZONE_CHEST, armor_block)
 
	var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST) // p - plasmamen
	var/armor_block_p = A.run_armor_check(affecting_p, BOMB)
	A.apply_damage(10, BURN, BODY_ZONE_CHEST, armor_block_p) 

	D.Knockdown(3 SECONDS)
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	log_combat(A, D, "blasts(Explosive Fist)")
	D.visible_message(span_danger("[A] blasts [D]!"), \
				span_userdanger("[A] blasts you!"))
	var/atom/throw_target = get_edge_target_turf(D, dir)
	D.throw_at(throw_target, rand(1,2), 7, A)
	streak = ""

/datum/martial_art/explosive_fist/proc/detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, DETONATE_COMBO))
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		log_combat(A, D, "detonates(Explosive Fist)")
		D.visible_message(span_danger("[A] detonates [D]!"), \
					span_userdanger("[A] detonates you!"))
		explosion(get_turf(affected_mob), -1, 0, 2, 0, 0, 2)
		D.IgniteMob()
		playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
		
		var/obj/item/bodypart/affecting = A.get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = target.run_armor_check(affecting, BOMB)
		A.apply_damage(15, BRUTE, BODY_ZONE_CHEST, armor_block) 
		streak = ""

	else if(findtext(streak, ALMOST_DETONATE_COMBO))
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/armor_block = D.run_armor_check(affecting, MELEE, 0)
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
		playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/current_stamina_damage = D.getStaminaLoss()
		var/damage_to_deal = 55

		if(current_stamina_damage > 50)   ///We apply a stamina slowdown on our target, our do nothing!
			damage_to_deal = 0
		D.apply_damage(damage_to_deal, STAMINA, selected_zone, armor_block) 
		D.visible_message(span_danger("[A] activates [D]!"), \
						span_userdanger("[A] activates you!")) 
		log_combat(A, D, "activates(Explosive Fist)")
		D.adjust_fire_stacks(4)

	else 
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/brute_block = D.run_armor_check(affecting, MELEE, 0)
		var/burn_block = D.run_armor_check(affecting, BOMB, 0)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
		D.apply_damage(12, BRUTE, selected_zone, brute_block) 
		D.apply_damage(12, BURN, selected_zone, burn_block) 
		D.adjust_fire_stacks(2)
		D.visible_message(span_danger("[A] primes [D]!"), \
						span_userdanger("[A] primes you!"))		
		log_combat(A, D, "primes(Explosive Fist)")

/datum/martial_art/explosive_fist/proc/lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, LIFEFORCE_TRADE_COMBO))
		if(A.get_item_by_slot(ITEM_SLOT_HEAD))
			A.do_attack_animation(D, ATTACK_EFFECT_SMASH)			
			playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)

			var/selected_zone = A.zone_selected
			var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
			var/brute_block = D.run_armor_check(affecting, MELEE, 0)
			var/burn_block = D.run_armor_check(affecting, BOMB, 0)
			D.apply_damage(25, BRUTE, selected_zone, brute_block) 
			D.apply_damage(25, BURN, selected_zone, burn_block) 

			var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST)
			var/brute_block_p = A.run_armor_check(affecting_p, MELEE)
			var/burn_block_p = A.run_armor_check(affecting_p, BOMB)
			A.apply_damage(5, BRUTE, BODY_ZONE_CHEST, brute_block_p) 
			A.apply_damage(5, BURN, BODY_ZONE_CHEST, burn_block_p) 

			D.visible_message(span_danger("[A] headbutts [D]!"), \
							span_userdanger("[A] headbutts you!"))		
			log_combat(A, D, "headbutts(Explosive Fist)")
			streak = ""
		else
			if(!life_force_trade_active)
				return
			if(A.grab_state < GRAB_NECK)
				A.grab_state = GRAB_NECK
			if(!(A.pulling == D))
				D.grabbedby(A, 1)
			streak = ""
			A.adjust_fire_stacks(3)
			D.adjust_fire_stacks(3)
			A.IgniteMob()
			D.IgniteMob()
			proceed_lifeforce_trade(A, D)	

/datum/martial_art/explosive_fist/proc/proceed_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)	
	if(!can_suck_life(A, D))
		return
	if(!do_mob(A, D, 1 SECONDS))
		return
	if(!can_suck_life(A, D))
		return
	var/message = pick("You feel your life force being drained!", "It hurts!", "You stare into [A]'s expressionless skull and see only fire and death.")
	to_chat(D, span_userdanger(message))
	D.emote("scream")
	var/dam = 2
	D.adjustFireLoss(dam)
	var/bruteloss = D.getBruteLoss()
	var/fireloss = D.getFireLoss()
	A.heal_overall_damage(bruteloss/2, fireloss/2, 0, required_status, updating_health = TRUE, CONSCIOUS, TRUE)
	to_chat(A, span_notice("You drain lifeforce from [D]"))
	proceed_lifeforce_trade(A, D)
	
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
	if(A.stat == DEAD || A.stat == UNCONSCIOUS)
		return FALSE
	if(D.stat == DEAD || D.stat == UNCONSCIOUS)
		return FALSE
	return TRUE

