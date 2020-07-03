/*
NOTES:
There is a DB table to track ckeys and associated discord IDs.
The system is kept per-server (EG: Terry will not notify people who pressed notify on Sybil), but the accounts are between servers so you dont have to relink on each server.
 ##################
# HOW THIS WORKS #
##################
User inputs their Discord ID on the server.
They then type !verify ckey in a channel on their discord
Then their Discord ID is linked to their Ckey in the databse
*/

SUBSYSTEM_DEF(discord)
	name = "Discord"
	flags = SS_NO_FIRE

	var/list/account_link_cache = list() // List that holds accounts to link, used in conjunction with TGS
	var/notify_file = file("data/notify.json")

 // Returns ID from ckey
/datum/controller/subsystem/discord/proc/lookup_id(lookup_ckey)
	var/datum/DBQuery/query_get_discord_id = SSdbcore.NewQuery(
		"SELECT discord_id FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = lookup_ckey)
	)
	if(!query_get_discord_id.Execute())
		qdel(query_get_discord_id)
		return
	if(query_get_discord_id.NextRow())
		. = query_get_discord_id.item[1]
	qdel(query_get_discord_id)

 // Returns ckey from ID
/datum/controller/subsystem/discord/proc/lookup_ckey(lookup_id)
	var/datum/DBQuery/query_get_discord_ckey = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE discord_id = :discord_id",
		list("discord_id" = lookup_id)
	)
	if(!query_get_discord_ckey.Execute())
		qdel(query_get_discord_ckey)
		return
	if(query_get_discord_ckey.NextRow())
		. = query_get_discord_ckey.item[1]
	qdel(query_get_discord_ckey)

 // Finalises link
/datum/controller/subsystem/discord/proc/link_account(ckey)
	var/datum/DBQuery/link_account = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET discord_id = :discord_id WHERE ckey = :ckey",
		list("discord_id" = account_link_cache[ckey], "ckey" = ckey)
	)
	link_account.Execute()
	qdel(link_account)
	account_link_cache -= ckey

 // Unlink account (Admin verb used)
/datum/controller/subsystem/discord/proc/unlink_account(ckey)
	var/datum/DBQuery/unlink_account = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET discord_id = NULL WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	unlink_account.Execute()
	qdel(unlink_account)

 // Clean up a discord account mention
/datum/controller/subsystem/discord/proc/id_clean(input)
	var/regex/num_only = regex("\[^0-9\]", "g")
	return num_only.Replace(input, "")