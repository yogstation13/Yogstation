/datum/game_mode/send_intercept()
	var/intercepttext = "<b><i>Central Command Status Summary</i></b><hr>"
	if(station_goals.len)
		intercepttext += "<b>Special Orders for [station_name()]:</b><br>"
		for(var/datum/station_goal/G in station_goals)
			G.on_report()
			intercepttext += G.get_report()
	print_command_report(intercepttext, "Central Command Status Summary", announce=FALSE)
	priority_announce("A summary has been copied and printed to all communications consoles.", "Station orders received.", 'sound/ai/commandreport.ogg')