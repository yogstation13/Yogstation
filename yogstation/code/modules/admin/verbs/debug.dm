/client/proc/cmd_edit_script()
	set category = "Debug"
	set name = "External Script - Edit"
	if(!check_rights(R_DEBUG))
		return
	log_admin("[key_name(src)] is editing the external script.")
	message_admins("[key_name(src)] is editing the external script.")
	SSexscript.edit_script()

/client/proc/cmd_run_script()
	set category = "Debug"
	set name = "External Script - Run"
	if(!check_rights(R_DEBUG))
		return
	log_admin("[key_name(src)] has run the external script.")
	message_admins("[key_name(src)] has run the external script.")
	SSexscript.run_script()

/client/proc/cmd_stop_script()
	set category = "Debug"
	set name = "External Script - Stop"
	if(!check_rights(R_DEBUG))
		return
	log_admin("[key_name(src)] has stopped the external script.")
	message_admins("[key_name(src)] has stopped the external script.")
	SSexscript.emergency_brake = 1