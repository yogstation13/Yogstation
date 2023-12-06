#define DEFAULT_TTS_VOLUME 80
#define DEFAULT_TTS_VOLUME_RADIO 25
#define TTS_LOUDMODE_MULTIPLIER 1.5
#define TTS_COLOSSUS_MULTIPLIER 3

SUBSYSTEM_DEF(tts)
	name = "Text-to-Speech"
	init_order = INIT_ORDER_TTS

	priority = FIRE_PRIORITY_TTS
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	// TTS backend is not set to build in CI, but we want it to scream if it fails in real lobby
	flags = SS_OK_TO_FAIL_INIT

	var/pinging_tts = FALSE
	var/tts_alive = FALSE
	var/tts_capped = FALSE
	var/list/active_processing // Prevents us from queueing the same message twice, resulting in probable errors

/datum/controller/subsystem/tts/Initialize(timeofday)
	if(!CONFIG_GET(flag/tts_enable))
		return SS_INIT_NO_NEED
	if(!ping_tts())
		return SS_INIT_FAILURE
	active_processing = list()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/fire()
	if(CONFIG_GET(flag/tts_enable) && !pinging_tts)
		INVOKE_ASYNC(src, PROC_REF(ping_tts))

/// Ping TTS API - If we don't get a response, shut down TTS
/datum/controller/subsystem/tts/proc/ping_tts()
	pinging_tts = TRUE

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/ping")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code > 299)
		tts_alive = FALSE
	else
		tts_alive = TRUE

	pinging_tts = FALSE

	return tts_alive

/**
* @param {String} message - The message to feed the model i.e. "Hello, world!"
*
* @param {String} model - The model i.e. "GB-alba"
*
* @param {number} pitch - Pitch multiplier, range (0.5-2.0)
*
* @param {list} filters - Audio filters; See tts_filters.dm
*
* @param {list} receivers - List of weakrefs to receivers that should hear the message once completed
*
* @returns {sound/} or FALSE
*/
/datum/controller/subsystem/tts/proc/create_message(message, model, pitch = 1, list/filters = list(), list/receivers = list(), source, list/spans = list(), list/message_mods = list())
	if(spans[SPAN_ITALICS] || message_mods[RADIO_EXTENSION] || message_mods[MODE_HEADSET] || message_mods[WHISPER_MODE])
		return FALSE // Mutes any whispers or radio inputs, to both avoid duplication and asterisk spam
	if(spans[SPAN_CLOWN])
		pitch *= 1.5
	pitch = clamp(pitch, 0.5, 2)
	message = tts_filter(message) // Phonetically correct the message (NOT SANITIZATION!)
	var/sound/tts_sound_result = create_message_audio(message, model, pitch, filters)
	if(!tts_sound_result)
		return FALSE
	if(!istype(tts_sound_result))
		CRASH(tts_sound_result)

	for(var/datum/weakref/ref in receivers)
		var/mob/hearer = ref.resolve()
		if(!hearer || !istype(hearer))
			continue
		if(isnewplayer(hearer))
			continue
		if(!isobserver(hearer) && hearer.stat >= UNCONSCIOUS)
			continue
		var/volume = 0
		if(!filters[TTS_FILTER_RADIO])
			volume = hearer.client?.prefs?.read_preference(/datum/preference/numeric/tts_volume) || DEFAULT_TTS_VOLUME
		else
			volume = hearer.client?.prefs?.read_preference(/datum/preference/numeric/tts_volume_radio) || DEFAULT_TTS_VOLUME_RADIO
			if(filters[TTS_FILTER_MASKED]) // for some reason this combo is very loud!
				volume *= 0.7

		if(volume <= 0)
			continue

		if(spans[SPAN_COMMAND] || spans[SPAN_CLOWN])
			volume *= TTS_LOUDMODE_MULTIPLIER

		if(spans[SPAN_COLOSSUS])
			volume *= TTS_COLOSSUS_MULTIPLIER

		volume = clamp(volume, 0, 100)

		if(source)
			hearer.playsound_local(get_turf(source), vol = volume, S = tts_sound_result)
		else
			hearer.playsound_local(vol = volume, S = tts_sound_result)

	return TRUE

/datum/controller/subsystem/tts/proc/create_message_audio(spammy_message, model, pitch, list/filters)
	if(!CONFIG_GET(flag/tts_enable))
		return FALSE

	var/player_count = living_player_count()
	if(!tts_capped && player_count >= CONFIG_GET(number/tts_cap_shutoff))
		tts_capped = TRUE
		return FALSE

	if(tts_capped)
		if(player_count < CONFIG_GET(number/tts_uncap_reboot))
			tts_capped = FALSE
		else
			return FALSE

	if(!tts_alive || !can_fire || init_stage > Master.init_stage_completed)
		return FALSE

	/// anti spam
	/// Replaces any 3 or more consecutive characters with 2 consecutive characters
	var/static/regex/antispam_regex = new(@"(?=(.)\1\1).","g")
	/// We do not want to sanitize the message, as it goes in JSON body and is not exposed directly to CMD
	var/message = replacetext(spammy_message, antispam_regex, "")
	/// Delete when backend is updated
	var/san_message = sanitize_tts_input(message)
	/// We do want to sanitize the model
	var/san_model = sanitize_tts_input(model)
	if(!pitch || !isnum(pitch))
		pitch = 1

	var/string_filters = ""
	if(filters && islist(filters))
		string_filters = jointext(assoc_to_keys(filters), "-")
	var/file_name = "tmp/tts/[md5("[san_message][san_model][pitch][string_filters]")].wav"
	if(file_name in active_processing)
		return FALSE

	if(fexists(file_name))
		return sound(file_name)

	active_processing |= file_name

	// TGS updates can clear out the tmp folder, so we need to create the folder again if it no longer exists.
	if(!fexists("tmp/tts/init.txt"))
		rustg_file_write("rustg HTTP requests can't write to folders that don't exist, so we need to make it exist.", "tmp/tts/init.txt")

	if(!filters || !islist(filters))
		filters = list()

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	headers["Authorization"] = CONFIG_GET(string/tts_http_token)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?model=[url_encode(san_model)]&pitch=[url_encode(pitch)]", json_encode(list("message" = san_message, "filters" = filters)), headers, file_name)

	request.begin_async()

	UNTIL(request.is_complete())

	active_processing &= ~file_name

	var/datum/http_response/response = request.into_response()
	if(response.errored)
		fdel(file_name)
		return "TTS ERRORED: [response.error]"

	if(response.status_code > 299)
		fdel(file_name)
		return "TTS HTTP ERROR [response.status_code]: [response.body]"

	if(response.body == "bad auth" || response.body == "missing args" || response.body == "model not found")
		fdel(file_name)
		return "TTS BAD REQUEST: [response.body]"

	var/sound/tts_sound = sound(file_name)

	return tts_sound
