// SETUP

/proc/TopicHandlers()
	. = list()
	var/list/all_handlers = subtypesof(/datum/world_topic)
	for(var/I in all_handlers)
		var/datum/world_topic/WT = I
		var/keyword = initial(WT.keyword)
		if(!keyword)
			stack_trace("[WT] has no keyword! Ignoring...")
			continue
		var/existing_path = .[keyword]
		if(existing_path)
			stack_trace("[existing_path] and [WT] have the same keyword! Ignoring [WT]...")
		else if(keyword == "key")
			stack_trace("[WT] has keyword 'key'! Ignoring...")
		else
			.[keyword] = WT

// DATUM

/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE

/datum/world_topic/proc/TryRun(list/input)
	key_valid = config && (CONFIG_GET(string/comms_key) == input["key"])
	if(require_comms_key && !key_valid)
		return "Bad Key"
	input -= "key"
	. = Run(input)
	if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")

// TOPICS

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input)
	. = 0
	for (var/client/C in GLOB.clients)
		++.

/datum/world_topic/playing
	keyword = "playing"
	log = FALSE

/datum/world_topic/playing/Run(list/input)
	return GLOB.player_list.len

/datum/world_topic/pr_announce
	keyword = "announce"
	require_comms_key = TRUE
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round

/datum/world_topic/pr_announce/Run(list/input)
	var/list/payload = json_decode(input["payload"])
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = span_announce("PR: [input[keyword]]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/datum/world_topic/ahelp_relay
	keyword = "Ahelp"
	require_comms_key = TRUE

/datum/world_topic/ahelp_relay/Run(list/input)
	relay_msg_admins(span_adminnotice("<b><font color=red>HELP: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b>"))

/datum/world_topic/comms_console
	keyword = "Comms_Console"
	require_comms_key = TRUE

/datum/world_topic/comms_console/Run(list/input)
	minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
	for(var/obj/machinery/computer/communications/CM in GLOB.machines)
		CM.override_cooldown()

/datum/world_topic/news_report
	keyword = "News_Report"
	require_comms_key = TRUE

/datum/world_topic/news_report/Run(list/input)
	minor_announce(input["message"], "Breaking Update From [input["message_sender"]]")
	
/datum/world_topic/ooc_relay
	keyword = "ooc_relay"
	require_comms_key = TRUE

/datum/world_topic/ooc_relay/Run(list/input)
	var/messages = json_decode(input["message"])
	var/oocmsg = messages["normal"]
	var/oocmsg_toadmins = messages["admin"]
	
	var/source = json_decode(input["message_sender"])
	var/sourceadmin = source["is_admin"]
	var/sourcekey = source["key"]

	//SENDING THE MESSAGES OUT
	for(var/c in GLOB.clients)
		var/client/C = c // God bless typeless for-loops
		if( (C.prefs.chat_toggles & CHAT_OOC) && (sourceadmin || !(sourcekey in C.prefs.ignoring)) )
			var/sentmsg // The message we're sending to this specific person
			if(C.holder) // If they're an admin-ish
				sentmsg = oocmsg_toadmins // Get the admin one
			else
				sentmsg = oocmsg
			sentmsg = "[span_prefix("RELAY: [input["source"]]")] " + sentmsg
			//no pinging across servers, thats intentional
			to_chat(C,sentmsg)

/datum/world_topic/server_hop
	keyword = "server_hop"
	require_comms_key = TRUE

/datum/world_topic/server_hop/Run(list/input)
	var/expected_key = input[keyword]
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.key == expected_key)
			if(O.client)
				new /obj/screen/splash(O.client, TRUE)
			break

/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/adminmsg/Run(list/input)
	return IrcPm(input[keyword], input["msg"], input["sender"])

/datum/world_topic/namecheck
	keyword = "namecheck"
	require_comms_key = TRUE

/datum/world_topic/namecheck/Run(list/input)
	//Oh this is a hack, someone refactor the functionality out of the chat command PLS
	var/datum/tgs_chat_command/namecheck/NC = new
	var/datum/tgs_chat_user/user = new
	user.friendly_name = input["sender"]
	user.mention = user.friendly_name
	return NC.Run(user, input["namecheck"])

/datum/world_topic/adminwho
	keyword = "adminwho"
	require_comms_key = TRUE

/datum/world_topic/adminwho/Run(list/input)
	return ircadminwho()
	
