#define SLAM_COMBO "GH"
#define KICK_COMBO "DH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DDG"
#define CONSECUTIVE_COMBO "HHHHH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = /mob/living/carbon/human/proc/CQC_help
	block_chance = 75 //to do: make blocking actually ufcking work with everything instead of being hidden in 5 different locations
	var/just_a_cook = FALSE
	var/old_grab_state = null

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	just_a_cook = TRUE

/datum/martial_art/cqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/cqc/can_use(mob/living/carbon/human/H) //this is used to make chef CQC only work in kitchen
	var/area/A = get_area(H)
	if(just_a_cook && !(istype(A, /area/crew_quarters/kitchen)))
		return FALSE
	return ..()

/datum/martial_art/cqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,SLAM_COMBO))
		streak = ""
		Slam(A,D)
		return TRUE
	if(findtext(streak,KICK_COMBO))
		streak = ""
		Kick(A,D)
		return TRUE
	if(findtext(streak,RESTRAIN_COMBO))
		streak = ""
		Restrain(A,D)
		return TRUE
	if(findtext(streak,PRESSURE_COMBO))
		streak = ""
		Pressure(A,D)
		return TRUE
	if(findtext(streak,CONSECUTIVE_COMBO))
		streak = ""
		Consecutive(A,D)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(D.mobility_flags & MOBILITY_STAND)
		D.visible_message("<span class='warning'>[A] slams [D] into the ground!</span>", \
						  	"<span class='userdanger'>[A] slams you into the ground!</span>")
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Paralyze(10)
		D.Knockdown(60)
		log_combat(A, D, "slammed (CQC)")
	return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat || (D.mobility_flags & MOBILITY_STAND))
		D.visible_message("<span class='warning'>[A] kicks [D] back!</span>", \
							"<span class='userdanger'>[A] kicks you back!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, STAMINA)
		log_combat(A, D, "kicked (CQC)")
	if(!(D.mobility_flags & MOBILITY_STAND) && !D.stat)
		log_combat(A, D, "prone-kicked(CQC)")
		D.visible_message("<span class='warning'>[A] firmly kicks [D] in the abdomen!</span>", \
					  		"<span class='userdanger'>[A] kicks you in the abdomen!</span>")
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		D.apply_damage(30, STAMINA)
		D.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	return TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "pressured (CQC)")
	D.visible_message("<span class='warning'>[A] punches [D]'s neck!</span>")
	D.drop_all_held_items()
	D.adjustStaminaLoss(30)
	D.Immobilize(60)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(restraining)
		return
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "restrained (CQC)")
		D.visible_message("<span class='warning'>[A] locks [D] into a restraining position!</span>", \
							"<span class='userdanger'>[A] locks you into a restraining position!</span>")
		D.Stun(20)
		if(A.grab_state < GRAB_AGGRESSIVE)
			A.grab_state = GRAB_AGGRESSIVE
		restraining = TRUE
		addtimer(CALLBACK(src, .proc/drop_restraining), 300, TIMER_UNIQUE)
	return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(D.mobility_flags & MOBILITY_STAND)
		log_combat(A, D, "consecutive CQC'd (CQC)")
		D.visible_message("<span class='warning'>[A] delivers a firm blow to [D]'s head, knocking them down</span>", \
							"<span class='userdanger'>[A] delivers a firm blow to your head, causing you to fall over!</span>")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		D.Paralyze(20)
		D.Knockdown(100)
		D.apply_damage(25, STAMINA)
	return TRUE

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && can_use(A)) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		D.grabbedby(A, 1)
		D.Stun(15)
		return TRUE
	else
		return FALSE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "attacked (CQC)")
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "Big Bossed")
	var/bonus_damage = 15
	D.apply_damage(bonus_damage, STAMINA)
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	D.Immobilize(15)
	log_combat(A, D, "[picked_hit_type] (CQC)")
	if(A.resting && !D.stat && !(D.mobility_flags & MOBILITY_STAND))
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.Paralyze(10)
		D.Knockdown(60)
		A.set_resting(FALSE)
		A.SetKnockdown(0)
		log_combat(A, D, "sweeped (CQC)")
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	var/obj/item/I = null
	if(check_streak(A,D))
		return TRUE
	if(prob(65))
		if(!D.stat || !D.IsParalyzed() || !restraining)
			I = D.get_active_held_item()
			D.visible_message("<span class='warning'>[A] quickly grabs [D]'s arm and and chops it, disarming them!</span>", \
								"<span class='userdanger'>[A] grabs your arm and chops it, disarming you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, STAMINA)
	else
		D.visible_message("<span class='danger'>[A] grabs at [D]'s arm, but misses!</span>", \
							"<span class='userdanger'>[A] grabs at your arm, but misses!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	log_combat(A, D, "disarmed (CQC)", "[I ? " grabbing \the [I]" : ""]")
	if(restraining && A.pulling == D)
		log_combat(A, D, "began to chokehold(CQC)")
		D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
							"<span class='userdanger'>[A] puts you into a chokehold!</span>")
		if(handle_chokehold(A, D))
			D.Unconscious(400)
			if(A.grab_state < GRAB_NECK)
				A.grab_state = GRAB_NECK
			A.visibe_message("<span class='danger'>[A] relaxes their grip on [D].</span>", \ //ok sure it's actually probably a stronger grab but they aren't being choked nearly as fast
								"<span class='danger'>You relax your grip on [D].</span>") //visible message comes from attacker since defender is unconscious and therefore can't see
		else
			A.grab_state = min(0, A.grab_state - 1) //immediately lose grab power...
			if(prob(BASE_RESIST_CHANCE/A.grab_state)) //...and have a chance to lose the entire grab
				A.visible_message("<span class='danger'>[A] is put off balance, losing their grip on [D]!</span>", \
									"<span class='danger'>You are put off balance, and you lose your grip on [D]!</span>")
				A.stop_pulling()
			else
				A.visible_message("<span class='danger'>[A] is put off balance, and struggles to maintain their grip on [D]!</span>", \
									"<span class='danger>You are put off balance, and struggle to maintain your grip on [D]!</span>")
		restraining = FALSE
	else
		restraining = FALSE
		return FALSE
	return TRUE

/datum/martial_art/cqc/proc/handle_chokehold(mob/living/carbon/human/A, mob/living/carbon/human/D) //handles the chokehold attack, dealing oxygen damage until the target is unconscious or would have less than 20 health before knocking out
	var/damage2deal = 10 * (1+D.getStaminaLoss/100) //stamina damage boosts the effectiveness of an attack, making using other attacks to prepare important
	while(do_mob(A, D, 30))
		if(D.health - damage2deal < 20 || D.stat)
			return TRUE
		D.adjustOxyLoss(damage2deal)
		if(D.getOxyLoss >= 50)
			return TRUE

/datum/martial_art/cqc/handle_counter(mob/living/carbon/human/A, mob/living/carbon/human/D) //I am going to fucking gut whoever did the old counter system also whoever made martial arts
	if(!can_use(A))
		return
	D.visible_message("<span class='warning'>[A] grabs [D]'s arm as they attack and throws them to the ground!</span>", \
						"<span class='userdanger'>[A] grabs your arm as you attack and throws you to the ground!</span>")
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	I = D.get_active_held_item()
	if(I && D.temporarilyRemoveItemFromInventory(I))
		var/hand = A.get_inactive_hand_index()
		A.put_in_hand(I, hand)
	D.Paralyze(20)
	D.Knockdown(60)
	

/mob/living/carbon/human/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "<span class='notice'><b>All of your attacks deal stamina damage instead of your normal physical damage type</b></span>")
	
	to_chat(usr, "<span class='notice'><b>Disarm Intent</b> Has a chance to disarm the opponent's main hand, and immediately pick up the item if successful</span>")
	to_chat(usr, "<span class='notice'><b>Grab Intent</b> Will stun opponents for a short second, allowing you to quickly increase the strength of your grabs</span>")
	to_chat(usr, "<span class='notice'><b>Harm Intent</b> Will deal a competitive amount of stamina damage, and hitting a standing opponent while you are prone will both knock them down and stand you up</span>")
	
	to_chat(usr, "<span class='notice'>Slam</span>: Grab Harm. Slam opponent into the ground, knocking them down and dealing decent stamina damage.")
	to_chat(usr, "<span class='notice'>CQC Kick</span>: Disarm Harm. Knocks opponent away and slows them. Deals heavy stamina damage to prone opponents.")
	to_chat(usr, "<span class='notice'>Restrain</span>: Grab Grab. Locks opponents into a restraining position, making your grab harder to break out of, disarm to begin a chokehold which will knock out faster the more stamina damage the opponent has. Failing to complete the chokehold will weaken and possibly break your grab.")
	to_chat(usr, "<span class='notice'>Pressure</span>: Disarm Grab. Deals decent stamina damage and immobilizes the target, forcing them to drop anything they are holding.")
	to_chat(usr, "<span class='notice'>Consecutive CQC</span>: Harm Harm Harm Harm Harm. Offensive move, deals bonus stamina damage and knocking down on the last hit.")

	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")
