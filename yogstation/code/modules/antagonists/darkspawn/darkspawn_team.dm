//the team itself
/datum/team/darkspawn
	name = "Darkspawns"
	member_name = "darkspawn"
	///The name of the "converted" players
	var/thrall_name = "thrall"
	///The list containing all converted players
	var/list/datum/mind/thralls = list()
	///The number of drains required to perform the sacrament
	var/required_succs = 10 //How many succs are needed (this is changed in pre_setup, so it scales based on pop)
	///How many drains have happened so far
	var/lucidity = 0
	///The max number of people that can be actively converted
	var/max_thralls = 0
	///Boolean, Whether or not the darkspawn have been al;erted that they can perform the sacrament
	var/announced = FALSE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Basic Team Stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/New(starting_members)
	. = ..()
	var/datum/objective/darkspawn/O = new
	objectives += O
	if(SSticker?.mode)
		required_succs = clamp(round(SSticker.mode.num_players() / 2), 5, 25) //half the players, 5 at minimum, scaling up to 25 at max
	update_objectives()
	addtimer(CALLBACK(src, PROC_REF(enable_validhunt)), 75 MINUTES) //allow for validhunting after a duration

/datum/team/darkspawn/add_member(datum/mind/new_member)
	. = ..()
	new_member.announce_objectives()

/datum/team/darkspawn/remove_member(datum/mind/member) //also try to remove them from the thralls list just in case
	. = ..()
	thralls -= member

/datum/team/darkspawn/proc/add_thrall(datum/mind/new_member) //thralls are treated differently than darkspawns
	thralls |= new_member

/datum/team/darkspawn/proc/remove_thrall(datum/mind/member)
	thralls -= member

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Round end Stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/roundend_report()
	var/list/report = list()

	if(GLOB.sacrament_done)
		report += span_progenitor("The Darkspawn have ascended once again!<br>The station has forever been lost beyond the veil.")
	else
		report += span_header("[name]:") //only have a regular header if it's a loss
		if(check_darkspawn_death())
			report += span_redtext("The Darkspawn have been killed by the crew!")
		else if(EMERGENCY_ESCAPED_OR_ENDGAMED)
			report += span_redtext("The crew escaped the station before the Darkspawn could complete the Sacrament!")
		else //fallback in case the round ends weirdly
			report += span_redtext("The Darkspawn have failed!")

	report += "The [member_name]s were:"
	report += printplayerlist(members)

	if(LAZYLEN(thralls))
		report += "The [thrall_name]s were:"
		report += printplayerlist(thralls)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/darkspawn/proc/check_darkspawn_death() //check if a darkspawn is still alive
	for(var/datum/mind/dark_mind as anything in members)
		if(!istype(dark_mind)) //if for some reason something other than a mind was mixed in, skip it
			continue
		if(!dark_mind.current) //if they don't have a body, skip it
			continue
		if(QDELETED(dark_mind.current)) //if the body is deleted, but hasn't been cleaned up yet, skip it
			continue
		if(dark_mind.current.stat == DEAD) //if their body is dead, skip it
			continue
		if(isbrain(dark_mind.current) || issilicon(dark_mind.current)) //if they're a borg or mmi, skip it
			continue
		if(!dark_mind.current.ckey)//if they've gone cata, skip it
			continue
		return FALSE //they aren't all dead
	return TRUE //they're all dead
	
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
	return GLOB.sacrament_done

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Special antag procs--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/team/darkspawn/proc/grant_willpower(amount = 1, silent = FALSE)
	for(var/datum/mind/master in members)
		if(master.has_antag_datum(/datum/antagonist/darkspawn)) //sanity check
			var/datum/antagonist/darkspawn/antag = master.has_antag_datum(/datum/antagonist/darkspawn)
			antag.willpower += amount
			if(!silent && master.current)
				to_chat(master.current, span_velvet("You have gained [amount] willpower."))

/datum/team/darkspawn/proc/grant_lucidity(amount = 1)
	lucidity += amount
	if(lucidity >= (required_succs -1)) //enable valid hunting right before darkspawns complete their objective
		enable_validhunt()

	if(lucidity >= required_succs && !announced) //let the darkspawns know they've won
		announced = TRUE
		for(var/datum/mind/master in members)
			if(master.current)
				to_chat(master.current, span_progenitor("Enough lucidity has been gathered, perform the sacrament to ascend once more!"))

	if(lucidity >= (required_succs + 5)) //don't farm a round you've already basically won
		for(var/datum/mind/master in members)
			if(master.current)
				to_chat(master.current, span_userdanger("Your form can't maintain itself with all this energy!"))
				master.current.gib(TRUE, TRUE, TRUE)

/datum/team/darkspawn/proc/upon_sacrament()
	for(var/datum/mind/master in members)
		var/dead = FALSE
		if(master.current)
			if(master.current.stat == DEAD)
				dead = TRUE
			master.current.grab_ghost()
			master.current.revive(TRUE)
			if(dead)
				to_chat(master.current, "Returning to Nullspace has revitalized your form")

//60 minutes after the round starts, enable validhunters and powergamers to do their thing (station is probably fucked by that point anyways)
/datum/team/darkspawn/proc/enable_validhunt()
	if(check_darkspawn_death())//if no darkspawns are alive, don't bother announcing
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA)//if for some reason, it's already gamma, don't bother announcing
		return
	SSsecurity_level.set_level(SEC_LEVEL_GAMMA)
	priority_announce("Dangerous fluctuations in the veil have been detected aboard the station. Be on high alert for unusual beings commanding unnatural powers.", "Central Command Higher Dimensional Affairs")

	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(lock_validhunt)) //so you can't just turn off gamma

/datum/team/darkspawn/proc/lock_validhunt()
	if(check_darkspawn_death())//if no darkspawns are alive, don't bother announcing
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA)//if for some reason, it's already gamma, don't bother announcing
		return
	SSsecurity_level.set_level(SEC_LEVEL_GAMMA)
	priority_announce("The dangerous fluctuations in the veil have not abated. Do not attempt to lower the security level further.", "Central Command Higher Dimensional Affairs")
