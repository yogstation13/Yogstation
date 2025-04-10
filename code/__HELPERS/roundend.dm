#define POPCOUNT_SURVIVORS "survivors"					//Not dead at roundend
#define POPCOUNT_ESCAPEES "escapees"					//Not dead and on centcom/shuttles marked as escaped
#define POPCOUNT_SHUTTLE_ESCAPEES "shuttle_escapees" 	//Emergency shuttle only.

/datum/controller/subsystem/ticker/proc/gather_roundend_feedback()
	gather_antag_data()
	record_nuke_disk_location()
	var/json_file = file("[GLOB.log_directory]/round_end_data.json")
	var/list/file_data = list("escapees" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "abandoned" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "ghosts" = list(), "additional data" = list())
	var/num_survivors = 0
	var/num_escapees = 0
	var/num_shuttle_escapees = 0
	var/list/area/shuttle_areas
	if(SSshuttle && SSshuttle.emergency)
		shuttle_areas = SSshuttle.emergency.shuttle_areas
	for(var/mob/m in GLOB.mob_list)
		var/escaped
		var/category
		var/list/mob_data = list()
		if(isnewplayer(m))
			continue
		if(m.mind)
			if(m.stat != DEAD && !isbrain(m) && !iscameramob(m))
				num_survivors++
			mob_data += list("name" = m.name, "ckey" = ckey(m.mind.key))
			if(isobserver(m))
				escaped = "ghosts"
			else if(isliving(m))
				var/mob/living/L = m
				mob_data += list("location" = get_area(L), "health" = L.health)
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					category = "humans"
					mob_data += list("job" = H.mind.assigned_role, "species" = H.dna.species.name)
				else if(issilicon(L))
					category = "silicons"
					if(isAI(L))
						mob_data += list("module" = "AI")
					if(isAI(L))
						mob_data += list("module" = "pAI")
					if(iscyborg(L))
						var/mob/living/silicon/robot/R = L
						mob_data += list("module" = R.module)
			else
				category = "others"
				mob_data += list("typepath" = m.type)
		if(!escaped)
			if(EMERGENCY_ESCAPED_OR_ENDGAMED && (m.onCentCom() || m.onSyndieBase()))
				escaped = "escapees"
				num_escapees++
				if(shuttle_areas[get_area(m)])
					num_shuttle_escapees++
			else
				escaped = "abandoned"
		if(!m.mind && (!ishuman(m) || !issilicon(m)))
			var/list/npc_nest = file_data["[escaped]"]["npcs"]
			if(npc_nest.Find(initial(m.name)))
				file_data["[escaped]"]["npcs"]["[initial(m.name)]"] += 1
			else
				file_data["[escaped]"]["npcs"]["[initial(m.name)]"] = 1
		else
			if(isobserver(m))
				var/pos = length(file_data["[escaped]"]) + 1
				file_data["[escaped]"]["[pos]"] = mob_data
			else
				if(!category)
					category = "others"
					mob_data += list("name" = m.name, "typepath" = m.type)
				var/pos = length(file_data["[escaped]"]["[category]"]) + 1
				file_data["[escaped]"]["[category]"]["[pos]"] = mob_data
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	file_data["additional data"]["station integrity"] = station_integrity
	WRITE_FILE(json_file, json_encode(file_data))
	SSblackbox.record_feedback("nested tally", "round_end_stats", num_survivors, list("survivors", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", num_escapees, list("escapees", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len, list("players", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len - num_survivors, list("players", "dead"))
	. = list()
	.[POPCOUNT_SURVIVORS] = num_survivors
	.[POPCOUNT_ESCAPEES] = num_escapees
	.[POPCOUNT_SHUTTLE_ESCAPEES] = num_shuttle_escapees
	.["station_integrity"] = station_integrity

/datum/controller/subsystem/ticker/proc/gather_antag_data()
	var/team_gid = 1
	var/list/team_ids = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue

		var/list/antag_info = list()
		antag_info["key"] = A.owner.key
		antag_info["name"] = A.owner.name
		antag_info["antagonist_type"] = A.type
		antag_info["antagonist_name"] = A.name //For auto and custom roles
		antag_info["objectives"] = list()
		antag_info["team"] = list()
		var/datum/team/T = A.get_team()
		if(T)
			antag_info["team"]["type"] = T.type
			antag_info["team"]["name"] = T.name
			if(!team_ids[T])
				team_ids[T] = team_gid++
			antag_info["team"]["id"] = team_ids[T]

		if(A.objectives.len)
			for(var/datum/objective/O in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"
				antag_info["objectives"] += list(list("objective_type"=O.type,"text"=O.explanation_text,"result"=result))
		SSblackbox.record_feedback("associative", "antagonists", 1, antag_info)

/datum/controller/subsystem/ticker/proc/record_nuke_disk_location()
	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	if(N)
		var/list/data = list()
		var/turf/T = get_turf(N)
		if(T)
			data["x"] = T.x
			data["y"] = T.y
			data["z"] = T.z
		var/atom/outer = get_atom_on_turf(N,/mob/living)
		if(outer != N)
			if(isliving(outer))
				var/mob/living/L = outer
				data["holder"] = L.real_name
			else
				data["holder"] = outer.name

		SSblackbox.record_feedback("associative", "roundend_nukedisk", 1 , data)

/datum/controller/subsystem/ticker/proc/gather_newscaster()
	var/json_file = file("[GLOB.log_directory]/newscaster.json")
	var/list/file_data = list()
	var/pos = 1
	for(var/V in GLOB.news_network.network_channels)
		var/datum/newscaster/feed_channel/channel = V
		if(!istype(channel))
			stack_trace("Non-channel in newscaster channel list")
			continue
		file_data["[pos]"] = list("channel name" = "[channel.channel_name]", "author" = "[channel.author]", "censored" = channel.censored ? 1 : 0, "author censored" = channel.authorCensor ? 1 : 0, "messages" = list())
		for(var/M in channel.messages)
			var/datum/newscaster/feed_message/message = M
			if(!istype(message))
				stack_trace("Non-message in newscaster channel messages list")
				continue
			var/list/comment_data = list()
			for(var/C in message.comments)
				var/datum/newscaster/feed_comment/comment = C
				if(!istype(comment))
					stack_trace("Non-message in newscaster message comments list")
					continue
				comment_data += list(list("author" = "[comment.author]", "time stamp" = "[comment.time_stamp]", "body" = "[comment.body]"))
			file_data["[pos]"]["messages"] += list(list("author" = "[message.author]", "time stamp" = "[message.time_stamp]", "censored" = message.bodyCensor ? 1 : 0, "author censored" = message.authorCensor ? 1 : 0, "photo file" = "[message.photo_file]", "photo caption" = "[message.caption]", "body" = "[message.body]", "comments" = comment_data))
		pos++
	if(GLOB.news_network.wanted_issue.active)
		file_data["wanted"] = list("author" = "[GLOB.news_network.wanted_issue.scannedUser]", "criminal" = "[GLOB.news_network.wanted_issue.criminal]", "description" = "[GLOB.news_network.wanted_issue.body]", "photo file" = "[GLOB.news_network.wanted_issue.photo_file]")
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/ticker/proc/declare_completion()
	set waitfor = FALSE

	to_chat(world, "<BR><BR><BR><span class='big bold'>The round has ended.</span>")
	log_admin("The round has ended.")

	if(LAZYLEN(GLOB.round_end_notifiees))
		send2irc("Notice", "[GLOB.round_end_notifiees.Join(", ")] the round has ended.")

	for(var/I in round_end_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_end_events)

	RollCredits()
	// Don't interrupt admin music
	if(REALTIMEOFDAY >= SSticker.music_available)
		for(var/client/C in GLOB.clients)
			C.playtitlemusic(40)
	else // this looks worse but is better than uselessly comparing for every client
		for(var/client/C in GLOB.clients)
			if(!(C.prefs.toggles & SOUND_MIDI))
				C.playtitlemusic(40)

	var/popcount = gather_roundend_feedback()
	display_report(popcount)

	CHECK_TICK

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antagonist_hud in GLOB.active_alternate_appearances)
		for(var/mob/player as anything in GLOB.player_list)
			antagonist_hud.show_to(player)

	CHECK_TICK

	//Set news report and mode result
	SSgamemode.round_end_report()
	SSgamemode.store_roundend_data() // store data on roundend for next round

	// Check whether the cargo king achievement was achieved
	cargoking()

	send2irc("Server", "Round just ended.")

	if(length(CONFIG_GET(keyed_list/cross_server)))
		send_news_report()

	set_observer_default_invisibility(0, span_warning("The round is over! You are now visible to the living."))

	CHECK_TICK

	//These need update to actually reflect the real antagonists
	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!(A.name in total_antagonists))
			total_antagonists[A.name] = list()
		total_antagonists[A.name] += "[key_name(A.owner)]"

	CHECK_TICK

	// Reward people who stayed alive and escaped
	if(CONFIG_GET(flag/use_antag_rep))
		for(var/mob/M in GLOB.player_list)
			if(M.stat == DEAD || !M.ckey) // Skip dead or clientless players
				continue
			if(SSpersistence.antag_rep_change[M.ckey] < 0) // don't want to punish antags for being alive hehe
				continue
			else if(M.onCentCom() || SSticker.force_ending || SSgamemode.station_was_nuked)
				SSpersistence.antag_rep_change[M.ckey] *= CONFIG_GET(number/escaped_alive_bonus) // Reward for escaping alive
			else
				SSpersistence.antag_rep_change[M.ckey] *= CONFIG_GET(number/stayed_alive_bonus) // Reward for staying alive
			SSpersistence.antag_rep_change[M.ckey] = round(SSpersistence.antag_rep_change[M.ckey]) // rounds down

	CHECK_TICK

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/antag_name in total_antagonists)
		var/list/L = total_antagonists[antag_name]
		log_game("[antag_name]s :[L.Join(", ")].")

	CHECK_TICK
	SSdbcore.SetRoundEnd()
	//Collects persistence features
	if(SSgamemode.allow_persistence_save)
		SSpersistence.CollectData()

	//stop collecting feedback during grifftime
	SSblackbox.Seal()

	toggle_all_ctf()

	// Give all donors their griff toys
	// Create a fake uplink for purposes of stealing its component
	// We create the one and use it for every item, as initializing 50 uplink components is expensive
	var/obj/item/uplink/fake_uplink = new
	var/datum/component/uplink/fake_uplink_component = fake_uplink.GetComponent(/datum/component/uplink)
	for(var/mob/living/donor_mob in GLOB.player_list)
		if(!is_donator(donor_mob))
			continue

		// Get their pref
		var/eorg_path_string = donor_mob.client?.prefs?.read_preference(/datum/preference/choiced/donor_eorg)
		if(!eorg_path_string)
			continue

		// Parse their pref
		var/uplink_path = text2path(eorg_path_string)
		if(!uplink_path || !ispath(uplink_path, /datum/uplink_item))
			continue

		// Initialize the uplink item because we need spawn_item()
		var/datum/uplink_item/uplink_datum = new uplink_path
		if(!uplink_datum.item || uplink_datum.cost <= 0 || uplink_datum.cost > TELECRYSTALS_DEFAULT) // Safety
			qdel(uplink_datum)
			continue
		// The uplink item datum will handle the spawning. This is important for things like additional arm.
		var/atom/spawned_thing = uplink_datum.spawn_item(uplink_datum.item, donor_mob, fake_uplink_component)
		// Replace any firing pins with default pins, so that players can fire them
		if(isgun(spawned_thing))
			var/obj/item/gun/spawned_gun = spawned_thing
			qdel(spawned_gun.pin)
			spawned_gun.pin = new /obj/item/firing_pin(spawned_gun)
		else if(spawned_thing)
			for(var/obj/item/gun/spawned_gun in spawned_thing.get_all_contents())
				qdel(spawned_gun.pin)
				spawned_gun.pin = new /obj/item/firing_pin(spawned_gun)
		// Clean up
		QDEL_NULL(uplink_datum)
	// Clean up the fake uplink we created earlier
	QDEL_NULL(fake_uplink) // component will be destroyed automatically by /datum/Destroy()
	// End donor griff toys

	sleep(5 SECONDS)
	ready_for_reboot = TRUE
	standard_reboot()

