/**
 * # Plexora Subsystem
 *
 * This subsystem is for the Plexora Discord bot bridge.
 *
 * The repo for this can be found at https://github.com/monkestation/plexora
 *
 * The distinction between Plexora (the bot) and Plexora (the subsystem)
 * will be plexora (the bot) and SSplexora (the subsystem)
 *
 * NOTES:
 * * SSplexora makes heavy use of topics, and rust_g HTTP requests
 * * Lets hope to god plexora is configured properly and DOESNT CRASh,
 *	 -because i seriously do not want to put error catchers in
 *	 -EVERY FUNCTION THAT MAKES AN HTTP REQUEST
 */

#define TOPIC_EMITTER \
	if (input["emitter_token"]) { \
		INVOKE_ASYNC(SSplexora, TYPE_PROC_REF(/datum/controller/subsystem/plexora, topic_listener_response), input["emitter_token"], returning); \
		return; \
	};
#define AUTH_HEADER ("Basic " + CONFIG_GET(string/comms_key))
#define OLD_PLEXORA_CONFIG "config/plexora.json"

SUBSYSTEM_DEF(plexora)
	name = "Plexora"
	wait = 30 SECONDS
	init_order = INIT_ORDER_PLEXORA
	priority = FIRE_PRIORITY_PLEXORA
	runlevels = ALL

#ifdef UNIT_TESTS
	flags = SS_NO_INIT | SS_NO_FIRE
#endif

	// MUST INCREMENT BY ONE FOR EVERY CHANGE MADE TO PLEXORA
	var/version_increment_counter = 2
	var/plexora_is_alive = FALSE
	var/vanderlin_available = FALSE
	var/base_url = ""
	var/enabled = TRUE
	var/tripped_bad_version = FALSE
	var/list/default_headers

	//other thingys!
	var/hrp_available = FALSE

/datum/controller/subsystem/plexora/Initialize()
	if(!CONFIG_GET(flag/plexora_enabled) && !load_old_plexora_config())
		enabled = FALSE
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED

	var/comms_key = CONFIG_GET(string/comms_key)
	if (!comms_key)
		stack_trace("SSplexora is enabled BUT there is no configured comms key! Please make sure to set one and update Plexora's server config.")
		enabled = FALSE
		flags |= SS_NO_FIRE
		return SS_INIT_FAILURE

	base_url = CONFIG_GET(string/plexora_url)

	default_headers = list(
		"Content-Type" = "application/json",
		"Authorization" = AUTH_HEADER,
	)

	// Do a ping test to check if Plexora is actually running
	if (!is_plexora_alive())
		stack_trace("SSplexora is enabled BUT plexora is not alive or running! SS has not been aborted, subsequent fires will take place.")
	else
		serverstarted()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(roundstarted))

	return SS_INIT_SUCCESS

/datum/controller/subsystem/plexora/Recover()
	flags |= SS_NO_INIT // Make extra sure we don't initialize twice.
	initialized = SSplexora.initialized
	plexora_is_alive = SSplexora.plexora_is_alive
	base_url = SSplexora.base_url
	enabled = SSplexora.enabled
	tripped_bad_version = SSplexora.tripped_bad_version
	default_headers = SSplexora.default_headers
	if(initialized && !enabled)
		flags |= SS_NO_FIRE

// compat thing so that it'll load plexora.json if it's still used
/datum/controller/subsystem/plexora/proc/load_old_plexora_config()
	if(!rustg_file_exists(OLD_PLEXORA_CONFIG))
		return FALSE
	var/list/old_config = json_decode(rustg_file_read(OLD_PLEXORA_CONFIG))
	if(!old_config["enabled"])
		return FALSE
	stack_trace("Falling back to [OLD_PLEXORA_CONFIG], you should really migrate to the PLEXORA_ENABLED and PLEXORA_URL config entries!")
	CONFIG_SET(flag/plexora_enabled, TRUE)
	CONFIG_SET(string/plexora_url, "http://[old_config["ip"]]:[old_config["port"]]")
	return TRUE

