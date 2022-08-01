/datum/action/cooldown/flock
	var/datum/flock_command/action = null

/datum/action/cooldown/flock/Trigger()
	if(isflocktrace(owner))
		var/mob/camera/flocktrace/FT = owner
		FT.stored_action = new action

/datum/action/cooldown/flock/IsAvailable()
	return (next_use_time <= world.time) && (isflockdrone(owner) || isflocktrace(owner))

/datum/action/cooldown/flock/talk
	name = "Message Flock"

/datum/action/cooldown/flock/talk/Trigger()
	var/msg = input(owner,"Message your Flock","Communication","") as null|text
	if(!msg)    
		return
	ping_flock(message)

/datum/action/cooldown/flock/ping
	name = "Ping"
	desc = "Alert all sentient flock members to your location, and order non-sentient flockdrones to move to it."

/datum/action/cooldown/flock/ping/Trigger()
	if(get)
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
	name = "Designate Enemy(Click)"
	desc = "Alert your Flock that someone is definitely an enemy of your flock. NPC drones will fire lethal lasers at them regardles of conditions."
	action = 
