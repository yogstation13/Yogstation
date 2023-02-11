#define EXPLOSIVE_DISARM_COMBO "DD"

#define DETONATE_COMBO "QH"
#define ALMOST_DETONATE_COMBO "PD" 	//Sets streak to "Q"
#define PRE_DETONATE_COMBO "HH" 	//Sets streak to "P"

#define LIFEFORCE_TRADE_COMBO "MG" 
#define ALMOST_LIFEFORCE_TRADE_COMBO "LD" 	//Sets streak to "M"
#define PRE_LIFEFORCE_TRADE_COMBO "DG" 		//Sets streak to "L"

#define IMMOLATE_COMBO "JG" 
#define ALMOST_IMMOLATE_COMBO "ID"	//Sets streak to "J"
#define PRE_IMMOLATE_COMBO "DH"  	//Sets strak to "I"

//Important note: Plasma man max punch damage is 7, values are based off of this number.

/datum/martial_art/explosive_fist
	name = "Explosive Fist"
	id =  MARTIALART_EXPLOSIVEFIST
	help_verb = /mob/living/carbon/human/proc/explosive_fist_help
	var/succ_damage = 2	//Our life suck damage. Increases the longer it's held.

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
	playsound(get_turf(D), 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	D.apply_damage(A.get_punchdamagehigh() + 3, BRUTE, selected_zone, brute_block) 	//10 brute
	D.apply_damage(A.get_punchdamagehigh() + 3, BURN, selected_zone, burn_block) 	//10 burn (vs bomb armor)
	D.visible_message(span_danger("[A] [A.dna.species.attack_verb]s [D]!"), \
					  span_userdanger("[A] [A.dna.species.attack_verb]s you!"))
	log_combat(A, D, "[A.dna.species.attack_verb]s(Explosive Fist)")


/datum/martial_art/explosive_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE  

/datum/martial_art/explosive_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, EXPLOSIVE_DISARM_COMBO))
		streak = "" 
		explosive_disarm(A,D)
		return TRUE
	if(findtext(streak, DETONATE_COMBO))	// End Detonate Chain
		streak = ""
		detonate(A,D)
		return TRUE	
	if(findtext(streak, ALMOST_DETONATE_COMBO))
		streak = "Q"	//Q comes after P
		almost_detonate(A,D)
		return TRUE
	if(findtext(streak, PRE_DETONATE_COMBO))	//Start detonate chain
		streak = "P"
		pre_detonate(A,D)
		return TRUE
	if(findtext(streak, LIFEFORCE_TRADE_COMBO))	//End life force drain chain
		streak = ""
		lifeforce_trade(A,D)
		return TRUE
	if(findtext(streak, ALMOST_LIFEFORCE_TRADE_COMBO))
		streak = "M"	//M comes after L
		almost_lifeforce_trade(A,D)
		return TRUE
	if(findtext(streak, PRE_LIFEFORCE_TRADE_COMBO))	//Start life force drain chain
		streak = "L"
		pre_lifeforce_trade(A,D)
		return TRUE
	if(findtext(streak,IMMOLATE_COMBO))	//End immolate chain
		streak = ""
		immolate(A,D)
		return TRUE
	if(findtext(streak,ALMOST_IMMOLATE_COMBO))
		streak = "J"	//J comes after I
		almost_immolate(A,D)
		return TRUE
	if(findtext(streak,PRE_IMMOLATE_COMBO))	//Start immolate chain
		streak = "I"
		pre_immolate(A,D)
		return TRUE
	//I have come to realize maybe this martial art is too complicated - Mqiib

/datum/martial_art/explosive_fist/proc/explosive_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(A.get_punchdamagehigh() * 2 + 4, BURN, selected_zone, armor_block)	//18 burn (vs bomb armor)
	D.Knockdown((A.get_punchdamagehigh() * 4/10 + 0.2) SECONDS)	//3 seconds (baseline (7*4)/10 + 0.2 seconds)
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	log_combat(A, D, "blasts(Explosive Fist)")
	D.visible_message(span_danger("[A] blasts [D]!"), \
				span_userdanger("[A] blasts you!"))
	var/atom/throw_target = get_edge_target_turf(D, get_dir(A,D))
	D.throw_at(throw_target, rand(1,2), 7, A)
	streak = ""

