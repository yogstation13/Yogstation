#define UNTIL(X) while(!(X)) stoplag() // Used to be in unsorted.dm, but that is later than this file

/**
* @param {String} message - The message to feed the model i.e. "Hello, world!"
*
* @param {String} model - The model i.e. "GB-alba"
*
* @param {number} pitch - Pitch multiplier, range (0.5-2.0)
*
* @returns {sound/} or FALSE
*/
/proc/piper_tts(message, model, pitch, filters)
	if(!CONFIG_GET(flag/tts_enable))
		return FALSE

	var/player_count = living_player_count()
	if(!SSticker.tts_capped && player_count >= CONFIG_GET(number/tts_cap_shutoff))
		SSticker.tts_capped = TRUE
		return FALSE

	if(SSticker.tts_capped)
		if(player_count < CONFIG_GET(number/tts_uncap_reboot))
			SSticker.tts_capped = FALSE
		else
			return FALSE

	if(!SSticker.tts_alive)
		return FALSE

	var/san_message = sanitize_tts_input(message)
	var/san_model = sanitize_tts_input(model)
	if(!pitch || !isnum(pitch))
		pitch = 1

	var/string_filters = ""
	if(filters && islist(filters))
		string_filters = jointext(assoc_to_keys(filters), "-")
	var/file_name = "tmp/tts/[md5("[san_message][san_model][pitch][string_filters]")].wav"

	if(fexists(file_name))
		return sound(file_name)

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

	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code > 299)
		fdel(file_name)
		return FALSE

	if(response.body == "bad auth" || response.body == "missing args")
		fdel(file_name)
		return FALSE

	var/sound/tts_sound = sound(file_name)

	return tts_sound
