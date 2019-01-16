/client
	var/cachedmiddragtime

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	.=..()
	var/list/L = params2list(params)
	if (L["middle"])
		if(cachedmiddragtime <= middragtime - 20)
			cachedmiddragtime =middragtime
			log_game("[key_name(src)] is possibly using the middle click aimbot exploit")
			message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] is possibly using the middle click aimbot exploit</span>")