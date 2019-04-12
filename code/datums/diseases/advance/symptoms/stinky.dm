/*
//////////////////////////////////////
Stinky Syndicate
	Somewhat Noticable.
	Increases resistance.
	Increases stage speed.
	Very transmittible.
Bonus
	Forces a spread type of AIRBORNE
	with extra range!
//////////////////////////////////////
*/

/datum/symptom/stinky
	name = "Stinky Syndicate"
	desc = "A highly resistant virus causing rapid secretion of body odors that easily spread to nearby humans."
	stealth = 2
	resistance = 10
	stage_speed = 2
	transmittable = 4
	level = 666
	severity = 7
	symptom_delay_min = 5
	symptom_delay_max = 35
	threshold_desc = "<b>Transmission 9:</b> Increases stink range, spreading the virus over a larger area."


/datum/symptom/stinky/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 9) //longer spread range
		power = 2

/datum/symptom/stinky/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/human/H = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(!suppress_warning)
				H.set_hygiene(HYGIENE_LEVEL_DIRTY) 
		else
			H.set_hygiene(HYGIENE_LEVEL_DIRTY)
			if(H.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
				A.spread(4 + power)
