/// In the before times, toggles were all stored in one bitfield.
/// In order to preserve this existing data (and code) without massive
/// migrations, this middleware attempts to handle this in a way
/// transparent to the preferences UI itself.
/// In the future, the existing toggles data should just be migrated to
/// individual `/datum/preference/toggle`s.
/datum/preference_middleware/legacy_toggles
	// DO NOT ADD ANY NEW TOGGLES HERE!
	// Use `/datum/preference/toggle` instead.
	var/static/list/legacy_toggles = list(
		"announce_login" = ANNOUNCE_LOGIN,
		"combohud_lighting" = COMBOHUD_LIGHTING,
		"deadmin_always" = DEADMIN_ALWAYS,
		"deadmin_antagonist" = DEADMIN_ANTAGONIST,
		"deadmin_position_head" = DEADMIN_POSITION_HEAD,
		"deadmin_position_security" = DEADMIN_POSITION_SECURITY,
		"deadmin_position_silicon" = DEADMIN_POSITION_SILICON,
		"disable_arrivalrattle" = DISABLE_ARRIVALRATTLE,
		"disable_deathrattle" = DISABLE_DEATHRATTLE,
		"member_public" = MEMBER_PUBLIC,
		"sound_adminhelp" = SOUND_ADMINHELP,
		"sound_ambience" = SOUND_AMBIENCE,
		"sound_announcements" = SOUND_ANNOUNCEMENTS,
		"sound_instruments" = SOUND_INSTRUMENTS,
		"sound_lobby" = SOUND_LOBBY,
		"sound_midi" = SOUND_MIDI,
		"sound_prayers" = SOUND_PRAYERS,
		"sound_ship_ambience" = SOUND_SHIP_AMBIENCE,
		"sound_jukebox" = SOUND_JUKEBOX,
	)

	var/static/list/legacy_extra_toggles = list(
		"split_admin_tabs" = SPLIT_ADMIN_TABS,
		"fast_mc_refresh" = FAST_MC_REFRESH,
	)

	var/static/list/legacy_chat_toggles = list(
		"chat_bankcard" = CHAT_BANKCARD,
		"chat_dead" = CHAT_DEAD,
		"chat_ghostears" = CHAT_GHOSTEARS,
		"chat_ghostpda" = CHAT_GHOSTPDA,
		"chat_ghostradio" = CHAT_GHOSTRADIO,
		"chat_ghostsight" = CHAT_GHOSTSIGHT,
		"chat_ghostwhisper" = CHAT_GHOSTWHISPER,
		"chat_ooc" = CHAT_OOC,
		"chat_prayer" = CHAT_PRAYER,
		"chat_pullr" = CHAT_PULLR,
	)

	var/static/list/legacy_yog_toggles = list(
		"quiet_mode" = QUIET_ROUND,
		"pref_mood" = PREF_MOOD,
	)

/datum/preference_middleware/legacy_toggles/get_character_preferences(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_GAME_PREFERENCES)
		return list()

	var/static/list/admin_only_legacy_toggles = list(
		"admin_ignore_cult_ghost",
		"announce_login",
		"combohud_lighting",
		"deadmin_always",
		"deadmin_antagonist",
		"deadmin_position_head",
		"deadmin_position_security",
		"deadmin_position_silicon",
		"sound_adminhelp",
		"sound_prayers",
	)

	var/static/list/admin_only_extra_toggles = list(
		"split_admin_tabs",
		"fast_mc_refresh",
	)

	var/static/list/admin_only_chat_toggles = list(
		"chat_dead",
		"chat_prayer",
	)

	var/static/list/donor_only_yog_toggles = list(
		"quiet_mode",
	)

	var/static/list/deadmin_flags = list(
		"deadmin_antagonist",
		"deadmin_position_head",
		"deadmin_position_security",
		"deadmin_position_silicon",
	)

	var/list/new_game_preferences = list()
	var/is_admin = is_admin(user.client)
	var/is_donor = is_donator(user.client)

	for (var/toggle_name in legacy_toggles)
		if (!is_admin && (toggle_name in admin_only_legacy_toggles))
			continue

		if (is_admin && (toggle_name in deadmin_flags) && (preferences.toggles & DEADMIN_ALWAYS))
			continue

		if (toggle_name == "member_public" && !preferences.unlock_content)
			continue

		new_game_preferences[toggle_name] = (preferences.toggles & legacy_toggles[toggle_name]) != 0
	
	for (var/toggle_name in legacy_extra_toggles)
		if (!is_admin && (toggle_name in admin_only_extra_toggles))
			continue

		new_game_preferences[toggle_name] = (preferences.extra_toggles & legacy_extra_toggles[toggle_name]) != 0

	for (var/toggle_name in legacy_chat_toggles)
		if (!is_admin && (toggle_name in admin_only_chat_toggles))
			continue

		new_game_preferences[toggle_name] = (preferences.chat_toggles & legacy_chat_toggles[toggle_name]) != 0
	
	for (var/toggle_name in legacy_yog_toggles)
		if (!is_donor && (toggle_name in donor_only_yog_toggles))
			continue

		new_game_preferences[toggle_name] = (preferences.yogtoggles & legacy_yog_toggles[toggle_name]) != 0

	return list(
		PREFERENCE_CATEGORY_GAME_PREFERENCES = new_game_preferences,
	)

/datum/preference_middleware/legacy_toggles/pre_set_preference(mob/user, preference, value)
	var/legacy_flag = legacy_toggles[preference]
	if (!isnull(legacy_flag))
		if (value)
			preferences.toggles |= legacy_flag
		else
			preferences.toggles &= ~legacy_flag

		// I know this looks silly, but this is the only one that cares
		// and NO NEW LEGACY TOGGLES should ever be added.
		if (legacy_flag == SOUND_LOBBY)
			if (value && isnewplayer(user))
				user.client?.playtitlemusic()
			else
				user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

		return TRUE

	var/legacy_chat_flag = legacy_chat_toggles[preference]
	if (!isnull(legacy_chat_flag))
		if (value)
			preferences.chat_toggles |= legacy_chat_flag
		else
			preferences.chat_toggles &= ~legacy_chat_flag

		return TRUE
	
	var/legacy_yog_flag = legacy_yog_toggles[preference]
	if (!isnull(legacy_yog_flag))
		if (value)
			preferences.yogtoggles |= legacy_yog_flag
		else
			preferences.yogtoggles &= ~legacy_yog_flag

		return TRUE

	return FALSE
