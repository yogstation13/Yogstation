/datum/antagonist/nukeop/clownop
	name = "Clown Operative"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	job_rank = ROLE_CLOWNOP
	nukeop_outfit = /datum/outfit/syndicate/clownop
	preview_outfit = null

/datum/antagonist/nukeop/clownop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/hornin.ogg', 100, FALSE, pressure_affected = FALSE)
	
/datum/antagonist/nukeop/leader/clownop
	name = "Clown Operative Leader"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop/leader
	
/datum/antagonist/nukeop/leader/clownop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/hornin.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/nukeop/clownop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = "Clown Operative"
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has clown op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has clown op'ed [key_name(new_owner)].")
