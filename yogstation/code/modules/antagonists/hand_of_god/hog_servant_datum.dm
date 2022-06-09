/datum/antagonist/hog
	name = "Generic HoG servant"   ///Because i plan to make guys have different datums, so... you know
	roundend_category = "HoG Cultists"
	antagpanel_category = "HoG Cult"
	var/hud_type = "dude"
	var/datum/team/hog_cult/cult
	var/list/god_actions = list() 
	var/farewell = "Blahblahblah"

//Damn magic gangs

/datum/antagonist/hog/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/hog/get_team()
	return cult

/datum/antagonist/gang/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just returned a part of themselfes!")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("farewell"))
