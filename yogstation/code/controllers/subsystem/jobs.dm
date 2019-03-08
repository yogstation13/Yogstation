/datum/controller/subsystem/job/proc/PickCommander(candidates,jobname) 
	// Takes in a list of potential command role candidates from CheckHeadPositions and FindOccupation Candidates, and picks one weightedly based on hours.
	var/list/pickweightfood = list() // The list we'll be feeding to pickweights()
	for(var/i in candidates)
		var/mob/dead/new_player/candidate = candidates[i]
		var/hours = candidate.client.prefs.exp[jobname] / 60
		if(hours < 10) // Prevents fresh new guys from causing undefined errors or being 1000x less likely to get a role, when using log scale
			hours = 10
		pickweightfood[candidate] = log(10,hours) // Log base 10 of the hours
	return pickweight(pickweightfood)
