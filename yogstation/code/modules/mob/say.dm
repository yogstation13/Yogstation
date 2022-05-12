#define TYPING_INDICATOR_RANGE 7

/mob/proc/get_say()
	create_typing_indicator()
	window_typing = TRUE
	var/msg = input(src, null, "say \"text\"") as text|null
	window_typing = FALSE
	remove_typing_indicator()
	say_verb(msg)

/mob
	var/image/typing_overlay
	var/list/speech_bubble_recipients
	var/last_typed
	var/last_typed_time
	var/window_typing = FALSE
	var/bar_typing = FALSE

/mob/proc/handle_typing_indicator()
	INVOKE_ASYNC(src,.proc/typing_indicator_process)

/mob/proc/typing_indicator_process()
	if(!GLOB.typing_indicators)
		return
	if(client)
		var/temp = winget(client, "input", "text")
		if(temp != last_typed)
			last_typed = temp
			last_typed_time = world.time
		if(world.time > last_typed_time + 10 SECONDS)
			bar_typing = FALSE
			remove_typing_indicator()
			return
		if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
			create_typing_indicator()
			bar_typing = TRUE
		else if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
			//set_typing_indicator(1)
		else
			bar_typing = FALSE
			remove_typing_indicator()
			

/mob/proc/create_typing_indicator()
	if(typing_overlay) 
		return
	if(stat)
		return
	var/list/listening = get_hearers_in_view(TYPING_INDICATOR_RANGE, src)
	speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client && M.client.prefs.chat_toggles & CHAT_TYPING_INDICATOR)
			speech_bubble_recipients.Add(M.client)
	var/bubble = "default"
	if(isliving(src))
		var/mob/living/L = src
		bubble = L.bubble_icon
	typing_overlay = image('yogstation/icons/mob/talk.dmi', src, "[bubble]_talking", FLY_LAYER)
	typing_overlay.appearance_flags = APPEARANCE_UI
	typing_overlay.invisibility = invisibility
	typing_overlay.alpha = alpha
	for(var/client/C in speech_bubble_recipients)
		C.images += typing_overlay


/mob/proc/remove_typing_indicator()
	if(!typing_overlay) 
		return
	if(window_typing || bar_typing)
		return
	for(var/client/C in speech_bubble_recipients)
		C.images -= typing_overlay
	typing_overlay = null
	speech_bubble_recipients = list()

/mob/camera/handle_typing_indicator() //RIP in piece camera mobs
	return

/mob/camera/create_typing_indicator()
	return

/mob/camera/remove_typing_indicator()
	return
	

#undef TYPING_INDICATOR_RANGE
