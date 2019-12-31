/datum/achievement
	var/name = "achievement"
	var/desc = "Please make an issue on github, including this achievement's name and how you got it."
	var/id = 0 //Should be incremented so every achievement has a unique ID
	var/hidden = FALSE // Whether or not this achievement's description is hidden untill you accomplish this (doesn't apply to the online viewer)

/datum/achievement/bubblegum
	name = "Kick Ass and Chew Bubblegum"
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
  
/datum/achievement/badass
	name = "Badass Syndie"
	desc = "As a traitor, complete your objectives without buying any items"
	id = 8

/datum/achievement/jones
	name = "Lead Lined"
	desc = "Survive an explosion while inside of a freezer"
	id = 9
	hidden = TRUE

/datum/achievement/wizwin
	name = "Scholars of the Arcane"
	desc = "As a wizard, complete your objectives"
	id = 10

/datum/achievement/cpr
	name = "Breath of Life"
	desc = "Perform CPR on someone..."
	id = 11

/datum/achievement/anticpr
	name = "Breath of Death"
	desc = "... with incompatible lungs"
	id = 12
	hidden = TRUE

/datum/achievement/changelingwin
	name = "The Thing"
	desc = "As a changeling, complete your objectives"
	id = 13

/datum/achievement/slingascend
	name = "The Dark Shadow"
	desc = "As a shadowling, ascend successfully"
	id = 14

/datum/achievement/death
	name = "Flatlined"
	desc = "You died"
	id = 15

/datum/achievement/cremated
	name = "Back to Carbon"
	desc = "Get cremated"
	id = 16

/datum/achievement/cremated_alive
	name = "Burn in Hell"
	desc = "Get cremated... alive"
	id = 17
	hidden = TRUE

/datum/achievement/Poly_silent
	name = "Silence Bird!"
	desc = "As a signal technician create a script that mutes poly"
	id = 18
	hidden = TRUE

/datum/achievement/Poly_loud
	name = "Embrace The Bird!"
	desc = "As a signal technician create a script that makes poly LOUD"
	id = 19
	hidden = TRUE
  
/datum/achievement/cargoking
	name = "King of Credits"
	desc = "As the QM, beat the current record of cargo credits: " //theoretically, if someone manages to get to an amount that's larger than 1992 digits, this'd break DB things
	id = 20
	var/amount = 0

/datum/achievement/cargoking/New()
	.=..()
	var/datum/DBQuery/Q = SSdbcore.NewQuery("SELECT value FROM [format_table_name("misc")] WHERE `key` = 'cargorecord'")
	Q.Execute()
	if(Q.item.len)
		amount = Q.item[1]
	qdel(Q)
	desc += "[amount]"

/datum/achievement/likearecord
	name = "You spin me round"
	desc = "Use the surgical drill to spin right round like a record baby"
	id = 21
	hidden = TRUE
  
/datum/achievement/ducatduke
	name = "Duke of Ducats"
	desc = "As the QM, have a million cargo credits by the end of the round" //Cargoking-junior
	id = 22
