/*
//////////////////////////////////////
Stinky
	Very Noticable.
	Increases resistance.
	Increases stage speed.
	Very transmissible.
	High Level.
Bonus
	Forces a spread type of AIRBORNE (Might need to change airborne due to covering of mouth)
	with extra range!
//////////////////////////////////////
*/

/datum/symptom/stinky
	name = "Stinky Syndicate Virus"
	desc = "The highly resistant virus causes rapid secretion of body odors that spreads to nearby hosts."
	stealth = 0
	resistance = 10
	stage_speed = 4
	transmittable = 4
	level = 666
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 35
	threshold_desc = "<b>Transmission 9:</b> Increases stink range, spreading the virus over a larger area.<br>

/datum/symptom/stinky/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 9) //longer spread range
		power = 2

// Need to edit the shit below this and have it affect your hygiene.


/datum/symptom/stinky/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(!suppress_warning)
				 M.emote("sniff") 
		else
			M.emote("sneeze")
			if(M.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
				A.spread(4 + power)
