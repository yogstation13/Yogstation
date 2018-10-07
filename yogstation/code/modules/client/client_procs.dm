/client/proc/sync_logout_with_db(number)
	if(!number)
		return

	if(!SSdbcore.Connect())
		return

	var/datum/DBQuery/query_logout = SSdbcore.NewQuery("UPDATE [format_table_name("connection_log")] SET `left` = Now() WHERE id = [number]")
	query_logout.Execute(async = FALSE)
	qdel(query_logout)
