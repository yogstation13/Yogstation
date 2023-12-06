/// Helper for logging chat messages or other logs with arbitrary inputs (e.g. announcements)
/atom/proc/log_talk(message, message_type, tag=null, log_globally=TRUE, forced_by=null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix]\"[message]\"[suffix]", message_type, log_globally=log_globally)

/// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, message_type, tag="[tag] from [key_name(source)]", log_globally=FALSE)
