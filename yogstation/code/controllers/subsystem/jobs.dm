/datum/controller/subsystem/job/proc/PickCommander(candidates,jobname) 
	// Takes in a list of potential command role candidates from CheckHeadPositions and FindOccupation Candidates, and picks one weightedly based on hours.
	var/list/pickweightfood = list() // The list we'll be feeding to pickweights()
	for(var/x in candidates)
		var/mob/dead/new_player/candidate = x
		var/minutes = candidate.client.prefs.exp[jobname]
		if(!minutes || minutes < 600) 
			minutes = 600 // Prevents fresh new guys from causing undefined errors or being 1000x less likely to get a role, when using log scale
		pickweightfood[candidate] = log(10,minutes/60) // Log base 10 of the hours
		//Yes, doing the log of the hours instead of the minutes does affect things.
	return pickweight(pickweightfood)
