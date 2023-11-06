/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	icon = "necrotic_metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 0
	level = 5
	severity = 0

/datum/symptom/undead_adaptation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	A.process_dead = TRUE
	A.infectable_biotypes |= MOB_UNDEAD

/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	icon = "inorganic_biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmittable = 3
	level = 5
	severity = 0
	compatible_biotypes = ALL_BIOTYPES //i don't think this needs to be here, but just in case

/datum/symptom/inorganic_adaptation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	A.infectable_biotypes |= MOB_INORGANIC
	A.infectable_biotypes |= MOB_ROBOTIC
