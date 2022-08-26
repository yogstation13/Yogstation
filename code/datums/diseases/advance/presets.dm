// Cold
/datum/disease/advance/cold
	copy_type = /datum/disease/advance

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()

// Flu
/datum/disease/advance/flu
	copy_type = /datum/disease/advance

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()
	
/datum/disease/advance/necropolis
	copy_type = /datum/disease/advance

/datum/disease/advance/necropolis/New()
	name = "Necropolis Seed"
	symptoms = list(new/datum/symptom/necroseed)
	..()

/datum/disease/advance/tumor
	copy_type = /datum/disease/advance

/datum/disease/advance/tumor/New()
	name = "Tumors"
	symptoms = list(new/datum/symptom/tumor,new/datum/symptom/sneeze,new/datum/symptom/fever,new/datum/symptom/shivering,new/datum/symptom/itching,new/datum/symptom/cough)
	..()

/datum/disease/advance/vampirism
	copy_type = /datum/disease/advance

/datum/disease/advance/necropolis/New()
	name = "Hematophagy"
	symptoms = list(/datum/symptom/vampirism)
	..()


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
		if(!initial(S.naturally_occuring))
			continue
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
