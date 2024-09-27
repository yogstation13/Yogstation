///a changeling that has lost their powers. does nothing, other than signify they suck
/datum/antagonist/fallen_changeling
	name = "\improper Fallen Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	job_rank = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/fallen_changeling
	antag_hud_name = "changeling"
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE // monkestation addition

/datum/mood_event/fallen_changeling
	description = "My powers! Where are my powers?!"
	mood_change = -4

