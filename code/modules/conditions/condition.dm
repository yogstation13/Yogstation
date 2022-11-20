#define CONDITION_SOURCE_GENETIC 0
#define CONDITION_SOURCE_BODY	 1
#define CONDITION_SOURCE_IMMUNE  2

/datum/condition
	var/name = "Default Condition Name" //The name of your condition
	var/stage = 0
	var/max_stage = 0
	var/source = CONDITION_SOURCE_GENETIC
	var/list/datum/condition_symptom/symptoms = list()

/datum/condition/proc/is_cured(var/mob/living/carbon/human/H)
	return FALSE

/datum/condition/proc/modify_test_results(var/list/test_results)
	for (var/datum/condition_symptom/symptom in symptoms)
		symptom.modify_test_results(test_results)
	return FALSE

/datum/condition/proc/tick(var/mob/living/carbon/human/H)
	return FALSE
