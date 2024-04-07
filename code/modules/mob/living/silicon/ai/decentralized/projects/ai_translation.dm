#define HEARD_MESSAGES_TO_TRANSLATE 8

/datum/ai_project/translation
	name = "Heuristic Language Translation"
	description = "While running, this program analyzes unknown languages you encounter. After having gathered enough unique uses you will be able to permanently understand the language. Requires 10% CPU power to run"
	research_cost = 1500
	ram_required = 2
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

	var/heard_languages = list()

/datum/ai_project/translation/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	RegisterSignal(ai, COMSIG_MOVABLE_HEAR, PROC_REF(heard_message))
	dashboard.cpu_usage[name] = 0.1

	
/datum/ai_project/translation/proc/heard_message(datum/source, list/hearing_args)
	if(ai.has_language(hearing_args[HEARING_LANGUAGE]))
		return

	var/list/blacklisted_languages = list(
		/datum/language/ratvar,
		/datum/language/codespeak,
		/datum/language/xenocommon,
		/datum/language/vampiric
	)
	if(is_type_in_list(hearing_args[HEARING_LANGUAGE], blacklisted_languages))
		return

	heard_languages[hearing_args[HEARING_LANGUAGE]]++
	if(heard_languages[hearing_args[HEARING_LANGUAGE]] >= HEARD_MESSAGES_TO_TRANSLATE)
		ai.grant_language(hearing_args[HEARING_LANGUAGE], spoken = FALSE)

/datum/ai_project/translation/stop()
	UnregisterSignal(ai, COMSIG_MOVABLE_HEAR)
	dashboard.cpu_usage[name] = 0
	..()

/datum/ai_project/translation/canRun()
	. = ..()
	if(!.)
		return
	var/total_cpu_used = 0
	for(var/I in dashboard.cpu_usage)
		total_cpu_used += dashboard.cpu_usage[I]
	if(total_cpu_used < 0.9)
		return TRUE
	to_chat(ai, span_warning("Unable to run this program. You require 10% free CPU!"))

#undef HEARD_MESSAGES_TO_TRANSLATE
