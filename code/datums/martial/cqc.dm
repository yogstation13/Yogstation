/**
  *
  * CQC martial art
  *
  * Martial art that focuses on stamina damage and movement impairing effects
  * Combos:
  * [Slam][/datum/martial_art/cqc/proc/Slam]
  * [Kick][/datum/martial_art/cqc/proc/Kick]
  * [Restrain][/datum/martial_art/cqc/proc/Restrain]
  * [Pressure][/datum/martial_art/cqc/proc/Pressure]
  * [Consecutive][/datum/martial_art/cqc/proc/Consecutive]
  */

///slam combo string
#define SLAM_COMBO "HD"
///kick combo string
#define KICK_COMBO "DD"
///pressure combo string
#define PRESSURE_COMBO "DH"
///consecutive combo string
#define CONSECUTIVE_COMBO "HH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = /mob/living/carbon/human/proc/CQC_help
	block_chance = 90 //Don't get into melee with someone specifically trained for melee and prepared for your attacks
	nonlethal = TRUE //all attacks deal solely stamina damage or knock out before dealing lethal amounts of damage
	///used to stop a chokehold attack from stacking
	var/chokehold_active = FALSE

/datum/martial_art/cqc/can_use(mob/living/carbon/human/H)
	if(!H.combat_mode)
		return FALSE
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Check Streak----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * check_streak proc
  *
  * checks a martial arts' current combo string against combo defines
  * activates a combo and returns true if it succeeds and the user can use the art
  * otherwise returns false
  */
/datum/martial_art/cqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,KICK_COMBO))
		streak = ""
		Kick(A,D)
		return TRUE
		
	if(!(D.mobility_flags & MOBILITY_STAND)) //the rest need a standing target
		return FALSE

	if(findtext(streak,SLAM_COMBO))
		streak = ""
		Slam(A,D)
		return TRUE
	if(findtext(streak,PRESSURE_COMBO))
		streak = ""
		Pressure(A,D)
		return TRUE
	if(findtext(streak,CONSECUTIVE_COMBO))
		streak = ""
		Consecutive(A,D)
		return TRUE
	return FALSE


////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Helper Proc-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//proc the moves will use for damage dealing for armour checking purposes
/datum/martial_art/cqc/proc/stamina_harm(mob/living/carbon/human/user, mob/living/carbon/human/victim, damage)
	var/obj/item/bodypart/limb_to_hit = victim.get_bodypart(user.zone_selected)
	var/armor = victim.run_armor_check(limb_to_hit, MELEE)
	victim.apply_damage(damage, STAMINA, blocked = armor)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Harm intent-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///CQC harm intent, deals 15 stamina damage and immobilizes for 1 seconds, if the attacker is prone, they knock the defender down and stand up
