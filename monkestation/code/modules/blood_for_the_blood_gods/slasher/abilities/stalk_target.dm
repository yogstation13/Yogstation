/datum/action/cooldown/slasher/stalk_target
	name = "Stalk Target"
	desc = "Get a target to stalk, standing near them for 3 minutes will rip their soul from their body. YOU MUST PROTECT THEM FROM HARM."

	button_icon_state = "slasher_possession"

	cooldown_time = 5 MINUTES

/datum/action/cooldown/slasher/stalk_target/Activate(atom/target)
	. = ..()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/possible_target as anything in GLOB.player_list)
		if(!possible_target.mind)
			continue
		if(possible_target == owner.mind)
			continue
		if(!ishuman(possible_target))
			continue
		if(possible_target.stat == DEAD)
			continue
		if(!is_station_level(possible_target.z))
			continue
		if(possible_target.soul_sucked == TRUE)
			continue
		if(istype(possible_target, /datum/species/abductor)) //prevents abductors being chosen, they can't be spooked.
			continue
		if(possible_target.ssd_indicator == TRUE) //ssd people can't be spooked.
			continue
		possible_targets += possible_target

	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	slasherdatum.stalk_precent = 0
	if(slasherdatum && slasherdatum.stalked_human)
		slasherdatum.stalked_human.tracking_beacon.Destroy()
		var/datum/component/team_monitor/owner_monitor = owner.mind.current.team_monitor
		owner_monitor.hide_hud()

	var/mob/living/living_target = pick(possible_targets)
	var/mob/living/carbon/human/owner_human = owner
	if(!owner_human.team_monitor)
		owner_human.tracking_beacon = owner_human.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#00660e")
		owner_human.team_monitor = owner_human.AddComponent(/datum/component/team_monitor, "slasher", null, owner_human.tracking_beacon)

	living_target.tracking_beacon = living_target.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#660000")
	if(slasherdatum)
		slasherdatum.stalked_human = living_target
	owner_human.team_monitor.add_to_tracking_network(living_target.tracking_beacon)
	owner_human.team_monitor.show_hud(owner_human)

	if(living_target)
		to_chat(owner, span_notice("Your new target is [living_target]."))

		var/datum/antagonist/slasher/set_slasherdatum = slasherdatum
		living_target.apply_status_effect(/datum/status_effect/slasher/stalking, set_slasherdatum)
		owner_human.apply_status_effect(/datum/status_effect/slasher/stalker)
	if(living_target == null)
		to_chat(owner, span_notice("No target found."))






