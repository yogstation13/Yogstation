/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 2

/datum/round_event/radiation_storm/start()
	priority_announce("High levels of radiation detected near the station. Maintenance is best shielded from radiation.", "Anomaly Alert", ANNOUNCER_RADIATION)
	SSweather.run_weather(/datum/weather/rad_storm)
