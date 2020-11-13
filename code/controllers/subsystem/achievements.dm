/**
  * # Achievements Subsystem
  *	
  * Subsystem used for keeping track of which achievements exist, who has them, and unlocking new ones.
  *
  *
  *	The subsystem is the midpoint between the game and the database, intended to make it as easy as possible to add new achievements
  * and functionalities. 
  * Admin calling any of the functions in this subsystem isn't a good idea, nor is varediting it unnecessarily, as it really is 
  * intended to be 100% code-side. 
  * Also relevant: [/datum/achievement] and [/datum/achievement_browser]
  *
  * For usage in code: use [/datum/controller/subsystem/achievements/proc/has_achievement] to check if they have an achievement, and [/datum/controller/subsystem/achievements/proc/unlock_achievement] to unlock it
  * 
  *
  */
SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_BACKGROUND
	/// List of all the achievement instances, one for each achievement. Access through [/datum/controller/subsystem/achievements/proc/get_achievement]
	var/list/achievements = list()
	/// Dictionary of cached achievements. Key is a username, value is a dictionary where the keys are achievements and the values are booleans signifying completion. See [/datum/controller/subsystem/achievements/proc/cache_achievements]
	var/list/cached_achievements = list()
	/// Dictionary of all achievement browsers. Key is a username, value is the given browser. See [/datum/achievement_browser] and [/datum/controller/subsystem/achievements/get_browser]
	var/list/browsers = list()
	/// Dictionary of all achievements earned this round. Key is a username, value is a list of achievements that have been earnt by that username. 
	var/list/achievementsEarned = list() // Really should get around to adding that to the round-end report
	/// The current guy that SSachievements believes to be the CE. See [/datum/controller/subsystem/achievements/proc/fire]
	var/mob/living/carbon/human/CE

/**
  * Sets up all the lists used by the subsystem and updates the database
  *
  * First it creates all the achievement instances, then it updates the database to remove old achievements and add any new ones
  * It also updates old achievement name/descriptions in the database to the new ones
  * 
  * Arguments:
  * * timeofday - Time of initialization, used to calculate how long SS initialization took
  */
/datum/controller/subsystem/achievements/Initialize(timeofday)
	for(var/i in subtypesof(/datum/achievement))
		var/datum/achievement/A = new i
		achievements[A] = A.id

		var/datum/DBQuery/medalQuery = SSdbcore.NewQuery("SELECT name, descr FROM [format_table_name("achievements")] WHERE id = :id", list("id" = A.id)) // No sanitation of A is needed for these calls because we instantiated A right here in this proc.
		medalQuery.Execute()
		if(!medalQuery.NextRow())
			var/datum/DBQuery/medalQuery2 = SSdbcore.NewQuery("INSERT INTO [format_table_name("achievements")] (name, id, descr) VALUES (:name, :id, :desc)", list("name" = A.name, "id" = A.id, "desc" = A.desc))
			medalQuery2.Execute()
			qdel(medalQuery2)
		else if(medalQuery.item[1] != A.name || medalQuery.item[2] != A.desc)
			var/datum/DBQuery/medalQuery2 = SSdbcore.NewQuery("UPDATE [format_table_name("achievements")] SET name = :name, descr = :desc WHERE id = :id", list("name" = A.name, "desc" = A.desc, "id" = A.id))
			medalQuery2.Execute()
			qdel(medalQuery2)

		qdel(medalQuery)


	var/datum/DBQuery/ridOldChieves = SSdbcore.NewQuery("SELECT id FROM [format_table_name("achievements")]")
	ridOldChieves.Execute()
	while(ridOldChieves.NextRow())
		var/id = text2num(ridOldChieves.item[1]) // This id var also doesn't need to be sanitized because it's from the actual database
		var/found_achievement = FALSE
		for(var/I in achievements)
			var/datum/achievement/A = I
			if(A.id == id)
				found_achievement = TRUE
				break
		if(!found_achievement)
			log_sql("Old achievement [id] found in database, removing")
			var/datum/DBQuery/getRidOfOldStuff = SSdbcore.NewQuery("DELETE FROM [format_table_name("achievements")] WHERE id = :id", list("id" = id))
			getRidOfOldStuff.Execute()
			var/datum/DBQuery/ridTheOtherTableAsWell = SSdbcore.NewQuery("DELETE FROM [format_table_name("earned_achievements")] WHERE id = :id", list("id" = id))
			ridTheOtherTableAsWell.Execute()
			qdel(ridTheOtherTableAsWell)
			qdel(getRidOfOldStuff)

	qdel(ridOldChieves)
	return ..()

/**
  * Subsystem firing, checks solar panel achievement
  *
  * Checks whether there's currently a [CE][/datum/controller/subsystem/achievements/var/CE], if there isn't, it tries to find one
  * Otherwise, it checks to see whether [/datum/achievement/engineering/scotty] should be triggered. It then calls [/datum/controller/subsystem/proc/fire]
  *
  * Arguments:
  * * resumed - Whether or not this was resumed from last tick (unlikely with this subsystem)
  */