/datum/controller/subsystem/plexora/proc/is_plexora_alive()
	. = FALSE
	if(!enabled) return

	var/datum/http_request/request = new(RUSTG_HTTP_METHOD_GET, "[base_url]/alive")
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), 10 SECONDS)
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		plexora_is_alive = FALSE
		log_admin("Failed to check if Plexora is alive! She probably isn't. Check config on both sides")
		CRASH("Failed to check if Plexora is alive! She probably isn't. Check config on both sides")
	else
		var/list/json_body = json_decode(response.body)
		if (json_body["version_increment_counter"] != version_increment_counter)
			if (!tripped_bad_version)
				stack_trace("SSplexora's version does not match Plexora! SSplexora: [version_increment_counter] Plexora: [json_body["version_increment_counter"]]")
				tripped_bad_version = TRUE

		plexora_is_alive = TRUE
		return TRUE

/datum/controller/subsystem/plexora/fire()
	/*if((cur_day == "Sat") && (cur_hour >= 12 && cur_hour <= 18))
  	//hrp_available = check_byondserver_status("7cfa7daf")
	//else
    		hrp_available = FALSE */
	if(!is_plexora_alive()) return
	// Send current status to Plexora
	var/datum/world_topic/status/status_handler = new()
	var/list/status = status_handler.Run()

	http_request(
		RUSTG_HTTP_METHOD_POST,
		"[base_url]/status",
		json_encode(status),
		default_headers
	).begin_async()

/datum/controller/subsystem/plexora/Shutdown(hard = FALSE, requestedby)
	http_basicasync("serverupdates", list(
		"type" = "servershutdown",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.config?.map_name,
		"playercount" = length(GLOB.clients),
		"hard" = hard,
		"requestedby" = requestedby,
	))

/datum/controller/subsystem/plexora/proc/serverstarted()
	http_basicasync("serverupdates", list(
		"type" = "serverstart",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.config?.map_name,
		"playercount" = length(GLOB.clients),
	))

/datum/controller/subsystem/plexora/proc/serverinitdone(time)
	http_basicasync("serverupdates", list(
		"type" = "serverinitdone",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.config?.map_name,
		"playercount" = length(GLOB.clients),
		"init_time" = time,
	))

/datum/controller/subsystem/plexora/proc/roundstarted()
	http_basicasync("serverupdates", list(
		"type" = "roundstart",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.config?.map_name,
		"playercount" = length(GLOB.clients),
	))

/datum/controller/subsystem/plexora/proc/roundended()
	http_basicasync("serverupdates", list(
		"type" = "roundend",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.config?.map_name,
		"nextmap" = SSmapping.next_map_config?.map_name,
		"playercount" = length(GLOB.clients),
		"playerstring" = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]",
	))

/datum/controller/subsystem/plexora/proc/interview(datum/interview/interview)
	http_basicasync("interviewupdates", list(
		"id" = interview.id,
		"atomic_id" = interview.atomic_id,
		"owner_ckey" = interview.owner_ckey,
		"responses" = interview.responses,
		"read_only" = interview.read_only,
		"pos_in_queue" = interview.pos_in_queue,
		"status" = interview.status,
		"ip" = interview.owner?.address,
		"computer_id" = interview.owner?.computer_id,
	))

/datum/controller/subsystem/plexora/proc/check_byondserver_status(id)
	if (isnull(id)) return

	var/list/body = list(
		"id" = id
	)

	var/datum/http_request/request = new(RUSTG_HTTP_METHOD_GET, "[base_url]/byondserver_alive", json_encode(body), default_headers)
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), 5 SECONDS)
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		stack_trace("check_byondserver_status failed, likely an bad id passed ([id]) aka id of a server that doesnt exist")
		return FALSE
	else
		var/list/json_body = json_decode(response.body)
		return json_body["alive_likely"]

// note: recover_all_SS_and_recreate_master to force mc shit

/datum/controller/subsystem/plexora/proc/mc_alert(alert, level = 5)
	http_basicasync("serverupdates", list(
		"type" = "mcalert",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.config?.map_name,
		"playercount" = length(GLOB.clients),
		"playerstring" = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]",
		"defconstring" = alert,
		"defconlevel" = level,
	))

/datum/controller/subsystem/plexora/proc/new_note(list/note)
	note["replay_pass"] = CONFIG_GET(string/replay_password)
	http_basicasync("noteupdates", note)