/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/attack_verb = pick("CQC'd", "Big Bossed")


	if(!(A.mobility_flags & MOBILITY_STAND) && (D.mobility_flags & MOBILITY_STAND))
		attack_verb = "leg sweeps"
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)

		D.Knockdown(3 SECONDS)
		A.set_resting(FALSE)
		A.SetKnockdown(0)
	else
		var/bonus_damage = A.get_punchdamagehigh() * 1.5 //15 damage
		stamina_harm(A, D, bonus_damage)

	D.Immobilize(0.5 SECONDS)

	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message(span_danger("[A] [attack_verb] [D]!"), span_userdanger("[A] [attack_verb] you!"))
	A.changeNext_move(CLICK_CD_RANGE) //faster cooldown from basic hits

	log_combat(A, D, "[attack_verb] (CQC)")
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Disarm intent-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///CQC disarm, guaranteed knocks the enemy's item out of their hand
/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE

	if(A.pulling == D && A.grab_state >= GRAB_AGGRESSIVE)
		chokehold(A, D)
		return TRUE

	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE


	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)

	if(D.drop_all_held_items())
		D.visible_message(span_warning("[A] quickly grabs [D]'s arm and and chops it, disarming them!"), span_userdanger("[A] grabs your arm and chops it, disarming you!"))
	else
		D.visible_message(span_warning("[A] quickly chops [D]'s arm!"), span_userdanger("[A] quickly chops your arm!"))
	D.adjust_jitter(2 SECONDS)
	stamina_harm(A, D, A.get_punchdamagehigh())
	A.changeNext_move(CLICK_CD_RANGE) //faster cooldown from basic hits
	
	log_combat(A, D, "disarmed (CQC)")
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------Grab---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///CQC grab, stuns for 1.5 seconds on use
/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D) // prevents grabbing yourself
		return FALSE

	var/old_grab_state = A.grab_state
	D.grabbedby(A)
	addtimer(CALLBACK(A, TYPE_PROC_REF(/mob/living, changeNext_move), CLICK_CD_RAPID)) //gotta do it this way because grabs are weird
	//no, invoke async doesn't work. Yes, this works despite the lack of time included in the parameters

	if(A.grab_state == GRAB_AGGRESSIVE && A.grab_state != old_grab_state)
		D.visible_message(span_warning("[A] locks [D] into a restraining position!"), span_userdanger("[A] locks you into a restraining position!"))
		log_combat(A, D, "restrained (CQC)")
		D.Stun(1 SECONDS)
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Harm Disarm-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * CQC slam combo attack
  *
  * Basic counter that causes 20 stamina damage with an 8 second knockdown
  */
/datum/martial_art/cqc/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.mobility_flags & MOBILITY_STAND)
		log_combat(A, D, "slammed (CQC)")
		D.visible_message(span_warning("[A] slams [D] into the ground!"), span_userdanger("[A] slams you into the ground!"))
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1) //using hit_kick because for some stupid reason slam.ogg is delayed
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		stamina_harm(A, D, A.get_punchdamagehigh() * 2) //20 damage
		D.Knockdown(80)
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Disarm Disarm----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * CQC kick combo attack
  *
  * attack that deals 15 stamina and pushes the target away if they are standing
  * or 40 stamina damage with a ~8 second mute if they aren't
  */
/datum/martial_art/cqc/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	if(D.mobility_flags & MOBILITY_STAND)
		log_combat(A, D, "kicked (CQC)")
		D.visible_message(span_warning("[A] kicks [D] back!"), span_userdanger("[A] kicks you back!"))
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		step(D, A.dir)
		stamina_harm(A, D, A.get_punchdamagehigh() * 1.5) //15 damage
		D.add_movespeed_modifier(MOVESPEED_ID_SHOVE, override = TRUE, multiplicative_slowdown = (SHOVE_SLOWDOWN_STRENGTH * 1.5))
		addtimer(CALLBACK(D, TYPE_PROC_REF(/mob/living/carbon/human, clear_shove_slowdown)), SHOVE_SLOWDOWN_LENGTH)
	else
		log_combat(A, D, "prone-kicked(CQC)")
		D.visible_message(span_warning("[A] firmly kicks [D] in the abdomen!"), span_userdanger("[A] kicks you in the abdomen!"))
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		var/kickdamage = A.get_punchdamagehigh() * 4	//40 damage
		stamina_harm(A, D, kickdamage)
		D.clear_stamina_regen() //used for keeping people down, so reset that regen timer
		D.Stun(1 SECONDS)
		D.silent += 2
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Disarm Harm-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * CQC pressure attack
  *
  * Attack that disables a limb if an arm/leg is selected, randomly selects a limb if one is not selected
  */
