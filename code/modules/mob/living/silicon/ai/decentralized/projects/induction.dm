/datum/ai_project/induction_basic
	name = "Bluespace Induction Basics"
	description = "This research functions as a prerequisite for other induction research such as remote borg charging and APC emergency power."
	research_cost = 1500
	ram_required = 0
	research_requirements_text = "None"
	can_be_run = FALSE
	category = AI_PROJECT_INDUCTION

/datum/ai_project/induction_cyborg
	name = "Bluespace Induction - Cyborgs"
	description = "This ability will allow you to charge any visible cyborgs by 33%"
	research_cost = 2500
	ram_required = 0
	research_requirements_text = "Bluespace Induction Basics"
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION
	
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_cyborg/finish()
	var/datum/action/innate/ai/ranged/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/charge_borg_or_apc)
	if(ability)
		ability.works_on_borgs = TRUE
		ability.name = "Charge cyborg"
		ability.desc = "Click a cyborg to charge it by 33%"
	else
		ability = locate(/datum/action/innate/ai/ranged/charge_borg_or_apc) in ai.actions
		ability.works_on_borgs = TRUE
		ability.name = "Charge cyborg/APC"
		ability.desc = "Click a cyborg or APC to charge it by 33%"


/datum/ai_project/induction_apc
	name = "Bluespace Induction - APCs"
	description = "This ability will allow you to charge any visible APCs by 33%"
	research_cost = 2500
	ram_required = 0
	research_requirements_text = "Bluespace Induction Basics"
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION
	
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_apc/finish()
	var/datum/action/innate/ai/ranged/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/charge_borg_or_apc)
	if(ability)
		ability.name = "Charge APC"
		ability.desc = "Click an APC to charge it by 33%"
	else
		ability = locate(/datum/action/innate/ai/ranged/charge_borg_or_apc) in ai.actions
		ability.name = "Charge cyborg/APC"
		ability.desc = "Click a cyborg or APC to charge it by 33%"
	ability.works_on_apcs = TRUE


/datum/action/innate/ai/ranged/charge_borg_or_apc
	name = "Charge cyborg/APC"
	desc = "Depending on upgrades you can charge either a single cyborg or APC in view by 33%"
	button_icon_state = "electrified"
	uses = 1
	delete_on_empty = FALSE
	var/works_on_borgs = FALSE
	var/works_on_apcs = FALSE
	enable_text = span_notice("You prepare bluespace induction coils. Click a borg or APC to charge its cell by 33%")
	disable_text = span_notice("You power down your induction coils.")
	
/datum/action/innate/ai/ranged/charge_borg_or_apc/do_ability(mob/living/caller, params, atom/clicked_on)
	if(!iscyborg(clicked_on) && !istype(clicked_on, /obj/machinery/power/apc))
		to_chat(owner, span_warning("You can only charge cyborgs or APCs!"))
		return FALSE
	if(!works_on_borgs && iscyborg(clicked_on))
		to_chat(owner, span_warning("You can only charge APCs!"))
		return FALSE
	if(!works_on_apcs && istype(clicked_on, /obj/machinery/power/apc))
		to_chat(owner, span_warning("You can only charge cyborgs!"))
		return FALSE

	owner.playsound_local(owner, "sparks", 50, 0)

	if(charge_borg_or_apc(clicked_on))
		adjust_uses(-1)
		do_sparks(3, FALSE,clicked_on)
		to_chat(owner, span_notice("You charge [clicked_on]."))
		clicked_on.audible_message(span_userdanger("You hear a soothing electrical buzzing sound coming from [clicked_on]!"))
	return TRUE

/datum/action/innate/ai/ranged/charge_borg_or_apc/proc/charge_borg_or_apc(atom/target)
	if(target && !QDELETED(target))
		if(iscyborg(target))
			var/mob/living/silicon/robot/R = target
			log_game("[key_name(usr)] charged [R.name].")
			if(R.cell)
				if(R.cell.charge >= R.cell.maxcharge)
					to_chat(owner, span_warning("[R]'s power cell is already full!"))
					return FALSE 
				R.charge(null, R.cell.maxcharge * 0.33)
				return TRUE
			else
				to_chat(owner, span_warning("[R] has no powercell to charge!"))
		else if(istype(target, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/APC = target
			var/turf/T = get_turf(APC)
			log_game("[key_name(usr)] charged [APC.name] at [AREACOORD(T)].")
			if(APC.cell)
				if(APC.cell.charge >= APC.cell.maxcharge)
					to_chat(owner, span_warning("The APC is already fully charged!"))
					return FALSE
				APC.cell.give(APC.cell.maxcharge * 0.33)
				return TRUE
			else
				to_chat(owner, span_warning("The APC has no powercell to charge!"))
