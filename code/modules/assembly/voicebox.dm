#define VOICEBOX_OPTION_ADD "(ADD NEW)"
#define VOICEBOX_OPTION_CLEAR "(CLEAR ALL)"
#define VOICEBOX_OPTION_CLOSE "(CLOSE)"

/obj/item/assembly/voice_box
	name = "voice box"
	desc = "A device that says a message when activated. Often used in toys."
	icon_state = "control"

	/// List of messages, a random one will be selected when arctivated
	var/list/messages
	/// How long before another message can be sent
	var/cooldown_time = 0 SECONDS

/obj/item/assembly/voice_box/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	edit_mode(user)
	
/obj/item/assembly/voice_box/proc/edit_mode(mob/living/user)
	var/keep_open = TRUE
	var/list/choices
	var/list/menu_choices = list(VOICEBOX_OPTION_ADD, VOICEBOX_OPTION_CLEAR, VOICEBOX_OPTION_CLOSE)
	while(keep_open)
		choices = messages ? sortList(messages.Copy(), /proc/cmp_text_asc) : list()
		LAZYADD(choices, menu_choices)
		var/choice = sanitize_inlist(input("Select message to edit", "Edit Voicebox Messages") as null|anything in choices, choices, VOICEBOX_OPTION_CLOSE)

		switch(choice)
			if(VOICEBOX_OPTION_CLOSE)
				keep_open = FALSE
			if(VOICEBOX_OPTION_CLEAR)
				if(tgui_alert(user, "Are you sure you want to clear all messages?",, list("Yes", "No")) == "Yes")
					messages = list()
			else
				if(choice == VOICEBOX_OPTION_ADD)
					choice = "Hello"
				else
					LAZYREMOVE(messages, choice)
				var/new_message = sanitize(stripped_input(user, "What would you like the new message to be?", "[src]", choice, MAX_MESSAGE_LEN))
				if(isnotpretty(new_message)) // This proc has an awful name
					message_admins("[ADMIN_LOOKUPFLW(user)] just attempted to add a bad message to a voice box: '[new_message]'")
					to_chat(user, span_warning("Invalid message!"))
				else if(new_message in menu_choices)
					to_chat(user, span_warning("Invalid message!"))
				else if(new_message in messages)
					to_chat(user, span_warning("Message already exists!"))
				else
					LAZYADD(messages, new_message)
					to_chat(user, span_notice("\"[new_message]\" added to message list."))
					log_game("[key_name(user)] added a new message '[new_message]' to [src]")

	
/obj/item/assembly/voice_box/activate()
	if(TIMER_COOLDOWN_CHECK(src, "message") || !LAZYLEN(messages))
		return
	TIMER_COOLDOWN_START(src, "message", cooldown_time)
	var/atom/movable/speaker = loc
	if(istype(speaker))
		speaker.say(pick(messages))
	else
		say(pick(messages))

	
/obj/item/assembly/voice_box/bow
	cooldown_time = 1 SECONDS
	
// Good god all the below need to be changed
/obj/item/assembly/voice_box/bow/nanotrasen
	messages = list("Death to the Syndicate!!", "Glory to Nanotrasen!!", "Die Syndie scum!!", "Eat hardlight!!")

/obj/item/assembly/voice_box/bow/syndie
	messages = list("Death to Nanotrasen!!", "Glory to the Syndicate!!", "Die NT scum!!", "Eat hardlight!!")

/obj/item/assembly/voice_box/bow/clockwork
	messages = list("For Ratvar!!", "Death to the non-believers!!", "Glory to Ratvar!!")

#undef VOICEBOX_OPTION_ADD
#undef VOICEBOX_OPTION_CLEAR
#undef VOICEBOX_OPTION_CLOSE
