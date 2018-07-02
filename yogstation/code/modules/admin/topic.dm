/datum/admins/Topic(href, href_list)
	.=..()
	if(href_list["afreeze"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["afreeze"]) in GLOB.mob_list
		if(!M)
			return
		M.toggleafreeze(src.owner)