/datum/martial_art/explosive_fist/proc/detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
	log_combat(A, D, "detonates(Explosive Fist)")
	D.visible_message(span_danger("[A] detonates [D]!"), \
				span_userdanger("[A] detonates you!"))
	explosion(get_turf(D), -1, 0, 2, 0, 0, 2)
	D.IgniteMob()
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	
	var/obj/item/bodypart/affecting = A.get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = A.run_armor_check(affecting, BOMB)
	A.apply_damage(A.get_punchdamagehigh() * 1.5 + 4.5, BRUTE, BODY_ZONE_CHEST, armor_block) 	//15 brute (vs bomb)
	streak = ""

/datum/martial_art/explosive_fist/proc/almost_detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, 0)
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

	var/current_stamina_damage = D.getStaminaLoss()
	var/damage_to_deal = clamp(0, 55 - current_stamina_damage, 45)	//Tries to get their total stamina damage to 55
	D.apply_damage(damage_to_deal + 10, STAMINA, selected_zone, armor_block) 	//Always does at least 10

	D.visible_message(span_danger("[A] activates [D]!"), \
					span_userdanger("[A] activates you!")) 
	log_combat(A, D, "activates(Explosive Fist)")
	D.adjust_fire_stacks(4)

/datum/martial_art/explosive_fist/proc/pre_detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/brute_block = D.run_armor_check(affecting, MELEE, 0)
	var/burn_block = D.run_armor_check(affecting, BOMB, 0)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	D.apply_damage(A.get_punchdamagehigh() + 5, BRUTE, selected_zone, brute_block) 	//12 brute
	D.apply_damage(A.get_punchdamagehigh() + 5, BURN, selected_zone, burn_block) 	//12 burn (vs bomb armor)
	D.adjust_fire_stacks(2)
	D.visible_message(span_danger("[A] primes [D]!"), \
					span_userdanger("[A] primes you!"))		
	log_combat(A, D, "primes(Explosive Fist)")

/datum/martial_art/explosive_fist/proc/lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.get_item_by_slot(SLOT_HEAD))
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)			//BONK
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/brute_block = D.run_armor_check(affecting, MELEE, 0)
		var/burn_block = D.run_armor_check(affecting, BOMB, 0)
		D.apply_damage(A.get_punchdamagehigh() * 2.5 +  7.5, BRUTE, selected_zone, brute_block) 	//25 brute
		D.apply_damage(A.get_punchdamagehigh() * 2.5 +  7.5, BURN, selected_zone, burn_block) 		//25 burn (vs bomb armor)

		var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_HEAD)
		var/brute_block_p = A.run_armor_check(affecting_p, MELEE)
		var/burn_block_p = A.run_armor_check(affecting_p, BOMB)
		A.apply_damage(5, BRUTE, BODY_ZONE_HEAD, brute_block_p) 
		A.apply_damage(5, BURN, BODY_ZONE_HEAD, burn_block_p) 

		D.visible_message(span_danger("[A] headbutts [D]!"), \
						span_userdanger("[A] headbutts you!"))		
		log_combat(A, D, "headbutts(Explosive Fist)")
		streak = ""
	else
		if(A.grab_state < GRAB_NECK)
			A.grab_state = GRAB_NECK
		if(!(A.pulling == D))
			D.grabbedby(A, 1)
		D.visible_message(span_danger("[A] violently grabs [D]'s neck!"), \
						span_userdanger("[A] violently grabs your neck!"))		
		log_combat(A, D, "grabs by the neck(Explosive Fist)")
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		streak = ""
		A.adjust_fire_stacks(3)
		D.adjust_fire_stacks(3)
		A.IgniteMob()
		D.IgniteMob()
		succ_damage = initial(succ_damage)	//Reset our succ damage on start
		proceed_lifeforce_trade(A, D)

