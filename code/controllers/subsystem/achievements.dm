SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	var/list/achievements = list()
	var/list/cached_achievements = list()

/datum/controller/subsystem/achievements/Initialize(timeofday)
	for(var/i in subtypesof(/datum/achievement))
		var/datum/achievement/A = i
		achievements[A] = initial(A.id)

		var/datum/DBQuery/medalQuery = SSdbcore.NewQuery("SELECT name, desc FROM [format_table_name("achievements")] WHERE id = '[initial(A.id)]'")
		medalQuery.Execute()
		if(!medalQuery.NextRow())
			var/datum/DBQuery/medalQuery2 = SSdbcore.NewQuery("INSERT INTO [format_table_name("achievements")] (name, id, desc) VALUES ('[initial(A.name)]', '[initial(A.id)]', '[initial(A.desc)]')")
			medalQuery2.Execute()
			qdel(medalQuery2)
		else if(medalQuery.item[1] != initial(A.name) || medalQuery.item[2] != initial(A.desc))
			var/datum/DBQuery/medalQuery2 = SSdbcore.NewQuery("UPDATE [format_table_name("achievements")] SET name = '[initial(A.name)]', desc = '[initial(A.desc)]' WHERE id = '[initial(A.id)]'")
			medalQuery2.Execute()
			qdel(medalQuery2)
		
		qdel(medalQuery)
		
	
	var/datum/DBQuery/ridOldChieves = SSdbcore.NewQuery("SELECT id FROM [format_table_name("achievements")]")
	if(!ridOldChieves.Execute())
		stack_trace("Could not run check for outdated achievements")
		qdel(ridOldChieves)
		return ..()
	
	while(ridOldChieves.NextRow())
		var/id = ridOldChieves.item[1]
		var/found_achievement = FALSE
		for(var/A in achievements)
			if(achievements[A] == id)
				found_achievement = TRUE
				break
		if(!found_achievement)
			stack_trace("Old achievement [id] found in database, removing")
			var/datum/DBQuery/getRidOfOldStuff = SSdbcore.NewQuery("DELETE FROM [format_table_name("achievements")] WHERE id = '[id]'")
			getRidOfOldStuff.Execute()
			var/datum/DBQuery/ridTheOtherTableAsWell = SSdbcore.NewQuery("DELETE FROM [format_table_name("earned_achievements")] WHERE id = '[id]'")
			ridTheOtherTableAsWell.Execute()
			qdel(ridTheOtherTableAsWell)
			qdel(getRidOfOldStuff)


	return ..()

/datum/controller/subsystem/achievements/proc/unlock_achievement(datum/achievement/achievement, client/C)
	if(!achievements[achievement])
		stack_trace("Achievement [initial(achievement.name)] not found in list of achievements when trying to unlock for [C.ckey]")
		return FALSE
	if(!has_achievement(achievement, C))
		var/datum/DBQuery/medalQuery = SSdbcore.NewQuery("INSERT INTO [format_table_name("earned_achievements")] (ckey, id) VALUES ('[C.ckey]', '[achievements[achievement]]')")
		medalQuery.Execute()
		qdel(medalQuery)
		cached_achievements[C.ckey] += achievement
		return TRUE

/datum/controller/subsystem/achievements/proc/has_achievement(datum/achievement/achievement, client/C)
	if(!achievements[achievement])
		stack_trace("Achievement [initial(achievement.name)] not found in list of achievements when checking for [C.ckey]")
	if(!cached_achievements[C.ckey])
		cache_achievements(C)

	return (achievement in cached_achievements[C.ckey])

/datum/controller/subsystem/achievements/proc/cache_achievements(client/C)
	var/datum/DBQuery/cacheQuery = SSdbcore.NewQuery("SELECT id FROM [format_table_name("earned_achievements")] WHERE ckey = '[C.ckey]'")
	cacheQuery.Execute()
	cached_achievements[C.ckey] = list()
	while(cacheQuery.NextRow())
		for(var/i in achievements)
			if(achievements[i] == cacheQuery.item[1])
				cached_achievements[C.ckey] += i
				break
	return
