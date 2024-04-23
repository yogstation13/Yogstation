/obj/item/organ/eyes/robotic/preternis
	name = "preternis eyes"
	desc = "A form archaic robotic eyes that can see in the dark. "
	//preternis eyes need to be powered by a preternis to function, in a non preternis they slowly power down to blindness
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	compatible_biotypes = ALL_BIOTYPES

	low_threshold_passed = span_info("Your Preternis eyes switch to battery saver mode.")
	high_threshold_passed = span_info("Your Preternis eyes only show a sliver of battery life left!")
	now_failing = span_warning("An empty battery icon is all you can see as your eyes shut off!")
	now_fixed = span_info("Lines of text scroll in your vision as your eyes begin rebooting.")
	high_threshold_cleared = span_info("Your Preternis eyes have recharged enough to re-enable most functionality.")
	low_threshold_cleared = span_info("Your Preternis eyes have almost fully recharged.")
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/original_eye_color
	var/powered = TRUE 
	var/night_vision = FALSE
	// This list is used as the color cutoff for the night vision
	var/list/colour_cutoff_list = list(12, 0, 50)
	// This variable is the actual night vision strength
	var/light_cutoff = LIGHTING_CUTOFF_HIGH

/obj/item/organ/eyes/robotic/preternis/Insert(mob/living/carbon/M, special, drop_if_replaced, initialising)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		original_eye_color = H.eye_color
	
/obj/item/organ/eyes/robotic/preternis/Remove(mob/living/carbon/M, special)
	nv_off()
	. = ..()

/obj/item/organ/eyes/robotic/preternis/ui_action_click()
	if(damage > low_threshold || (powered && owner.nutrition <= NUTRITION_LEVEL_HUNGRY))
		to_chat(owner, span_warning("Your [src] flash warnings that they've disabled night vision to save power!"))
		//no nightvision if your eyes are low on power, whether internal or external
		return
	if (night_vision)
		nv_off()
	else
		nv_on()

/obj/item/organ/eyes/robotic/preternis/proc/nv_on()
	night_vision = TRUE
	color_cutoffs = colour_cutoff_list.Copy()
	lighting_cutoff = light_cutoff
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		original_eye_color = H.eye_color
		H.eye_color = "#8b60ff"
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		H.update_body()
	owner.update_sight()

/obj/item/organ/eyes/robotic/preternis/proc/nv_off()
	night_vision = FALSE
	color_cutoffs = null
	lighting_cutoff = null
	if(ishuman(owner) && original_eye_color)
		var/mob/living/carbon/human/H = owner
		H.eye_color = original_eye_color
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		H.update_body()
	owner.update_sight()

/obj/item/organ/eyes/robotic/preternis/on_life()
	. = ..()
	if(!owner)
		return
	if((HAS_TRAIT(owner, TRAIT_POWERHUNGRY) || (owner.mob_biotypes & MOB_ROBOTIC)) && !powered)
		powered = TRUE
		to_chat(owner, span_notice("A battery icon disappears from your vision as your [src] switch to external power."))
	if(!(HAS_TRAIT(owner, TRAIT_POWERHUNGRY) || (owner.mob_biotypes & MOB_ROBOTIC)) && powered) //these eyes depend on being inside a preternis for power
		powered = FALSE
		to_chat(owner, span_boldwarning("Your [src] flash warnings that they've lost their power source, and are running on emergency power!"))
	if(powered)
		//when powered, they recharge by healing
		owner.adjustOrganLoss(ORGAN_SLOT_EYES,-0.5)
		if(night_vision)
			owner.adjust_nutrition(-1) //consumes power to stay charged
			if(owner.nutrition <= NUTRITION_LEVEL_HUNGRY)
				to_chat(owner, span_boldwarning("Your [src] flash warnings that they've disabled night vision to save power!"))
				nv_off() //if low on power, turn off
	else if(night_vision)
		owner.adjustOrganLoss(ORGAN_SLOT_EYES,0.5) //to simulate running out of power, they take damage
		if(damage > low_threshold)
			to_chat(owner, span_boldwarning("Your [src] flash warnings that they've disabled night vision to save power!"))
			nv_off() //if low on power, turn off
	
/obj/item/organ/eyes/robotic/preternis/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC && (organ_flags & ORGAN_FAILING))
		. += span_warning("[src] appears to be completely out of charge. However, that's nothing popping them back in a Preternis wouldn't fix.")

	else if(organ_flags & ORGAN_FAILING)
		. += span_warning("[src] appears to be completely out of charge. If they were put back in a Preternis they would surely recharge in time.")

	else if(damage > high_threshold)
		. += span_warning("[src] seem to flicker on and off. They must be pretty low on charge without being in a Preternis")


///////////////////////////////////////////////////////////
//----------------------Preternis Lungs------------------//
///////////////////////////////////////////////////////////
/obj/item/organ/lungs/preternis
	name = "preternis lungs"
	desc = "A specialized set of lungs. Due to the cybernetic nature of these lungs, they are far less resistant to cold but are more heat resistant and more efficent at filtering oxygen."
	icon_state = "lungs-c"

	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	safe_breath_min = 12

	gas_max = list(
		GAS_CO2 = 30, 
		GAS_PLASMA = 10
	)

	gas_stimulation_min = 0.01 //fucking filters removing my stimulants

	cold_level_1_threshold = 280 //almost room temperature
	cold_level_1_damage = 2
	cold_level_2_threshold = 260
	cold_level_2_damage = 4
	cold_level_3_threshold = 220
	cold_level_3_damage = 6

	heat_level_1_threshold = 500
	heat_level_1_damage = 4
	heat_level_2_threshold = 1000
	heat_level_2_damage = 7
	heat_level_3_threshold = 35000 //are you on the fucking surface of the sun or something?
	heat_level_3_damage = 25 //you should already be dead
	
///////////////////////////////////////////////////////////
//---------------------Preternis Stomach-----------------//
///////////////////////////////////////////////////////////
/obj/item/organ/stomach/cell/preternis
	name = "preternis cell-stomach"
	desc = "Calling it a stomach is perhaps a bit generous. It's better at grinding rocks than dissolving food. Also works as a power cell."
	icon_state = "stomach-c"
	compatible_biotypes = ALL_BIOTYPES // also works as a stomach, so organics can use it too

/obj/item/organ/stomach/cell/preternis/on_life()
	. = ..()
	var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in owner.reagents.reagent_list
	if(nutri)
		owner.reagents.remove_reagent(/datum/reagent/consumable/nutriment, 1) //worse for actually eating (not that it matters for preterni)

/obj/item/organ/stomach/cell/preternis/emp_act(severity)
	owner.vomit(stun=FALSE) // fuck that
	owner.adjust_disgust(2*severity)
	to_chat(owner, "<span class='warning'>You feel violently ill as the EMP causes your stomach to kick into high gear.</span>")