/datum/controller/subsystem/ticker/proc/standard_reboot()
	if(ready_for_reboot)
		if(SSgamemode.station_was_nuked)
			Reboot("Station destroyed by Nuclear Device.", "nuke")
		else
			Reboot("Round ended.", "proper completion")
	else
		CRASH("Attempted standard reboot without ticker roundend completion")

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	//AI laws
	parts += law_report()

	CHECK_TICK

	//Antagonists
	parts += antag_report()

	CHECK_TICK
	//Security
	parts += sec_report()

	CHECK_TICK
	//Medals
	parts += medal_report()
	CHECK_TICK

	parts += mouse_report()

	CHECK_TICK
	//Station Goals
	parts += station_goal_report()

	CHECK_TICK
	// Department Goals
	parts += department_goal_report()

	listclearnulls(parts)

	return parts.Join()

/datum/controller/subsystem/ticker/proc/survivor_report(popcount)
	var/list/parts = list()

	parts += "<div class='panel stationborder'><span class='header'>[("Storyteller: [SSgamemode.storyteller ? SSgamemode.storyteller.name : "N/A"]")]</span></div>"

	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED

	if(GLOB.round_id)
		var/statspage = CONFIG_GET(string/roundstatsurl)
		var/info = statspage ? "<a href='byond://?action=openLink&link=[url_encode(statspage)][GLOB.round_id]'>[GLOB.round_id]</a>" : GLOB.round_id
		parts += "[GLOB.TAB]Round ID: <b>[info]</b>"
	parts += "[GLOB.TAB]Shift Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B>"
	parts += "[GLOB.TAB]Station Integrity: <B>[SSgamemode.station_was_nuked ? span_redtext("Destroyed") : "[popcount["station_integrity"]]%"]</B>"
	var/total_players = GLOB.joined_player_list.len
	if(total_players)
		parts+= "[GLOB.TAB]Total Population: <B>[total_players]</B>"
		if(station_evacuated)
			parts += "<BR>[GLOB.TAB]Evacuation Rate: <B>[popcount[POPCOUNT_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_ESCAPEES]/total_players)]%)</B>"
			parts += "[GLOB.TAB](on emergency shuttle): <B>[popcount[POPCOUNT_SHUTTLE_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_SHUTTLE_ESCAPEES]/total_players)]%)</B>"
		parts += "[GLOB.TAB]Survival Rate: <B>[popcount[POPCOUNT_SURVIVORS]] ([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)]%)</B>"
		if(SSblackbox.first_death)
			var/list/ded = SSblackbox.first_death
			if(ded.len)
				parts += "[GLOB.TAB]First Death: <b>[ded["name"]], [ded["role"]], at [ded["area"]]. Damage taken: [ded["damage"]].[ded["last_words"] ? " Their last words were: \"[ded["last_words"]]\"" : ""]</b>"
			//ignore this comment, it fixes the broken sytax parsing caused by the " above
			else
				parts += "[GLOB.TAB]<i>Nobody died this shift!</i>"
	return parts.Join("<br>")

