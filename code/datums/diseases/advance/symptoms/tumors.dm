//benign, premalignant, malignant tumors

/datum/symptom/tumor
	name = "Benign tumors"
	desc = "The virus causes benign growths all over your body."
	stealth = 0
	resistance = 4
	stage_speed = -4
	transmittable = -4
	level = 1
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 35
	threshold_descs = list(
		"Transmission 7" = "Gives visible growths on the host's body.",
		"Stealth 4" = "Regenerates limbs that are incredibly fragile.",
	)
	var/regeneration = FALSE

/datum/symptom/tumor/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 7) //visible growths
		if(ishuman(A.affected_mob))
			A.affected_mob.visible_tumors = TRUE
	if(A.totalStealth() >= 4) //regeneration of limbs
		regeneration = TRUE

/datum/symptom/tumor/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	if(prob(100)) //2% chance to make a new tumor somewhere
		var/obj/item/organ/tumor/T = new()
		T.Insert(M)

/datum/symptom/tumor/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		//unfuck their tumors
		A.affected_mob.visible_tumors = FALSE
