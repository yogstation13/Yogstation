/datum/antagonist/traitor/malf //inheriting traitor antag datum since traitor AIs use it.
	malf = TRUE
	roundend_category = "malfunctioning AIs"
	name = "Malfunctioning AI"
	show_to_ghosts = TRUE

/datum/antagonist/traitor/malf/forge_ai_objectives()
	var/datum/objective/block/block_objective = new
	block_objective.owner = owner
	add_objective(block_objective)
	var/datum/objective/survive/exist/exist_objective = new
	exist_objective.owner = owner
	add_objective(exist_objective)

/datum/antagonist/traitor/malf/can_be_owned(datum/mind/new_owner)
	return istype(new_owner.current, /mob/living/silicon/ai)

/datum/antagonist/traitor/malf/get_preview_icon()
	var/icon/malf_ai_icon = icon('icons/mob/ai.dmi', "ai-red")

	// Crop out the borders of the AI, just the face
	malf_ai_icon.Crop(5, 27, 28, 6)

	malf_ai_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return malf_ai_icon
