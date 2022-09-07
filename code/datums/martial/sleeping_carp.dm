#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	deflection_chance = 0 //no block unless throwmode is on
	reroute_deflection = TRUE
	no_guns = TRUE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help
	var/old_grab_state = null

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		streak = ""
		wristWrench(A,D)
		return TRUE
	if(findtext(streak,BACK_KICK_COMBO))
		streak = ""
		backKick(A,D)
		return TRUE
	if(findtext(streak,STOMACH_KNEE_COMBO))
		streak = ""
		kneeStomach(A,D)
		return TRUE
	if(findtext(streak,HEAD_KICK_COMBO))
		streak = ""
		headKick(A,D)
		return TRUE
	if(findtext(streak,ELBOW_DROP_COMBO))
		streak = ""
		elbowDrop(A,D)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/wristWrench(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "wrist wrenched (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(span_warning("[A] grabs [D]'s wrist and wrenches it sideways!"), \
						  span_userdanger("[A] grabs your wrist and violently wrenches it to the side!"))
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(A.get_punchdamagehigh() / 2, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), wound_bonus = CANT_WOUND)	//5 damage
		D.Stun(60)
		return TRUE

	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/backKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		if(A.dir == D.dir)
			log_combat(A, D, "back-kicked (Sleeping Carp)")
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			D.visible_message(span_warning("[A] kicks [D] in the back!"), \
								span_userdanger("[A] kicks you in the back, making you stumble and fall!"))
			step_to(D,get_step(D,D.dir),1)
			D.Paralyze(80)
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
			return TRUE
		else
			log_combat(A, D, "missed a back-kick (Sleeping Carp) on")
			D.visible_message(span_warning("[A] tries to kick [D] in the back, but misses!"), \
								span_userdanger("[A] tries to kick you in the back, but misses!"))
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/kneeStomach(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "stomach kneed (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message(span_warning("[A] knees [D] in the stomach!"), \
						  span_userdanger("[A] winds you with a knee in the stomach!"))
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(40)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return TRUE
	return basic_hit(A,D)	

/datum/martial_art/the_sleeping_carp/proc/headKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "head kicked (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message(span_warning("[A] kicks [D] in the head!"), \
						  span_userdanger("[A] kicks you in the jaw!"))
		D.apply_damage(A.get_punchdamagehigh() + 10, A.dna.species.attack_type, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)	//20 damage
		D.drop_all_held_items()
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Stun(80)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/elbowDrop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(D.mobility_flags & MOBILITY_STAND))
		log_combat(A, D, "elbow dropped (Sleeping Carp)")
		var/dunk_damage = A.get_punchdamagehigh() * 3 + 20 //50 damage, get dunked on
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(span_warning("[A] elbow drops [D]!"), \
							span_userdanger("[A] piledrives you with their elbow!"))
		if(D.stat)
			D.() //FINISH HIM!
		D.apply_damage(dunk_damage, A.dna.species.attack_type, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = A.grab_state
		D.grabbedby(A, 1)
		if(old_grab_state == GRAB_PASSIVE)
			D.drop_all_held_items()
			A.grab_state = GRAB_AGGRESSIVE //Instant agressive grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively")
			D.visible_message(span_warning("[A] violently grabs [D]!"), \
								span_userdanger("[A] violently grabs you!"))
		return TRUE
	else
		return FALSE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	var/harm_damage = A.get_punchdamagehigh() + rand(0,5)	//10-15 damage
	D.visible_message(span_danger("[A] [atk_verb] [D]!"), \
					  span_userdanger("[A] [atk_verb] you!"))
	D.apply_damage(harm_damage, BRUTE, wound_bonus = CANT_WOUND)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(D.getBruteLoss()) && (D.mobility_flags & MOBILITY_STAND))
		D.visible_message(span_warning("[D] stumbles and falls!"), span_userdanger("The blow sends you to the ground!"))
		D.Paralyze(80)
	log_combat(A, D, "[atk_verb] (Sleeping Carp)")
	return TRUE


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return ..()

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

	to_chat(usr, "[span_notice("Wrist Wrench")]: Disarm Disarm. Forces opponent to drop item in hand.")
	to_chat(usr, "[span_notice("Back Kick")]: Harm Grab. Opponent must be facing away. Knocks down.")
	to_chat(usr, "[span_notice("Stomach Knee")]: Grab Harm. Knocks the wind out of opponent and stuns.")
	to_chat(usr, "[span_notice("Head Kick")]: Disarm Harm Harm. Decent damage, forces opponent to drop item in hand.")
	to_chat(usr, "[span_notice("Elbow Drop")]: Harm Disarm Harm Disarm Harm. Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition.")

	to_chat(usr, "<b><i>You will only deflect projectiles while throwmode is enabled.</i></b>")

/obj/item/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 14
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/twohanded/bostaff/update_icon()
	icon_state = "bostaff[wielded]"
	return

/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	if(user.a_intent == INTENT_DISARM)
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with the front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message(span_warning("[pick(fluffmessages)]"), \
							   span_userdanger("[pick(fluffmessages)]"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 75, 1, -1)
		SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, H, user)
		SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, H, user)
		H.lastattacker = user.real_name
		H.lastattackerckey = user.ckey

		user.do_attack_animation(H)

		log_combat(user, H, "Bo Staffed", src.name, "((DAMTYPE: STAMINA)")
		add_fingerprint(user)
		H.apply_damage(rand(28,33), STAMINA, BODY_ZONE_HEAD)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
									   span_userdanger("[user] knocks you unconscious!"))
				H.SetSleeping(300)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return FALSE
