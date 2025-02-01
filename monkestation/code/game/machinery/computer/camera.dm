/obj/machinery/camera/proc/count_spesstv_viewers()
	. = 0
	var/list/spesstv_viewers = GLOB.spesstv_viewers // just in case this ends up being a hot proc
	for(var/key in spesstv_viewers)
		if(spesstv_viewers[key] == c_tag)
			.++
