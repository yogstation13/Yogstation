#define NUTRI_STASH_MAX 8 //8 nutriment = 300 nutrition

/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb = list("gored", "squished", "slapped", "digested")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 1.15 // ~13 minutes, the stomach is one of the first organs to die

	low_threshold_passed = span_info("Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.")
	high_threshold_passed = span_warning("Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!")
	high_threshold_cleared = span_info("The pain in your stomach dies down for now, but food still seems unappealing.")
	low_threshold_cleared = span_info("The last bouts of pain in your stomach have died out.")

	var/disgust_metabolism = 1

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/human/H = owner
	var/datum/reagent/Nutri

	..()
	if(istype(H))
		if(!(organ_flags & ORGAN_FAILING))
			H.dna.species.handle_digestion(H)
		handle_disgust(H)

	if(damage < low_threshold)
		return

	Nutri = locate(/datum/reagent/consumable/nutriment) in H.reagents.reagent_list

	if(Nutri)
		if(prob((damage/40) * Nutri.volume * Nutri.volume))
			H.vomit(damage)
			to_chat(H, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))

	else if(Nutri && damage > high_threshold)
		if(prob((damage/10) * Nutri.volume * Nutri.volume))
			H.vomit(damage)
			to_chat(H, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H)
	if(H.disgust)
		var/pukeprob = 5 + 0.05 * H.disgust
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(prob(10))
				H.adjust_stutter(1 SECONDS)
				H.adjust_confusion(2 SECONDS)
			if(prob(10) && !H.stat)
				to_chat(H, span_warning("You feel kind of iffy..."))
			H.adjust_jitter(-6 SECONDS)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(prob(pukeprob)) //iT hAndLeS mOrE ThaN PukInG
				H.adjust_confusion(2.5 SECONDS)
				H.adjust_stutter(1 SECONDS)
				H.vomit(10, 0, 1, 0, 1, 0)
			H.adjust_dizzy(5 SECONDS)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(prob(25))
				H.adjust_eye_blur(3) //We need to add more shit down here

		H.adjust_disgust(-0.5 * disgust_metabolism)
	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /atom/movable/screen/alert/gross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /atom/movable/screen/alert/verygross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /atom/movable/screen/alert/disgusted)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
	..()

/obj/item/organ/stomach/get_availability(datum/species/species)
	return !(NOSTOMACH in species.species_traits)

/obj/item/organ/stomach/cybernetic
	name = "cybernetic stomach"
	desc = "A cybernetic metabolic furnace that can be connected to a digestive system in place of a stomach."
	icon_state = "stomach-c"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	disgust_metabolism = 1.5	//Slightly more efficient at stabilizing itself

/obj/item/organ/stomach/cybernetic/upgraded
	name = "upgraded cybernetic stomach"
	desc = "An upgraded metabolic furnace that can be connected to a digestive system in place of a stomach. Both hardier and capable of storing excess nutrition if the body is already well sustained."
	icon_state = "stomach-c-u"
	maxHealth = 3 * STANDARD_ORGAN_THRESHOLD
	var/nutriment_stashed = 0
	disgust_metabolism = 2		//Twice as efficient as stabilizing itself

/obj/item/organ/stomach/cybernetic/upgraded/on_life()
	if(owner.nutrition >= NUTRITION_LEVEL_FULL && nutriment_stashed < NUTRI_STASH_MAX)
		var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in owner.reagents.reagent_list
		if(nutri)
			var/amt_stored = min(nutri.volume, NUTRI_STASH_MAX - nutriment_stashed)
			nutriment_stashed += amt_stored
			owner.reagents.remove_reagent(/datum/reagent/consumable/nutriment, amt_stored)
	..()
	if(owner.nutrition <= NUTRITION_LEVEL_HUNGRY && nutriment_stashed)
		owner.reagents.add_reagent(/datum/reagent/consumable/nutriment, nutriment_stashed)
		nutriment_stashed = 0
		to_chat(owner, span_notice("You feel less hungry..."))

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "stomach-p"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."

/obj/item/organ/stomach/cell
	name = "micro-cell"
	icon_state = "microcell"
	zone = "chest"
	slot = "stomach"
	attack_verb = list("assault and battery'd")
	desc = "A micro-cell, for IPC use only. Do not swallow."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	compatible_biotypes = MOB_ROBOTIC
	var/stored_charge = NUTRITION_LEVEL_WELL_FED
	var/emp_message = span_warning("Alert: EMP Detected. Cycling battery.")

