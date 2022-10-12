/obj/item/organ/eyes/robotic/preternis
	name = "preternis eyes"
	desc = "An experimental upgraded version of eyes that can see in the dark. They are designed to fit preternis"
	see_in_dark = PRETERNIS_NV_ON
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	//preternis eyes need to be powered by a preternis to function, in a non preternis they slowly power down to blindness
	organ_flags = ORGAN_SYNTHETIC

	low_threshold_passed = span_info("Your Preternis eyes switch to battery saver mode.")
	high_threshold_passed = span_info("Your Preternis eyes only show a sliver of battery life left!")
	now_failing = span_warning("An empty battery icon is all you can see as your eyes shut off!")
	now_fixed = span_info("Lines of text scroll in your vision as your eyes begin rebooting.")
	high_threshold_cleared = span_info("Your Preternis eyes have recharged enough to re-enable most functionality.")
	low_threshold_cleared = span_info("Your Preternis eyes have almost fully recharged.")
	var/powered = TRUE 
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/robotic/preternis/ui_action_click()
	if(damage > low_threshold)
		//no nightvision if your eyes are hurt
		return
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

/obj/item/organ/eyes/robotic/preternis/on_life()
	. = ..()
	if(!owner)
		return
	if(ispreternis(owner) && !powered)
		powered = TRUE
		to_chat(owner, span_notice("A battery icon disappears from your vision as your [src] switch to external power."))
	if(!ispreternis(owner) && powered) //these eyes depend on being inside a preternis for power
		powered = FALSE
		to_chat(owner, span_boldwarning("Your [src] flash warnings that they've lost their power source, and are running on emergency power!"))
	if(powered)
		//when powered, they recharge by healing
		owner.adjustOrganLoss(ORGAN_SLOT_EYES,-0.5)
	else
		//to simulate running out of power, they take damage
		owner.adjustOrganLoss(ORGAN_SLOT_EYES,0.5)
	
	if(damage < low_threshold)
		if(see_in_dark == PRETERNIS_NV_OFF)
			see_in_dark = PRETERNIS_NV_ON
			owner.update_sight()
	else
		//if your eyes start getting hurt no more nightvision
		if(see_in_dark == PRETERNIS_NV_ON)
			see_in_dark = PRETERNIS_NV_OFF
			owner.update_sight()
		if(lighting_alpha < LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
			owner.update_sight()

/obj/item/organ/eyes/robotic/preternis/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC && (organ_flags & ORGAN_FAILING))
		. += span_warning("[src] appears to be completely out of charge. However, that's nothing popping them back in a Preternis wouldn't fix.")

	else if(organ_flags & ORGAN_FAILING)
		. += span_warning("[src] appears to be completely out of charge. If they were put back in a Preternis they would surely recharge in time.")

	else if(damage > high_threshold)
		. += span_warning("[src] seem to flicker on and off. They must be pretty low on charge without being in a Preternis")

/obj/item/organ/lungs/preternis
	name = "preternis lungs"
	desc = "An experimental set of lungs.Due to the cybernetic nature of these lungs,they are less resistant to heat and cold but are more efficent at filtering oxygen."
	icon_state = "lungs-c"
	safe_oxygen_min = 12
	safe_toxins_max = 10
	gas_stimulation_min = 0.1 //fucking filters removing my stimulants

	cold_level_1_threshold = 280
	cold_level_1_damage = 1.5
	cold_level_2_threshold = 260
	cold_level_2_damage = 3
	cold_level_3_threshold = 200
	cold_level_3_damage = 4.5

	heat_level_1_threshold = 320
	heat_level_2_threshold = 400
	heat_level_3_threshold = 600 //HALP MY LUNGS ARE ON FIRE
