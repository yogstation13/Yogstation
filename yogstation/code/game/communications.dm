/datum/signal/proc/sanitize_data() // An NTSL-related proc, to help sanitize the crap that is shat out by those fuckin' script kiddies
	for(var/d in data)
		var/val = data[d]
		if(istext(val))
			data[d] = html_encode(val)
