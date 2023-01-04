/client/proc/queue_check()
	set category = "Server"
	set name = "List Server Queue"
	set desc = "Gives a list of all the people who are waiting in the queue to join the game."

	if(!check_rights(R_ADMIN))
		return
	
	listclearnulls(SSticker.queued_players)
	to_chat(usr,span_notice("<b>List of queued players:</b>"), confidential=TRUE)
	for(var/mob/dead/new_player/guy in SSticker.queued_players)
		to_chat(usr,"\t[guy]", confidential=TRUE)

/client/proc/release_queue()
	set category = "Server"
	set name = "Free Server Queue"
	set desc = "Allows everyone in the current queue to play the game."
	
	if(!check_rights(R_SERVER))
		return
	
	listclearnulls(SSticker.queued_players)
	var/list/queue = SSticker.queued_players
	
	if(!queue.len)
		to_chat(usr,span_warning("There is nobody in the server queue!"), confidential=TRUE)
		return
	
	if(alert("Are you sure you want to allow [queue.len] people to skip the queue and join the game?",,"Yes","No") != "Yes")
		return
	
	//Below is basically a clone of whatever's in that one part of check_queue()
	for (var/mob/dead/new_player/NP in queue)
		to_chat(NP, span_userdanger("The alive players limit has been released!<br><a href='?src=[REF(NP)];late_join=override'>[html_encode(">>Join Game<<")]</a>"))
		SEND_SOUND(NP, sound('sound/misc/notice1.ogg'))
		GLOB.latejoin_menu.ui_interact(NP)
	queue.len = 0
	SSticker.queue_delay = 0
