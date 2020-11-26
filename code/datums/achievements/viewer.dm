//UI adapted from https://github.com/tgstation/tgstation/pull/47058

/**
  * # Achievement browser
  *
  * One is created for every person who wants to view their achievements.
  * See: [/datum/controller/subsystem/achievements] and [/client/verb/checkachievements()]
  */
/datum/achievement_browser

/**
  * Instanciates the achievement browser
  *
  * Assigns the given client to this browser
  *
  * Arguments:
  * * C - The client we're created for. See [/client]
  */
/datum/achievement_browser/New(client/C)
	SSachievements.browsers[C.ckey] = src

/**
  * Fetches all the achievements for the client from SSachievements
  *
  * Returns a dictionary with each key being the achievement, and each value a boolean representing whether it's been unlocked
  *
  * Arguments:
  * * C - The client we're fetching achievements for. See [/client]
  */
/datum/achievement_browser/proc/get_achievements(client/C)
	var/list/A = list()
	for(var/i in SSachievements.achievements)
		A[i] = SSachievements.has_achievement(i, C)
	return A

// I don't even know what like, 7 of the args are for l m a o
/**
  * Opens the UI for the given user.
  *
  * Opens the TGUI for the given user. Called by [/client/verb/checkachievements]
  *
  * Arguments:
  * * user - The mob we're opening it for
  */
/datum/achievement_browser/ui_state(mob/user)
	return GLOB.always_state

/datum/achievement_browser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Achievements", "achievements")
		ui.open()

/**
  * Supplies the data for the TGUI window.
  *
  * Gives all the data necessary for the TGUI Window, including names, unlocked status, and descriptions
  *
  * Arguments:
  * * user - The mob we're opening the UI for. See [/mob]
  */
/datum/achievement_browser/ui_data(mob/user)
	var/data = list("achievements" = list())
	var/list/achievements = get_achievements(user.client)
	for(var/B in achievements)
		var/datum/achievement/achievement = B
		var/list/A = list(
			"name" = achievement.name,
			"unlocked" = achievements[achievement],
			"desc" = (!achievement.hidden || achievements[achievement]) ? achievement.desc : "???"
		)
		data["achievements"] += list(A)

	return data

/**
  * Verb for opening the achievement viewer
  *
  * Opens the achievement browser for the given client, see [/datum/achievement_browser]
  */
/client/verb/checkachievements()
	set category = "OOC"
	set name = "Check achievements"
	set desc = "See all of your achivements"

	if(!SSachievements.initialized)
		to_chat(src, "<span class='warning'>SSachievements has not initialized yet, please wait.</span>")
		return

	var/datum/achievement_browser/achievement_browser = SSachievements.get_browser(src)
	achievement_browser.ui_interact(usr)
