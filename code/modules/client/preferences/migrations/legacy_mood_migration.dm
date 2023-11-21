/datum/preferences/proc/migrate_yog_legacy_toggles(savefile/savefile)
	write_preference(GLOB.preference_entries[/datum/preference/toggle/quiet_mode], yogtoggles & 1<<0)
	write_preference(GLOB.preference_entries[/datum/preference/toggle/mood_enabled], yogtoggles & 1<<1)
