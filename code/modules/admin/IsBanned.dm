//Blocks an attempt to connect before even creating our client datum thing.

//How many new ckey matches before we revert the stickyban to it's roundstart state
//These are exclusive, so once it goes over one of these numbers, it reverts the ban
#define STICKYBAN_MAX_MATCHES 15
#define STICKYBAN_MAX_EXISTING_USER_MATCHES 3 //ie, users who were connected before the ban triggered
#define STICKYBAN_MAX_ADMIN_MATCHES 1

/world/IsBanned(key, address, computer_id, type, real_bans_only=FALSE)
	var/static/key_cache = list()
	if(!real_bans_only)
		if(key_cache[key])
			return list("reason"="concurrent connection attempts", "desc"="You are attempting to connect too fast. Try again.")
		key_cache[key] = 1

	debug_world_log("isbanned(): '[args.Join("', '")]'")
	if (!key || (!real_bans_only && (!address || !computer_id)))
		if(real_bans_only)
			key_cache[key] = 0
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		key_cache[key] = 0
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	var/admin = FALSE
	var/ckey = ckey(key)

	if(!real_bans_only && GLOB.directory[ckey])
		key_cache[key] = 0
		return FALSE

	//IsBanned can get re-called on a user in certain situations, this prevents that leading to repeated messages to admins.
	var/static/list/checkedckeys = list()
	//magic voodo to check for a key in a list while also adding that key to the list without having to do two associated lookups
	var/message = !checkedckeys[ckey]++

	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = TRUE

	var/client/C = GLOB.directory[ckey]
	//Whitelist
	if(!real_bans_only && !C && CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey))
			if (admin)
				log_admin("The admin [key] has been allowed to bypass the whitelist")
				if (message)
					message_admins(span_adminnotice("The admin [key] has been allowed to bypass the whitelist"))
					addclientmessage(ckey,span_adminnotice("You have been allowed to bypass the whitelist"))
			else
				log_access("Failed Login: [key] - Not on whitelist")
				key_cache[key] = 0
				return list("reason"="whitelist", "desc" = "\nReason: You are not on the white list for this server")

	//Guest Checking
	if(!real_bans_only && !C && IsGuestKey(key))
		if (CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [key] - Guests not allowed")
			key_cache[key] = 0
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect())
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			key_cache[key] = 0
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
//Yogs start -- Keeps extreme popcap as always being a living-players count.
	if(!real_bans_only && extreme_popcap) // if we ought to use the extreme popcap
		if(living_player_count() + (SSticker && SSticker.queued_players.len) >= extreme_popcap) // if the extreme popcap has been reached
			if(!admin && !GLOB.joined_player_list.Find(ckey) && !(is_donator(C) || (C.ckey in get_donators()))) // if they are not exempt
				log_access("Failed Login: [key] - Population cap reached")
				key_cache[key] = 0
				return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")
