/datum/action/cooldown/flock
	var/datum/flock_command/action = null
	var/messg = "Uhh you will do nothing cry about it"

/datum/action/cooldown/flock/Trigger()
	if(isflocktrace(owner))
		var/mob/camera/flocktrace/FT = owner
		if(FT.stored_action)
			if(istype(FT.stored_action, action.type))
				qdel(FT.stored_action)
				FT.stored_action = null
				to_chat(owner, span_warning("You cancell your current action."))
				return
			qdel(FT.stored_action)
			FT.stored_action = null			
		FT.stored_action = new action(FT)
	else
		return

/datum/action/cooldown/flock/IsAvailable()
	return (next_use_time <= world.time) && (isflockdrone(owner) || isflocktrace(owner))

/datum/action/cooldown/flock/talk
	name = "Message Flock"

/datum/action/cooldown/flock/talk/Trigger()
	var/msg = input(owner,"Message your Flock","Communication","") as null|text
	if(!msg)
		return
	ping_flock(msg, owner)

/datum/action/cooldown/flock/ping
	name = "Ping"
	desc = "Alert all sentient flock members to your location, and order non-sentient flockdrones to move to it."

/datum/action/cooldown/flock/ping/Trigger()
	var/message = "[owner] requests presence of members of the Flock to [get_area(owner)]"
	ping_flock(message)
	var/turf/T = get_turf(owner)
	if(!is_station_level(T.z))
		to_chat(owner, span_warning("You can't do this if not on the station Z-level!"))
		return
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/flockdrone/FD in GLOB.mob_list)
		if(isturf(FD.loc) && get_dist(FD, T) <= 35 && !FD.key)
			FD.LoseTarget()
			FD.Goto(pick(surrounding_turfs), FD.move_to_delay)

/datum/action/cooldown/flock/eject
	name = "Eject"
	desc = "Leave your current vessel."

/datum/action/cooldown/flock/eject/Trigger()
	if(!isflockdrone(owner))
		to_chat(owner, span_warning("You are not in a flockdrone!"))
		return
	var/mob/living/simple_animal/hostile/flockdrone/FD = owner
	FD.EjectPilot()

/datum/action/cooldown/flock/eject
	name = "Designate Enemy"
	desc = "Alert your Flock that someone is definitely an enemy of your flock. NPC drones will fire lethal lasers at them regardles of conditions."
	action = /datum/flock_command/enemy_of_the_flock

/datum/action/cooldown/flock/flocktrace
	name = "Partition Mind"
	desc = "Alert your Flock that someone is definitely an enemy. NPC drones will fire lethal lasers at them regardles of conditions."
	cooldown_time = 60 SECONDS
	var/waiting = FALSE

/datum/action/cooldown/flock/flocktrace/Trigger()
	if(waiting || !isflockmind(owner))
		return
	waiting = TRUE
	to_chat(owner, span_notice("You attempt to summon a Flocktrace..."))
	var/list/candidates = pollGhostCandidates("Do you want to play as a flocktrace?", ROLE_FLOCKMEMBER)
	if(!candidates.len)
		waiting = FALSE
		to_chat(owner, span_warning("You fail to summon a Flocktrace. Maybe try again later?"))
		return
	
	var/mob/dead/selected = pick(candidates)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/camera/flocktrace/FT = new (get_turf(owner))
	player_mind.transfer_to(FT)
	player_mind.assigned_role = "Flocktrace"
	player_mind.special_role = "Flocktrace"
	var/datum/team/flock/team = get_flock_team(owner)
	team.add_member(player_mind)
	message_admins("[ADMIN_LOOKUPFLW(FT)] has been made into a Flocktrace by [ADMIN_LOOKUPFLW(owner)]'s [name] ability.")
	log_game("[key_name(FT)] was spawned as a Flocktrace by [key_name(owner)]'s [name] ability.")
	waiting = FALSE
	StartCooldown()

/datum/action/cooldown/flock/repair_burst
	name = "Concentrated Repair Burst"
	desc = "Fully heal a drone through acceleration of its repair processes."
	action = /datum/flock_command/repair
	cooldown_time = 20 SECONDS

/datum/action/cooldown/flock/door_open
	name = "Gatecrash"
	desc = "Open any non-bolted and AI controlable airlocks near you."
	cooldown_time = 10 SECONDS

/datum/action/cooldown/flock/door_open/Trigger()
	var/list/targets = list()
	for(var/obj/machinery/door/airlock/A in range(10, get_turf(owner)))
		if(A.canAIControl())
			targets += A
	if(length(targets))
		playsound(owner, 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		to_chat(owner, span_notice("You force open all the airlocks around you."))
		StartCooldown()
		sleep(1.5 SECONDS)
		for(var/obj/machinery/door/airlock/A in targets)
			A.open()
	else
		to_chat(owner, span_warning("There is no valid airlocks around you."))
		return
/datum/action/cooldown/flock/radio_stun
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone nearby. Will not work on broken or non-existent headsets. Ear protection reduce the effect."
	cooldown_time = 20 SECONDS

/datum/action/cooldown/flock/radio_stun/Trigger()
	var/list/targets = list()
	for(var/mob/living/L in range(10, owner))
		if(HAS_TRAIT(L, TRAIT_DEAF))
			continue
		if(L.stat == DEAD)
			continue
		var/obj/item/radio/headset/H = L.get_item_by_slot(ITEM_SLOT_EARS)
		if(H && H.on && H.listening && istype(H))
			targets += L
	if(length(targets))
		playsound(owner, 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		to_chat(owner, span_notice("You transmit the worst static you can weave into the headsets around you."))
		StartCooldown()
		for(var/mob/living/L in targets)
			var/distance = max(0,get_dist(get_turf(owner), get_turf(L)))
			if(L.soundbang_act(1, 20/max(1,distance), rand(1, 5)))
				L.Paralyze(max(150/max(1,distance), 60))
				to_chat(L, span_userdanger("Horrifying static bursts into your headset, disorienting you severely!"))
				playsound(L, pick(list('sound/effects/radio_sweep1.ogg','sound/effects/radio_sweep2.ogg','sound/effects/radio_sweep3.ogg','sound/effects/radio_sweep4.ogg','sound/effects/radio_sweep5.ogg')), 100, 1)
	else
		to_chat(owner, span_warning("There is no valid targets around you."))

/datum/action/cooldown/flock/radio_talk
	name = "Narrowbeam Transmission"
	desc = "Directly send a transmission to a target's radio headset or a radio device."
	action = /datum/flock_command/talk
	cooldown_time = 20 SECONDS