/client/proc/roundend_report_file()
	return "data/roundend_reports/[ckey].html"

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, previous = FALSE)
	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(!previous)
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		remove_verb(C, /client/proc/show_previous_roundend_report)
		fdel(filename)
		text2file(content, filename)
	else
		content = file2text(filename)
	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	roundend_report.open(FALSE)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/M = C.mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					parts += "<div class='panel stationborder'>"
					parts += span_marooned("You managed to survive, but were marooned on [station_name()]...")
				else
					parts += "<div class='panel greenborder'>"
					parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")
			else
				parts += "<div class='panel greenborder'>"
				parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")
				if(M.mind.assigned_role in GLOB.engineering_positions) // We don't actually need to even really do a check to see if assigned_role is set to anything.
					SSachievements.unlock_achievement(/datum/achievement/engineering, C)
				else if(M.mind.assigned_role in GLOB.supply_positions) // We don't actually need to even really do a check to see if assigned_role is set to anything.
					SSachievements.unlock_achievement(/datum/achievement/cargo, C)


		else
			parts += "<div class='panel redborder'>"
			parts += span_redtext("You did not survive the events on [station_name()]...")
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += GLOB.survivor_report
	parts += "</div>"

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report(popcount)
	GLOB.common_report = build_roundend_report()
	GLOB.survivor_report = survivor_report(popcount)
	for(var/client/C in GLOB.clients)
		show_roundend_report(C, FALSE)
		give_show_report_button(C)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/law_report()
	var/list/parts = list()
	var/borg_spacer = FALSE //inserts an extra linebreak to seperate AIs from independent borgs, and then multiple independent borgs.
	//Silicon laws report
	for (var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/aiPlayer = i
		if(aiPlayer.mind)
			parts += "<b>[aiPlayer.name]</b> (Played by: <b>[aiPlayer.mind.key]</b>)'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was [span_redtext("deactivated")]"] were:"
			parts += aiPlayer.laws.get_law_list(include_zeroth=TRUE)
		else if(aiPlayer.deployed_shell?.mind)
			parts += "<b>[aiPlayer.name]</b> (Played by: <b>[aiPlayer.deployed_shell.mind.key]</b>)'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was [span_redtext("deactivated")]"] were:"
			parts += aiPlayer.laws.get_law_list(include_zeroth=TRUE)
		parts += "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if (aiPlayer.connected_robots.len)
			var/borg_num = aiPlayer.connected_robots.len
			var/robolist = "<br><b>[aiPlayer.real_name]</b>'s minions were: "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				borg_num--
				if(robo.mind)
					robolist += "<b>[robo.name]</b> (Played by: <b>[robo.mind.key]</b>)[robo.stat == DEAD ? " [span_redtext("(Deactivated)")]" : ""][borg_num ?", ":""]<br>"
			parts += "[robolist]"
		if(!borg_spacer)
			borg_spacer = TRUE

	for (var/mob/living/silicon/robot/robo in GLOB.silicon_mobs)
		if (!robo.connected_ai && robo.mind)
			parts += "[borg_spacer?"<br>":""]<b>[robo.name]</b> (Played by: <b>[robo.mind.key]</b>) [(robo.stat != DEAD)? "[span_greentext("survived")] as an AI-less borg!" : "was [span_redtext("unable to survive")] the rigors of being a cyborg without an AI."] Its laws were:"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				parts += robo.laws.get_law_list(include_zeroth=TRUE)

			if(!borg_spacer)
				borg_spacer = TRUE

	if(parts.len)
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""

