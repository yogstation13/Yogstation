#define EXPLOSIVE_DISARM_COMBO "DD"

#define DETONATE_COMBO "HHDH"
#define PRE_DETONATE_COMBO "HH" 
#define ALMOST_DETONATE_COMBO "HHD" 


/datum/martial_art/explosive_fist
	name = "Explosive Fist"
	id =  MARTIALART_PRETERNISSTEALTH
	//help_verb = /mob/living/carbon/human/proc/preternis_martial_help

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

/datum/martial_art/explosive_fist/proc/explosive_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.adjustFireLoss(10)
	D.adjustFireLoss(18)
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
		D.adjust_fire_stacks(1)
		D.IgniteMob()
		playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
		
		var/obj/item/bodypart/affecting = target.get_bodypart(BODY_ZONE_CHEST)
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



	