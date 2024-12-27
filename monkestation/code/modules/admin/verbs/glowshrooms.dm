/client/proc/delete_all_glowshrooms()
	set category = "Admin.Game"
	set name = "Delete All Glowshrooms"
	set desc = "Deletes all glowshrooms in the world. Use this instead of SDQL, as this prevents them from spreading mid-deletion."
	if(!check_rights(R_ADMIN))
		return
	var/static/currently_nuking_glowshrooms = FALSE
	if(currently_nuking_glowshrooms)
		to_chat(src, span_warning("Someone is already in the process of clearing all glowshrooms!"))
		return

	currently_nuking_glowshrooms = TRUE
	message_admins("[key_name_admin(src)] started deleting all glowshrooms.")
	log_admin("[key_name(src)] started deleting all glowshrooms.")
	ASYNC
		nuke_glowshrooms()
		currently_nuking_glowshrooms = FALSE

/proc/nuke_glowshrooms()
	var/old_enable_spreading = SSglowshrooms.enable_spreading
	SSglowshrooms.enable_spreading = FALSE
	SSglowshrooms.can_fire = FALSE
	SSglowshrooms.currentrun_spread.Cut()
	SSglowshrooms.currentrun_decay.Cut()

	var/glowshrooms_deleted = 0
	for(var/obj/structure/glowshroom/glowshroom as anything in SSglowshrooms.glowshrooms)
		if(QDELETED(glowshroom))
			continue
		qdel(glowshroom)
		glowshrooms_deleted++
		CHECK_TICK
	SSglowshrooms.glowshrooms.Cut()

	SSglowshrooms.can_fire = TRUE
	SSglowshrooms.enable_spreading = old_enable_spreading
	message_admins("Cleared a total of [glowshrooms_deleted] glowshrooms.")
	log_admin("Cleared a total of [glowshrooms_deleted] glowshrooms.")

/client/proc/toggle_glowshroom_spread()
	set category = "Admin.Game"
	set name = "Toggle Glowshroom Spreading"
	set desc = "Toggles whether glowshrooms can spread or not. You don't need to use this if you're using the Delete All Glowshrooms verb, as that handles that on its own."
	if(!check_rights(R_ADMIN))
		return

	SSglowshrooms.enable_spreading = !SSglowshrooms.enable_spreading
	message_admins("[key_name_admin(src)] toggled glowshroom spreading [SSglowshrooms.enable_spreading ? "on" : "off"].")
	log_admin("[key_name(src)] toggled glowshroom spreading [SSglowshrooms.enable_spreading ? "on" : "off"].")
