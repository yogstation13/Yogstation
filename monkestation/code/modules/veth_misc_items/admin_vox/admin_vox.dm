/client/proc/AdminVOX()
	set name = "VOX"
	set category = "Admin"
	set desc = "Allows unrestricted use of the AI VOX announcement system."

	if(!check_rights(NONE))
		message_admins("[key_name(usr)] attempted to use AdminVOX without sufficient rights.")
		return

	// Prompt message via TGUI
	var/message = tgui_input_text(usr, "Enter your VOX announcement message:", "AdminVOX", encode = FALSE)

	// Check for valid message input
	if(!message || message == "")
		return

	// Process the message for VOX
	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words

	words.len = min(30, length(words))

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB.vox_sounds[word])
			LAZYADD(incorrect_words, word)

	if(LAZYLEN(incorrect_words))
		to_chat(usr, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	// Announce to players on the same Z-level
	var/list/players = list()
	var/turf/ai_turf = get_turf(usr)
	for(var/mob/player_mob in GLOB.player_list)
		var/turf/player_turf = get_turf(player_mob)
		if(is_valid_z_level(ai_turf, player_turf))
			players += player_mob

	minor_announce(capitalize(message), "[usr] announces:", players = players, should_play_sound = FALSE)

	// Play each VOX word for the announcement
	for(var/word in words)
		play_vox_word(word, ai_turf, null)

	// Log the successful announcement
	message_admins("[key_name(usr)] made a VOX announcement: \"[message]\".")
	log_admin("[key_name(usr)] made a VOX announcement: \"[message]\".")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show VOX Announcement")
