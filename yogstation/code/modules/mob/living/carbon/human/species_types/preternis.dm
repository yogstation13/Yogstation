/*
-weak to EMPS //done
-emag level 1 = brain dmg //done
-emag level 2 = flashing colors //done
-125% brute dmg //done
-150% shock dmg //done
-cold and heat sensible //dpme

-fully augmented
-implant insertion
-night vision if not hungry
-rad immunity
-virus resistant
-all virus are airborne
-feeds on power,gloves decresse and insulated prevent
-purge chem after 40 seconds
-oil heals burn at 2 per cycle
-welding fuel at 1 per cycle
-teslium = meth but gives 200% dmg to shock
-special robot language

*/

/datum/species/preternis
	name = "Preternis"
	id = "preternis"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	say_mod = "intones"
	attack_verb = "assaults"
	meat = null
	toxic_food = NONE
	brutemod = 1.25
	burnmod = 1.15
	var/eating_msg_cooldown = FALSE
	var/emag_lvl = 0

/datum/species/preternis/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if (istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/food = chem
		if (food.nutriment_factor)
			food.nutriment_factor *= 0.2
			if (!eating_msg_cooldown)
				eating_msg_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, eating_msg_cooldown, FALSE), 5 MINUTES)
				to_chat(H,"<span class='info'>NOTICE: Digestive subroutines are inefficient. Seek sustenance via power-cell C.O.N.S.U.M.E. technology induction.</span>")
	return TRUE

/datum/species/preternis/spec_emp_act(mob/living/carbon/human/H, severity)
	. = ..()
	switch(severity)
		if(EMP_HEAVY)
			H.adjustBruteLoss(20)
			H.adjustFireLoss(20)
			H.Stun(5)
			H.nutrition *= 0.4
			H.visible_message("<span class='danger'>Electricity ripples over [H]'s subdermal implants, smoking profusely.</span>", \
							"<span class='userdanger'>A surge of searing pain erupts throughout your very being! As the pain subsides, a terrible sensation of emptiness is left in its wake.</span>")
		if(EMP_LIGHT)
			H.adjustBruteLoss(10)
			H.adjustFireLoss(10)
			H.Stun(2)
			H.nutrition *= 0.6
			H.visible_message("<span class='danger'>A faint fizzling emanates from [H].</span>", \
							"<span class='userdanger'>A fit of twitching overtakes you as your subdermal implants convulse violently from the electromagnetic disruption. Your sustenance reserves have been partially depleted from the blast.</span>")

/datum/species/preternis/spec_emag_act(mob/living/carbon/human/H, mob/user)
	. = ..()
	emag_lvl = MIN(emag_lvl++,2)
	switch(emag_lvl)
		if(1)
			H.adjustBrainLoss(50) //HALP AM DUMB
			to_chat(H,"<span class='danger'>ALERT! MEMORY UNIT [rand(1,5)] FAILURE.NERVEOUS SYSTEM DAMAGE.")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
		if(2)
			H.overlay_fullscreen("preternis_emag", /obj/screen/fullscreen/high)
			H.throw_alert("preternis_emag". /obj/screen/alert/high/preternis )

/obj/screen/alert/high/preternis //i dont want to make a file for 4 lines
	name = "Optic sensor failure"
	desc = "Main unit optic sensors damage detected.Vision processor compromised"
	icon_state = "high"

/obj/item/organ/eyes/preternis
	name = "preternis eyes"
	desc = "An experimental upgraded version of eyes that can see in the dark.They are designed to fit preternis"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/preternis/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/eyes/preternis/on_life()
	. = ..()
	if(owner.nutrition >= NUTRITION_LEVEL_ALMOST_FULL && see_in_dark == 2)
		see_in_dark = 8
	else if(see_in_dark == 8)
		see_in_dark = 2

/obj/item/organ/lungs/preternis
	name = "preternis lungs"
	desc = "An experimental set of lungs.Due to the cybernetic nature of these lungs,they are less resistant to heat and cold but are more efficent at filtering oxygen."
	icon_state = "lungs-c"
	safe_oxygen_min = 12
	safe_toxins_max = 0.15
	gas_stimulation_min = 0.1 //fucking filters removing my stimulants

	cold_level_1_threshold = 280
	cold_level_2_threshold = 260
	cold_level_3_threshold = 200

	heat_level_1_threshold = 320
	heat_level_2_threshold = 400
	heat_level_3_threshold = 600 //HALP MY LUNGS ARE ON FIRE