/datum/martial_art/cqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)

	var/list/viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	var/selected_zone = A.zone_selected
	if(!viable_zones.Find(selected_zone)) //if the selected bodypart isn't valid, pick a random one and hope it's there
		selected_zone = pick(viable_zones)
	var/obj/item/bodypart/hit_limb = D.get_bodypart(selected_zone)

	if(!hit_limb) //the body part is missing for one reason or another
		D.visible_message(span_warning("[A] harmlessly swings for [D]'s missing [hit_limb]!"), span_userdanger("[A] swings for your missing [hit_limb]!"))
		playsound(D, 'sound/weapons/punchmiss.ogg', 35, 1, -1)
		return FALSE

	hit_limb.force_wound_upwards(/datum/wound/blunt/moderate) //handles all those that can have limbs disabled with wounds (also proper dislocation)
	D.apply_damage(50, STAMINA, selected_zone) //handles most of those that can't (curse you boneless organic species!)

	D.visible_message(span_warning("[A] dislocates [D]'s [hit_limb]!"), span_userdanger("[A] dislocates your [hit_limb]!"))
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	log_combat(A, D, "pressured (CQC)")
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Harm Harm-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * CQC consecutive attack
  *
  * Attack that causes 50 stamina damage and confuses
  */
/datum/martial_art/cqc/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	log_combat(A, D, "consecutive CQC'd (CQC)")
	D.visible_message(span_warning("[A] delivers a firm blow to [D]'s head!"), span_userdanger("[A] delivers a firm blow to your head!"))
	playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	var/consecutivedamage = A.get_punchdamagehigh() * 5 //50 damage
	D.apply_damage(consecutivedamage, STAMINA)
	D.adjust_confusion_up_to(4 SECONDS, 8 SECONDS)
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Grab Grab-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
  * CQC restrain attack
  *
  * attack that puts the target into a restraining position, stunning and muting them for a short period
  * used to set up a chokehold attack
  */