/datum/controller/subsystem/ticker/proc/station_goal_report()
	var/list/parts = list()
	if(SSgamemode.station_goals.len)
		for(var/V in SSgamemode.station_goals)
			var/datum/station_goal/G = V
			parts += G.get_result()
		return "<div class='panel stationborder'><ul>[parts.Join()]</ul></div>"

/datum/controller/subsystem/ticker/proc/department_goal_report()
	var/list/parts = list("<div class='panel stationborder'><ul>")
	var/list/goals = list(
		ACCOUNT_ENG = list(),
		ACCOUNT_SCI = list(),
		ACCOUNT_MED = list(),
		ACCOUNT_SRV = list(),
		ACCOUNT_CAR = list(),
		ACCOUNT_SEC = list())
	for(var/datum/department_goal/dg in SSYogs.department_goals)
		goals[dg.account] += dg.get_result()

	parts += "<br>[span_header("Engineering department goals:")]<br>"
	parts += goals[ACCOUNT_ENG]

	parts += "<br>[span_header("Science department goals:")]<br>"
	parts += goals[ACCOUNT_SCI]

	parts += "<br>[span_header("Medical department goals:")]<br>"
	parts += goals[ACCOUNT_MED]

	parts += "<br>[span_header("Service department goals:")]<br>"
	parts += goals[ACCOUNT_SRV]

	parts += "<br>[span_header("Cargo department goals:")]<br>"
	parts += goals[ACCOUNT_CAR]

	parts += "<br>[span_header("Security department goals:")]<br>"
	parts += goals[ACCOUNT_SEC]

	parts += "</ul></div>"
	return parts.Join()

