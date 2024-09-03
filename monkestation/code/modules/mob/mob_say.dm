/mob/say_dead()
	if(!client?.holder && !GLOB.deadchat_allowed && !QDELETED(src))
		to_chat(src, span_danger("Deadchat is disabled."))
		return

	. = ..()
