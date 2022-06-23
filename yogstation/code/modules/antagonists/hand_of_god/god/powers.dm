/datum/action/innate/godspeak
	name = "Divine Telephaty"
	button_icon_state = "godspeak"

/datum/action/innate/godspeak/IsAvailable()
	if(..())
		if(istype(owner, /mob/camera/hog_god))
			return 1
		return 0

/datum/action/innate/godspeak/Activate()
    var/datum/antagonist/hog/god = IS_HOG_CULTIST(owner)
    if(!god)
        return
	var/msg = input(owner,"Speak to your servants","Divine Telephaty","") as null|text
	if(!msg)
		return
    god.cult.message_all_dudes("<span class='cultlarge'><b>[owner]: [msg]</b></span>", FALSE)