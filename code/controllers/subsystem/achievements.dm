SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_BACKGROUND
	var/list/achievements = list()
	var/list/cached_achievements = list()
	var/list/browsers = list()
	var/list/achievementsEarned = list()
	var/mob/living/carbon/human/CE // The current guy that SSachievements believes to be the CE.

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

//Ad-hoc procs
/datum/controller/subsystem/achievements/proc/unlock_achievement(achievementPath, client/C)
	if(!C)
		return FALSE
	var/datum/achievement/achievement = get_achievement(achievementPath)
	if(!achievement)
		log_sql("Achievement [achievementPath] not found in list of achievements when trying to unlock for [ckey(C.ckey)]")
		return FALSE
	if(istype(achievement,/datum/achievement/greentext) && achievementPath != /datum/achievement/greentext)
		unlock_achievement(/datum/achievement/greentext,C) // Oooh, a little bit recursive!
	if(!has_achievement(achievementPath, C))
		var/datum/DBQuery/medalQuery = SSdbcore.NewQuery("INSERT INTO [format_table_name("earned_achievements")] (ckey, id) VALUES (:ckey, :id)", list("ckey" = ckey(C.ckey), "id" = initial(achievement.id)))
		medalQuery.Execute()
		qdel(medalQuery)
		cached_achievements[C.ckey] += achievement
		if(!achievementsEarned[C.ckey])
			achievementsEarned[C.ckey] = list()
		achievementsEarned[C.ckey] += achievement
		to_chat(C, "<span class='greentext'>You have unlocked the \"[achievement.name]\" achievement!</span>")
		return TRUE

/datum/controller/subsystem/achievements/proc/has_achievement(achievementPath, client/C)
	var/datum/achievement/achievement = get_achievement(achievementPath)
	if(!achievement)
		log_sql("Achievement [achievementPath] not found in list of achievements when checking for [C.ckey]")
		return FALSE
	if(!cached_achievements[C.ckey])
		cache_achievements(C)

	return (achievement in cached_achievements[C.ckey])

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

/datum/controller/subsystem/achievements/proc/get_browser(client/C)
	return browsers[C.ckey]

/datum/controller/subsystem/achievements/proc/get_achievement(achievementPath)
	for(var/datum/achievement/i in achievements)
		if(i.type == achievementPath) // Can't use istype() here since it needs to be the EXACT correct type.
			return i
	return FALSE
