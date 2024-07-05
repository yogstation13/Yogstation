/datum/round_event/psi
	startWhen = 30
	endWhen = 120

/datum/round_event/psi/announce()
	priority_announce( \
		"A localized disruption within the neighboring psionic continua has been detected. All psi-operant crewmembers \
		are advised to cease any sensitive activities and report to medical personnel in case of damage.", "Central Command Higher Dimensional Affairs")

/datum/round_event/psi/end()
	priority_announce( \
		"The psi-disturbance has ended and baseline normality has been re-asserted. \
		Anything you still can't cope with is therefore your own problem.", "Central Command Higher Dimensional Affairs")

/datum/round_event/psi/tick()
	for(var/thing in SSpsi.processing)
		apply_psi_effect(thing)

/datum/round_event/psi/proc/apply_psi_effect(var/datum/psi_complexus/psi)
	return
