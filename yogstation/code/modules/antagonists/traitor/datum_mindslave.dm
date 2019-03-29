/datum/antagonist/mindslave
	name = "Mindslave"
	antagpanel_category = "Mindslave"
	job_rank = ROLE_TRAITOR
	show_in_antagpanel = FALSE
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER
	var/mob/living/carbon/master

/datum/objective/mindslave
	name = "Mindslave Objective"
	martyr_compatible = TRUE
	completed = TRUE
	explanation_text = "Serve your master no matter what!"