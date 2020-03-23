/datum/antagonist/cult/agent
	name = "cult Agent"
	antagpanel_category = "Cult Agent"
	make_team = FALSE
	agent = TRUE
	ignore_holy_water = TRUE
	var/datum/team/blood_agents/agent_team

/datum/antagonist/cult/agent/on_gain()
	SSticker.mode.bloodagents += owner
	SSticker.mode.update_servant_icons_added(owner)
	owner.special_role = ROLE_BLOOD_AGENT
	agent_team = SSticker.mode.blood_agent_team //only one agent team can exist for each side
	if(!agent_team)
		agent_team = new
		SSticker.mode.blood_agent_team = agent_team
		agent_team.add_member(owner)
		agent_team.forge_blood_objectives()
		objectives += agent_team.objectives
	else
		agent_team.add_member(owner)
		objectives += agent_team.objectives
	..()

/datum/antagonist/cult/agent/greet()
	if(considered_alive(owner))
		to_chat(owner, "<span class='sevtug'>Here's the deal; Rats wants some stuff from this station and he's got me herding you idiots to get it. \
						We're running on fumes especially this far out so you'll be missing some scriptures, mainly the ones that make more cultists. Just finish our little shopping list and make a getaway. \
						There's some minds I can sense that seem to be stronger than the others, probably being manipulated by our enemy. I shouldn't have to say this more than once: Be. Careful.</span>")
	owner.current.playsound_local(get_turf(owner.current),'sound/effects/screech.ogg' , 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/cult/agent/admin_add(datum/mind/new_owner, mob/admin)
	add_servant_of_ratvar(new_owner.current, TRUE, FALSE, TRUE)
	agent_team = SSticker.mode.blood_agent_team
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a bloodwork Agent.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a bloodwork Agent.")

/datum/antagonist/cult/agent/admin_remove(mob/user)
	remove_servant_of_ratvar(owner.current, TRUE)
	message_admins("[key_name_admin(user)] has removed bloodwork agent status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed bloodwork agent status from [key_name(owner)].")

/datum/antagonist/cult/agent/create_team(datum/team/blood_agents/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	agent_team = new_team

/datum/team/blood_agents
	name = "bloodwork Agents"

/datum/team/blood_agents/proc/forge_blood_objectives()
	objectives = list()
	//add_objective(new/datum/objective/soul_extraction)
	add_objective(new/datum/objective/implant/blood)
	add_objective(new/datum/objective/escape/onesurvivor/bloodagent)
	return

/datum/team/blood_agents/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/objective/escape/onesurvivor/bloodagent
	name = "escape blood agent"
	explanation_text = "<span class='cultbold'>Escape alive and out of custody.</span>"
	team_explanation_text = "<span class='cultbold'>Escape with your entire team intact and at least one member alive. Do not get captured.</span>"
