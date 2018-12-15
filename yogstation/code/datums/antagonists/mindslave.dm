/datum/antagonist/mindslave
	name = "Mindslave"
	show_in_antagpanel = FALSE
	antag_moodlet = /datum/mood_event/focused
	var/master_name
	var/master_ckey

/datum/antagonist/mindslave/antag_panel_data()
	return "<B>Current master: [master_name]/([master_ckey])</B>"