/datum/controller/subsystem/plexora/proc/new_ban(list/ban)
	// TODO: It might be easier to just send off a ban ID to Plexora, but oh well.
	// list values are in sql_ban_system.dm
	ban["replay_pass"] = CONFIG_GET(string/replay_password)
	http_basicasync("banupdates", ban)

// Maybe we should consider that, if theres no admin_ckey when creating a new ticket,
// This isnt a bwoink. Other wise if it does exist, it is a bwoink.
/datum/controller/subsystem/plexora/proc/aticket_new(datum/admin_help/ticket, msg_raw, is_bwoink, urgent, admin_ckey = null)
	if(!enabled) return
	http_basicasync("atickets/new", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"name" = ticket.name,
		"ckey" = ticket.initiator_ckey,
		"key_name" = ticket.initiator_key_name,
		"is_bwoink" = is_bwoink,
		"urgent" = urgent,
		"msg_raw" = msg_raw,
		"opened_at" = rustg_unix_timestamp(),
		"replay_pass" = CONFIG_GET(string/replay_password),
		"icon_b64" = icon2base64(getFlatIcon(ticket.initiator.mob, SOUTH, no_anim = TRUE)),
		"admin_ckey" = admin_ckey,
	))

/datum/controller/subsystem/plexora/proc/aticket_closed(datum/admin_help/ticket, closed_by, close_type = AHELP_CLOSETYPE_CLOSE, close_reason = AHELP_CLOSEREASON_NONE)
	if(!enabled) return
	http_basicasync("atickets/close", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"closed_by" = closed_by,
		// Make sure the defines in __DEFINES/admin.dm match up with Plexora's code
		"close_reason" = close_reason,
		"close_type" = close_type,
		"time_closed" = rustg_unix_timestamp(),
	))

/datum/controller/subsystem/plexora/proc/aticket_reopened(datum/admin_help/ticket, reopened_by)
	if(!enabled) return
	http_basicasync("atickets/reopen", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"time_reopened" = rustg_unix_timestamp(),
		"reopened_by" = reopened_by, // ckey
	))

/datum/controller/subsystem/plexora/proc/aticket_pm(datum/admin_help/ticket, message, admin_ckey = null)
	if(!enabled) return
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["message"] = message

	// We are just.. going to assume that if there is no admin_ckey param,
	// that the person sending the message is not an admin.
	// no admin_ckey = user is the initiator

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_basicasync("atickets/pm", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"message" = message,
		"admin_ckey" = admin_ckey,
	))

/datum/controller/subsystem/plexora/proc/aticket_connection(datum/admin_help/ticket, is_disconnect = TRUE)
	if(!enabled) return
	http_basicasync("atickets/connection_notice", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"is_disconnect" = is_disconnect,
		"time_of_connection" = rustg_unix_timestamp(),
	))

// Begin Mentor tickets

/datum/controller/subsystem/plexora/proc/mticket_new(datum/request/ticket)
	if (!enabled) return
	http_basicasync("mtickets/new", list(
		"id" = ticket.id,
		"ckey" = ticket.owner_ckey,
		"key_name" = ticket.owner_name,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"opened_at" = rustg_unix_timestamp(),
		"icon_b64" = icon2base64(getFlatIcon(ticket.owner.mob, SOUTH, no_anim = TRUE)),
		"replay_pass" = CONFIG_GET(string/replay_password),
		"message" = ticket.message,
	))

/datum/controller/subsystem/plexora/proc/mticket_pm(datum/request/ticket, mob/frommob, mob/tomob, msg,)
	http_basicasync("mtickets/pm", list(
		"id" = ticket.id,
		"from_ckey" = frommob.ckey,
		"ckey" = tomob.ckey,
		"key_name" = tomob.key,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"timestamp" = rustg_unix_timestamp(),
		"icon_b64" = icon2base64(getFlatIcon(frommob, SOUTH, no_anim = TRUE)),
		"message" = msg,
	))

/datum/controller/subsystem/plexora/proc/topic_listener_response(token, data)
	if(!enabled) return
	http_basicasync("topic_emitter", list(
		"token" = token,
		"data" = data,
	))

/datum/controller/subsystem/plexora/proc/http_basicasync(path, list/body) as /datum/http_request
	RETURN_TYPE(/datum/http_request)
	if(!enabled) return

	var/datum/http_request/request = new(
		RUSTG_HTTP_METHOD_POST,
		"[base_url]/[path]",
		json_encode(body),
		default_headers,
		"tmp/response.json"
	)
	request.begin_async()
	return request

