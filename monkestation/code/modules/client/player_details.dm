/datum/player_details
	/// Patreon data for this player.
	var/datum/patreon_data/patreon
	/// Twitch subscription data for this player.
	var/datum/twitch_data/twitch
	/// Currently active challenges.
	var/list/datum/challenge/active_challenges
	/// Currently applied challenges.
	var/list/datum/challenge/applied_challenges
	/// The challenge menu for this mob.
	var/datum/challenge_selector/challenge_menu
	/// Bonus monkecoins to reward this player at roundend.
	var/roundend_monkecoin_bonus = 0

/datum/player_details/New(player_key)
	. = ..()
	patreon = new(src)
	twitch = new(src)

/// Finds the current mob this player is in control of.
/datum/player_details/proc/find_current_mob() as /mob
	RETURN_TYPE(/mob)
	var/client/client = GLOB.directory[ckey]
	. = client?.mob
	if(.)
		return
	for(var/mob/mob as anything in GLOB.mob_list)
		if(!QDELETED(mob) && mob.ckey == ckey)
			return mob

/**
 * Gets a player details instance from a variable, whether it be a mob, a client, or a ckey.
 */
/proc/get_player_details(target) as /datum/player_details
	RETURN_TYPE(/datum/player_details)
	if(istype(target, /datum/player_details))
		return target // well, that was easy
	else if(istext(target))
		return GLOB.player_details[ckey(target)]
	else if(ismob(target))
		var/mob/mob_target = target
		// Check to see if there's a client first.
		. = mob_target.client?.player_details
		if(!. && mob_target.ckey)
			// Do they have a ckey? Let's try that.
			var/mob_ckey = replacetext(mob_target.ckey, "@", "")
			return GLOB.player_details[mob_ckey]
	else if(IS_CLIENT_OR_MOCK(target))
		var/datum/client_interface/client_target = target
		return client_target.player_details