/obj/item/organ/stomach/cell/emp_act(severity)
	to_chat(owner, emp_message)
	charge(amount = owner.nutrition * -0.02 * severity)

/obj/item/organ/stomach/cell/Insert(mob/living/carbon/stomach_owner, special, drop_if_replaced)
	. = ..()
	if(HAS_TRAIT(stomach_owner, TRAIT_POWERHUNGRY))
		stomach_owner.nutrition = stored_charge
	RegisterSignal(stomach_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge), override = TRUE)

/obj/item/organ/stomach/cell/Remove(mob/living/carbon/stomach_owner, special)
	. = ..()
	if(HAS_TRAIT(stomach_owner, TRAIT_POWERHUNGRY))
		stored_charge = stomach_owner.nutrition
		stomach_owner.nutrition = 0
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	stomach_owner.dna?.species.handle_digestion(stomach_owner) // update nutrition stuff

/obj/item/organ/stomach/cell/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		return // do nothing in the owner doesn't run on electricity
	owner.adjust_nutrition(amount/100) // ipcs can't get fat anymore

/obj/item/organ/stomach/cell/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	status = ORGAN_ORGANIC
	organ_flags = NONE
	compatible_biotypes = ALL_NON_ROBOTIC

/obj/item/organ/stomach/cell/ethereal/Insert(mob/living/carbon/stomach_owner, special = 0)
	. = ..()
	RegisterSignal(stomach_owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/organ/stomach/cell/ethereal/Remove(mob/living/carbon/stomach_owner, special = 0)
	UnregisterSignal(stomach_owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	return ..()

/obj/item/organ/stomach/cell/ethereal/proc/on_electrocute(mob/living/victim, shock_damage, obj/source, siemens_coeff = 1, zone = null, tesla_shock = 0, illusion = 0)
	SIGNAL_HANDLER
	if(illusion)
		return
	if(!HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		return
	owner.adjust_nutrition(shock_damage * siemens_coeff)
	to_chat(owner, span_notice("You absorb some of the shock into your body!"))

/obj/item/organ/stomach/cell/ethereal/emp_act(severity)
	return // it's organic

/obj/item/organ/stomach/cursed
	name = "cursed stomach"
	icon_state = "stomach-cursed"
	desc = "A stomach that used be a source of power of something incredibly vile. It seems to be beating."
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/stomach/cursed/ui_action_click() //Stomach that allows you to vomit at will, oh the humanity!
	if(HAS_TRAIT(owner, TRAIT_NOHUNGER) || HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		to_chat(owner, span_notice("You don't eat food, you can't vomit!"))
		return
	if(owner.IsParalyzed())
		to_chat(owner, span_notice("You can't bring yourself to vomit while stunned!"))
		return
	if(istype(owner.loc, /obj/effect/dummy/crawling))
		to_chat(owner, span_notice("You can't vomit while in vomitform!")) //no vomitghosts allowed
		return
	to_chat(owner, span_notice("You force yourself to vomit."))
	owner.vomit(10, FALSE, TRUE, rand(0,4))  //BLEEEUUUGHHHH!!

/obj/item/organ/stomach/cursed/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth with disgust and tears into it with [user.p_their()] teeth!?"), \
						 span_danger("An unnatural hunger consumes you. You raise [src] your mouth and unwillingly devour it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 35, 1)
	if(user.GetComponent(/datum/component/crawl/vomit))
		to_chat(user, span_warning("...and you don't feel any different."))
		qdel(src)
		return
	user.visible_message(span_warning("[user] looks extremely sick!"), \
						 span_userdanger("You feel extremely weird... you have absorbed the demonic vomit-travelling powers?"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Are you gonna seriously gonna eat THAT?

/obj/item/organ/stomach/cursed/Insert(mob/living/carbon/M, special = 0)
	..()
	M.AddComponent(/datum/component/crawl/vomit)

/obj/item/organ/stomach/cursed/Remove(mob/living/carbon/M, special = 0)
	..()
	var/datum/component/crawl/vomit/B = M.GetComponent(/datum/component/crawl/vomit)
	if(B)
		qdel(B)
