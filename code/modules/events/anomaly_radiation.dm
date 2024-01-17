/datum/round_event_control/anomaly/anomaly_radiation
	name = "Anomaly: Radiation"
	typepath = /datum/round_event/anomaly/anomaly_radiation

	max_occurrences = 7
	weight = 20

/datum/round_event/anomaly/anomaly_radiation
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/radiation

/datum/round_event/anomaly/anomaly_radiation/announce(fake)
	if(prob(90))
		priority_announce("Large radiation pulse detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
	else
		print_command_report("Large radiation pulse detected on long range scanners. Expected location: [impact_area.name].", "Radioactive anomaly")
