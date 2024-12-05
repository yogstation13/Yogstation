/datum/patreon_data
	/// The details of the linked player.
	var/datum/player_details/owner
	///the stored patreon client key for the information
	var/client_key
	///the stored patreon rank collected from the server
	var/owned_rank = NO_RANK
	///access rank in numbers
	var/access_rank = 0


/datum/patreon_data/New(datum/player_details/owner)
	. = ..()
	if(!owner)
		return
	src.owner = owner
	if(!SSdbcore.IsConnected())
		owned_rank = NUKIE_RANK ///this is a testing variable
		return

	fetch_key_and_rank()
	assign_access_rank()

/datum/patreon_data/proc/fetch_key_and_rank()
	var/datum/db_query/query_get_key = SSdbcore.NewQuery("SELECT patreon_key, patreon_rank FROM [format_table_name("player")] WHERE ckey = :ckey", list("ckey" = owner.ckey))
	if(query_get_key.warn_execute())
		if(query_get_key.NextRow())
			client_key = query_get_key.item[1]
			owned_rank = query_get_key.item[2]
			if(owned_rank == "UNSUBBED2")
				owned_rank = NO_RANK
	qdel(query_get_key)

/datum/patreon_data/proc/assign_access_rank()
	switch(owned_rank)
		if(THANKS_RANK)
			access_rank =  ACCESS_THANKS_RANK
		if(ASSISTANT_RANK)
			access_rank =  ACCESS_ASSISTANT_RANK
		if(COMMAND_RANK)
			access_rank =  ACCESS_COMMAND_RANK
		if(TRAITOR_RANK)
			access_rank =  ACCESS_TRAITOR_RANK
		if(NUKIE_RANK, OLD_NUKIE_RANK, REALLY_ANOTHER_FUCKING_NUKIE_RANK)
			access_rank =  ACCESS_NUKIE_RANK

/datum/patreon_data/proc/has_access(rank)
	if(!access_rank)
		assign_access_rank()
	if(rank <= access_rank)
		return TRUE
	return FALSE

/datum/patreon_data/proc/is_donator()
	return owned_rank && owned_rank != NO_RANK && owned_rank != UNSUBBED
