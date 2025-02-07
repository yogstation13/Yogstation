/mob/living/simple_animal/bot/secbot/beepsky/big
	name = "Officer Bigsky"
	desc = "It's Commander Beep O'sky's massive, just-as aggressive cousin, Bigsky."
	health = 150
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED
	commissioned = FALSE

/mob/living/simple_animal/bot/secbot/beepsky/big/Initialize(mapload)
	. = ..()
	update_transform(1.3)
