/**
* @param {String} message - The message to feed the model i.e. "Hello, world!"
*
* @param {String} model - The model i.e. "GB-alba"
*
* @returns {sound/} or FALSE
*/
/proc/piper_tts(message, model)
	var/san_message = sanitize_tts_input(message)
	var/output_filepath = "piper/cache/[md5("[san_message][model]")].wav"
	if(fexists(output_filepath))
		return sound(output_filepath)

	var/set_quality
	if(fexists("piper/voices/[model]/low/en_[model]-low.onnx"))
		set_quality = "low"
	else if(fexists("piper/voices/[model]/medium/en_[model]-medium.onnx"))
		set_quality = "medium"
	else if(fexists("piper/voices/[model]/high/en_[model]-high.onnx"))
		set_quality = "high"

	if(!set_quality)
		return FALSE

	if(world.system_type == MS_WINDOWS)
		world.shelleo("echo \"[san_message]\" | \"./piper/windows_amd64/piper.exe\" --model \"./piper/voices/[model]/[set_quality]/en_[model]-[set_quality].onnx\" --output_file \"./[output_filepath]\" -q")
	else
		world.shelleo("echo \"[san_message]\" | \"./piper/linux_x86_64/piper\" --model \"./piper/voices/[model]/[set_quality]/en_[model]-[set_quality].onnx\" --output_file \"./[output_filepath]\" -q")

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(fdel_defined), output_filepath), 5 MINUTES)

	return sound(output_filepath)

/proc/fdel_defined(filepath)
	fdel(filepath)
