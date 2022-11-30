#define HEARD_MESSAGES_TO_TRANSLATE 8

/datum/ai_project/translation
	name = "Heuristic Language Translation"
	description = "While running this program analyzes unknown languages you encounter. After having gathered enough unique uses you will be able to permanently understand the language."
	research_cost = 1500
	ram_required = 2
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

	var/heard_languages = list()

/datum/ai_project/translation/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	RegisterSignal(ai, COMSIG_MOVABLE_HEAR, .proc/heard_message)

	
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
	..()

#undef HEARD_MESSAGES_TO_TRANSLATE
