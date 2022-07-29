/client/proc/dsay(msg as text)
	set category = "Misc.Unused"
	set name = "Dsay"
	set hidden = TRUE
	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential=TRUE)
		return
	if(!mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, span_danger("You cannot send DSAY messages (muted)."), confidential=TRUE)
		return

	if (handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	mob.log_talk(msg, LOG_DSAY)

	if (!msg)
		return
	var/rank_name = holder.rank
	var/admin_name = key
	var/follow_link = ""
	if(holder.fakekey)
		rank_name = holder.fakekey
		admin_name = holder.fakename
		follow_link = "<a href=\"\">(F)</a> "
	var/rendered = "<span class='game deadsay'>[follow_link][span_prefix("DEAD:")] [span_name("([rank_name]) [admin_name]")] says, [span_message("\"[emoji_parse(msg)]\"")]</span>"

	for (var/mob/M in GLOB.player_list)
		if(isnewplayer(M) && !(M.client && M.client.holder)) // Yogs -- Allows admins to hear admin deadsay while in the lobby
			continue
		if (M.stat == DEAD || (M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD))) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			to_chat(M, rendered)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dead_say()
	// yogs start - Cancel button
	var/msg = input(src, null, "dsay \"text\"") as text|null
	if(msg)
		msg = to_utf8(msg, src)
		dsay(msg)
	// yogs end
