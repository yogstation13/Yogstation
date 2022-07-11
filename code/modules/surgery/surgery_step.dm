#define SURGERY_FUCKUP_CHANCE 50

/datum/surgery_step
	var/name
	/// What tools can be used in this surgery, format is path = probability of success.
	var/list/implements = list()	
	/// The current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/implement_type = null		
	/// Does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_hand = FALSE				
	/// Does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/accept_any_item = FALSE			
	/// How long does the step take?
	var/time = 1 SECONDS				
	/// Can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop
	var/repeatable = FALSE				
	/// List of chems needed to complete the step. Even on success, the step will have no effect if there aren't the chems required in the mob. Use *require_all_chems* to specify if its any on the list or all on the list
	var/list/chems_needed = list()  
	/// If *chems_needed* requires all chems in the list or one chem in the list.
	var/require_all_chems = TRUE    
	/// Chems that will modify the chance for fuckups while operating on conscious patients, stacks.
	var/list/ouchie_modifying_chems = list(/datum/reagent/consumable/ethanol/painkiller = 0.5, /datum/reagent/consumable/ethanol/inocybeshine = 0.5, /datum/reagent/medicine/morphine = 0.5) 
	/// Base damage dealt on a surgery being done without anesthetics on SURGERY_FUCKUP_CHANCE percent chance
	var/fuckup_damage = 10			
	/// Damage type fuckup_damage is dealt as
	var/fuckup_damage_type = BRUTE
	/// If silicons have to deal with success chance
	var/silicons_obey_prob = FALSE
	/// If this step causes blood to get on the user
	var/bloody_chance = 20

	/// Sound played when the step is started
	var/preop_sound 
	/// Sound played if the step succeeded
	var/success_sound 
	/// Sound played if the step fails
	var/failure_sound 

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
		if(iscyborg(user) && istype(tool, /obj/item/borg/cyborghug))
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
				to_chat(user, span_warning("You need to expose [target]'s [parse_zone(target_zone)] to perform surgery on it!"))
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


/datum/surgery_step/proc/initiate(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	surgery.step_in_progress = TRUE
	var/advance = FALSE

	var/tool_speed_mod = 1
	var/user_speed_mod = 1

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = FALSE
		return FALSE
	play_preop_sound(user, target, target_zone, tool, surgery)

	if(tool)
		tool_speed_mod = tool.toolspeed

	if(IS_MEDICAL(user))
		user_speed_mod = 0.8

	var/previous_loc = user.loc

	if(do_after(user, time * tool_speed_mod * user_speed_mod, target))
		var/prob_chance = 100

		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		prob_chance *= surgery.get_probability_multiplier()

		// Blood splatters on tools and user
		if(tool && prob(bloody_chance))
			tool.add_mob_blood(target)
			to_chat(user, span_warning("\The [tool] gets covered in [target]'s blood."))
		if(prob(bloody_chance * 0.5))
			user.add_mob_blood(target)
			to_chat(user, span_warning("You get covered in [target]'s blood."))

		if((prob(prob_chance) || (iscyborg(user) && !silicons_obey_prob)) && chem_check(target, user, tool) && !try_to_fail)
			if(success(user, target, target_zone, tool, surgery))
				play_success_sound(user, target, target_zone, tool, surgery)
				advance = TRUE
		else
			if(failure(user, target, target_zone, tool, surgery))
				play_failure_sound(user, target, target_zone, tool, surgery)
				
				advance = TRUE
		if(iscarbon(target) && !HAS_TRAIT(target, TRAIT_SURGERY_PREPARED) && target.stat != DEAD && !IS_IN_STASIS(target) && fuckup_damage) //not under the effects of anaesthetics or a strong painkiller, harsh penalty to success chance
			if(!issilicon(user) && !HAS_TRAIT(user, TRAIT_SURGEON)) //borgs and abductors are immune to this
				var/obj/item/bodypart/operated_bodypart = target.get_bodypart(target_zone)
				if(!operated_bodypart || operated_bodypart?.status == BODYPART_ORGANIC) //robot limbs don't feel pain
					cause_ouchie(user, target, target_zone, tool, advance)
		if(advance && !repeatable)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete()
	else
		if(!(previous_loc == user.loc))
			move_ouchie(user, target, target_zone, tool, advance)
	surgery.step_in_progress = FALSE
	return advance

/datum/surgery_step/proc/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to perform surgery on [target]..."),
		"[user] begins to perform surgery on [target].",
		"[user] begins to perform surgery on [target].")