/*Yogs continue
	if(!real_bans_only && !C && extreme_popcap && !admin)
		var/hard_popcap = CONFIG_GET(number/hard_popcap)

		var/popcap_value = living_player_count()
		if (hard_popcap)
			popcap_value = GLOB.clients.len
		if (!GLOB.enter_allowed || length(SSticker.queued_players) || !SSticker.HasRoundStarted())
			hard_popcap = 0
			popcap_value = GLOB.clients.len

		if(popcap_value >= extreme_popcap && (!hard_popcap || living_player_count() >= hard_popcap))
			log_access("Failed Login: [key] - Population cap reached")
			return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

Yogs End*/
	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			if (message)
				message_admins(msg)
		else
			if(!real_bans_only)
				var/datum/DBQuery/query_get_bound_creds = SSdbcore.NewQuery({"
					SELECT
						ckey,
						ip,
						computerid
					FROM [format_table_name("bound_credentials")]
					WHERE
						(ip = INET_ATON(:ip) OR computerid = :computerid)
				"}, list("ckey" = ckey, "ip" = address, "computerid" = computer_id))
				if(!query_get_bound_creds.warn_execute())
					qdel(query_get_bound_creds)
					return
				
				//Null = unchecked, false = verified, true = reject
				var/reject_bound_cid
				var/reject_bound_ip

				while(query_get_bound_creds.NextRow())
					var/bound_ckey = query_get_bound_creds.item[1]
					var/bound_ip = query_get_bound_creds.item[2]
					var/bound_cid = query_get_bound_creds.item[3]

					//We have yet to confirm the ip and this entry specifies one
					if(bound_ip && (reject_bound_ip != FALSE))
						//If it matches, we set it to false and we stop checking bound ips
						// Otherwise, we set it to true and it will reject the login if no bound ip is found
						reject_bound_ip = (bound_ckey != ckey)
					
					//Same logic but for cids
					if(bound_cid && (reject_bound_cid != FALSE))
						reject_bound_cid = (bound_ckey != ckey)

				if(reject_bound_cid || reject_bound_ip)
					var/cause = reject_bound_cid ? "computer ID" : "IP address"
					var/msg = {"This [cause] has been bound to another account.
					Please visit [CONFIG_GET(string/banappeals) || "the forums"] if this was done in error or if you have recently changed BYOND accounts."}
					log_access("Failed Login: [key] [computer_id] [address] - Bound [cause]")
					key_cache[key] = 0
					return list("reason" = "bound [cause]", "desc" = msg)
				
				qdel(query_get_bound_creds)

			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [key] is admin banned, and has been disallowed access."
						log_admin(msg)
						if (message)
							message_admins(msg)
					else
						var/msg = "Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						if (message)
							message_admins(msg)
							addclientmessage(ckey,span_adminnotice("Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."))
						continue
				var/expires = "This is a permanent ban."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]]
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[expires] If you wish to appeal this ban please use the keyword 'assistantgreytide' to register an account on the forums. Also please do not take anything from the current game round to the forums or discord."} //yogs
				log_access("Failed Login: [key] [computer_id] [address] - Banned (#[i["id"]])")
				key_cache[key] = 0
				if(address == i["ip"])
					SSblackbox.record_feedback("amount", "login_blocked_ips", 1)
					SSblackbox.record_feedback("tally", "login_blocked_ips_by_ckey", 1, key)
				if(computer_id == i["computerid"])
					SSblackbox.record_feedback("amount", "login_blocked_cids", 1)
					SSblackbox.record_feedback("tally", "login_blocked_cids_by_ckey", 1, key)
				return list("reason"="Banned","desc"="[desc]")

	var/list/ban = ..()	//default pager ban stuff

	if (ban)
		if (!admin)
			. = ban
		if (real_bans_only)
			key_cache[key] = 0
			return
		var/bannedckey = "ERROR"
		if (ban["ckey"])
			bannedckey = ban["ckey"]

		var/newmatch = FALSE
		var/list/cachedban = SSstickyban.cache[bannedckey]
		//rogue ban in the process of being reverted.
		if (cachedban && (cachedban["reverting"] || cachedban["timeout"]))
			world.SetConfig("ban", bannedckey, null)
			key_cache[key] = 0
			return null

		if (cachedban && ckey != bannedckey)
			newmatch = TRUE
			if (cachedban["keys"])
				if (cachedban["keys"][ckey])
					newmatch = FALSE
			if (cachedban["matches_this_round"][ckey])
				newmatch = FALSE

		if (newmatch && cachedban)
			var/list/newmatches = cachedban["matches_this_round"]
			var/list/pendingmatches = cachedban["matches_this_round"]
			var/list/newmatches_connected = cachedban["existing_user_matches_this_round"]
			var/list/newmatches_admin = cachedban["admin_matches_this_round"]

			if (C)
				newmatches_connected[ckey] = ckey
				newmatches_connected = cachedban["existing_user_matches_this_round"]
				pendingmatches[ckey] = ckey
				sleep(STICKYBAN_ROGUE_CHECK_TIME)
				pendingmatches -= ckey
			if (admin)
				newmatches_admin[ckey] = ckey

			if (cachedban["reverting"] || cachedban["timeout"])
				key_cache[key] = 0
				return null

			newmatches[ckey] = ckey


			if (\
				newmatches.len+pendingmatches.len > STICKYBAN_MAX_MATCHES || \
				newmatches_connected.len > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
				newmatches_admin.len > STICKYBAN_MAX_ADMIN_MATCHES \
			)

				var/action
				if (ban["fromdb"])
					cachedban["timeout"] = TRUE
					action = "putting it on timeout for the remainder of the round"
				else
					cachedban["reverting"] = TRUE
					action = "reverting to its roundstart state"

				world.SetConfig("ban", bannedckey, null)

				//we always report this
				log_game("Stickyban on [bannedckey] detected as rogue, [action]")
				message_admins("Stickyban on [bannedckey] detected as rogue, [action]")
				//do not convert to timer.
				spawn (5)
					world.SetConfig("ban", bannedckey, null)
					sleep(0.1 SECONDS)
					world.SetConfig("ban", bannedckey, null)
					if (!ban["fromdb"])
						cachedban = cachedban.Copy() //so old references to the list still see the ban as reverting
						cachedban["matches_this_round"] = list()
						cachedban["existing_user_matches_this_round"] = list()
						cachedban["admin_matches_this_round"] = list()
						cachedban -= "reverting"
						SSstickyban.cache[bannedckey] = cachedban
						world.SetConfig("ban", bannedckey, list2stickyban(cachedban))
				key_cache[key] = 0
				return null

		if (ban["fromdb"])
			if(SSdbcore.Connect())
				INVOKE_ASYNC(SSdbcore, /datum/controller/subsystem/dbcore/proc.QuerySelect, list(
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_ckey")] (matched_ckey, stickyban) VALUES (:ckey, :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("ckey" = ckey, "bannedckey" = bannedckey)
					),
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_ip")] (matched_ip, stickyban) VALUES (INET_ATON(:address), :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("address" = address, "bannedckey" = bannedckey)
					),
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_cid")] (matched_cid, stickyban) VALUES (:computer_id, :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("computer_id" = computer_id, "bannedckey" = bannedckey)
					)
				), FALSE, TRUE)


		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if (admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]")
			if (message)
				message_admins(span_adminnotice("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]"))
				addclientmessage(ckey,span_adminnotice("You have been allowed to bypass a matching host/sticky ban on [bannedckey]"))
			key_cache[key] = 0
			return null

		if (C) //user is already connected!.
			to_chat(C, "You are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect using file -> reconnect to see if the match was automatically reversed.", confidential=TRUE)

		var/desc = "\nReason:(StickyBan) You, or another user of this computer or connection ([bannedckey]) is banned from playing here. The ban reason is:\n[ban["message"]]\nThis ban was applied by [ban["admin"]]\nThis is a BanEvasion Detection System ban, if you think this ban is a mistake, please wait EXACTLY 6 seconds, then try again before filing an appeal. If you wish to appeal this ban please use the keyword 'assistantgreytide' to register an account on the forums.\n" //yogs
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [ban["message"]] Target Username: [bannedckey] Placed by [ban["admin"]]")

	key_cache[key] = 0
	return .


#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
