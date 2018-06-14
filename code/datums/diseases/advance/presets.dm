// Cold
<<<<<<< HEAD
=======
/datum/disease/advance/cold
	copy_type = /datum/disease/advance
>>>>>>> 7bd689c6a3... Fixed randomly generated diseases infinitely looping in New() (#38472)

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()


// Flu
<<<<<<< HEAD
=======
/datum/disease/advance/flu
	copy_type = /datum/disease/advance
>>>>>>> 7bd689c6a3... Fixed randomly generated diseases infinitely looping in New() (#38472)

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()

<<<<<<< HEAD

// Voice Changing

/datum/disease/advance/voice_change/New()
	name = "Epiglottis Mutation"
	symptoms = list(new/datum/symptom/voice_change)
	..()


// Toxin Filter

/datum/disease/advance/heal/New()
	name = "Liver Enhancer"
	symptoms = list(new/datum/symptom/heal)
	..()


// Hallucigen

/datum/disease/advance/hallucigen/New()
	name = "Second Sight"
	symptoms = list(new/datum/symptom/hallucigen)
	..()

// Sensory Restoration

/datum/disease/advance/mind_restoration/New()
	name = "Intelligence Booster"
	symptoms = list(new/datum/symptom/mind_restoration)
	..()

// Sensory Destruction

/datum/disease/advance/narcolepsy/New()
	name = "Experimental Insomnia Cure"
	symptoms = list(new/datum/symptom/narcolepsy)
	..()
=======
//Randomly generated Disease, for virus crates and events
/datum/disease/advance/random
	name = "Experimental Disease"
	copy_type = /datum/disease/advance

/datum/disease/advance/random/New(max_symptoms, max_level = 8)
	if(!max_symptoms)
		max_symptoms = rand(1, VIRUS_SYMPTOM_LIMIT)
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			symptoms += S
	Refresh()

	name = "Sample #[rand(1,10000)]"
>>>>>>> 7bd689c6a3... Fixed randomly generated diseases infinitely looping in New() (#38472)
