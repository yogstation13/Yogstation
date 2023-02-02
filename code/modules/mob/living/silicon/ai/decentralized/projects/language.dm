/datum/ai_project/language_upgrade
	name = "Language Processing Upgrade"
	description = "Through brute force neural processing through several audio recordings and books written in other languages, you can learn common languages."
	research_cost = 4000
	ram_required = 1
	category = AI_PROJECT_SURVEILLANCE
	var/static/list/common_languages = list(
		/datum/language/bonespeak,
		/datum/language/draconic,
		/datum/language/english,
		/datum/language/etherean,
		/datum/language/felinid,
		/datum/language/mothian,
		/datum/language/polysmorph,
		/datum/language/sylvan
	)

/datum/ai_project/language_upgrade/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	for(var/datum/language/lang in common_languages)
		ai.grant_language(lang, TRUE, TRUE, LANGUAGE_SOFTWARE)

/datum/ai_project/language_upgrade/stop()
	ai.remove_all_languages(LANGUAGE_SOFTWARE)
	..()