/datum/world_topic/plx_announce
	keyword = "PLX_announce"
	require_comms_key = TRUE

/datum/world_topic/plx_announce/Run(list/input)
	var/message = input["message"]
	var/from = input["from"]

	send_formatted_announcement(message, "From [from]")

// // not ready yet
// /datum/world_topic/plx_commandreport
// 	keyword = "PLX_commandreport"
// 	require_comms_key = TRUE

// /datum/world_topic/plx_commandreport/Run(list/input)
// 	priority_announce(text = input["text"], title = input["title"], encode_title = FALSE, encode_text = FALSE, color_override)

/datum/world_topic/plx_globalnarrate
	keyword = "PLX_globalnarrate"
	require_comms_key = TRUE

/datum/world_topic/plx_globalnarrate/Run(list/input)
	var/message = input["contents"]

	for(var/mob/player as anything in GLOB.player_list)
		to_chat(player, message)

/datum/world_topic/plx_who
	keyword = "PLX_who"
	require_comms_key = TRUE

/datum/world_topic/plx_who/Run(list/input)
	. = list()
	for(var/client/client as anything in GLOB.clients)
		if(QDELETED(client))
			continue
		. += list(list("key" = client.holder?.fakekey || client.key, "avgping" = "[round(client.avgping, 1)]ms"))

/datum/world_topic/plx_adminwho
	keyword = "PLX_adminwho"
	require_comms_key = TRUE

/datum/world_topic/plx_adminwho/Run(list/input)
	. = list()
	for (var/client/admin as anything in GLOB.admins)
		if(QDELETED(admin))
			continue
		var/admin_info = list(
			"name" = admin,
			"ckey" = admin.ckey,
			"rank" = admin.holder.rank_names(),
			"afk" = admin.is_afk(),
			"stealth" = !!admin.holder.fakekey,
			"stealthkey" = admin.holder.fakekey,
		)

		if(isobserver(admin.mob))
			admin_info["state"] = "observing"
		else if(isnewplayer(admin.mob))
			admin_info["state"] = "lobby"
		else
			admin_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(admin_info)

/datum/world_topic/plx_mentorwho
	keyword = "PLX_mentorwho"
	require_comms_key = TRUE

/datum/world_topic/plx_mentorwho/Run(list/input)
	. = list()
	for (var/client/mentor as anything in GLOB.mentors)
		if(QDELETED(mentor))
			continue
		var/list/mentor_info = list(
			"name" = mentor,
			"ckey" = mentor.ckey,
			"rank" = mentor.holder?.rank_names(),
			"afk" = mentor.is_afk(),
			"stealth" = !!mentor.holder?.fakekey,
			"stealthkey" = mentor.holder?.fakekey,
		)

		if(isobserver(mentor.mob))
			mentor_info["state"] = "observing"
		else if(isnewplayer(mentor.mob))
			mentor_info["state"] = "lobby"
		else
			mentor_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(mentor_info)

/datum/world_topic/plx_getloadoutrewards
	keyword = "PLX_getloadoutrewards"
	require_comms_key = TRUE

/datum/world_topic/plx_getloadoutrewards/Run(list/input)
	return subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart)

/datum/world_topic/plx_getunusualitems
	keyword = "PLX_getunusualitems"
	require_comms_key = TRUE

/datum/world_topic/plx_getunusualitems/Run(list/input)
	return GLOB.possible_lootbox_clothing

/datum/world_topic/get_unusualeffects
	keyword = "PLX_getunusualeffects"
	require_comms_key = TRUE

/datum/world_topic/get_unusualeffects/Run(list/input)
	return subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement

/datum/world_topic/plx_getsmites
	keyword = "PLX_getsmites"
	require_comms_key = TRUE

/datum/world_topic/plx_getsmites/Run(list/input)
	. = list()
	for (var/datum/smite/smite_path as anything in subtypesof(/datum/smite))
		var/smite_name = smite_path::name
		if(!smite_name)
			continue
		try
			var/datum/smite/smite_instance = new smite_path
			if (smite_instance.configure(new /datum/client_interface("fake_player")) == "NO_CONFIG")
				.[smite_name] = smite_path
			QDEL_NULL(smite_instance)
		catch
			pass()

