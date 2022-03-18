#define TYPING_INDICATOR_RANGE 7

/mob/proc/get_say()
	create_typing_indicator()
	var/msg = input(src, null, "say \"text\"") as text|null
	remove_typing_indicator()
	say_verb(msg)

/mob
	var/image/typing_overlay
	var/list/speech_bubble_recipients

/mob/proc/create_typing_indicator()
	if(typing_overlay) 
		return
	var/list/listening = get_hearers_in_view(TYPING_INDICATOR_RANGE, src)
	speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client && !(isobserver(src) && !isobserver(M)))
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
