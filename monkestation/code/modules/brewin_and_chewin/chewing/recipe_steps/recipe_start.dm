
//The default starting step.
//Doesn't do anything, just holds the item.

/datum/chewin_cooking/recipe_step/start
	class = CHEWIN_START
	var/required_container

/datum/chewin_cooking/recipe_step/start/New(var/container)
	required_container = container