/datum/controller/subsystem/ticker/proc/medal_report()
	if(GLOB.commendations.len)
		var/list/parts = list()
		parts += span_header("Medal Commendations:")
		for (var/com in GLOB.commendations)
			parts += com
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""

/datum/controller/subsystem/ticker/proc/mouse_report()
	if(GLOB.mouse_food_eaten)
		var/list/parts = list()
		parts += span_header("Mouse stats:")
		parts += "Mice Born: [GLOB.mouse_spawned]"
		parts += "Mice Killed: [GLOB.mouse_killed]"
		parts += "Trash Eaten: [GLOB.mouse_food_eaten]"
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/result = list()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/team/A in GLOB.antagonist_teams)
		if(!A.members)
			continue
		all_teams |= A

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_antagonists |= A

	for(var/datum/team/T in all_teams)
		result += T.roundend_report()
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		result += " "//newline between teams
		CHECK_TICK

	var/currrent_category
	var/datum/antagonist/previous_category

	sortTim(all_antagonists, /proc/cmp_antag_category)

	for(var/datum/antagonist/A in all_antagonists)
		if(!A.show_in_roundend)
			continue
		if(A.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
				result += "</div>"
			result += "<div class='panel redborder'>"
			result += A.roundend_report_header()
			currrent_category = A.roundend_category
			previous_category = A
		result += A.roundend_report()
		result += "<br><br>"
		CHECK_TICK

	if(all_antagonists.len)
		var/datum/antagonist/last = all_antagonists[all_antagonists.len]
		result += last.roundend_report_footer()
		result += "</div>"

	return result.Join()

/datum/controller/subsystem/ticker/proc/sec_report()
	var/list/sec = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
			sec |= player.mind
	if (sec.len)
		var/list/result = list()
		result += span_header("Security Officers:<br>")
		for(var/mob/living/carbon/human/player in GLOB.carbon_list)
			if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
				result += "<ul class='player report'><b>[player.name]</b> (Played by: <b>[player.mind.key]</b>) [(player.stat != DEAD)? "[span_greentext("survived")] as a <b>[player.mind.assigned_role]</b>" : "[span_redtext("fell in the line of duty")] as a <b>[player.mind.assigned_role]</b>"]<br></ul>"

		return "<div class='panel stationborder'><ul>[result.Join()]</ul></div>"
	return ""

/proc/cmp_antag_category(datum/antagonist/A,datum/antagonist/B)
	return sorttext(B.roundend_category,A.roundend_category)


/datum/controller/subsystem/ticker/proc/give_show_report_button(client/C)
	var/datum/action/report/R = new
	C.player_details.player_actions += R
	R.Grant(C.mob)
	to_chat(C,"<a href='byond://?src=[REF(R)];report=1'>Show roundend report again</a>")

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "round_end"
	show_to_observers = FALSE

/datum/action/report/Trigger()
	if(owner && GLOB.common_report && SSticker.current_state == GAME_STATE_FINISHED)
		SSticker.show_roundend_report(owner.client, FALSE)

/datum/action/report/IsAvailable(feedback = FALSE)
	return 1

/datum/action/report/Topic(href,href_list)
	if(usr != owner)
		return
	if(href_list["report"])
		Trigger()
		return


/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(ply.assigned_role)
		jobtext = " the <b>[ply.assigned_role]</b>"
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b>[jobtext] and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " [span_redtext("died")]"
		else
			text += " [span_greentext("survived")]"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while [span_redtext("fleeing the station")]"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " [span_redtext("had their body destroyed")]"
	return text

/proc/printplayerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printplayer(M,fleecheck)]</li>"
	parts += "</ul>"
	return parts.Join()


