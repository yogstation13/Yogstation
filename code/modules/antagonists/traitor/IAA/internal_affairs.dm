#define PINPOINTER_MINIMUM_RANGE 15
#define PINPOINTER_EXTRA_RANDOM_RANGE 10
#define PINPOINTER_PING_TIME 40
#define PROB_ACTUAL_TRAITOR 20
#define TRAITOR_AGENT_ROLE "Gorlex Marauders Exile"
#define TRAITOR_AGENT_SROLE "gorlex marauders exile"

/datum/antagonist/traitor/internal_affairs
	name = "Syndicate Internal Affairs Agent"
	special_role = "internal affairs agent" //Doesn't have it listed but employer should still be syndicate
	antagpanel_category = "IAA"
	var/marauder = FALSE
	var/last_man_standing = FALSE
	var/list/datum/mind/targets_stolen
	greentext_achieve = /datum/achievement/greentext/internal

/datum/antagonist/traitor/internal_affairs/proc/give_pinpointer()
	if(owner && owner.current)
		owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer)

/datum/antagonist/traitor/internal_affairs/apply_innate_effects()
	.=..() //in case the base is used in future
	if(owner && owner.current)
		give_pinpointer(owner.current)

/datum/antagonist/traitor/internal_affairs/remove_innate_effects()
	.=..()
	if(owner && owner.current)
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer)

/datum/antagonist/traitor/internal_affairs/on_gain()
	START_PROCESSING(SSprocessing, src)

	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/implant/dusting/E = new/obj/item/implant/dusting(H)
		E.implant(H)

	company = pick(subtypesof(/datum/corporation/traitor))

	.=..()
/datum/antagonist/traitor/internal_affairs/on_removal()
	STOP_PROCESSING(SSprocessing,src)
	.=..()
/datum/antagonist/traitor/internal_affairs/process()
	iaa_process()


/datum/status_effect/agent_pinpointer
	id = "agent_pinpointer"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	var/range_fuzz_factor = PINPOINTER_EXTRA_RANDOM_RANGE
	var/mob/scan_target = null
	var/range_mid = 8
	var/range_far = 16

/obj/screen/alert/status_effect/agent_pinpointer
	name = "Internal Affairs Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range + rand(0, range_fuzz_factor))
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.icon_state = "pinonclose"
		else if(dist > range_mid && dist <= range_far)
			linked_alert.icon_state = "pinonmedium"
		else if(dist > range_far)
			linked_alert.icon_state = "pinonfar"

/datum/status_effect/agent_pinpointer/proc/scan_for_target()
	scan_target = null
	if(owner)
		if(owner.mind)
			for(var/datum/objective/objective_ in owner.mind.get_all_objectives())
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				var/mob/current = objective.target.current
				if(current&&current.stat!=DEAD)
					scan_target = current
					break

/datum/status_effect/agent_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()


/proc/is_internal_objective(datum/objective/O)
	return (istype(O, /datum/objective/assassinate/internal)||istype(O, /datum/objective/destroy/internal))

/datum/antagonist/traitor/proc/replace_escape_objective_martyr()
	if(!owner || !objectives.len)
		return
	for (var/objective_ in objectives)
		if(!(istype(objective_, /datum/objective/escape)||istype(objective_, /datum/objective/survive)||istype(objective_, /datum/objective/hijack)))
			continue
		remove_objective(objective_)

	var/datum/objective/martyr/martyr_objective = new
	martyr_objective.owner = owner
	add_objective(martyr_objective)

/datum/antagonist/traitor/proc/replace_escape_objective_hijack() //Should work?
	if(!owner || !objectives.len)
		return
	for (var/objective_ in objectives)
		if(!(istype(objective_, /datum/objective/escape)||istype(objective_, /datum/objective/survive)||istype(objective_, /datum/objective/martyr)))
			continue
		remove_objective(objective_)
	
	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.owner = owner
	add_objective(hijack_objective)

/datum/antagonist/traitor/proc/reinstate_escape_objective()
	if(!owner||!objectives.len)
		return
	for (var/objective_ in objectives)
		if(!istype(objective_, /datum/objective/martyr) || !istype(objective_, /datum/objective/hijack))
			continue
		remove_objective(objective_)

/datum/antagonist/traitor/internal_affairs/reinstate_escape_objective()
	..()
	var/objtype = traitor_kind == TRAITOR_HUMAN ? /datum/objective/escape : /datum/objective/survive
	var/datum/objective/escape_objective = new objtype
	escape_objective.owner = owner
	add_objective(escape_objective)

