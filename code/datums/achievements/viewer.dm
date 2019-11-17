//UI adapted from https://github.com/tgstation/tgstation/pull/47058

/datum/achievement_browser
	var/client/client
	var/achievements = list()

/datum/achievement_browser/New(client/C)
	client = C
	get_achievements()

/datum/achievement_browser/proc/get_achievements()
	for(var/i in SSachievements.achievements)
		achievements[i] = SSachievements.has_achievement(i, client)

/datum/achievement_browser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "achievements", "achievements", 450, 450, master_ui, state)
		ui.open()

/datum/achievement_browser/ui_data(mob/user)
	var/data = list()
	get_achievements()
	for(var/datum/achievement/achievement in achievements)
		var/list/A = list(
			"name" = initial(achievement.name),
			"desc" = initial(achievement.desc),
			"unlocked" = achievements[achievement]
		)
		data["achievements"] += list(A)
	
	return data

/client/verb/checkachievements()
	set category = "OOC"
	set name = "Check achievements"
	set desc = "See all of your achivements"

	if(!SSachievements.initialized)
		to_chat(src, "SSachievements has not initialized yet, please wait.")
		return

	if(!achievement_browser)
		achievement_browser = new(src)
	achievement_browser.ui_interact(mob)