/datum/world_topic/plx_gettwitchevents
	keyword = "PLX_gettwitchevents"
	require_comms_key = TRUE

/datum/world_topic/plx_gettwitchevents/Run(list/input)
	. = list()
	for (var/datum/twitch_event/event_path as anything in subtypesof(/datum/twitch_event))
		.[event_path::event_name] = event_path

/datum/world_topic/plx_getbasicplayerdetails
	keyword = "PLX_getbasicplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getbasicplayerdetails/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = "missingckey")

	var/list/returning = list(
		"ckey" = ckey
	)

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		returning["present"] = FALSE
	else
		returning["present"] = TRUE
		returning["key"] = client.key

	var/datum/player_details/details = GLOB.player_details[ckey]

	if (details)
		returning["byond_version"] = details.byond_version

	if (QDELETED(client))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)
		returning["playtime"] = mock_player.get_exp_living(FALSE)
	else
		returning["playtime"] = client.get_exp_living(FALSE)

	return returning

/datum/world_topic/plx_getplayerdetails
	keyword = "PLX_getplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getplayerdetails/Run(list/input)
	var/ckey = input["ckey"]
	var/omit_logs = input["omit_logs"]

	if (!ckey)
		return list("error" = "missingckey")

	var/datum/player_details/details = GLOB.player_details[ckey]

	if (QDELETED(details))
		return list("error" = "detailsnotexist")

	var/client/client = disambiguate_client(ckey)

	var/list/returning = list(
		"ckey" = ckey,
		"present" = !QDELETED(client),
		"admin_datum" = null,
		"logging" = details.logging,
		"played_names" = details.played_names,
		"byond_version" = details.byond_version,
		"achievements" = details.achievements.data,
	)

	var/mob/clientmob
	if (!QDELETED(client))
		returning["playtime"] = client.get_exp_living(FALSE)
		returning["key"] = client.key
		clientmob = client.mob
	else
		for (var/mob/mob as anything in GLOB.mob_list)
			if (!QDELETED(mob) && mob.ckey == ckey)
				clientmob = mob
				break

	if (!omit_logs)
		returning["logging"] = details.logging

	if (GLOB.admin_datums[ckey])
		var/datum/admins/ckeyadatum = GLOB.admin_datums[ckey]
		returning["admin_datum"] = list(
			"name" = ckeyadatum.name,
			"ranks" = ckeyadatum.ranks,
			"fakekey" = ckeyadatum.fakekey,
			"deadmined" = ckeyadatum.deadmined,
			"bypass_2fa" = ckeyadatum.bypass_2fa,
			"admin_signature" = ckeyadatum.admin_signature,
		)

	returning["mob"] = list(
		"name" = clientmob.name,
		"real_name" = clientmob.real_name,
		"type" = clientmob.type,
		"gender" = clientmob.gender,
		"stat" = clientmob.stat,
	)
	if (!QDELETED(client) && isliving(clientmob))
		var/mob/living/livingmob = clientmob
		returning["health"] = livingmob.health
		returning["maxHealth"] = livingmob.maxHealth
		returning["bruteloss"] = livingmob.bruteloss
		returning["fireloss"] = livingmob.fireloss
		returning["toxloss"] = livingmob.toxloss
		returning["oxyloss"] = livingmob.oxyloss

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_mobpicture
	keyword = "PLX_mobpicture"
	require_comms_key = TRUE

/datum/world_topic/plx_mobpicture/Run(list/input)
	var/ckey = input["ckey"]

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = "clientnotexist")

	var/returning = list(
		"icon_b64" = icon2base64(getFlatIcon(client.mob, no_anim = TRUE))
	)

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_generategiveawaycodes
	keyword = "PLX_generategiveawaycodes"
	require_comms_key = TRUE

