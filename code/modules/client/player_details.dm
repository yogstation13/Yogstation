
///assoc list of ckey -> /datum/player_details
GLOBAL_LIST_EMPTY_TYPED(player_details, /datum/player_details)

/datum/player_details
	/// The ckey of the player this is tied to.
	var/ckey
	/// Action datums assigned to this player
	var/list/datum/action/player_actions = list()
	/// Tracks client action logging
	var/list/logging = list()
	/// Callbacks invoked when this client logs in again
	var/list/post_login_callbacks = list()
	/// Callbacks invoked when this client logs out
	var/list/post_logout_callbacks = list()
	/// List of names this key played under this round
	/// assoc list of name -> mob tag
	var/list/played_names = list()
	/// Major version of BYOND this client is using.
	var/byond_version
	/// Build number of BYOND this client is using.
	var/byond_build
	/// Tracks achievements they have earned
	var/datum/achievement_data/achievements

/datum/player_details/New(player_key)
	src.ckey = ckey(player_key)
	achievements = new(src.ckey)

/// Returns the full version string (i.e 515.1642) of the BYOND version and build.
/datum/player_details/proc/full_byond_version()
	if(!byond_version)
		return "Unknown"
	return "[byond_version].[byond_build || "xxx"]"

/proc/log_played_names(ckey, ...)
	if(!ckey || length(args) < 2)
		return
	var/list/names = args.Copy(2)
	var/datum/player_details/details = GLOB.player_details[ckey]
	for(var/name in names)
		if(name)
			details.played_names |= name
