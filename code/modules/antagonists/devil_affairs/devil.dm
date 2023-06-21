/datum/antagonist/devil
	name = "Devil"
	greentext_achieve = /datum/achievement/greentext/devil
	///The amount of souls the devil has so far.
	var/souls = 0

/datum/antagonist/devil/on_gain()
	. = ..()
	SSinfernal_affairs.devils += src
	RegisterSignal(SSinfernal_affairs, COMSIG_ON_SOUL_HARVESTED, PROC_REF(on_soul_harvest))

/datum/antagonist/devil/on_removal()
	UnregisterSignal(SSinfernal_affairs, COMSIG_ON_SOUL_HARVESTED)
	SSinfernal_affairs.devils -= src
	return ..()

/datum/antagonist/devil/proc/on_soul_harvest(atom/source, datum/antagonist/infernal_affairs/harvested_agent)
	SIGNAL_HANDLER
	if(harvested_agent.owner.current.stat != DEAD)
		return
	ADD_TRAIT(harvested_agent.owner, TRAIT_HELLBOUND, DEVIL_TRAIT)
	souls++
	SSinfernal_affairs.update_objective_datums()
