GLOBAL_DATUM(admin_event, /datum/admin_event)

/// Loads JSON event
/client/proc/load_json_admin_event()
	set name = "Load JSON Admin Event"
	set category = "Event"

	if(IsAdminAdvancedProcCall() || !check_rights(R_FUN))
		return

	var/json_data = input("Enter JSON Data:", "Text", "") as null|message
	if(!json_data)
		return

	var/event_data = json_decode(json_data)
	var/datum/admin_event/event = new
	event.name = event_data["name"]
	event.description = event_data["description"]

	for(var/role_type_string in event_data["role_greetings"])
		var/role_type = text2path(role_type_string)
		if(role_type)
			LAZYSET(event.role_greetings, role_type, event_data["role_greetings"][role_type_string])

	if(alert(usr, "Load [event.name]?", "JSON Event System", "Yes", "Cancel") != "Yes")
		qdel(event)
		return

	message_admins("[key_name_admin(usr)] loaded JSON event: [event.name]")
	log_admin_private("[key_name(usr)] loaded JSON for event [event.name]: [json_data]")
	event.load()

/client/proc/event_info()
	set name = "Event Info"
	set category = "Event"
	set desc = "Shows the event info for the current event, if any"
	if(GLOB.admin_event)
		GLOB.admin_event.show_info(src)

/datum/admin_event
	/// Name of the event
	var/name = ""

	/// Public description of the event
	var/description = ""

	/// Additional welcome messages for specific jobs and antag datums
	var/list/role_greetings

/datum/admin_event/proc/load()
	if(GLOB.admin_event)
		message_admins("Error loading [name]: [GLOB.admin_event.name] already loaded!")
		return
	GLOB.admin_event = src
	show_info(world)

	for(var/client/C in GLOB.clients)
		add_verb(C, /client/proc/event_info)

/datum/admin_event/proc/show_info(target)
	to_chat(target, examine_block("<h1>[name]</h1><br />[description]"))

/datum/admin_event/proc/greet_role(mob/M, role)
	var/greeting = LAZYACCESS(role_greetings, role)
	if(greeting)
		to_chat(M, examine_block("Role specific event information:<br />[greeting]"))
		return TRUE
	return FALSE

