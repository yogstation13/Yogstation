/datum/http_request/New(...)
	. = ..()
	if(length(args))
		src.prepare(arglist(args))

/// Helper for `new /datum/http_request` with a return type,
/// so you can do stuff like `http_request(...).begin_async()`
/proc/http_request(...) as /datum/http_request
	RETURN_TYPE(/datum/http_request)
	return new /datum/http_request(arglist(args))
