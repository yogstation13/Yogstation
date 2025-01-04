///basically just a copy of how part of /datum/action/innate works, but as a spell typepath
/datum/action/cooldown/spell/toggle
	/// Whether we're active or not
	var/active = FALSE
	/// An associative list of all resource costs for maintaining this ability
	var/list/maintain_costs
	
/datum/action/cooldown/spell/toggle/New()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/toggle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()
	
/datum/action/cooldown/spell/toggle/Remove(mob/living/remove_from)
	if(active)
		Disable()
	return ..()

/datum/action/cooldown/spell/toggle/process()
	build_all_button_icons(ALL) //so as to be consistent with situational requirements, keep the button updated

	if(active && owner.mind && !bypass_cost && LAZYLEN(maintain_costs))
		for(var/i in maintain_costs)
			if(SEND_SIGNAL(owner.mind, COMSIG_MIND_CHECK_ANTAG_RESOURCE, i, maintain_costs[i]))
				SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, maintain_costs)
				continue
			Activate(owner)
			return FALSE
	return TRUE

/datum/action/cooldown/spell/toggle/cast(atom/cast_on)
	active = !active
	if(active)
		Enable()
	else
		Disable()
	return ..()

/datum/action/cooldown/spell/toggle/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return active

/datum/action/cooldown/spell/toggle/proc/Enable()
	return

/datum/action/cooldown/spell/toggle/proc/Disable()
	return
