/datum/controller/subsystem/ticker/proc/save_tokens()
	rustg_file_write(json_encode(GLOB.saved_token_values), "[GLOB.log_directory]/tokens.json")

/datum/controller/subsystem/ticker/proc/distribute_rewards()
	var/hour = round((world.time - SSticker.round_start_time) / 36000)
	var/minute = round(((world.time - SSticker.round_start_time) - (hour * 36000)) / 600)
	var/added_xp = round(25 + (minute ** 0.85))
	for(var/client/client as anything in GLOB.clients)
		distribute_rewards_to_client(client, added_xp)

/datum/controller/subsystem/ticker/proc/distribute_rewards_to_client(client/client, added_xp)
	if(!istype(client) || QDELING(client))
		return
	var/datum/player_details/details = get_player_details(client)
	if(!QDELETED(client?.prefs))
		client?.prefs?.adjust_metacoins(client?.ckey, 75, "Played a Round")
		var/bonus = details?.roundend_monkecoin_bonus
		if(bonus)
			client?.prefs?.adjust_metacoins(client?.ckey, bonus, "Special Bonus")
		// WHYYYYYY
		if(QDELETED(client))
			return
		if(client?.mob?.mind?.assigned_role)
			add_jobxp(client, added_xp, client?.mob?.mind?.assigned_role?.title)
	if(QDELETED(client))
		return
	var/list/applied_challenges = details?.applied_challenges
	if(LAZYLEN(applied_challenges))
		var/mob/living/client_mob = client?.mob
		if(!istype(client_mob) || QDELING(client_mob) || client_mob?.stat == DEAD)
			return
		var/total_payout = 0
		for(var/datum/challenge/listed_challenge as anything in applied_challenges)
			if(listed_challenge.failed)
				continue
			total_payout += listed_challenge.challenge_payout
		if(total_payout)
			client?.prefs?.adjust_metacoins(client?.ckey, total_payout, "Challenge rewards.")

/datum/controller/subsystem/ticker/proc/refund_cassette()
	if(!length(GLOB.cassette_reviews))
		return

	for(var/id in GLOB.cassette_reviews)
		var/datum/cassette_review/review = GLOB.cassette_reviews[id]
		if(!review || review.action_taken) // Skip if review doesn't exist or already handled (denied / approved)
			continue

		var/ownerckey = review.submitted_ckey // ckey of who made the cassette.
		if(!ownerckey)
			continue

		var/client/client = GLOB.directory[ownerckey] // Use directory for direct lookup (Client might be a differnet mob than when review was made.)
		if(client && !QDELETED(client?.prefs))
			var/prev_bal = client?.prefs?.metacoins
			var/adjusted = client?.prefs?.adjust_metacoins(
				client?.ckey, 5000,
				reason = "No action taken on cassette:\[[review.submitted_tape.name]\] before round end.",
				announces = TRUE, donator_multipler = FALSE
			)
			if(!adjusted)
				message_admins("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins]. Issue logged.")
				log_admin("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins].")
			qdel(review)
