SUBSYSTEM_DEF(augury)
	name = "Augury"
	flags = SS_NO_INIT | SS_NO_FIRE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/doombringers = list()

	var/list/observers_given_action = list()

/datum/controller/subsystem/augury/stat_entry(msg)
	msg = "D:[length(doombringers)]"
	return ..()

/datum/controller/subsystem/augury/proc/register_doom(atom/A, severity)
	doombringers[A] = severity
	if(doombringers.len == 1) // New debris show button
		for(var/i in GLOB.player_list)
			if(isobserver(i) && (!(observers_given_action[i])))
				var/datum/action/innate/augury/Action = new
				Action.Grant(i)
				observers_given_action[i] = TRUE

/datum/controller/subsystem/augury/proc/unregister_doom(atom/A)
	doombringers -= A
	if(!doombringers.len)
		for(var/i in observers_given_action)
			if(observers_given_action[i] && isobserver(i))
				var/mob/dead/observer/O = i
				for(var/datum/action/innate/augury/Action in O.actions)
					qdel(Action)
			observers_given_action -= i

/datum/action/innate/augury
	name = "Follow Debris"
	icon_icon = 'icons/obj/meteor.dmi'
	button_icon_state = "flaming"
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

/datum/action/innate/augury/Trigger()
	var/tofollow = pick(SSaugury.doombringers)
	if(tofollow && isobserver(owner)) // nullcheck
		var/mob/dead/observer/O = owner
		O.ManualFollow(tofollow)

