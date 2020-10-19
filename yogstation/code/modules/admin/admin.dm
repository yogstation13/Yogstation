/client/proc/YogsPPoptions(mob/M) // why is this client and not /datum/admins? noone knows, in PP src == client, instead of holder. wtf. - I'm confused too man
	var/body = "<br>"
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];makementor=[M.ckey]'>Make mentor</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];removementor=[M.ckey]'>Remove mentor</A>"
	return body

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc = "can you even see verb descriptions anywhere?"
	set name = "Toggle LOOC"

	toggle_looc()
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] toggled LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle LOOC", "[GLOB.looc_allowed ? "Enabled" : "Disabled"]"))

/datum/admins/proc/toggleloocdead()
	set category = "Server"
	set desc = "seriously, why do we even bother"
	set name = "Toggle Dead LOOC"

	toggle_dlooc()
	log_admin("[key_name(usr)] toggled Dead LOOC.")
	message_admins("[key_name_admin(usr)] toggled Dead LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead LOOC", "[GLOB.dlooc_allowed ? "Enabled" : "Disabled"]"))