/datum/antagonist/clockcult/agent
	name = "ClockCult Agent"
	antagpanel_category = "Cult Agent"
	make_team = FALSE
	agent = TRUE
	ignore_holy_water = TRUE
	var/datum/team/clock_agents/agent_team

/datum/antagonist/clockcult/agent/on_gain()
	SSticker.mode.clockagents += owner
	SSticker.mode.update_servant_icons_added(owner)
	owner.special_role = ROLE_CLOCK_AGENT
	agent_team = SSticker.mode.clock_agent_team //only one agent team can exist for each side
	if(!agent_team)
		agent_team = new
		SSticker.mode.clock_agent_team = agent_team
		agent_team.add_member(owner)
		agent_team.forge_clock_objectives()
		objectives += agent_team.objectives
	else
		agent_team.add_member(owner)
		objectives += agent_team.objectives
	..()

/datum/antagonist/clockcult/agent/greet()
	if(considered_alive(owner))
		to_chat(owner, "<span class='sevtug'>Here's the deal; Rats wants some stuff from this station and he's got me herding you idiots to get it. \
						We're running on fumes especially this far out so you'll be missing some scriptures, mainly the ones that make more cultists. Just finish our little shopping list and make a getaway. \
						There's some minds I can sense that seem to be stronger than the others, probably being manipulated by our enemy. I shouldn't have to say this more than once: Be. Careful.</span>")
	owner.current.playsound_local(get_turf(owner.current),'sound/effects/screech.ogg' , 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/clockcult/agent/admin_add(datum/mind/new_owner, mob/admin)
	add_servant_of_ratvar(new_owner.current, TRUE, FALSE, TRUE)
	agent_team = SSticker.mode.clock_agent_team
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a Clockwork Agent.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a Clockwork Agent.")

/datum/antagonist/clockcult/agent/admin_remove(mob/user)
	remove_servant_of_ratvar(owner.current, TRUE)
	message_admins("[key_name_admin(user)] has removed clockwork agent status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed clockwork agent status from [key_name(owner)].")

/datum/antagonist/clockcult/agent/admin_give_slab(mob/admin)
	if(!SSticker.mode.equip_clock_agent(owner.current))
		to_chat(admin, "<span class='warning'>Failed to outfit [owner.current]!</span>")
	else
		to_chat(admin, "<span class='notice'>Successfully gave [owner.current] a slab!</span>")

/datum/antagonist/clockcult/agent/create_team(datum/team/clock_agents/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	agent_team = new_team

/datum/team/clock_agents
	name = "Clockwork Agents"

/datum/team/clock_agents/proc/forge_clock_objectives()
	objectives = list()
	/*var/list/active_ais = active_ais() //will be added in the "i'm done with the gamemode" DLC pack, currently out for soul extraction testing
	if(active_ais.len && prob(50))
		var/datum/objective/steal/AI = new
		AI.targetinfo = /datum/objective_item/steal/functionalai
		add_objective(AI)
	else*/
	add_objective(new/datum/objective/soul_extraction)
	add_objective(new/datum/objective/implant)
	add_objective(new/datum/objective/escape/onesurvivor/clockagent)
	GLOB.clockwork_power += 5000
	return

/datum/team/clock_agents/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/objective/escape/onesurvivor/clockagent //flavortext variant
	name = "escape clock agent"
	explanation_text = "<span class='inathneq'>Escape alive and out of custody.</span>"
	team_explanation_text = "<span class='inathneq'>Escape with your entire team intact and at least one member alive. Do not get captured.</span>"

/obj/item/clockwork/slab/agent
	quickbound = list(/datum/clockwork_scripture/create_object/integration_cog, \
	/datum/clockwork_scripture/vanguard, /datum/clockwork_scripture/ranged_ability/hateful_manacles)

/obj/item/clockwork/slab/agent/examine(mob/user)
	. = ..()
	if(user.mind?.has_antag_datum(/datum/antagonist/clockcult/agent))
		. += "<span class='sevtug'>This slab's connection to the Justicar is modified for covert operations, with some scriptures being weakened or unusable. Additionally, replica fabricators made with this slab have extra uses for specific objectives.</span>"
