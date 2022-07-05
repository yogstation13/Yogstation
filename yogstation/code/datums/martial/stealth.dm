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
	return FALSE  ///We need it work like a generic, non martial art attack


/datum/martial_art/stealth/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE  ///Same as with harm_act

/datum/martial_art/stealth/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, PRE_DAGGER_COMBO))
		return hidden_knife(A,D)
	if(findtext(streak, PRE_INJECTION_COMBO))
		injection(A,D)
		return TRUE
	if(findtext(streak, PRE_FINGERGUN_COMBO))
		fingergun(A,D)
		return TRUE

/datum/martial_art/stealth/proc/hidden_knife(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, DAGGER_COMBO))
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(selected_zone))
		var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 40)
		D.apply_damage(30, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 
		to_chat(A, span_warning("You stab [D] with a hidden blade!"))
		to_chat(D, span_userdanger("You are suddenly stabbed with a blade!"))
		streak = ""
		return TRUE
	else 
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(selected_zone))
		var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 10)
		D.apply_damage(20, STAMINA, affecting, armor_block)
		D.apply_damage(5, BRUTE, affecting, armor_block)
		return FALSE //Because it is a stealthy martial art, we need it to work like... a normal shove, so people nearby couldn't understand so easy that you know a martial art.


/datum/martial_art/stealth/proc/injection(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, INJECTION_COMBO))
		D.reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 8)
		to_chat(A, span_warning("You inject sodium thiopental into [D]!"))
		to_chat(D, span_notice("You feel a tiny prick."))
		streak = ""
	else 
		D.reagents.add_reagent(/datum/reagent/toxin/cyanide, 5)
		to_chat(A, span_warning("You inject cyanide into [D]!"))
		to_chat(D, span_notice("You feel a tiny prick."))		

/datum/martial_art/stealth/proc/fingergun(mob/living/carbon/human/A, mob/living/carbon/human/D)

