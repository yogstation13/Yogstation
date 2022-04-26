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
	var/mob/living/carbon/human/user = owner
	if(!(user.dna.species == /datum/species/human))
		user.grant_language(/datum/language/english) //Yes.
		owner.current.grant_language(/datum/language/english) //Yes.
	update_servant_icons_added(owner.current)
	. = ..()

/datum/antagonist/servant/on_removal()
	if(master && master.owner)
		master.servants -= src
		owner.enslaved_to = null
	/// Remove Language & Hud
	var/mob/living/carbon/human/user = owner
	if(!(user.dna.species == /datum/species/human))
		user.grant_language(/datum/language/english) //Yes.
		owner.current.remove_language(/datum/language/english)
	update_servant_icons_removed(owner.current)
	return ..()

/datum/antagonist/servant/greet()
	. = ..()
	to_chat(owner, span_userdanger("You are now the servant of [master.owner.current], the King"))
	to_chat(owner, span_boldannounce("[master.owner.current] is the only true King, the other kings and the chain of command are the false rulers, so your king's will has the greatest priority for you."))
	antag_memory += "You are the servant of <b>[master.owner.current]</b>, the King!<br>"
	/// Message told to your King.
	to_chat(master.owner, span_userdanger("[owner.current] has become your servant."))

/datum/antagonist/servant/farewell()
	to_chat(owner, span_deconversion_message("You no longer feel a need to serve [master.owner], and you are now free from this medieval shit."))
	/// Message told to your ex-king
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel that [owner.current] has betrayed you, and no longer is your servant!"))

/datum/antagonist/servant/knight
	name = "\improper Knight"
	roundend_category = "Knight"
	antagpanel_category = "King"
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/servant/knight/greet()
	. = ..()
	to_chat(owner, span_userdanger("You are now the knight of [master.owner.current], the King"))
	to_chat(owner, span_boldannounce("You may serve the [master.owner.current] with honour, because only he is the true King!"))
	antag_memory += "You are the servant of <b>[master.owner.current]</b>, the King!<br>"
	/// Message told to your King.
	to_chat(master.owner, span_userdanger("[owner.current] has become your knight."))

/**
 * # HUD
 */
/datum/antagonist/servant/proc/update_servant_icons_added(mob/living/servant, icontype = "servant")
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_KING]
	hud.join_hud(servant)
	set_antag_hud(servant, icontype)


/datum/antagonist/servant/proc/update_servant_icons_removed(mob/living/servant)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_KING]
	hud.leave_hud(servant)
	set_antag_hud(servant, null)

/datum/antagonist/servant/knight/update_servant_icons_added(mob/living/knight, icontype = "knight")
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_KING]
	hud.join_hud(knight)
	set_antag_hud(knight, icontype)


/datum/antagonist/servant/update_servant_icons_removed(mob/living/knight)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_KING]
	hud.leave_hud(knight)
	set_antag_hud(knight, null)