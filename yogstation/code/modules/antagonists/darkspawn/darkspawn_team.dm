//the team itself
/datum/team/darkspawn
	name = "darkspawns"
	member_name = "darkspawn"
	var/veil_name = "veil"
	var/list/datum/mind/veils = list() //not quite members (the darkspawns)
	var/required_succs = 10 //How many succs are needed (this is changed in pre_setup, so it scales based on pop)
	var/lucidity = 0
	var/max_veils = 0
	var/announced = FALSE //if the announcement that they've got enough lucidity has been sent

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Basic Team Stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/New(starting_members)
	. = ..()
	var/datum/objective/darkspawn/O = new
	objectives += O
	if(SSticker?.mode)
		required_succs = clamp(round(SSticker.mode.num_players() / 3), 5, 20) //a third the players, 5 at minimum, scaling up to 20 at max
	update_objectives()

/datum/team/darkspawn/add_member(datum/mind/new_member)
	. = ..()
	new_member.announce_objectives()

/datum/team/darkspawn/proc/add_veil(datum/mind/new_member) //veils are treated differently than darkspawns
	veils |= new_member

/datum/team/darkspawn/proc/remove_veil(datum/mind/member)
	veils -= member

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Round end Stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/roundend_report()
	var/list/report = list()

	if(SSticker.mode.sacrament_done)
		report += span_progenitor("The Darkspawn have ascended once again! The station has forever been lost to the veil.")
	else if(!SSticker.mode.sacrament_done && check_darkspawn_death())
		report += span_redtext("The Darkspawn have been killed by the crew!")
	else if(!SSticker.mode.sacrament_done && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		report += span_redtext("The crew escaped the station before the Darkspawn could complete the Sacrament!")
	else //fallback in case the round ends weirdly
		report += span_redtext("The Darkspawn have failed!")

	report += "The [member_name]s were:"
	report += printplayerlist(members)

	if(LAZYLEN(veils))
		report += "The [veil_name]s were:"
		report += printplayerlist(veils)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/darkspawn/proc/check_darkspawn_death() //check if a darkspawn is still alive
	for(var/datum/mind/dark_mind as anything in members)
		if(istype(dark_mind) && (dark_mind?.current?.stat != DEAD))
			return FALSE
	return TRUE
	
////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Team Objective----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/proc/update_objectives() //teams should really have this as a default proc or something
	for(var/datum/objective/darkspawn/O as anything in objectives)
		if(istype(O))
			O.required_succs = src.required_succs
			O.update_explanation_text()

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

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Special antag procs--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/proc/grant_willpower(amount = 1)
	for(var/datum/mind/master in members)
		if(master.has_antag_datum(/datum/antagonist/darkspawn)) //sanity check
			var/datum/antagonist/darkspawn/antag = master.has_antag_datum(/datum/antagonist/darkspawn)
			antag.willpower += amount
			if(master.current)
				to_chat(master.current, span_velvet("You have gained [amount] willpower."))

/datum/team/darkspawn/proc/grant_lucidity(amount = 1)
	lucidity += amount
	if(lucidity >= required_succs && !announced)
		announced = TRUE
		for(var/datum/mind/master in members)
			if(master.current)
				to_chat(master.current, span_progenitor("Enough lucidity has been gathered, perform the sacrament to ascend once more!"))

/datum/team/darkspawn/proc/upon_sacrament()
	for(var/datum/mind/master in members)
		var/dead = FALSE
		if(master.current)
			if(master.current.stat == DEAD)
				dead = TRUE
			master.current.revive(TRUE)
			if(dead)
				to_chat(master.current, "Returning to the shadowlands has revitalized your form")
