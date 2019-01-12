/datum/antagonist/on_gain()
	. = ..()
	log_game("[owner.key] has been selected as a [name] with objectives: ")
	for(var/datum/objective/O in objectives)
		log_game("[O.explanation_text]")
		
/datum/antagonist/shadowling/on_gain()
	SSticker.mode.update_vampire_icons_added(owner)

/datum/antagonist/vampire/on_removal()
	SSticker.mode.update_vampire_icons_removed(owner)