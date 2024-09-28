/// Sends a message to all dead and observing players, if a source is provided a follow link will be attached.
/proc/send_to_observers(message, source)
	var/list/all_observers = SSgamemode.current_players[CURRENT_DEAD_PLAYERS] + SSgamemode.current_players[CURRENT_OBSERVERS]
	for(var/mob/observer as anything in all_observers)
		if (isnull(source))
			to_chat(observer, "[message]")
			continue
		var/link = FOLLOW_LINK(observer, source)
		to_chat(observer, "[link] [message]")