/datum/martial_art/cqc/proc/chokehold(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(chokehold_active)
		return

	log_combat(A, D, "began to chokehold(CQC)")
	D.visible_message(
		span_danger("[isipc(D) ? "[A] attempts to deactivate [D]!" : "[A] puts [D] into a chokehold!"]"),
		span_userdanger("[isipc(D) ? "[A] attempts to deactivate you!" : "[A] puts you into a chokehold!"]")
	)
	if(handle_chokehold(A, D))
		D.Unconscious(40 SECONDS)
		if(A.grab_state < GRAB_NECK)
			A.grab_state = GRAB_NECK
		A.visible_message(span_danger("[A] relaxes their grip on [D]."), span_danger("You relax your grip on [D].")) //visible message comes from attacker since defender is unconscious and therefore can't see
	else //honestly with the way current grabs work this doesn't really do all that much
		A.stop_pulling()
		A.visible_message(span_danger("[A] is put off balance, losing their grip on [D]!"), span_danger("You are put off balance, and you lose your grip on [D]!"))
	chokehold_active = FALSE
	return

/**
  * CQC chokehold handle
  *
  * handles chokehold attack, dealing 10 oxygen damage with stamina damage multiplied as a % bonus every second
  * returns true if total damage reaches 80 or oxygen damage reaches 50
  * returns false if the attack is interrupted
  */
/datum/martial_art/cqc/proc/handle_chokehold(mob/living/carbon/human/A, mob/living/carbon/human/D) //handles the chokehold attack, dealing oxygen damage until the target is unconscious or would have less than 20 health before knocking out
	chokehold_active = TRUE
	var/damage2deal = 15
	while(do_after(A, isipc(D) ? 5 SECONDS : 1 SECONDS, D)) // doesn't make sense to deal oxygen damage to IPCs so instead do a longer channel that automatically succeeds
		if(!A.grab_state)
			return FALSE
		if(isipc(D)) // have you tried turning it off and on again
			return TRUE
		damage2deal = 15 * (1+D.getStaminaLoss()/100) //stamina damage boosts the effectiveness of an attack, making using other attacks to prepare important
		if(HAS_TRAIT(D, TRAIT_NOBREATH))
			damage2deal *= 0.5 // if they don't breathe they can't be choked, but you can still cut off blood flow to the head
		if(D.health - damage2deal < 20 || D.stat)
			return TRUE
		D.apply_damage(damage2deal, OXY) // respect oxygen damage mods
		if(D.getOxyLoss() >= 50)
			return TRUE

///CQC counter: attacker's weapon is placed in the defender's offhand and they are knocked down
/datum/martial_art/cqc/handle_counter(mob/living/carbon/human/user, mob/living/carbon/human/attacker) //I am going to fucking gut whoever did the old counter system also whoever made martial arts
	if(!can_use(user))
		return
	user.do_attack_animation(attacker, ATTACK_EFFECT_DISARM)
	attacker.visible_message(span_warning("[user] grabs [attacker]'s arm as they attack and throws them to the ground!"), \
						span_userdanger("[user] grabs your arm as you attack and throws you to the ground!"))
	playsound(get_turf(attacker), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	var/obj/item/I = attacker.get_active_held_item()
	if(I && attacker.temporarilyRemoveItemFromInventory(I))
		var/hand = user.get_inactive_hand_index()
		if(!user.put_in_hand(I, hand))
			I.forceMove(get_turf(attacker))
	attacker.Knockdown(60)
	user.adjustStaminaLoss(10)	//Can't block forever. Really, if this becomes a problem you're already screwed.

/**
  * CQC help proc
  *
  * Tells the user how CQC attacks work
  */
/mob/living/carbon/human/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	
	var/list/combined_msg = list()
	combined_msg += "<b><i>You try to remember some of the basics of CQC.</i></b>"

	combined_msg += span_notice("<b>All of your unarmed attacks deal stamina damage instead of your normal physical damage type</b>")

	combined_msg += span_notice("<b>Punching (Combat Mode)</b> Will deal more stamina damage, \
		and hitting a standing opponent while you are prone will both knock them down and stand you up. Has a reduced attack cooldown.")
	combined_msg += span_notice("<b>Shoving (Right Click)</b> Immediately disarms the opponent's main hand. Has a reduced attack cooldown.")
	combined_msg += span_notice("<b>Grabbing (Ctrl Click)</b> Has a significantly reduced attack cooldown, allowing you to quickly increase the strength of your grabs.")

	combined_msg += "[span_notice("Dislocate")]: Disarm Harm. Disables the targeted limb or a random limb if the head or chest are targeted."
	combined_msg += "[span_notice("CQC Kick")]: Disarm Disarm. Knocks a standing opponent away and slows them. Deals heavy stamina damage and briefly muting prone opponents."
	combined_msg += "[span_notice("Slam")]: Harm Disarm. Slam opponent into the ground, knocking them down and dealing decent stamina damage."
	combined_msg += "[span_notice("Discombobulate")]: Harm Harm. Offensive move, deals bonus stamina damage and confuses the target."

	combined_msg += "[span_notice("Restrain")]: Getting a target into an aggressive grab locks them into a restraining position, briefly stunning them."
	combined_msg += "[span_notice("Chokehold")]: Disarming a target you have aggressively grabbed will attempt to choke them unconscious."

	combined_msg += "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to counter attacks done to you. Beware, counter-attacks are tiring and you won't be able to defend yourself forever!</i></b>"

	to_chat(usr, examine_block(combined_msg.Join("\n")))

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Chef version----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	id = MARTIALART_CQC_COOK

/datum/martial_art/cqc/under_siege/proc/in_kitchen(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(istype(A, /area/crew_quarters/kitchen))
		return TRUE
	return FALSE

/datum/martial_art/cqc/under_siege/can_use(mob/living/carbon/human/H) //this is used to make chef CQC only work in kitchen
	if(!in_kitchen(H))
		return FALSE
	return ..()

/datum/martial_art/cqc/under_siege/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!in_kitchen(D)) //if you somehow check the streak on a target outside of kitchen, still stop
		return FALSE
	return ..()

/datum/martial_art/cqc/under_siege/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!in_kitchen(D)) //no disarming people outside of the kitchen
		return FALSE
	return ..()

/datum/martial_art/cqc/under_siege/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!in_kitchen(D)) //no harming people outside of the kitchen
		return FALSE
	return ..()

/datum/martial_art/cqc/under_siege/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!in_kitchen(D)) //no grabbing people outside of the kitchen
		return FALSE
	return ..()