/datum/world_topic/plx_generategiveawaycodes/Run(list/input)
	var/type = input["type"]
	var/codeamount = input["limit"]

	. = list()

	if (type == "loadout" && !input["loadout"])
		return

	for (var/i in 1 to codeamount)
		var/returning = list("type" = type)

		switch(type)
			if ("coin")
				var/amount = input["coins"]
				if (isnull(amount))
					amount = 5000
				returning["coins"] = amount
				returning["code"] = generate_coin_code(amount, TRUE)
			if ("loadout")
				var/loadout = input["loadout"]
				//we are not chosing a random one for this, you MUST specify
				if (!loadout) return
				returning["loadout"] = loadout
				returning["code"] = generate_loadout_code(loadout, TRUE)
			if ("antagtoken")
				var/tokentype = input["antagtoken"]
				if (!tokentype)
					tokentype = LOW_THREAT
				returning["antagtoken"] = tokentype
				returning["code"] = generate_antag_token_code(tokentype, TRUE)
			if ("unusual")
				var/item = input["unusual_item"]
				var/effect = input["unusual_effect"]
				if (!item)
					item = pick(GLOB.possible_lootbox_clothing)
				if (!effect)
					var/static/list/possible_effects = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
					effect = pick(possible_effects)
				returning["item"] = item
				returning["effect"] = effect
				returning["code"] = generate_unusual_code(item, effect, TRUE)

		. += list(returning)

/datum/world_topic/plx_givecoins
	keyword = "PLX_givecoins"
	require_comms_key = TRUE

/datum/world_topic/plx_givecoins/Run(list/input)
	var/ckey = input["ckey"]
	var/amount = input["amount"]
	var/reason = input["reason"]

	var/client/userclient = disambiguate_client(ckey)

	var/datum/preferences/prefs
	if (QDELETED(userclient))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)

		prefs = mock_player.prefs
	else
		prefs = userclient.prefs

	prefs.adjust_metacoins(ckey, amount, reason, donator_multipler = FALSE, respects_roundcap = FALSE, announces = FALSE)

	return list("totalcoins" = prefs.metacoins)

/datum/world_topic/plx_generategiveawaycode
	keyword = "PLX_generategiveawaycode"
	require_comms_key = TRUE

/datum/world_topic/plx_generategiveawaycode/Run(list/input)


/datum/world_topic/plx_forceemote
	keyword = "PLX_forceemote"
	require_comms_key = TRUE

/datum/world_topic/plx_forceemote/Run(list/input)
	var/target_ckey = input["ckey"]
	var/emote = input["emote"]
	var/emote_args = input["emote_args"]

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = "clientnomob")

	return list(
		"success" = client_mob.emote(emote, message = emote_args, intentional = FALSE)
	)

/datum/world_topic/plx_forcesay
	keyword = "PLX_forcesay"
	require_comms_key = TRUE

/datum/world_topic/plx_forcesay/Run(list/input)
	var/target_ckey = input["ckey"]
	var/message = input["message"]

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = "clientnomob")

	client_mob.say(message, forced = TRUE)

/datum/world_topic/plx_runtwitchevent
	keyword = "plx_runtwitchevent"
	require_comms_key = TRUE

/datum/world_topic/plx_runtwitchevent/Run(list/input)
	var/event = input["event"]
	// TODO: do something with the executor input
	//var/executor = input["executor"]

	if (!CONFIG_GET(string/twitch_key))
		return list("error" = "twitchkeynotconfigured")

	// cant be bothered, lets just call the topic.
	var/outgoing = list("TWITCH-API", CONFIG_GET(string/twitch_key), event,)
	SStwitch.handle_topic(outgoing)

/datum/world_topic/plx_smite
	keyword = "PLX_smite"
	require_comms_key = TRUE

/datum/world_topic/plx_smite/Run(list/input)
	var/target_ckey = input["ckey"]
	var/selected_smite = input["smite"]
	var/smited_by = input["smited_by_ckey"]

	if (!GLOB.smites[selected_smite])
		return "error=invalidsmite"

	var/client/client = disambiguate_client(target_ckey)

	if (QDELETED(client))
		return list("error" = "clientnotexist")

	// DIVINE SMITING!
	var/smite_path = GLOB.smites[selected_smite]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(client)
	if (configuration_success == FALSE)
		return

	// Mock admin
	var/datum/client_interface/mockadmin = new(key = smited_by)

	usr = mockadmin
	picking_smite.effect(client, client.mob)

/datum/world_topic/plx_jailmob
	keyword = "PLX_jailmob"
	require_comms_key = TRUE