/datum/antagonist/traitor/internal_affairs/proc/steal_targets(datum/mind/victim)
	if(!owner.current||owner.current.stat==DEAD)
		return
	to_chat(owner.current, span_userdanger("Target eliminated: [victim.name]"))
	for(var/objective_ in victim.get_all_objectives())
		if(istype(objective_, /datum/objective/assassinate/internal))
			var/datum/objective/assassinate/internal/objective = objective_
			if(objective.target==owner)
				continue
			else if(targets_stolen.Find(objective.target) == 0)
				var/datum/objective/assassinate/internal/new_objective = new
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				add_objective(new_objective)
				targets_stolen += objective.target
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, span_userdanger("New target added to database: [objective.target.name] ([status_text])"))
		else if(istype(objective_, /datum/objective/destroy/internal))
			var/datum/objective/destroy/internal/objective = objective_
			var/datum/objective/destroy/internal/new_objective = new
			if(objective.target==owner)
				continue
			else if(targets_stolen.Find(objective.target) == 0)
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				add_objective(new_objective)
				targets_stolen += objective.target
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, span_userdanger("New target added to database: [objective.target.name] ([status_text])"))
	last_man_standing = TRUE
	for(var/objective_ in objectives)
		if(!is_internal_objective(objective_))
			continue
		var/datum/objective/assassinate/internal/objective = objective_
		if(!objective.check_completion())
			last_man_standing = FALSE
			return
	if(last_man_standing)
		if(!marauder)
			to_chat(owner.current,span_userdanger("Every agent confirmed turncoat has been eliminated. However, given that the entire cell was compromised, your loyalty is being called into question. Die a glorious death, and prove your unending allegiance to the Syndicate."))
			replace_escape_objective_martyr(owner)
		else
			to_chat(owner.current,span_userdanger("Each of the others lies dead at your feet. Your final obstacle of this trial is to hijack the shuttle. Leave none standing and no survivors in your wake. Your brothers await you with open arms, Marauder."))
			replace_escape_objective_hijack(owner)

/datum/antagonist/traitor/internal_affairs/proc/iaa_process()
	if(owner&&owner.current&&owner.current.stat!=DEAD)
		for(var/objective_ in objectives)
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			if(!objective.target)
				continue
			if(objective.check_completion())
				if(objective.stolen)
					continue
				else
					steal_targets(objective.target)
					objective.stolen = TRUE
			else
				if(objective.stolen)
					var/fail_msg = span_userdanger("Your sensors tell you that [objective.target.current.real_name], one of the targets you were meant to have killed, lives once again.")
					if(last_man_standing)
						if(!marauder)
							fail_msg += span_userdanger("You no longer have permission to die. Track the treacherous vermin down, and kill them. No loose ends are permitted.")
						else
							fail_msg += span_userdanger("They will not judge us weak.</font><B><font size=5 color=red> Cease your terror on Nanotrasen and eliminate the tenacious target once more. Fail to do this, and a bullet awaits you at the base.")
						reinstate_escape_objective(owner)
						last_man_standing = FALSE
					to_chat(owner.current, fail_msg)
					objective.stolen = FALSE

/datum/antagonist/traitor/internal_affairs/proc/forge_iaa_objectives()
	if(SSticker.mode.target_list.len && SSticker.mode.target_list[owner]) // Is a double agent
		// Assassinate
		var/datum/mind/target_mind = SSticker.mode.target_list[owner]
		if(issilicon(target_mind.current))
			var/datum/objective/destroy/internal/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.target = target_mind
			destroy_objective.update_explanation_text()
			add_objective(destroy_objective)
		else
			var/datum/objective/assassinate/internal/kill_objective = new
			kill_objective.owner = owner
			kill_objective.target = target_mind
			kill_objective.update_explanation_text()
			add_objective(kill_objective)

		//Lower chance of someone needing to do an additional objective, but getting hijack instead of DaGD
		if(prob(PROB_ACTUAL_TRAITOR)) //20%
			company = /datum/corporation/gorlex //Should not double wammy the corporate introduction, I hope
			owner.special_role = TRAITOR_AGENT_ROLE
			special_role = TRAITOR_AGENT_SROLE
			marauder = TRUE
			forge_single_objective()
			greentext_achieve = /datum/achievement/greentext/external

/datum/antagonist/traitor/internal_affairs/forge_traitor_objectives()
	forge_iaa_objectives()

	var/objtype = traitor_kind == TRAITOR_HUMAN ? /datum/objective/escape : /datum/objective/survive
	var/datum/objective/escape_objective = new objtype
	escape_objective.owner = owner
	add_objective(escape_objective)

/datum/antagonist/traitor/internal_affairs/proc/greet_iaa()
	to_chat(owner.current, span_userdanger("You are the [special_role]."))
	if(!marauder)
		to_chat(owner.current, span_userdanger("An intel leak suggests that operatives on this station have been turned by Nanotrasen. For now, your target is the only confirmed turncoat."))
		to_chat(owner.current, "<B><font size=5 color=red>Any apparent damage you cause may draw early suspicion to an intelligence leak. Limit collateral damage to avoid this.</font></B>") //yogs - murderbone rule exists, apparently
		to_chat(owner.current, span_userdanger("You have been provided with a standard uplink to accomplish your task."))
	else
		to_chat(owner.current, span_userdanger("You have been granted a chance to rejoin the Gorlex ranks, despite your dishonorable behavior. Complete this small task and eliminate every other Syndicate agent on the station to prove yourself. Your listed target is the first of many."))
		to_chat(owner.current, "<B><font size=5 color=red>Unnecessary collateral damage will condemn yourself. Keep your destructive force focused on your targets, or you will fail this trial.</font></B>")
		to_chat(owner.current, span_userdanger("We have given you a standard uplink for tools in your glorious hunt. Use them well, use them cunningly."))

	to_chat(owner.current, span_userdanger("Your target still likely has an uplink of their own, and other agents may be moving to eliminate you, if your identity has been compromised. Be careful, and watch your back."))
	owner.announce_objectives()

/datum/antagonist/traitor/internal_affairs/greet()
	greet_iaa()

#undef PROB_ACTUAL_TRAITOR
#undef PINPOINTER_EXTRA_RANDOM_RANGE
#undef PINPOINTER_MINIMUM_RANGE
#undef PINPOINTER_PING_TIME
