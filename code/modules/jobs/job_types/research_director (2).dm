/datum/job/rd
	exp_requirements = 720
	
	minimal_character_age = 26 // "A PhD takes twice as long as a bachelor's degree to complete. The average student takes 8.2 years to slog through a PhD program and is 33 years old before earning that top diploma."

/datum/job/rd/New()
	access += ACCESS_CAPTAIN
	return ..()
