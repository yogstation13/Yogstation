/client/proc/subtlemessage_faction() // Thanks GenericDM very cool
	set name = "SM to Faction"
	set desc = "Allows you to send a mass SM to every member of a particular faction or antagonist type."
	set category = "Admin.Player Interaction"

	var/list/choices = list() //This list includes both factions in the "mob.factions" sense
	// and also factions as in, types of /datum/antagonist/

	//First, lets generate a list of possible factions for this admin to choose from
	for(var/mob/living/player in GLOB.player_list)
		if(player.faction)
			for(var/i in player.faction)
				choices |= i
		var/list/antagstuffs = player.mind.antag_datums
		if(antagstuffs && antagstuffs.len)
			for(var/antagdatum in antagstuffs)
				choices |= "[antagdatum]"
	message_admins("[key_name_admin(src)] has started a SM to Faction.")
	var/chosen = input("Select faction or antag type you would like to contact:","SM to Faction") in choices
	if(!chosen)
		message_admins("[key_name_admin(src)] has decided not to SM to Faction.")
		return
	message_admins("[key_name_admin(src)] has chosen SM to Faction: [chosen].")
	var/msg = input("Message:", text("Subtle PM to [chosen]")) as text|null
	if(!msg)
		message_admins("[key_name_admin(src)] has decided not to SM to Faction.")
		return
	log_admin("SubtleMessage Faction: [key_name_admin(src)] -> Faction [chosen] : [msg]")
	message_admins("SubtleMessage Faction: [key_name_admin(src)] -> Faction [chosen] : [msg]")
	var/text // The real HTML-and-text we will send to the SM'd.
	if(chosen == "Clock Cultist")
		text = "[span_large_brass("You hear a booming voice in your head... ")][span_heavy_brass("[msg]")]"
	else if(chosen == "Cultist")
		text = "[span_cultlarge("You hear a booming voice in your head... ")][span_cult("[msg]")]"
	else if(chosen == "swarmer")
		text = "<i>You are receiving a message from the masters... <b>[msg]</i></b>"
	else
		text = "<i>You hear a booming voice in your head... <b>[msg]</b></i>"

	for(var/mob/living/player in GLOB.player_list)
		var/done = FALSE
		if(player.faction)
			for(var/i in player.faction)
				if(i == chosen)
					to_chat(player,text)
					done = TRUE
					break
		if(done)
			continue
		var/list/antagstuffs = player.mind.antag_datums
		if(antagstuffs && antagstuffs.len)
			for(var/antagdatum in antagstuffs)
				if("[antagdatum]" == chosen)
					to_chat(player,text)
					break
