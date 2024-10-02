#define LIVER_DEFAULT_TOX_LETHALITY 1 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Pairing suggestion: chianti and fava beans."
	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY // smack in the middle of decay times
	/// whether we can still have our damages fixed through surgery
	var/operated = FALSE	
	/// affects how much damage the liver takes from alcohol
	var/alcohol_tolerance = ALCOHOL_RATE
	/// modifier to toxpwr for liver and toxin damage taken
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY 
	/// cached list of the toxinpower of toxins
	var/list/cached_toxpower = list()
	/// whether or not the toxin process can provide a message
	var/provide_pain_message = FALSE

/obj/item/organ/liver/Insert(mob/living/carbon/M, special, drop_if_replaced, special_zone)
	. = ..()
	RegisterSignal(M, COMSIG_CARBON_UPDATE_TOXINS, PROC_REF(update_toxin_cache), override = TRUE)

/obj/item/organ/liver/Remove(mob/living/carbon/M, special)
	UnregisterSignal(M, COMSIG_CARBON_UPDATE_TOXINS)
	return ..()

/obj/item/organ/liver/proc/update_toxin_cache()
	var/mob/living/carbon/C = owner
	if(!istype(C))
		return

	provide_pain_message = FALSE
	cached_toxpower = list()

	for(var/datum/reagent/toxin/T in C.reagents.reagent_list)
		cached_toxpower += T.toxpwr
		provide_pain_message = provide_pain_message || !T.silent_toxin
			
	sort_list(cached_toxpower,  cmp = /proc/cmp_numeric_dsc) //sort all toxpowers scaling from highest to lowest

/obj/item/organ/liver/on_life()
	var/mob/living/carbon/C = owner
	..()	//perform general on_life()
	if(istype(C))
		if(organ_flags & ORGAN_FAILING)//for when our liver's failing
			C.reagents.end_metabolization(C, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
			C.reagents.metabolize(C, can_overdose=FALSE, liverless = TRUE)
			if(HAS_TRAIT(C, TRAIT_STABLELIVER))
				return
			C.adjustToxLoss(4, TRUE,  TRUE)
			if(prob(30))
				to_chat(C, span_warning("You feel a stabbing pain in your abdomen!"))
					
		else 
			if(length(cached_toxpower)) //deal with toxins
				var/damage_multiplier = 1 //reduced for every subsequent toxin
				
				for(var/dmg in cached_toxpower)
					var/real_damage = dmg * toxLethality * damage_multiplier
					damage_multiplier *= 0.5 //reduce the damage dealt for every subsequent toxin
					C.adjustToxLoss(real_damage)
					if(!HAS_TRAIT(owner, TRAIT_TOXINLOVER)) //don't hurt the liver if they like toxins
						damage += (real_damage / 2)

			//metabolize reagents
			C.reagents.metabolize(C, can_overdose=TRUE)

			if(provide_pain_message && damage > 10 && !HAS_TRAIT(owner, TRAIT_TOXINLOVER) && prob(damage/3))//the higher the damage the higher the probability
				to_chat(C, span_warning("You feel a dull pain in your abdomen."))

	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

/obj/item/organ/liver/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent(/datum/reagent/iron, 5)
	return S

/obj/item/organ/liver/get_availability(datum/species/species)
	return !(NOLIVER in species.species_traits)

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "liver-p"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/alien
	name = "alien liver" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "A liver that used to belong to a killer alien, who knows what it used to eat."
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 0.5

/obj/item/organ/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. Handles toxins slightly better than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 0.9

/obj/item/organ/liver/cybernetic/upgraded
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An upgraded version of the cybernetic liver, designed to handle extreme levels of toxins. It can even heal minor amounts of toxin damage."
	alcohol_tolerance = 0.0005
	maxHealth = 3 * STANDARD_ORGAN_THRESHOLD //300% health of a normal liver
	healing_factor = 2 * STANDARD_ORGAN_HEALING //Can regenerate from damage quicker
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 0.7

/obj/item/organ/liver/cybernetic/upgraded/on_life()
	. = ..()
	var/mob/living/carbon/C = owner
	if(!(organ_flags & ORGAN_FAILING)) //Passive Toxin damage healing
		C.adjustToxLoss(-0.5, TRUE, FALSE)

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	applyOrganDamage(5 * severity)

/obj/item/organ/liver/cybernetic/upgraded/ipc
	name = "substance processor"
	icon_state = "substance_processor"
	attack_verb = list("processed")
	desc = "A machine component, installed in the chest. This grants the machine the ability to process chemicals that enter its systems."
	alcohol_tolerance = 0
	toxLethality = 0
	status = ORGAN_ROBOTIC
	compatible_biotypes = ALL_BIOTYPES

/obj/item/organ/liver/cybernetic/upgraded/ipc/emp_act(severity)
	if(prob(10))
		return
	to_chat(owner, "<span class='warning'>Alert: Your Substance Processor has been damaged. An internal chemical leak is affecting performance.</span>")
	owner.adjustToxLoss(severity)
