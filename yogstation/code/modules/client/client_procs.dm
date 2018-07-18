/client/proc/sync_logout_with_db(number)
	if(!number)
		message_admins("Failed to update logout for \"[ckey]\", check server logs and notify coders")
		log_sql("Could not update logout for ckey \"[ckey]\"; connection_number = \"[number]\"")
		return

	if(!SSdbcore.Connect())
		return

	var/datum/DBQuery/query_logout = SSdbcore.NewQuery("UPDATE [format_table_name("connection_log")] SET left = Now() WHERE id = [number]")
	query_logout.Execute()
	qdel(query_logout)