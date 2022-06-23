/datum/action/innate/pray
	name = "Talk to your God"
	button_icon_state = "godspeak"
	
/datum/action/innate/pray/IsAvailable()
	if(..())
		if(IS_HOG_CULTIST(owner))
			return 1
		return 0

/datum/action/innate/pray/Activate()
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(owner)
	if(!cultie)
		return
	if(!cultie.cult.god || !cultie.cult)
		to_chat(owner, span_warning("You don't have any god to pray to!"))
		return
	var/msg = input(owner,"Speak to your god","pray","") as null|text
	if(!msg)
		return
	to_chat(owner, span_notice("You pray to your god: [msg]"))
	to_chat(cultie.cult.god, span_cult("[owner] prays to you: [msg]"))