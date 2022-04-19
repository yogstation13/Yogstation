/datum/antagonist/servant
	name = "\improper Servant"
	show_in_antagpanel = TRUE
	roundend_category = "servants"
	antagpanel_category = "King"
	can_hijack = HIJACK_NEUTRAL
	show_to_ghosts = FALSE
	var/datum/antagonist/king/master
/datum/antagonist/servant/on_gain()
	if(master)
		var/datum/antagonist/king/kingdatum = master.owner.has_antag_datum(/datum/antagonist/king)
		if(kingdatum)
			kingdatum.servants |= src
		owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has become a servant of [master.owner.current]!", LOG_ATTACK, color="#960000")
	if(owner.dna?.species != /datum/species/human)
		owner.current.grant_language(/datum/language/english) //Yes.
	update_servant_icons_added(owner.current)
	. = ..()

/datum/antagonist/servant/on_removal()
	if(master && master.owner)
		master.servants -= src
		owner.enslaved_to = null
	/// Remove Language & Hud
	if(owner.dna?.species != /datum/species/human)
		owner.current.remove_language(/datum/language/english)
	update_servant_icons_removed(owner.current)
	return ..()





























/datum/antagonist/servant/knight
	name = "\improper Knight"
	roundend_category = "Knight"
	antagpanel_category = "King"
	can_hijack = HIJACK_HIJACKER

