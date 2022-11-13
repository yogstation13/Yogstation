/datum/antagonist/traitor/malf //inheriting traitor antag datum since traitor AIs use it.
	malf = TRUE
	roundend_category = "malfunctioning AIs"
	name = "Malf"
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
