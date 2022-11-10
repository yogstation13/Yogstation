GLOBAL_DATUM_INIT(compsci_vr, /datum/compsci_vr, new)


/datum/compsci_vr
	var/unlocked_missions = list()

	var/roundstart_missions = list()


	var/human_occupant
	var/ai_occupant

	var/emagged = TRUE


/datum/compsci_vr/New()
	. = ..()
	unlocked_missions |= roundstart_missions


/datum/compsci_vr/proc/can_join(mob/user)
	if(ishuman(user) && human_occupant)
		return FALSE
	if(isAI(user) && ai_occupant)
		return FALSE

/datum/compsci_vr/proc/emag(mob/user)
	emagged = TRUE
