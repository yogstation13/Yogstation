//the team itself
/datum/team/darkspawn
	name = "darkspawns"
	member_name = "darkspawn"
	var/list/datum/mind/veils = list() //not quite members (the darkspawns)
	var/required_succs = 20 //How many succs are needed (this is changed in pre_setup, so it scales based on pop)
	var/lucidity = 0
	var/max_veils = 0

/datum/team/darkspawn/New(starting_members)
	. = ..()
	var/datum/objective/darkspawn/O = new
	objectives += O
	O.update_explanation_text()
	if(SSticker?.mode?.num_players())
		required_succs = clamp(round(SSticker.mode.num_players() / 3), 10, 30)

/datum/team/darkspawn/roundend_report()
	var/list/report = list()

	if(SSticker.mode.sacrament_done)
		report += "<span class='greentext big'>The Darkspawn have ascended once again! The station has forever been lost to the veil.</span><br>"
	else if(!SSticker.mode.sacrament_done && check_darkspawn_death())
		report += "<span class='redtext big'>The Darkspawn have been killed by the crew!</span><br>"
	else if(!SSticker.mode.sacrament_done && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		report += "<span class='redtext big'>The crew escaped the station before the Darkspawn could complete the Sacrament!</span><br>"
	else //fallback in case the round ends weirdly
		report += "<span class='redtext big'>The Darkspawn have failed!</span><br>"

	report += span_header("The darkspawns were:")
	for(var/datum/mind/master in members)
		report += printplayer(master)

	if(LAZYLEN(veils))
		report += span_header("The veils were:")
		for(var/datum/mind/veil in veils)
			report += printplayer(veil)


	return report

/datum/team/darkspawn/proc/grant_willpower(amount = 1)
	for(var/datum/mind/master in members)
		if(master.has_antag_datum(/datum/antagonist/darkspawn)) //sanity check
			var/datum/antagonist/darkspawn/antag = master.has_antag_datum(/datum/antagonist/darkspawn)
			antag.willpower += amount

/datum/team/darkspawn/add_member(datum/mind/new_member)
	. = ..()
	new_member.announce_objectives()

/datum/team/darkspawn/proc/add_veil(datum/mind/new_member) //veils are treated differently than darkspawns
	veils |= new_member

/datum/team/darkspawn/proc/remove_veil(datum/mind/member)
	veils -= member

/datum/team/darkspawn/proc/update_objectives() //teams should really have this as a default proc or something
	for(var/datum/objective/darkspawn/O as anything in objectives)
		if(istype(O))
			O.required_succs = src.required_succs
			O.update_explanation_text()

/datum/team/darkspawn/proc/check_darkspawn_death() //check if a darkspawn is still alive
	for(var/datum/mind/dark_mind as anything in members)
		if(istype(dark_mind) && (dark_mind?.current?.stat != DEAD))
			return FALSE
	return TRUE
	
//the objective
/datum/objective/darkspawn
	explanation_text = "Become lucid and perform the Sacrament."
	var/required_succs = 20

/datum/objective/darkspawn/update_explanation_text()
	explanation_text = "Devour enough wills to gain [required_succs] lucidity and perform the sacrament."

/datum/objective/darkspawn/check_completion()
	if(..())
		return TRUE
	return SSticker.mode.sacrament_done