/datum/surgery_step/proc/play_preop_sound(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!preop_sound)
		return
	var/sound_file_use
	if(islist(preop_sound))	
		for(var/typepath in preop_sound)//iterate and assign subtype to a list, works best if list is arranged from subtype first and parent last
			if(istype(tool, typepath))
				sound_file_use = preop_sound[typepath]	
				break	
	else
		sound_file_use = preop_sound
	if(!sound_file_use)
		return
	playsound(get_turf(target), sound_file_use, 30, TRUE, falloff = 2)

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You succeed."),
		"[user] succeeds!",
		"[user] finishes.")
	return TRUE

/datum/surgery_step/proc/play_success_sound(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!success_sound)
		return
	var/sound_file_use
	if(islist(success_sound ))	
		for(var/typepath in success_sound )//iterate and assign subtype to a list, works best if list is arranged from subtype first and parent last
			if(istype(tool, typepath))
				sound_file_use = success_sound [typepath]	
				break	
	else
		sound_file_use = success_sound
	if(!sound_file_use)
		return
	playsound(get_turf(target), sound_file_use, 30, TRUE, falloff = 2)

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You screw up!"),
		span_warning("[user] screws up!"),
		"[user] finishes.", TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/play_failure_sound(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!failure_sound)
		return
	var/sound_file_use
	if(islist(failure_sound))	
		for(var/typepath in failure_sound)//iterate and assign subtype to a list, works best if list is arranged from subtype first and parent last
			if(istype(tool, typepath))
				sound_file_use = failure_sound[typepath]	
				break	
	else
		sound_file_use = failure_sound
	if(!sound_file_use)
		return
	playsound(get_turf(target), sound_file_use, 30, TRUE, falloff = 2)

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/datum/surgery_step/proc/chem_check(mob/living/target, user,  obj/item/tool)
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

///Attempts to deal damage if the patient isn't sedated or under painkillers
/datum/surgery_step/proc/cause_ouchie(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, success)
	var/ouchie_mod = 1
	for(var/datum/reagent/R in ouchie_modifying_chems)
		if(target.reagents?.has_reagent(R))
			ouchie_mod *= ouchie_modifying_chems[R]
	if(target.stat == UNCONSCIOUS)
		ouchie_mod *= 0.8
	ouchie_mod *= clamp(1 - target.drunkenness / 100, 0, 1)
	if(!success)
		ouchie_mod *= 2
	var/final_ouchie_chance = SURGERY_FUCKUP_CHANCE * ouchie_mod
	if(!prob(final_ouchie_chance))
		return
	user.visible_message(span_boldwarning("[target] flinches, bumping [user]'s [tool ? tool.name : "hand"] into something important!"), span_boldwarning("[target] flinches, bumping your [tool ? tool.name : "hand"] into something important!"))
	target.apply_damage(fuckup_damage, fuckup_damage_type, target_zone)

///Deal damage if the user moved during the op
/datum/surgery_step/proc/move_ouchie(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, success)
	user.visible_message(span_boldwarning("[user] bumps [p_their(FALSE, user)] [tool ? tool.name : "hand"] into something important!"), span_boldwarning("You move, bumping your [tool ? tool.name : "hand"] into something important!"))
	target.apply_damage(fuckup_damage, fuckup_damage_type, target_zone)

/**
 * Sends a pain message to the target, including a chance of screaming.
 *
 * Arguments:
 * * target - Who the message will be sent to
 * * pain_message - The message to be displayed
 * * mechanical_surgery - Boolean flag that represents if a surgery step is done on a mechanical limb (therefore does not force scream)
 */
/datum/surgery_step/proc/display_pain(mob/living/target, pain_message, mechanical_surgery = FALSE)
	if(!HAS_TRAIT(target, TRAIT_SURGERY_PREPARED))
		to_chat(target, span_userdanger(pain_message))
		if(prob(30) && !mechanical_surgery)
			target.emote("scream")
