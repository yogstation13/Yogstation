/client/proc/get_ooc()
	var/msg = input(src, null, "ooc \"text\"") as text|null
	ooc(msg)