/datum/martial_art/explosive_fist/proc/almost_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)			
	playsound(get_turf(D), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

	D.visible_message(span_danger("[A] staggers [D]!"), \
					span_userdanger("[A] staggers you!"))		
	log_combat(A, D, "staggers(Explosive Fist)")

	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
	var/stamina_block = D.run_armor_check(affecting, MELEE, 0)
	var/burn_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(A.get_punchdamagehigh() * 2 + 6, STAMINA, selected_zone, stamina_block) 	//20 stamina
	D.apply_damage(A.get_punchdamagehigh() - 2, BURN, selected_zone, burn_block) 			//5 burn (vs bomb armor)

	if(!D.has_movespeed_modifier(MOVESPEED_ID_SHOVE)) /// We apply a more long shove slowdown if our target doesn't already have one
		D.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
		addtimer(CALLBACK(D, /mob/living/carbon/human/proc/clear_shove_slowdown), 4 SECONDS)

	D.dna.species.aiminginaccuracy += 25
	addtimer(CALLBACK(src, .proc/remove_stagger, D), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	
/datum/martial_art/explosive_fist/proc/pre_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return

	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)

	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(A.get_punchdamagehigh() * 2 + 6, BURN, selected_zone, armor_block)	//20 burn (vs bomb armor)

	D.visible_message(span_danger("[A] burns [D]!"), \
					span_userdanger("[A] burns you!"))		
	log_combat(A, D, "burns(Explosive Fist)")

/datum/martial_art/explosive_fist/proc/immolate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return

	if(A.get_item_by_slot(ITEM_SLOT_HEAD))   //No helmets???
		streak = ""
		return FALSE
	else 
		for(var/mob/living/target in view_or_range(2, A, "range"))
			if(target == A)  
				continue
			target.adjustFireLoss(30)
			if(get_dist(get_turf(A), get_turf(target)) <= 1)	//If they're close we ignite them too
				target.IgniteMob() 	

		var/obj/item/bodypart/hed = D.get_bodypart(BODY_ZONE_HEAD)
		var/armor_block = D.run_armor_check(hed, BOMB)
		D.apply_damage(A.get_punchdamagehigh() + 3, BURN, BODY_ZONE_HEAD, armor_block) 		//10 burn (vs bomb armor)
		D.emote("scream")		
		D.blur_eyes(4)

		A.apply_damage(10, BURN, BODY_ZONE_CHEST, 0) 	//Take some unblockable damage since you're using your inner flame or something

		A.visible_message(span_danger("[A] explodes violently!"), \
					span_userdanger("You unleash the flames from yourself!"))
		log_combat(A, D, "immolates(Explosive Fist)")	
		playsound(get_turf(A), 'sound/effects/explosion1.ogg', 50, TRUE, -1)			
	
/datum/martial_art/explosive_fist/proc/almost_immolate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	for(var/mob/living/target in view_or_range(2, A, "range"))
		target.adjust_fire_stacks(5)
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(A.zone_selected))
		var/burn_block = target.run_armor_check(affecting, BOMB, 0)
		var/brute_block = target.run_armor_check(affecting, MELEE, 0)
		target.apply_damage(A.get_punchdamagehigh() + 3, BURN, selected_zone, burn_block)	//10 brute
		target.apply_damage(A.get_punchdamagehigh() - 2, BRUTE, selected_zone, brute_block)	//5 burn (vs bomb armor)
	D.visible_message(span_danger("[A] primes [D]!"), \
				span_userdanger("[A] primes you!"))
	log_combat(A, D, "primes(Explosive Fist)")	
	playsound(get_turf(D), 'sound/effects/explosion1.ogg', 50, TRUE, -1)


/datum/martial_art/explosive_fist/proc/pre_immolate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)

	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(A.get_punchdamagehigh() * 2 + 6, BURN, selected_zone, armor_block)	//20 burn (vs bomb armor)

	D.visible_message(span_danger("[A] burns [D]!"), \
					span_userdanger("[A] burns you!"))		
	log_combat(A, D, "burns(Explosive Fist)")

	return TRUE

