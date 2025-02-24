/client/proc/reload_mentors()
	set name = "Reload Mentors"
	set category = "Admin"

	if(!src.holder)
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to reload all mentors?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	load_mentors()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reload All Mentors") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] manually reloaded mentors")