/datum/world_topic/mentorwho
	keyword = "mentorwho"
	require_comms_key = TRUE

/datum/world_topic/mentorwho/Run(list/input)
	var/list/message = list("Mentors: ")
	for(var/client/mentor in GLOB.mentors)
		if(LAZYLEN(message) > 1)
			message += ", [mentor.key]"
		else
			message += "[mentor.key]"

	return jointext(message, "")

// Plays a voice announcement, given the ID of a voice annoucnement datum and a filename of a file in the shared folder, among other things
/datum/world_topic/voice_announce
	keyword = "voice_announce"
	require_comms_key = TRUE

/datum/world_topic/voice_announce/Run(list/input)
	var/datum/voice_announce/A = GLOB.voice_announce_list[input["voice_announce"]]
	if(istype(A))
		A.handle_announce(input["ogg_file"], input["uploaded_file"], input["ip"], text2num(input["duration"]))

// Cancels a voice announcement, given the ID of voice announcement datum, used if the user closes their browser window instead of uploading
/datum/world_topic/voice_announce_cancel
	keyword = "voice_announce_cancel"
	require_comms_key = TRUE

/datum/world_topic/voice_announce_cancel/Run(list/input)
	var/datum/voice_announce/A = GLOB.voice_announce_list[input["voice_announce_cancel"]]
	if(istype(A))
		qdel(A)
		
// Queries information about a voice announcement.
/datum/world_topic/voice_announce_query
	keyword = "voice_announce_query"
	require_comms_key = TRUE

/datum/world_topic/voice_announce_query/Run(list/input)
	. = list()
	var/datum/voice_announce/A = GLOB.voice_announce_list[input["voice_announce_query"]]
	if(istype(A))
		A.was_queried = TRUE
		.["exists"] = TRUE
		.["is_ai"] = A.is_ai
	else
		.["exists"] = FALSE

/datum/world_topic/status
	keyword = "status"

/datum/world_topic/status/Run(list/input)
	. = list()
	.["version"] = GLOB.game_version
	.["mode"] = GLOB.master_mode
	.["respawn"] = config ? !CONFIG_GET(flag/norespawn) : FALSE
	.["enter"] = GLOB.enter_allowed
	.["vote"] = CONFIG_GET(flag/allow_vote_mode)
	.["ai"] = CONFIG_GET(flag/allow_ai)
	.["host"] = world.host ? world.host : null
	.["round_id"] = GLOB.round_id
	.["players"] = GLOB.clients.len
	.["revision"] = GLOB.revdata?.commit
	.["revision_date"] = GLOB.revdata?.date

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
	.["gamestate"] = SSticker.current_state

	.["map_name"] = SSmapping.config?.map_name || "Loading..."

	if(key_valid)
		.["active_players"] = get_active_player_count()
		if(SSticker.HasRoundStarted())
			.["real_mode"] = SSticker.mode.name
			// Key-authed callers may know the truth behind the "secret"

	.["security_level"] = get_security_level()
	.["round_duration"] = SSticker ? round((world.time-SSticker.round_start_time)/10) : 0
	// Amount of world's ticks in seconds, useful for calculating round duration
	
	//Time dilation stats.
	.["time_dilation_current"] = SStime_track.time_dilation_current
	.["time_dilation_avg"] = SStime_track.time_dilation_avg
	.["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	.["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast
	
	//pop cap stats
	.["soft_popcap"] = CONFIG_GET(number/soft_popcap) || 0
	.["hard_popcap"] = CONFIG_GET(number/hard_popcap) || 0
	.["extreme_popcap"] = CONFIG_GET(number/extreme_popcap) || 0
	.["popcap"] = max(CONFIG_GET(number/soft_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/extreme_popcap)) //generalized field for this concept for use across ss13 codebases
	
	if(SSshuttle && SSshuttle.emergency)
		.["shuttle_mode"] = SSshuttle.emergency.mode
		// Shuttle status, see /__DEFINES/stat.dm
		.["shuttle_timer"] = SSshuttle.emergency.timeLeft()
		// Shuttle timer, in seconds

/datum/world_topic/systemmsg
	keyword = "systemmsg"
	require_comms_key = TRUE

/datum/world_topic/systemmsg/Run(list/input)
	to_chat(world, span_boldannounce(input["message"]))

