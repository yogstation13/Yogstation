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

/datum/achievement/greentext/nukewin
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

/datum/achievement/greentext/wizwin
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

/datum/achievement/greentext/changelingwin
	name = "The Thing"
	desc = "As a changeling, complete your objectives"
	id = 13

/datum/achievement/greentext/slingascend
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

// The achievements that are basically just "greentext as this sort of antag"

/datum/achievement/greentext
	name = "Green Text"
	desc = "As an Antagonist achieve your first green text"
	id = 23

/datum/achievement/greentext/ratvar
	name = "Clock Work"
	desc = "As a Servant of Ratvar summon Ratvar"
	id = 24

/datum/achievement/greentext/ratvar/eminence
	name = "Clock Work"
	desc = "As the Eminence, summon Ratvar"
	id = 25

/datum/achievement/greentext/narsie
	name = "Blood Rites"
	desc = "As a member of Blood Cult summon Nar-Sie"
	id = 26

/datum/achievement/greentext/narsie/master
	name = "Master of Blood"
	desc = "As a Cult Master, summon Nar-Sie"
	id = 27

/datum/achievement/greentext/revolution
	name = "Down with Nanotrasen"
	desc = "As a Revolutionary, complete your objectives"
	id = 28

/datum/achievement/greentext/revolution/head
	name = "Viva la Revolution!"
	desc = "As a Head Revolutionary, complete your objectives"
	id = 29

/datum/achievement/greentext/gang
	name = "Turf War"
	desc = "As a Gang Member, take over the station"
	id = 30

/datum/achievement/greentext/gangleader
	name = "\"I have built my organization upon fear.\""
	desc = "As a Gang Leader, take over the station"
	id = 31

/datum/achievement/greentext/blob
	name = "Grey Goo"
	desc = "As a Blob complete your objectives"
	id = 32

/datum/achievement/greentext/clownop
	name = "\"You wouldn't get it\""
	desc = "As a Clown Operative score a Major or Minor Victory"
	id = 33

/datum/achievement/greentext/internal
	name = "Triple Cross"
	desc = "As an Internal Affairs Agent, complete your objectives"
	id = 34

/datum/achievement/greentext/external
	name = "Quadruple Cross"
	desc = "As an External Affairs Agent, complete your objectives"
	id = 35

/datum/achievement/greentext/disease
	name = "Space Aids"
	desc = "As Sentient Disease, survive and complete your objectives"
	id = 36
//end-greentext

//start-redtext
/datum/achievement/redtext
	name = "Mission Failed, We'll Get'em Next Time"
	desc = "As an antagonist, fail your objectives."
	id = 37

/datum/achievement/redtext/winlost
	name = "Arcane Failure"
	desc = "As a Wizard, fail your objectives."
	id = 38
	hidden = TRUE
//end-redtext