/datum/world_topic/plx_jailmob/Run(list/input)
	var/ckey = input["ckey"]
	var/jailer = input["admin_ckey"]

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = "clientnomob")

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = jailer,
	)

	usr = mockadmin

	client_mob.forceMove(pick(GLOB.prisonwarp))
	to_chat(client_mob, span_adminnotice("You have been sent to Prison!"), confidential = TRUE)

	log_admin("Discord: [key_name(usr)] has sent [key_name(client_mob)] to Prison!")
	message_admins("Discord: [key_name_admin(usr)] has sent [key_name_admin(client_mob)] to Prison!")

/datum/world_topic/plx_ticketaction
	keyword = "PLX_ticketaction"
	require_comms_key = TRUE

/datum/world_topic/plx_ticketaction/Run(list/input)
	var/ticketid = input["id"]
	var/action_by_ckey = input["action_by"]
	var/action = input["action"]


	var/datum/client_interface/mockadmin = new(key = action_by_ckey)

	usr = mockadmin

	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	if (QDELETED(ticket)) return list("error" = "couldntfetchticket")

	if (action != "reopen" && ticket.state != AHELP_ACTIVE)
		return

	switch(action)
		if("reopen")
			if (ticket.state == AHELP_ACTIVE) return
			SSplexora.aticket_reopened(ticket, action_by_ckey)
			ticket.Reopen()
		if("reject")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_REJECT)
			ticket.Reject(action_by_ckey)
		if("icissue")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE, AHELP_CLOSEREASON_IC)
			ticket.ICIssue(action_by_ckey)
		if("close")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE)
			ticket.Close(action_by_ckey)
		if("resolve")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE)
			ticket.Resolve(action_by_ckey)
		if("mhelp")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE, AHELP_CLOSEREASON_MENTOR)
			ticket.MHelpThis(action_by_ckey)

/datum/world_topic/plx_sendaticketpm
	keyword = "PLX_sendaticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendaticketpm/Run(list/input)
	// We're kind of copying /proc/TgsPm here...
	var/ticketid = text2num(input["ticket_id"])
	var/input_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/stealth = input["stealth"]
	var/message = input["message"]

	var/requested_ckey = ckey(input_ckey)
	var/client/recipient = disambiguate_client(requested_ckey)

	if (QDELETED(recipient))
		return list("error" = "clientnotexist")

	var/datum/admin_help/ticket = ticketid ? GLOB.ahelp_tickets.TicketByID(ticketid) : GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)

	if (QDELETED(ticket))
		return list("error" = "couldntfetchticket")

	var/plx_tagged = "[sender]"

	var/adminname = stealth ? "Administrator" : plx_tagged
	var/stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if (!message)
		return list("error" = "sanitizationfailed")

	// I have no idea what this does honestly.


	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name_admin(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [message]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [message]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)

	recipient.receive_ahelp(
		"<a href='byond://?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)


	admin_ticket_log(recipient, "<font color='purple'>PM From [adminname]: [message]</font>", log_in_blackbox = FALSE)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(!QDELETED(recipient))
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT

/datum/world_topic/plx_sendmticketpm
	keyword = "PLX_sendmticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendmticketpm/Run(list/input)
	//var/ticketid = input["ticket_id"]
	var/target_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/message = input["message"]

	var/client/recipient = disambiguate_client(ckey(target_ckey))

	if (QDELETED(recipient))
		return list("error" = "clientnotexist")

	// var/datum/request/request = GLOB.mentor_requests.requests_by_id[num2text(ticketid)]

	SEND_SOUND(recipient, 'sound/items/bikehorn.ogg')
	to_chat(recipient, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(sender, recipient, TRUE, FALSE, FALSE)]</b>: [message]</font>")
	for(var/client/honked_client as anything in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_client) || honked_client == recipient)
			continue
		to_chat(honked_client,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<B><font color='green'>Mentor PM: [key_name_mentor(sender, honked_client, FALSE, FALSE)]-&gt;[key_name_mentor(recipient, honked_client, FALSE, FALSE)]:</B> <font color = #5c00e6> <span class='message linkify'>[message]</span></font>",
			confidential = TRUE)

#undef OLD_PLEXORA_CONFIG
#undef AUTH_HEADER
#undef TOPIC_EMITTER
