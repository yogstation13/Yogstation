///hidden dagger
#define DAGGER_COMBO "HH"
///fingergun
#define FINGERGUN_COMBO "HG"

/datum/martial_art/liquidator
	name = "Liquidator"
	id =  MARTIALART_LIQUIDATOR
	help_verb = /mob/living/carbon/human/proc/preternis_martial_help
	/// List of chemicals and how much is injected, will inject in descending order based on if a target has at least half the designated amount
	var/list/injection_chems = list(
		/datum/reagent/toxin/sodium_thiopental = 10,
		/datum/reagent/toxin/cyanide = 5
	)
	/// Chem injected if no other chem is valid
	var/datum/reagent/default_chem = /datum/reagent/toxin/cyanide

/datum/martial_art/liquidator/can_use(mob/living/carbon/human/H)
	if(!H.combat_mode)
		return FALSE
	if(!ispreternis(H))
		return FALSE
	return TRUE

/datum/martial_art/liquidator/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D)
		return FALSE

	add_to_streak("G",D)
	if(check_streak(A,D)) //if a combo is made no grab upgrade is done (QoL rather than stealth)
		return TRUE
	return FALSE

/datum/martial_art/liquidator/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE

	add_to_streak("H",D)
	check_streak(A,D)
	return FALSE  ///We need it work like a generic, non martial art attack at all times


/datum/martial_art/liquidator/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE

	injection(A, D)
	return FALSE //always looks like a generic push

/datum/martial_art/liquidator/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, DAGGER_COMBO))
		hidden_knife(A,D)
		streak = ""
		return FALSE
		
	if(findtext(streak, FINGERGUN_COMBO))
		fingergun(A,D)
		streak = ""
		return FALSE

/datum/martial_art/liquidator/proc/hidden_knife(mob/living/carbon/human/A, mob/living/carbon/human/D)	if(findtext(streak, DAGGER_COMBO))
	var/selected_zone = A.zone_selected
	var/armor_block = D.run_armor_check(selected_zone, MELEE, armour_penetration = 40)
	D.apply_damage(A.get_punchdamagehigh() * 4, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 	//28 damage
	to_chat(A, span_warning("You stab [D] with a hidden blade!"))
	to_chat(D, span_userdanger("You are suddenly stabbed with a blade!"))
	A.playsound_local(src, 'sound/weapons/batonextend.ogg', 15, TRUE) //sound only to you as audio feedback that you stabbed them
	A.playsound_local(src, 'sound/weapons/bladeslice.ogg', 15, TRUE)

/datum/martial_art/liquidator/proc/injection(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/datum/reagent/picked_chem = default_chem
	var/amount = injection_chems[picked_chem]

	for(var/i in injection_chems)
		var/has_reagent = D.reagents.get_reagent_amount(i)
		if(has_reagent <= (injection_chems[i]/2))
			picked_chem = i
			amount = injection_chems[i]
			break

	D.reagents.add_reagent(picked_chem, amount)
	to_chat(A, span_warning("You inject [initial(picked_chem.name)] into [D]!"))
	to_chat(D, span_notice("You feel a tiny prick."))

/*---------------------------------------------------------------

	start of fingergun section

---------------------------------------------------------------*/
/datum/martial_art/liquidator/proc/fingergun(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/gun/ballistic/automatic/pistol/martial/gun = new /obj/item/gun/ballistic/automatic/pistol/martial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	A.playsound_local(A, 'sound/items/change_jaws.ogg', 10, TRUE) //sound only to you as audio feedback that you pulled out a gun
	to_chat(A, span_notice("You extract a hidden gun from your hand."))	
	D.Paralyze(1 SECONDS)

/obj/item/gun/ballistic/automatic/pistol/martial
	desc = "A concelated version of a stechkin APS pistol, that comes with special Preternis upgrade modules."
	can_suppress = TRUE
	fire_sound_volume = 30
	lefthand_file = null  ///We don't want it to be visible inhands
	righthand_file = null
	mag_type = /obj/item/ammo_box/magazine/m10mm/martial
	var/mob/gun_owner

/obj/item/ammo_box/magazine/m10mm/martial
	max_ammo = 1

/obj/item/gun/ballistic/automatic/pistol/martial/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
	ADD_TRAIT(src, TRAIT_NODROP, "martial")
	RegisterSignal(src, COMSIG_ITEM_PREDROPPED, PROC_REF(on_drop))

/obj/item/gun/ballistic/automatic/pistol/martial/attack_self(mob/living/user)
	on_drop()

/obj/item/gun/ballistic/automatic/pistol/martial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	if(!magazine.ammo_count(FALSE))//if it's out of ammo delete it
		to_chat(gun_owner, span_warning("You hide [src]."))	
		qdel(src)	

/obj/item/gun/ballistic/automatic/pistol/martial/proc/on_drop()
	to_chat(gun_owner, span_notice("You decide that it isn't the best time to use [src]"))
	qdel(src)

/*---------------------------------------------------------------

	end of fingergun section

---------------------------------------------------------------*/
/mob/living/carbon/human/proc/preternis_martial_help()
	set name = "Refresh Data"
	set desc = "You try to remember some basic actions from your covert combat module."
	set category = "Remnant Liquidator"
	var/list/combined_msg = list()

	var/datum/martial_art/liquidator/helper = new()

	combined_msg += "<b><i>You try to remember some basic actions from your covert combat module.</i></b>"

	combined_msg += "[span_notice("Hidden Blade")]: Harm Harm. You stab the target with a hidden blade, dealing considerable brute damage."
	combined_msg += "[span_notice("Finger gun")]: Harm Grab. Briefly paralyse your target and place a stealthy version of a stechkin in your hand."

	combined_msg += "[span_notice("Injection")]: Your disarm intent will inject chemicals in a determined order."
	combined_msg += span_notice("The chemicals that will be injected in this order are:")
	for(var/datum/reagent/chemical as anything in helper.injection_chems)
		combined_msg += span_notice("[helper.injection_chems[chemical]]u of [initial(chemical.name)]. But only if there is less than [helper.injection_chems[chemical]/2]u in the target already.")
	combined_msg += span_notice("If none of the above chemicals are injected, you will default to [helper.injection_chems[helper.default_chem]]u of [initial(helper.default_chem.name)].")

	qdel(helper)

#undef PRE_DAGGER_COMBO
#undef DAGGER_COMBO 
#undef PRE_INJECTION_COMBO 
#undef INJECTION_COMBO 
#undef FINGERGUN_COMBO 
