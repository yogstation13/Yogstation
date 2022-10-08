///hidden dagger
#define PRE_DAGGER_COMBO "HH"
#define DAGGER_COMBO "HHG"
///injection
#define PRE_INJECTION_COMBO "DH"
#define INJECTION_COMBO "DHD"
///fingergun
#define FINGERGUN_COMBO "HDD"

/datum/martial_art/stealth
	name = "Stealth"   //Sorry for shitty name, I am bad at this
	id =  MARTIALART_PRETERNISSTEALTH
	help_verb = /mob/living/carbon/human/proc/preternis_martial_help

/datum/martial_art/stealth/can_use(mob/living/carbon/human/H)
	return ispreternis(H)

/datum/martial_art/stealth/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		return FALSE
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
	if(findtext(streak, FINGERGUN_COMBO))
		fingergun(A,D)
		return FALSE

/datum/martial_art/stealth/proc/hidden_knife(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, DAGGER_COMBO))
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
		var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 40)
		D.apply_damage(30, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 
		to_chat(A, span_warning("You stab [D] with a hidden blade!"))
		to_chat(D, span_userdanger("You are suddenly stabbed with a blade!"))
		streak = ""
		return TRUE
	else 
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
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
	var/obj/item/gun/ballistic/automatic/pistol/martial/gun = new /obj/item/gun/ballistic/automatic/pistol/martial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	to_chat(A, span_notice("You extract a hiden gun from your hand."))	
	D.Paralyze(1 SECONDS)
	streak = ""

/obj/item/gun/ballistic/automatic/pistol/martial
	desc = "A concelated version of a stechkin APS pistol, that comes with special Preternis upgrade modules."
	can_suppress = TRUE
	fire_sound_volume = 30
	lefthand_file = null  ///We don't want it to be visible inhands
	righthand_file = null
	mag_type = /obj/item/ammo_box/magazine/m10mm/martial
	var/mob/gun_owner
	var/dying = FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
	ADD_TRAIT(src, TRAIT_NODROP, "martial")

/obj/item/gun/ballistic/automatic/pistol/martial/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/attack_self(mob/living/user)
	to_chat(user, span_notice("You decide that it isn't the best time to use [src]"))
	qdel(src)
	return

/obj/item/gun/ballistic/automatic/pistol/martial/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!dying)
		addtimer(CALLBACK(src, .proc/process_burst), 1 SECONDS)  ///I, kinda, don't very understand what gun code does, but it seems to be OK.
		dying = TRUE
	. = ..()

/obj/item/gun/ballistic/automatic/pistol/martial/proc/Die()
	to_chat(gun_owner, span_warning("You hide [src]."))	
	qdel(src)	

/obj/item/ammo_box/magazine/m10mm/martial
	max_ammo = 1

/mob/living/carbon/human/proc/preternis_martial_help()
	set name = "Refresh Data"
	set desc = "You try to remember some basic actions from your upgraded combat modules."
	set category = "Combat Modules"
	to_chat(usr, "<b><i>You try to remember some basic actions from your upgraded combat modules.</i></b>")

	to_chat(usr, "[span_notice("Hidden Blade")]: Harm Harm Grab. The second strike will deal 20 stamina and 5 brute damage, and finishing the combo will make you stab the victim with a hiden blade, dealing 30 brute damage.")
	to_chat(usr, "[span_notice("Injection")]: Disarm Harm Disarm. The second and third attack will stealthy inject respectively 5 units of cyanide and 8 unites of sodium thiopental.")
	to_chat(usr, "[span_notice("Finger gun")]: Harm Disarm Disarm. Finishing the combo will paralyze your target and place a stealthy version of a stechkin in your hand.")

#undef PRE_DAGGER_COMBO
#undef DAGGER_COMBO 
#undef PRE_INJECTION_COMBO 
#undef INJECTION_COMBO 
#undef FINGERGUN_COMBO 