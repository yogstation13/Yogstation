/datum/action/innate/god

/datum/action/innate/god/IsAvailable()
	if(..())
		if(istype(owner, /mob/camera/hog_god))
			return 1
		return 0

/datum/action/innate/god/godspeak
	name = "Divine Telephaty"
	button_icon_state = "godspeak"

/datum/action/innate/god/godspeak/Activate()
	var/datum/antagonist/hog/god = IS_HOG_CULTIST(owner)
	if(!god)
		return
	var/msg = input(owner,"Speak to your servants","Divine Telephaty","") as null|text
	if(!msg)
		return
	god.cult.message_all_dudes("<span class='cultlarge'><b>[owner]: [msg]</b></span>", FALSE)

/datum/action/innate/god/nexus
	name = "Jump to Nexus"
	button_icon_state = "nexus"

/datum/action/innate/god/nexus/Activate()
	var/datum/antagonist/hog/god = IS_HOG_CULTIST(owner)
	if(!god)
		return
	if(god.cult.nexus)
		ForceMove(get_turf(god.cult.nexus))
		to_chat(user, span_notice("You jump to your nexus."))
	else
		to_chat(user, span_warning("You don't have any nexus to jump to, you need construct one."))

/datum/action/innate/god/whisper
	name = "Whisper"
	button_icon_state = "whisper"

/datum/action/innate/god/whisper/Activate()
	var/list/dudes = list()
	for(var/mob/living/L in view(7, owner))
		if(!L.mind || !L.client)
			continue
		dudes += L
	var/mob/choice = input("Choose who you wish to whisper to", "Talk to ANYONE") as null|anything in dudes
	if(choice)
		var/msg = input(owner,"Whisper to [choice]","Whisper","") as null|text
		to_chat(choice, span_cult("You hear a voice in your head: [msg]"))

/datum/action/innate/god/place_nexus
	name = "Place nexus"
	button_icon_state = "whisper"

/datum/action/innate/god/place_nexus/Activate()
	var/list/dudes = list()
	for(var/mob/living/L in view(7, owner))
		if(!L.mind || !L.client)
			continue
		dudes += L
	var/mob/choice = input("Choose who you wish to whisper to", "Talk to ANYONE") as null|anything in dudes
	if(choice)
		var/msg = input(owner,"Whisper to [choice]","Whisper","") as null|text
		to_chat(choice, span_cult("You hear a voice in your head: [msg]"))