/datum/martial_art/explosive_fist/proc/proceed_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)	
	if(!can_suck_life(A, D))
		return
	if(!do_mob(A, D, 1 SECONDS))
		return
	if(!can_suck_life(A, D))
		return
	if(prob(35))
		var/message = pick("You feel your life force being drained!", "It hurts!", "You stare into [A]'s expressionless skull and see only fire and death.")
		to_chat(D, span_userdanger(message))
	if(prob(25))
		D.emote("scream")
	D.adjustFireLoss(succ_damage)
	D.adjustStaminaLoss(succ_damage * 2)		//YOU ARE HELPLESS TO RESIST THE SPOOKY SKELETON
	A.heal_overall_damage(succ_damage/2, succ_damage/2, 0, CONSCIOUS, TRUE)
	to_chat(A, span_notice("You drain lifeforce from [D]"))
	succ_damage++	//+1 damage per succ
	proceed_lifeforce_trade(A, D)
	
/datum/martial_art/explosive_fist/proc/can_suck_life(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.get_item_by_slot(SLOT_HEAD))
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

/datum/martial_art/explosive_fist/proc/remove_stagger(mob/living/carbon/human/D)
	D.dna.species.aiminginaccuracy -= 25

/mob/living/carbon/human/proc/explosive_fist_help()
	set name = "Remember the basics"
	set desc = "You try to remember some basic actions from the explosive fist art."
	set category = "Explosive Fist"
	to_chat(usr, "<b><i>You try to remember some basic actions from the explosive fist art.</i></b>")

	to_chat(usr, span_notice("<b>Harm Intent</b> Will deal 10 burn and 10 brute damage to people who you hit."))

	to_chat(usr, "[span_notice("Explosive disarm")]: Disarm Disarm. Finishing this combo will deal 10 damage to you and 18 to your target, as well as throwing your target away and knocking down for three seconds.")
	to_chat(usr, "[span_notice("Detonate")]: Harm Harm Disarm Harm. Second strike will deal 12/12 brute/burn and apply 2 fire stacks to the target. Third strike will apply 4 fire stacks and deal some stamina damage if the target has less then 50 stamina damage. The final strike will ignite the target, make a light explosion and deal 15 damage to you.")
	to_chat(usr, "[span_notice("Life force trade")]: Disarm Grab Disarm Grab. Second strike will deal 20 damage to the target and 5 damage to you. Third strike will deal 20 stamina and 5 burn damage to the target, and will make it unable to use ranged weapons for 2 second as well as a more long shove slowdown. Finishing the combo with a headwear on will just deal 25/25 brute/burn damage to the target, and if you don't wear a helmet, you will instantly grab the target by a neck, as well as start to drain life from them.")
	to_chat(usr, "[span_notice("Immolate")]: Disarm Harm Disarm Grab. Second strike will deal 25 burn damage to the target and 5 burn damage to you. Third strike will apply 5 fire stacks to EVERYONE in the range of 2 tiles. Finishing the combo will, if you don't wear any headwear, will deal 30 burn damage to anyone except you in the range of 2 tiles, or ignite them if they are close enough to you. You target will get additional 10 burn damage and get blurry vision.")

/datum/martial_art/explosive_fist/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	ADD_TRAIT(H, TRAIT_RESISTHEAT, "explosive_fist")

/datum/martial_art/explosive_fist/on_remove(mob/living/carbon/human/H)
	..()
	REMOVE_TRAIT(H, TRAIT_RESISTHEAT, "explosive_fist")

//these aren't needed elsewhere
#undef EXPLOSIVE_DISARM_COMBO

#undef DETONATE_COMBO
#undef ALMOST_DETONATE_COMBO
#undef PRE_DETONATE_COMBO

#undef LIFEFORCE_TRADE_COMBO
#undef ALMOST_LIFEFORCE_TRADE_COMBO
#undef PRE_LIFEFORCE_TRADE_COMBO

#undef IMMOLATE_COMBO
#undef ALMOST_IMMOLATE_COMBO
#undef PRE_IMMOLATE_COMBO
