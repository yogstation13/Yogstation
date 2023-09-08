///Devils' objective to collect souls.
/datum/objective/devil_souls
	name = "devil souls"
	///How many souls are needed to complete the objective
	var/souls_needed = DEVIL_SOULS_TO_ASCEND

/datum/objective/devil_souls/admin_edit(mob/admin)
	var/tgui_input = tgui_input_number(admin, "How many souls does this objective need to complete?", "Needed Souls", DEVIL_SOULS_TO_ASCEND, max_value = 100)
	if(!tgui_input || !isnum(tgui_input))
		return
	souls_needed = tgui_input
	update_explanation_text()

/datum/objective/devil_souls/check_completion()
	var/datum/antagonist/devil/devil_datum = IS_DEVIL(owner.current)
	if(!devil_datum)
		return FALSE
	return devil_datum.souls >= souls_needed

/datum/objective/devil_souls/update_explanation_text()
	. = ..()
	explanation_text = "Collect [souls_needed] souls to ascend into your best form."


///The objective given to Agents to assassinate eachother.
/datum/objective/assassinate/internal
	name = "assassinate internal"

//We do not find a target, we'll be set manually in the game.
/datum/objective/assassinate/internal/find_target_by_role(role, role_type = FALSE, invert = FALSE)
	return

/datum/objective/assassinate/internal/update_explanation_text()
	if(target && target.current && (target.current.stat != DEAD))
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Turn in the corpse of [target.name], who has been obliterated, to the Devil using a calling card (AltClick a paper)."
