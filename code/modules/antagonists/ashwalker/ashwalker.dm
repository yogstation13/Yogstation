/datum/team/ashwalkers
	name = "Ashwalkers"
	show_roundend_report = FALSE

/datum/antagonist/ashwalker
	name = "Ash Walker"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Ash Walkers"
	var/datum/team/ashwalkers/ashie_team

/datum/antagonist/ashwalker/create_team(datum/team/team)
	if(team)
		ashie_team = team
		objectives |= ashie_team.objectives
	else
		ashie_team = new

/datum/antagonist/ashwalker/get_team()
	return ashie_team

/datum/antagonist/ashwalker/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	UnregisterSignal(old_body, COMSIG_MOB_EXAMINATE)
	RegisterSignal(new_body, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/ashwalker/on_gain()
	. = ..()
	for(var/crafting_recipe_type in list(/datum/crafting_recipe/bola_arrow, /datum/crafting_recipe/flaming_arrow, /datum/crafting_recipe/raider_leather, /datum/crafting_recipe/tribal_wraps, /datum/crafting_recipe/ash_robe, /datum/crafting_recipe/ash_robe/young, /datum/crafting_recipe/ash_robe/chief, /datum/crafting_recipe/ash_robe/shaman, /datum/crafting_recipe/ash_robe/tunic, /datum/crafting_recipe/chestwrap, /datum/crafting_recipe/tribalmantle, /datum/crafting_recipe/leathercape, /datum/crafting_recipe/hidemantle))
		var/datum/crafting_recipe/R = crafting_recipe_type
		owner.teach_crafting_recipe(R)
	RegisterSignal(owner.current, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/ashwalker/on_removal()
	. = ..()
	UnregisterSignal(owner.current, COMSIG_MOB_EXAMINATE)

/datum/antagonist/ashwalker/proc/on_examinate(datum/source, atom/A)
	if(istype(A, /obj/structure/headpike))
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_good)
