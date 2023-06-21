/datum/antagonist/infernal_affairs
	name = "Devil Affairs Agent"
	///Reference to the Uplink, so we can mess with it when required.
	var/datum/component/uplink/uplink_holder
	///The active objective this agent has to currently complete.
	var/datum/objective/assassinate/internal/active_objective

/datum/antagonist/infernal_affairs/on_gain(mob/living/mob_override)
	. = ..()
	uplink_holder = owner.equip_traitor(employer = "The Devil" uplink_owner = src)

/datum/antagonist/infernal_affairs/on_removal()
	. = ..()
	QDEL_NULL(uplink_holder)