/proc/printobjectives(list/objectives)
	if(!objectives || !objectives.len)
		return
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objective_parts += "<b>[objective.objective_name] #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			objective_parts += "<b>[objective.objective_name] #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
		count++
	return objective_parts.Join("<br>")

/datum/controller/subsystem/ticker/proc/cargoking()
	var/datum/achievement/cargoking/CK = SSachievements.get_achievement(/datum/achievement/cargoking)
	var/cargoking = FALSE
	var/ducatduke = FALSE
	if(SSshuttle.points > 1000000)//Why is the cargo budget on SSshuttle instead of SSeconomy :thinking:
		ducatduke = TRUE
		if(SSshuttle.points > CK.amount)
			cargoking = TRUE
	var/hasQM = FALSE //we only wanna update the record if there's a QM
	for(var/mob/M in GLOB.player_list)
		if(M.mind?.assigned_role == "Quartermaster")
			if(ducatduke)
				SSachievements.unlock_achievement(/datum/achievement/ducatduke, M.client)
				if(cargoking)
					SSachievements.unlock_achievement(/datum/achievement/cargoking, M.client)
			hasQM = TRUE //there might be more than one QM, so we do the DB stuff outside of the loop
	if(hasQM && cargoking)
		var/datum/DBQuery/Q = SSdbcore.New("UPDATE [format_table_name("misc")] SET `value` = '[SSshuttle.points]' WHERE `key` = 'cargorecord'")
		Q.Execute()
		qdel(Q)

