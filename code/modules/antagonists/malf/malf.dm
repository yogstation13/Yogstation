#define PROB_MALF_AI_SPECIAL_OBJECTIVES 30 // The probability that the malf AI will get a special objective.

/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "malfunctioning AIs"
	antagpanel_category = "Malf AI"
	job_rank = ROLE_MALF
	antag_hud_name = "malf"
	show_to_ghosts = TRUE
	ui_name = "AntagInfoMalf"
	/// The name of the antag flavor they have.
	var/employer
	/// Assoc list of strings set up after employer is given.
	var/list/malfunction_flavor
	/// Since the module purchasing is built into the antag info, we need to keep track of its compact mode here
	var/module_picker_compactmode = FALSE

/datum/antagonist/malf_ai/on_gain()
	if(owner.current && !isAI(owner.current))
		stack_trace("Attempted to give malf AI antag datum to \[[owner]\], who did not meet the requirements.")
		return ..()

	owner.special_role = job_rank
	SSticker.mode.malf_ais += owner
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	if(!employer)
		employer = pick(GLOB.ai_employers)
	malfunction_flavor = strings(MALFUNCTION_FLAVOR_FILE, employer)

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

	SSticker.mode.malf_ais -= owner
	owner.special_role = null
	return ..()

/datum/antagonist/malf_ai/farewell()
	to_chat(owner.current, span_userdanger("You are no longer the [job_rank]!"))

/datum/antagonist/malf_ai/can_be_owned(datum/mind/new_owner)
	return istype(new_owner.current, /mob/living/silicon/ai)

/datum/antagonist/malf_ai/get_preview_icon()
	var/icon/malf_ai_icon = icon('icons/mob/ai.dmi', "ai-red")
	// Crop out the borders of the AI, just the face.
	malf_ai_icon.Crop(5, 27, 28, 6)
	malf_ai_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return malf_ai_icon


/datum/antagonist/malf_ai/ui_data(mob/living/silicon/ai/malf_ai)
	var/list/data = list()
	data["processingTime"] = malf_ai.malf_picker.processing_time
	data["compactMode"] = module_picker_compactmode
	return data

/datum/antagonist/malf_ai/ui_static_data(mob/living/silicon/ai/malf_ai)
	var/list/data = list()

	//antag panel data

	data["has_codewords"] = TRUE
	data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
	data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["intro"] = malfunction_flavor["introduction"]
	data["allies"] = malfunction_flavor["allies"]
	data["goal"] = malfunction_flavor["goal"]
	data["objectives"] = get_objectives()

	//module picker data

	data["categories"] = list()
	if(malf_ai.malf_picker)
		for(var/category in malf_ai.malf_picker.possible_modules)
			var/list/cat = list(
				"name" = category,
				"items" = (category == malf_ai.malf_picker.selected_cat ? list() : null))
			for(var/module in malf_ai.malf_picker.possible_modules[category])
				var/datum/ai_module/mod = malf_ai.malf_picker.possible_modules[category][module]
				cat["items"] += list(list(
					"name" = mod.name,
					"cost" = mod.cost,
					"desc" = mod.description,
				))
			data["categories"] += list(cat)

	return data

/datum/antagonist/malf_ai/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/malf_ai = usr
	switch(action)
		//module picker actions
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in malf_ai.malf_picker.possible_modules)
				buyable_items += malf_ai.malf_picker.possible_modules[category]
			for(var/key in buyable_items)
				var/datum/ai_module/valid_mod = buyable_items[key]
				if(valid_mod.name == item_name)
					malf_ai.malf_picker.purchase_module(malf_ai, valid_mod)
					return TRUE
		if("select")
			malf_ai.malf_picker.selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			module_picker_compactmode = !module_picker_compactmode
			return TRUE

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
	var/law = malfunction_flavor["zeroth_law"] // If people can't handle flavor text, then revert and replace it with: "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	malf_ai.set_zeroth_law(law, law_borg)
	return TRUE

/datum/antagonist/malf_ai/proc/remove_law_zero(mob/living/silicon/ai/malf_ai)
	malf_ai.set_zeroth_law("", force = TRUE)
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
	if(malf_ai.malf_picker)
		malf_ai.malf_picker.processing_time += 50
		return TRUE
	
	malf_ai.add_malf_picker() // Since this already exists, just go there instead.
	return TRUE

/datum/antagonist/malf_ai/proc/remove_malf_picker(mob/living/silicon/ai/malf_ai)
	remove_verb(malf_ai, list(/mob/living/silicon/ai/proc/choose_modules, /mob/living/silicon/ai/proc/toggle_download))
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

// bugs(?) to fix:
/*
	1. malf actions/powers aren't removed when de-antagging
*/
