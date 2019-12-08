/datum/achievement
	var/name = "achievement"
	var/desc = "Please make an issue on github, including this achievement's name and how you got it."
	var/id = 0 //Should be incremented so every achievement has a unique ID
	var/hidden = FALSE // Whether or not this achievement's description is hidden untill you accomplish this (doesn't apply to the online viewer)

/datum/achievement/bubblegum
	name = "Kick Ass and Chew Bubblegum."
	desc = "Kill Bubblegum, the king of slaughter demons." //Should be improved(?)
	id = 1

/datum/achievement/roboborg
	name = "I live again"
	desc = "As a roboticist, create a cyborg"
	id = 2

/datum/achievement/defib
	name = "Lifesaver"
	desc = "Successfully defibrillate someone"
	id = 3

/datum/achievement/pa_emag			//Should be hidden but that's not a thing yet
	name = "Catastrophe"
	desc = "Emag a Particle Accelerator"
	id = 4
	hidden = TRUE
  
/datum/achievement/flukeops
	name = "Reverse Card"
	desc = "As a member of the Crew, deal a Humiliating defeat to Nuclear Team"
	id = 5

/datum/achievement/nukewin
	name = "Delta Alert"
	desc = "As a Nuclear Operative, score a Major or Minor Victory"
	id = 6

/datum/achievement/honorarynukie
	name = "Honorary Nukie"
	desc = "Kill yourself using the nuclear authentication disk"
	id = 7
	hidden = TRUE


/datum/achievement/dab
	name = "King of Dab"
	desc = "Hit the ULTIMATE dab"
	id = 420
	hidden = FALSE
