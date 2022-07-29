/datum/round_event_control/balm
	name = "Psi Balm"
	typepath = /datum/round_event/psi/balm
	weight = 20
	max_occurrences = 3
	max_alert = SEC_LEVEL_DELTA

/datum/round_event/psi/balm
	var/static/list/balm_messages = list(
		"A soothing balm washes over your psyche.",
		"For a moment, you can hear a distant, familiar voice singing a quiet lullaby.",
		"A sense of peace and comfort falls over you like a warm blanket."
		)

/datum/round_event/psi/balm/apply_psi_effect(var/datum/psi_complexus/psi)
	var/soothed
	if(psi.stun > 1)
		psi.stun--
		soothed = TRUE
	else if(psi.stamina < psi.max_stamina)
		psi.stamina = min(psi.max_stamina, psi.stamina + rand(1,3))
		soothed = TRUE
	else if(psi.owner.getOrganLoss(ORGAN_SLOT_BRAIN) > 0)
		psi.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)
		soothed = TRUE
	if(soothed && prob(10))
		to_chat(psi.owner, span_notice("<i>[pick(balm_messages)]</i>"))
