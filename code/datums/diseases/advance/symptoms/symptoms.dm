/// # Disease Symptoms
/// Symptoms are the effects that engineered advanced diseases do.
/datum/symptom
	/// Friendly symptom name
	var/name = ""
	/// Basic symptom description
	var/desc = "If you see this something went very wrong."
	/// Asset representing this symptom in Pandemic UI
	var/icon = "symptom.invalid.png"
	/// Descriptions of threshold effects
	var/threshold_descs = list()
	var/stealth = 0
	var/resistance = 0
	var/stage_speed = 0
	var/transmittable = 0
	/// The type level of the symptom. Higher is harder to generate.
	var/level = 0
	/// The severity level of the symptom. Higher is more dangerous.
	var/severity = 0
	/// The hash tag for our diseases, we will add it up with our other symptoms to get a unique id! ID MUST BE UNIQUE!!!
	var/id = ""
	/// Chance of warning the affected mob about this symptom
	var/base_message_chance = 10
	/// If the early warning messages are suppressed or not
	var/suppress_warning = FALSE
	/// Ticks between each activation
	var/next_activation = 0
	var/symptom_delay_min = 1
	var/symptom_delay_max = 1
	/// Can be used to multiply virus effects
	var/power = 1
	/// A neutered symptom has no effect, and only affects statistics.
	var/neutered = FALSE
	var/list/thresholds
	/// True if this symptom can appear from [/datum/disease/advance/proc/GenerateSymptoms]
	var/naturally_occuring = TRUE
	/// Types of mob this symptom should affect.
	/// Checked against [/mob/living/proc/get_process_flags]
	var/compatible_biotypes = MOB_ORGANIC

/datum/symptom/New()
	var/list/S = SSdisease.list_symptoms
	for(var/i = 1; i <= S.len; i++)
		if(type == S[i])
			id = "[i]"
			return
	CRASH("We couldn't assign an ID!")

// Called when processing of the advance disease, which holds this symptom, starts.
/datum/symptom/proc/Start(datum/disease/advance/A)
	if(neutered)
		return FALSE
	next_activation = world.time + rand(symptom_delay_min * 10, symptom_delay_max * 10) //so it doesn't instantly activate on infection
	return TRUE

// Called when the advance disease is going to be deleted or when the advance disease stops processing.
/datum/symptom/proc/End(datum/disease/advance/A)
	if(neutered)
		return FALSE
	return TRUE

/datum/symptom/proc/Activate(datum/disease/advance/A)
	if(neutered)
		return FALSE
	if(world.time < next_activation)
		return FALSE
	if(compatible_biotypes & A.affected_mob.mob_biotypes)
		next_activation = world.time + rand(symptom_delay_min * 10, symptom_delay_max * 10)
		return TRUE

/datum/symptom/proc/on_stage_change(new_stage, datum/disease/advance/A)
	if(neutered)
		return FALSE
	return TRUE

/datum/symptom/proc/Copy()
	var/datum/symptom/new_symp = new type
	new_symp.name = name
	new_symp.id = id
	new_symp.neutered = neutered
	return new_symp

/datum/symptom/proc/generate_threshold_desc()
	return
