/datum/symptom/numb

	name = "Analgesia"
	desc = "The Virus attacks pain receptors in the host making them unable to feel injuries."
	stealth = 2
	resistance = -2
	stage_speed = 0
	transmittable = -2
	level = 5
	severity = 2
	base_message_chance = 15
	symptom_delay_min = 5		//quick because it needs to reduce stun times
	symptom_delay_max = 10
	var/stun_reduce = -15
	var/stamina_regen = FALSE
	threshold_descs = list(
		"Resistance 8" = "Increases stun resistance.",
		"Transmission 6" = "Gives stamina regen.",
		"Stealth 4" = "The symptom remains hidden until active."
	)
					  
/datum/symptom/numb/Start(datum/disease/advance/A)  //ADD Stamina reg, and a stun resist
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalResistance() >= 8)
		stun_reduce = -25
	if(A.totalTransmittable() >= 7)
		stamina_regen = TRUE
		
/datum/symptom/numb/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage < 5)
		if(prob(base_message_chance) && !suppress_warning)
			to_chat(M, "<span class='notice'>[pick("You feel better.")]</span>")
	else
		ADD_TRAIT(M, TRAIT_SURGERY_PREPARED, DISEASE_TRAIT)
		M.AdjustStun(stun_reduce, 0)
		M.set_screwyhud(SCREWYHUD_HEALTHY)
		if(stamina_regen)
			M.adjustStaminaLoss(-2, 0)
		M.updatehealth()
			
	return
	
/datum/symptom/numb/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	. = ..()
	if(!.)
		return
	else
		REMOVE_TRAIT(M, TRAIT_SURGERY_PREPARED, DISEASE_TRAIT)
		M.set_screwyhud(SCREWYHUD_NONE)
		M.updatehealth()
	return