/datum/controller/subsystem/achievements/fire(resumed)
	//The solar panel achievement
	if(!CE)
		for(var/x in GLOB.player_list)
			if(ishuman(x))
				var/mob/living/carbon/human/H = x
				if(H.mind?.assigned_role == "Chief Engineer")
					CE = H
					break
	else
		for(var/n in SSmachines.powernets)
			var/datum/powernet/net = n
			if(is_station_level(net.z)) // If the powernet is on the station z-level
				if(net.avail >= 3000 && CE.stat != DEAD && CE.client) // If there's 3 MW available (Value is in kW)
					unlock_achievement(/datum/achievement/engineering/scotty, CE.client)

/**
  * Unlocks the given achievement for the given client.
  *
  * Will log if the achievement getting unlocked doesn't exist.
  * Will unlock the given achievement, save it to the DB and cache it for the round.
  * This won't work if you're admin calling the proc, since SQL blocks admin-called queries
  *
  * Arguments:
  * * achievementPath - The typepath for the achievement you're trying to unlock. See [/datum/achievement]
  * * C - Client that you're unlocking it for, See [/client]
  *
  */
/datum/controller/subsystem/achievements/proc/unlock_achievement(achievementPath, client/C)
	if(!C)
		return FALSE
	var/datum/achievement/achievement = get_achievement(achievementPath)
	if(!achievement)
		log_sql("Achievement [achievementPath] not found in list of achievements when trying to unlock for [ckey(C.ckey)]")
		return FALSE
	if(istype(achievement, /datum/achievement/greentext) && achievementPath != /datum/achievement/greentext)
		unlock_achievement(/datum/achievement/greentext, C) // Oooh, a little bit recursive!
	if(!has_achievement(achievementPath, C))
		var/datum/DBQuery/medalQuery = SSdbcore.NewQuery("INSERT INTO [format_table_name("earned_achievements")] (ckey, id) VALUES (:ckey, :id)", list("ckey" = ckey(C.ckey), "id" = initial(achievement.id)))
		medalQuery.Execute()
		qdel(medalQuery)
		cached_achievements[C.ckey] += achievement
		achievementsEarned[C.ckey] += list(achievement) // Apparently adding a list to a nullvar just makes the var the list. Neat!
		to_chat(C, "<span class='greentext'>You have unlocked the \"[achievement.name]\" achievement!</span>")
		return TRUE

/**
  * Checks whether the client has an achievement. 
  *
  * Will create a cache of the given client's achievements if it doesn't already exist
  *
  * Arguments:
  * * achievementPath - The typepath for the achievement you're checking. See [/datum/achievement]
  * * C - Client that you're checking it for, See [/client]
  */

/datum/controller/subsystem/achievements/proc/has_achievement(achievementPath, client/C)
	var/datum/achievement/achievement = get_achievement(achievementPath)
	if(!achievement)
		log_sql("Achievement [achievementPath] not found in list of achievements when checking for [C.ckey]")
		return FALSE
	if(!cached_achievements[C.ckey])
		cache_achievements(C)

	return (achievement in cached_achievements[C.ckey])

/**
  * Creates a cache of all achievements and whether or not they're unlocked for the given ckey
  * 
  * Will likely not work if admins call this proc, since SQL calls as a result of admin calls are blocked
  *
  * Arguments: 
  * * C - Client that you're caching for, See [/client]
  */
/datum/controller/subsystem/achievements/proc/cache_achievements(client/C)
	var/datum/DBQuery/cacheQuery = SSdbcore.NewQuery("SELECT id FROM [format_table_name("earned_achievements")] WHERE ckey = :ckey", list("ckey" = ckey(C.ckey)))
	cacheQuery.Execute()
	cached_achievements[C.ckey] = list()
	while(cacheQuery.NextRow())
		for(var/i in achievements)
			if(achievements[i] == text2num(cacheQuery.item[1]))
				cached_achievements[C.ckey] += i
				break
	qdel(cacheQuery)
	return

/**
  * Gets the achievement browser for the given client. See [/datum/achievement_browser]
  *
  * If the achievement_browser doesn't exist, it'll create it and then return it
  *
  * Arguments:
  * * C - Client that you're getting the browser for, See [/client]
  */

/datum/controller/subsystem/achievements/proc/get_browser(client/C)
	return browsers[C.ckey] ? browsers[C.ckey] : new /datum/achievement_browser(C)

/**
  * Gets the achievement instance for the given achievement path
  *
  * Will return false if it doesn't exist, otherwise it'll get that exact achievement (subtypes aren't accepted)
  *
  * Arguments:
  * * achievementPath - The typepath for the achievement you're trying to get. See [/datum/achievement]
  */
/datum/controller/subsystem/achievements/proc/get_achievement(achievementPath)
	for(var/datum/achievement/i in achievements)
		if(istype(i, achievementPath) && !(i in subtypesof(achievementPath)))
			return i
	return FALSE
