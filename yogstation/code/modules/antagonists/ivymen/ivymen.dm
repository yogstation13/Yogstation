/datum/team/ivymen
	name = "Ivymen"
	show_roundend_report = FALSE

/datum/antagonist/ivymen
	name = "Ivyman"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Ivymen"
	var/datum/team/ivymen/ivymen_team

/datum/antagonist/ivymen/create_team(datum/team/team)
	if(team)
		ivymen_team = team
		objectives |= ivymen_team.objectives
	else
		ivymen_team = new

/datum/antagonist/ivymen/get_team()
	return ivymen_team

/datum/antagonist/ivymen/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	UnregisterSignal(old_body, COMSIG_MOB_EXAMINATE)
	RegisterSignal(new_body, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/ivymen/on_gain()
	. = ..()
	RegisterSignal(owner.current, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/ivymen/on_removal()
	. = ..()
	UnregisterSignal(owner.current, COMSIG_MOB_EXAMINATE)

/datum/antagonist/ivymen/proc/on_examinate(datum/source, atom/A)
	if(istype(A, /obj/structure/headpike))
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_good)
