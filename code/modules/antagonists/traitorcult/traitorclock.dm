/datum/antagonist/clockcult/agent
	name = "ClockCult Agent"
	antagpanel_category = "Clock Agent"
	make_team = FALSE
	agent = TRUE
	ignore_holy_water = TRUE

/datum/antagonist/clockcult/agent/on_gain()
	SSticker.mode.clockagents += owner
	SSticker.mode.update_servant_icons_added(owner)
	equip_clock_agent()
	owner.special_role = ROLE_CLOCK_AGENT
	..()

/datum/antagonist/clockcult/agent/greet()
	if(considered_alive(owner))
		to_chat(owner, "<span class='sevtug'>Here's the deal; Rats wants some stuff from this station and he's got me herding you idiots to get it. \
						We're running on fumes especially this far out so you'll be missing some scriptures, mainly the ones that make more cultists. Just finish our little shopping list and make a getaway. \
						There's some minds I can sense that seem to be stronger than the others, probably being manipulated by our enemy. I shouldn't have to say this more than once: Be. Careful.</span>")
	owner.current.playsound_local(get_turf(owner.current),'sound/effects/screech.ogg' , 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/clockcult/agent/on_removal()
	SSticker.mode.clock_agent_team.remove_member(owner)
	SSticker.mode.clockagents -= owner
	. = ..()

/datum/antagonist/clockcult/agent/admin_add(datum/mind/new_owner, mob/admin)
	if(!SSticker.mode.clock_agent_team)
		SSticker.mode.clock_agent_team = new()
	add_servant_of_ratvar(new_owner.current, TRUE, FALSE, TRUE)
	SSticker.mode.clock_agent_team.add_member(owner)
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a Clockwork Agent.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a Clockwork Agent.")

/datum/antagonist/clockcult/agent/admin_remove(mob/user)
	message_admins("[key_name_admin(user)] has removed clockwork agent status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed clockwork agent status from [key_name(owner)].")
	remove_servant_of_ratvar(owner.current, TRUE)

/datum/antagonist/clockcult/agent/proc/equip_clock_agent()
	var/mob/living/M = owner.current
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	var/obj/item/clockwork/slab/agent/S = new
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = SLOT_L_STORE, "In your right pocket" = SLOT_R_STORE, "In your backpack" = SLOT_IN_BACKPACK, "On your belt" = SLOT_BELT)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(slot == "At your feet")
		if(!S.forceMove(get_turf(L)))
			qdel(S)
	if(S && !QDELETED(S))
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
	return S

/datum/antagonist/clockcult/agent/admin_give_slab(mob/admin)
	if(!equip_clock_agent(owner.current))
		to_chat(admin, "<span class='warning'>Failed to outfit [owner.current]!</span>")
	else
		to_chat(admin, "<span class='notice'>Successfully gave [owner.current] a slab!</span>")

/datum/team/clock_agents
	name = "Clockwork Agents"

/datum/team/clock_agents/New(starting_members)
	. = ..()
	adjust_clockwork_power(1000)

/datum/team/clock_agents/proc/forge_clock_objectives()
	objectives = list()
	var/list/active_ais = active_ais()
	if(active_ais.len && prob(50))
		var/datum/objective/steal/AI = new
		AI.targetinfo = /datum/objective_item/steal/functionalai
		AI.explanation_text = "<span class='nezbere'>Recover an AI for use in the manufactories.</span>"
		add_objective(AI)
	else
		add_objective(new/datum/objective/soul_extraction)
	add_objective(new/datum/objective/implant)
	add_objective(new/datum/objective/escape/onesurvivor/clockagent)
	return

/datum/team/clock_agents/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/objective/escape/onesurvivor/clockagent //flavortext variant
	name = "escape clock agent"
	explanation_text = "<span class='inathneq'>Escape alive and out of custody.</span>"
	team_explanation_text = "<span class='inathneq'>Broken bodies can be fixed, lost ones can't. Leave no servant behind, alive or dead. Do not get captured.</span>"

/obj/item/clockwork/slab/agent
	quickbound = list(/datum/clockwork_scripture/create_object/integration_cog, \
	/datum/clockwork_scripture/vanguard, /datum/clockwork_scripture/ranged_ability/hateful_manacles)

/obj/item/clockwork/slab/agent/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += "<span class='sevtug'>This slab's connection to the Justicar is modified for covert operations, with some scriptures being weakened or unusable. Additionally, replica fabricators made with this slab have extra uses for specific objectives.</span>"
