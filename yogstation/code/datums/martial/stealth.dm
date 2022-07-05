///hidden dagger
#define PRE_DAGGER_COMBO "HH"
#define DAGGER_COMBO "HHG"
///injection
#define PRE_INJECTION_COMBO "DH"
#define INJECTION_COMBO "DHD"
///fingergun
#define PRE_FINGERGUN_COMBO "HD"
#define FINGERGUN_COMBO "HDD"

/datum/martial_art/stealth
	name = "Stealth"   //Sorry for shitty name, I am bad at this
	id =  MARTIALART_PRETERNISSTEALTH
	//help_verb = /mob/living/carbon/human/proc/CQC_help

/datum/martial_art/stealth/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		return TRUE
	else
		return FALSE

/datum/martial_art/stealth/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 10)
	D.apply_damage(A.dna.species.punchdamagehigh + 2, A.dna.species.attack_type, selected_zone, armor_block) 
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	D.visible_message(span_danger("[A] assaulted [D]!"), \
					  span_userdanger("[A] assaults you!"))
	log_combat(A, D, "assaulted")


/datum/martial_art/stealth/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	user.visible_message(span_danger("[user.name] shoves [target.name]!"),
		span_danger("You shove [target.name]!"), null, COMBAT_MESSAGE_RANGE)
	var/target_held_item = target.get_active_held_item()
	var/knocked_item = FALSE
	if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types))
		target_held_item = null
	if(!target.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
		target.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
		if(target_held_item)
			target.visible_message(span_danger("[target.name]'s grip on \the [target_held_item] loosens!"),
				span_danger("Your grip on \the [target_held_item] loosens!"), null, COMBAT_MESSAGE_RANGE)
		addtimer(CALLBACK(target, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
	else if(target_held_item)
		target.dropItemToGround(target_held_item)
		knocked_item = TRUE
		target.visible_message(span_danger("[target.name] drops \the [target_held_item]!!"),
		span_danger("You drop \the [target_held_item]!!"), null, COMBAT_MESSAGE_RANGE)
	var/append_message = ""
	if(target_held_item)
		if(knocked_item)
			append_message = "causing them to drop [target_held_item]"
		else
			append_message = "loosening their grip on [target_held_item]"
	log_combat(user, target, "shoved", append_message)

/datum/martial_art/stealth/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, PRE_DAGGER_COMBO))
		hidden_knife(A,D)
		return TRUE
	if(findtext(streak, PRE_INJECTION_COMBO))
		injection(A,D)
		return TRUE
	if(findtext(streak, PRE_FINGERGUN_COMBO))
		fingergun(A,D)
		return TRUE

/datum/martial_art/stealth/proc/hidden_knife(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, DAGGER_COMBO))
		var/selected_zone = A.zone_selected
		var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 40)
		D.apply_damage(30, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 

/datum/martial_art/stealth/proc/injection(mob/living/carbon/human/A, mob/living/carbon/human/D)

/datum/martial_art/stealth/proc/fingergun(mob/living/carbon/human/A, mob/living/carbon/human/D)

