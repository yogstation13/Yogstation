/datum/antagonist/cult/agent
	name = "Blood Agent"
	antagpanel_category = "Blood Agent"
	make_team = FALSE
	agent = TRUE
	ignore_holy_water = TRUE

/datum/antagonist/cult/agent/on_gain()
	SSticker.mode.bloodagents += owner
	SSticker.mode.update_cult_icons_added(owner)
	equip_cultist(FALSE)
	owner.special_role = ROLE_BLOOD_AGENT
	..()

/datum/antagonist/cult/agent/greet()
	if(considered_alive(owner))
		to_chat(owner, "<span class='cultlarge'>\"These fools are in possession of some things I want. You are here to retrieve them for me.\
		 				The veil is not weak enough to allow much support in this area, so you will be unable to convert, use constructs or some spells. \
		 				Additionally, you may be in contact with some heretical forces. Do not get yourselves killed.\"</span>")
	owner.current.playsound_local(get_turf(owner.current),'sound/ambience/antag/assimilation.ogg' , 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/cult/agent/on_removal()
	SSticker.mode.blood_agent_team.remove_member(owner)
	SSticker.mode.bloodagents -= owner
	. = ..()
/datum/antagonist/cult/agent/admin_add(datum/mind/new_owner, mob/admin)
	if(!SSticker.mode.blood_agent_team)
		SSticker.mode.blood_agent_team = new()
	new_owner.add_antag_datum(/datum/antagonist/cult/agent)
	SSticker.mode.blood_agent_team.add_member(new_owner)
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a Blood Agent.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a Blood Agent.")

/datum/antagonist/cult/agent/admin_remove(mob/user)
	message_admins("[key_name_admin(user)] has removed blood agent status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed blood agent status from [key_name(owner)].")
	owner.remove_antag_datum(/datum/antagonist/cult/agent)

/datum/team/blood_agents
	name = "Blood Agents"

/datum/team/blood_agents/proc/forge_blood_objectives()
	objectives = list()
	add_objective(new/datum/objective/soulshard)
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
