#define CONDITION_SYMPTOM_SEVERITY_ANNOYING 1
#define CONDITION_SYMPTOM_SEVERITY_MILD 2
#define CONDITION_SYMPTOM_SEVERITY_SEVERE 3

/datum/condition_symptom
	var/name = "Condition Symptom"
	var/severity = 0

/datum/condition_symptom/proc/process_effects(var/datum/condition/parent)
	return FALSE
	
/datum/condition_symptom/proc/modify_test_results(var/list/test_results)
	return FALSE
