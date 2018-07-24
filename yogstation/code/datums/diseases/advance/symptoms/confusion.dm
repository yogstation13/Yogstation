/datum/symptom/confusion/numb

	name = "Nerve hardening"
	desc = "The virus strengthens nerve connections decreasing interference to nerve connections, as a side effect the nervous system no longer reacts to pain."
	stealth = 2
	resistance = -2
	stage_speed = 0
	transmittable = -2
	level = 1
	severity = 2
	base_message_chance = 15
	symptom_delay_min = 5		//quick because it needs to reduce stun times
	symptom_delay_max = 10
	var/stun_reduce = -15
	var/stamina_regen = FALSE
	threshold_desc = "<b>Resistance 8:</b> Increases stun resistance.<br>\
					  <b>Transmission 6:</b> Increases confusion duration.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."
					  
/datum/symptom/confusion/numb/Start(datum/disease/advance/A)  //ADD Stamina reg, and a stun resist
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 8)
		stun_reduce = -25
	if(A.properties["transmission"] >= 7)
		stamina_regen = TRUE
		
/datum/symptom/confusion/numb/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='notice'>[pick("You feel better.")]</span>")
		else
			M.AdjustStun(stun_reduce, 0)
			M.set_screwyhud(SCREWYHUD_HEALTHY)
			if(stamina_regen)
				M.adjustStaminaLoss(-2, 0)
			M.updatehealth()
			
	return
	
/datum/symptom/confusion/numb/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(!..())
		return
	else
		M.set_screwyhud(SCREWYHUD_NONE)
		M.updatehealth()
	return
