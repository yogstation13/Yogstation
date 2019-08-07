/datum/storyteller
	var/name = "Pause"
	var/desc = "Pauses point generation"
	var/probability = 0			//this storyteller can't get randomly picked anyways, regardless of probability

	var/minor_point_gain = 0	//amount of minor points gained every 10 seconds
	var/medium_point_gain = 0	//amount of medium points gained every 10 seconds
	var/major_point_gain = 0	//amount of major points gained every 10 seconds
	var/antag_point_gain = 0	//amount of antag points gained every 10 seconds

/datum/storyteller/proc/handle_point_change(amount, type, reason) //whenever an event occurs which usually increases/decreases points, the storyteller can modify the amount
	return 0 //Pause storyteller stops all point generation, both negative and positive