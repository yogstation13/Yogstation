#define SURGERY_FUCKUP_CHANCE 50

/datum/surgery_step
	var/name
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = FALSE				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = FALSE			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/time = 10					//how long does the step take?
	var/repeatable = FALSE				//can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop
	var/list/chems_needed = list()  //list of chems needed to complete the step. Even on success, the step will have no effect if there aren't the chems required in the mob.
	var/require_all_chems = TRUE    //any on the list or all on the list?
	var/list/ouchie_modifying_chems = list(/datum/reagent/consumable/ethanol/painkiller = 0.5, /datum/reagent/medicine/morphine = 0.5) //chems that will modify the chance for fuckups while operating on conscious patients, stacks.
	var/fuckup_damage = 10			//base damage dealt on a surgery being done without anesthetics on SURGERY_FUCKUP_CHANCE percent chance
	var/fuckup_damage_type = BRUTE	//damage type fuckup_damage is dealt as

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
		if(iscyborg(user))
			success = TRUE

// yogs start - tool switcher
	if(istype(tool, /obj/item/storage/belt/tool_switcher))
		var/obj/item/storage/belt/tool_switcher/S = tool
		tool = S.find_current_tool()
		if(!tool)
			tool = S
// yogs end

	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = TRUE

	else if(tool)
		for(var/key in implements)
			var/match = FALSE

			if(ispath(key) && istype(tool, key))
				match = TRUE
			else if(tool.tool_behaviour == key)
				match = TRUE

			if(match)
				implement_type = key
				if(tool_check(user, tool))
					success = TRUE
					break

	if(success)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone) || surgery.ignore_clothes)
				initiate(user, target, target_zone, tool, surgery, try_to_fail)
			else
				to_chat(user, "<span class='warning'>You need to expose [target]'s [parse_zone(target_zone)] to perform surgery on it!</span>")
			return TRUE	//returns TRUE so we don't stab the guy in the dick or wherever.

	if(repeatable)
		var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
		if(next_step)
			surgery.status++
			if(next_step.try_op(user, target, user.zone_selected, user.get_active_held_item(), surgery))
				return TRUE
			else
				surgery.status--
	return FALSE


/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	surgery.step_in_progress = TRUE
	var/advance = FALSE

	var/tool_speed_mod = 1
	var/user_speed_mod = 1

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = 0
		return

	if(tool)
		tool_speed_mod = tool.toolspeed

	if(IS_MEDICAL(user))
		user_speed_mod = 0.8

	if(do_after(user, time * tool_speed_mod * user_speed_mod, target = target))
		var/prob_chance = 100

		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		prob_chance *= surgery.get_probability_multiplier()

		if((prob(prob_chance) || iscyborg(user)) && chem_check(target, user,
	 tool) && !try_to_fail)
			if(success(user, target, target_zone, tool, surgery))
				advance = TRUE
		else
			if(failure(user, target, target_zone, tool, surgery))
				advance = TRUE
		if(!HAS_TRAIT(target, TRAIT_SURGERY_PREPARED) && target.stat != DEAD && !IS_IN_STASIS(target) && fuckup_damage) //not under the effects of anaesthetics or a strong painkiller, harsh penalty to success chance
			if(!issilicon(user) && !HAS_TRAIT(user, TRAIT_SURGEON)) //borgs and abductors are immune to this
				var/obj/item/bodypart/operated_bodypart = target.get_bodypart(target_zone)
				if(!operated_bodypart || operated_bodypart?.status == BODYPART_ORGANIC) //robot limbs don't feel pain
					cause_ouchie(user, target, target_zone, tool, advance)
		if(advance && !repeatable)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete()

	surgery.step_in_progress = FALSE
	return advance


/datum/surgery_step/proc/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform surgery on [target]...</span>",
		"[user] begins to perform surgery on [target].",
		"[user] begins to perform surgery on [target].")

/datum/surgery_step/proc/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed.</span>",
		"[user] succeeds!",
		"[user] finishes.")
	return TRUE

/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screw up!</span>",
		"<span class='warning'>[user] screws up!</span>",
		"[user] finishes.", TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/datum/surgery_step/proc/chem_check(mob/living/carbon/target, user,  obj/item/tool)
	if(!LAZYLEN(chems_needed))
		return TRUE
	var/obj/item/reagent_containers/syringe/S
	if(target.can_inject(user, FALSE))
		S = tool
	if(require_all_chems)
		. = TRUE
		for(var/R in chems_needed)
			if(!target.reagents.has_reagent(R))
				if(!(S && S.reagents.has_reagent(R)))
					return FALSE
				S.reagents.remove_reagent(R, min(S.amount_per_transfer_from_this, S.reagents.get_reagent_amount(R)))
	else
		. = FALSE
		for(var/R in chems_needed)
			if(target.reagents.has_reagent(R))
				return TRUE
			if(S && S.reagents.has_reagent(R))
				S.reagents.remove_reagent(R, min(S.amount_per_transfer_from_this, S.reagents.get_reagent_amount(R)))
				return TRUE

/datum/surgery_step/proc/get_chem_list()
	if(!LAZYLEN(chems_needed))
		return
	var/list/chems = list()
	for(var/R in chems_needed)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[R]
		if(temp)
			var/chemname = temp.name
			chems += chemname
	return english_list(chems, and_text = require_all_chems ? " and " : " or ")

//Replaces visible_message during operations so only people looking over the surgeon can tell what they're doing, allowing for shenanigans.
/datum/surgery_step/proc/display_results(mob/user, mob/living/carbon/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	var/list/detailed_mobs = get_hearers_in_view(1, user) //Only the surgeon and people looking over his shoulder can see the operation clearly
	if(!target_detailed)
		detailed_mobs -= target //The patient can't see well what's going on, unless it's something like getting cut
	user.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)
	user.visible_message(vague_message, "", ignored_mobs = detailed_mobs)

/datum/surgery_step/proc/cause_ouchie(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, success)
	var/ouchie_mod = 1
	for(var/datum/reagent/R in ouchie_modifying_chems)
		if(target.reagents?.has_reagent(R))
			ouchie_mod *= ouchie_modifying_chems[R]
	if(target.stat == UNCONSCIOUS)
		ouchie_mod *= 0.8
	ouchie_mod *= clamp(1-target.drunkenness/100, 0, 1)
	if(!success)
		ouchie_mod *= 2
	var/final_ouchie_chance = SURGERY_FUCKUP_CHANCE * ouchie_mod
	if(!prob(final_ouchie_chance))
		return
	user.visible_message("<span class='boldwarning'>[target] flinches, bumping [user]'s [tool ? tool.name : "hand"] into something important!</span>", "<span class='boldwarning'>[target]  flinches, bumping your [tool ? tool.name : "hand"] into something important!</span>")
	target.apply_damage(fuckup_damage, fuckup_damage_type, target_zone)
	if(ishuman(target) &&fuckup_damage_type == BRUTE && prob(final_ouchie_chance/2))
		var/mob/living/carbon/human/H = target
		H.bleed_rate += min(fuckup_damage/4, 10)
