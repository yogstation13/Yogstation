GLOBAL_LIST_EMPTY(donators)
/world/proc/load_yogs_stuff()
	load_donators()
	load_mentors()

/world/proc/load_donators()
	var/list/donatorskeys = list()
	if(!SSdbcore.IsConnected())
		message_admins("Failed to connect to database in load_donators().")
		log_sql("Failed to connect to database in load_donators().")
		return

	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("donors")] WHERE (expiration_time > Now()) AND (revoked IS NULL)")
	if(!query.Execute())
		message_admins("Error loading donators from database.")
		log_sql("Error loading donators from database.")
		qdel(query)
		return

	var/ckey
	while(query.NextRow())
		ckey = query.item[1]
		if(ckey)
			donatorskeys |= ckey

	qdel(query)

	var/datum/preferences/P
	for(var/key in donatorskeys)
		ckey = ckey(key)
		GLOB.donators |= ckey
		P = GLOB.preferences_datums[ckey]
		if(P)
			P.unlock_content |= 2
