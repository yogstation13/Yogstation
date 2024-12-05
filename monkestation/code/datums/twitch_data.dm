/datum/twitch_data
	/// The details of the linked player.
	var/datum/player_details/owner
	///the stored twitch client key for the information
	var/client_key
	///the stored twitch rank collected from the server
	var/owned_rank = NO_TWITCH_SUB
	///access rank in numbers
	var/access_rank = 0

/datum/twitch_data/New(datum/player_details/owner)
	. = ..()
	if(!owner)
		return
	src.owner = owner
	if(!SSdbcore.IsConnected())
		owned_rank = ACCESS_TWITCH_SUB_TIER_3 ///this is a testing variable
		return

	fetch_rank()
	assign_twitch_rank()

/datum/twitch_data/proc/fetch_rank()
	var/datum/db_query/query_get_rank = SSdbcore.NewQuery("SELECT twitch_rank FROM [format_table_name("player")] WHERE ckey = :ckey", list("ckey" = owner.ckey))
	if(query_get_rank.warn_execute())
		if(query_get_rank.NextRow())
			owned_rank = query_get_rank.item[1] || NO_TWITCH_SUB
	qdel(query_get_rank)


/datum/twitch_data/proc/assign_twitch_rank()
	switch(owned_rank)
		if(TWITCH_SUB_TIER_1)
			access_rank =  ACCESS_TWITCH_SUB_TIER_1
		if(TWITCH_SUB_TIER_2)
			access_rank =  ACCESS_TWITCH_SUB_TIER_2
		if(TWITCH_SUB_TIER_3)
			access_rank =  ACCESS_TWITCH_SUB_TIER_3

/datum/twitch_data/proc/has_access(rank)
	if(!access_rank)
		assign_twitch_rank()
	if(rank <= access_rank)
		return TRUE
	return FALSE

/datum/twitch_data/proc/is_donator()
	return owned_rank != NO_TWITCH_SUB
