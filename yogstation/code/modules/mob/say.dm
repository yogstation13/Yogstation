#define TYPING_INDICATOR_RANGE 7

/mob/proc/get_say()
	create_typing_indicator()
	var/msg = input(src, null, "say \"text\"") as text|null
	remove_typing_indicator()
	say_verb(msg)

/mob
	var/image/typing_overlay
	var/list/speech_bubble_recipients
	var/last_typed
	var/last_typed_time

/mob/proc/handle_typing_indicator()
	if(!GLOB.typing_indicators)
		return
	if(client)
		var/temp = winget(client, "input", "text")
		if(temp != last_typed)
			last_typed = temp
			last_typed_time = world.time
		if(world.time > last_typed_time + 10 SECONDS)
			remove_typing_indicator()
			return
		if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
			create_typing_indicator()
		else if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
			//set_typing_indicator(1)
		else
			remove_typing_indicator()

/mob/proc/create_typing_indicator()
	if(typing_overlay) 
		return
	if(stat)
		return
	var/list/listening = get_hearers_in_view(TYPING_INDICATOR_RANGE, src)
	speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client && !(isobserver(src) && !isobserver(M)) && client.prefs.see_typing_indicators)
			speech_bubble_recipients.Add(M.client)
	var/bubble = "default"
	if(isliving(src))
		var/mob/living/L = src
		bubble = L.bubble_icon
	typing_overlay = image('icons/mob/talk.dmi', src, "[bubble]_talking", FLY_LAYER)
	typing_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/flick_overlay, typing_overlay, speech_bubble_recipients)


/mob/proc/remove_typing_indicator()
	if(!typing_overlay) 
		return
	INVOKE_ASYNC(GLOBAL_PROC, /proc/remove_images_from_clients, typing_overlay, speech_bubble_recipients)
	typing_overlay = null
	speech_bubble_recipients = list()

#undef TYPING_INDICATOR_RANGE
