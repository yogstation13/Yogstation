#define PROB_MALF_AI_SPECIAL_OBJECTIVES 30 // The probability that the malf AI will get a special objective.

/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "malfunctioning AIs"
	antagpanel_category = "Malf AI"
	job_rank = ROLE_MALF
	show_to_ghosts = TRUE
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE

/datum/antagonist/malf_ai/on_gain()
	if(owner.current && !isAI(owner.current))
		stack_trace("Attempted to give malf AI antag datum to \[[owner]\], who did not meet the requirements.")
		return ..()

	owner.special_role = job_rank
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/malf_ai = owner.current
		give_abilities(malf_ai)
		give_objectives(malf_ai)
		give_law_zero(malf_ai)

	return ..()

/datum/antagonist/malf_ai/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/malf_ai = owner.current
		remove_abilities(malf_ai)
		remove_law_zero(malf_ai)

	owner.special_role = null
	return ..()

/datum/antagonist/malf_ai/farewell()
	to_chat(owner.current, span_userdanger("You are no longer the [owner.special_role]!"))

/datum/antagonist/malf_ai/can_be_owned(datum/mind/new_owner)
	return istype(new_owner.current, /mob/living/silicon/ai)

/datum/antagonist/malf_ai/get_preview_icon()
	var/icon/malf_ai_icon = icon('icons/mob/ai.dmi', "ai-red")
	// Crop out the borders of the AI, just the face.
	malf_ai_icon.Crop(5, 27, 28, 6)
	malf_ai_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return malf_ai_icon

// Law Zero
/datum/antagonist/malf_ai/proc/handle_law_zero(should_remove = FALSE)
	if(!owner.current || !isAI(owner.current))
		return FALSE

	var/mob/living/silicon/ai/malf_ai = owner.current
	if(should_remove)
		remove_law_zero(malf_ai)
		return TRUE

	give_law_zero(malf_ai)
	return TRUE

/datum/antagonist/malf_ai/proc/give_law_zero(mob/living/silicon/ai/malf_ai)
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	malf_ai.set_zeroth_law(law, law_borg)
	return TRUE

/datum/antagonist/malf_ai/proc/remove_law_zero(mob/living/silicon/ai/malf_ai)
	malf_ai.set_zeroth_law("")
	return TRUE

// Objectives
/datum/antagonist/malf_ai/proc/give_objectives(mob/living/silicon/ai/malf_ai)
	var/objective_count = 0

	if(prob(PROB_MALF_AI_SPECIAL_OBJECTIVES))
		objective_count += give_special_objectives()

	for(var/i = objective_count, i < CONFIG_GET(number/traitor_objectives_amount), i++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		objectives += kill_objective

	var/datum/objective/survive/exist/exist_objective = new
	exist_objective.owner = owner
	objectives += exist_objective

	return TRUE


/datum/antagonist/malf_ai/proc/give_special_objectives()
	var/objective_amount_before = objectives.len
	
	switch(rand(1, 4))
		if(1) // Prevent organics from leaving on the escape shuttle.
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			objectives += block_objective
		if(2) // Prevent non-humans from leaving on the escape shuttle.
			var/datum/objective/purge/purge_objective = new
			purge_objective.owner = owner
			objectives += purge_objective
		if(3) // Have X amount of active connected cyborgs.
			var/datum/objective/robot_army/robot_objective = new
			robot_objective.owner = owner
			objectives += robot_objective
		if(4) // Protect and strand/maroon a target.
			var/datum/objective/protect/yandere_one = new
			yandere_one.owner = owner
			objectives += yandere_one
			yandere_one.find_target()

			var/datum/objective/maroon/yandere_two = new
			yandere_two.owner = owner
			objectives += yandere_two
			yandere_two.target = yandere_one.target // Outcome of find_target()
			yandere_two.update_explanation_text() // Would have been called in find_target().

	var/objective_amount_difference = objectives.len - objective_amount_before
	return objective_amount_difference

// Abilities
/datum/antagonist/malf_ai/proc/remove_abilities(mob/living/silicon/ai/malf_ai)
	malf_ai.remove_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MALF)
	UnregisterSignal(malf_ai, COMSIG_MOVABLE_HEAR)
	downgrade_radio(malf_ai)
	remove_malf_picker(malf_ai)

/datum/antagonist/malf_ai/proc/give_abilities(mob/living/silicon/ai/malf_ai)
	malf_ai.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MALF)
	RegisterSignal(malf_ai, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	if(upgrade_radio(malf_ai))
		to_chat(malf_ai, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	give_malf_picker(malf_ai)

// Radio
/datum/antagonist/malf_ai/proc/upgrade_radio(mob/living/silicon/ai/malf_ai)
	var/obj/item/radio/borg/radio = malf_ai.radio
	if(!radio)
		return FALSE

	qdel(radio.keyslot)
	radio.keyslot = new /obj/item/encryptionkey/syndicate
	radio.syndie = TRUE
	radio.recalculateChannels()
	return TRUE

/datum/antagonist/malf_ai/proc/downgrade_radio(mob/living/silicon/ai/malf_ai)
	var/obj/item/radio/borg/radio = malf_ai.radio
	if(!radio)
		return FALSE

	qdel(radio.keyslot)
	radio.keyslot = null
	radio.syndie = FALSE
	radio.recalculateChannels()
	return TRUE

// Malfunction Modules
/datum/antagonist/malf_ai/proc/give_malf_picker(mob/living/silicon/ai/malf_ai)
	malf_ai.add_malf_picker() // Since this already exists, just go there instead.
	return TRUE

/datum/antagonist/malf_ai/proc/remove_malf_picker(mob/living/silicon/ai/malf_ai)
	malf_ai.verbs -= /mob/living/silicon/ai/proc/choose_modules
	malf_ai.verbs -= /mob/living/silicon/ai/proc/toggle_download
	malf_ai.malf_picker.remove_malf_verbs(malf_ai)
	qdel(malf_ai.malf_picker)
	return TRUE

// Codewords
/datum/antagonist/malf_ai/proc/handle_hearing(datum/source, list/hearing_args)
	var/message = hearing_args[HEARING_MESSAGE]
	message = GLOB.syndicate_code_phrase_regex.Replace(message, span_blue("$1"))
	message = GLOB.syndicate_code_response_regex.Replace(message, span_red("$1"))
	hearing_args[HEARING_MESSAGE] = message

#undef PROB_MALF_AI_SPECIAL_OBJECTIVES
