/datum/xeno_mutation/reproduction
	name = "Cringe"
	coexisting = XENO_MUT_UNIQUE
	mut_type = XENO_MUT_REPRODUCTION

	var/datum/action/innate/action

	var/action_name = "Become cringe"
	var/action_desc = "amongus"
	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"

/datum/xeno_mutation/reproduction/Activate()
	. = ..()
	if(action)
		action.Grant(mymob)
	else
		action = new
		action.name = action_name
		action.name = action_desc
		action.name = icon_icon
		action.name = button_icon_state
		action.linked_mutation = src
		action.UpdateButtonIcon()

/datum/xeno_mutation/reproduction/Deactivate()
	. = ..()
	qdel(action)

/datum/xeno_mutation/reproduction/proc/OnActionActivate()

/datum/action/innate/xeno_reproduce
	var/datum/xeno_mutation/reproduction/linked_mutation

/datum/action/innate/xeno_reproduce/Trigger()
	linked_mutation.OnActionActivate()