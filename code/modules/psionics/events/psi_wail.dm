/datum/round_event_control/wail
	name = "Psi Wail"
	typepath = /datum/round_event/psi/wail
	weight = 20
	max_occurrences = 3
	max_alert = SEC_LEVEL_DELTA

/datum/round_event/psi/wail
	var/static/list/whine_messages = list(
		"A nerve-tearing psychic whine intrudes on your thoughts.",
		"A horrible, distracting humming sound breaks your train of thought.",
		"Your head aches as a psychic wail intrudes on your psyche."
		)

/datum/round_event/psi/wail/apply_psi_effect(var/datum/psi_complexus/psi)
	var/annoyed
	if(prob(1))
		psi.stunned(1)
		annoyed = TRUE
	else if(prob(10))
		psi.adjust_heat(rand(1,3))
		annoyed = TRUE
	else if(psi.stamina)
		psi.adjust_stamina(-rand(1,3))
		annoyed = TRUE
	if(annoyed && prob(1))
		to_chat(psi.owner, span_notice("<i>[pick(whine_messages)]</i></span>"))
