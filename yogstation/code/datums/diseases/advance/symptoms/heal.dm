/datum/symptom/heal/conversion
	name = "Rapid Protein Synthesis"
	desc = "The virus rapidly consumes nutrients in blood to heal wounds."
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmittable = -2
	level = 6
	passive_message = "<span class='notice'>You feel tough.</span>"
	var/Toxin_damage = FALSE
	var/Hunger_reduction = 8
	threshold_descs = list(
		"Resistance 9" = "No blood loss.",
		"Stage Speed 7" = "Reduces nutrients used."
	)

/datum/symptom/heal/conversion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		Hunger_reduction = 4
	if(A.properties["resistance"] >= 9)
		Toxin_damage = TRUE
		
/datum/symptom/heal/conversion/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	
	if(HAS_TRAIT(M, TRAIT_NOHUNGER))
		return FALSE
	
	switch(M.nutrition)
		if(0)
			return FALSE
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_STARVING)
			return 0.5
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			return 1
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			return 1.5
		else
			return 2
		
/datum/symptom/heal/conversion/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power
	var/Hunger_multi = actual_power
	
	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return
		
	M.adjust_nutrition(-(Hunger_reduction * Hunger_multi)) // So heal to nutrient ratio doesnt change
	
	if(M.nutrition <= NUTRITION_LEVEL_STARVING && !Toxin_damage)
		M.blood_volume -= 10
		if(prob(45))
			to_chat(M, "<span class='warning'>You feel like you are wasting away!</span>")
	
	if(Toxin_damage)
		M.adjustToxLoss(2)
		if(prob(45))
			to_chat(M, "<span class='warning'>You dont feel so well.</span>")
	
	if(prob(25))
		to_chat(M, "<span class='notice'>You feel your wounds getting warm.</span>")

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len))
			M.update_damage_overlays()

	return TRUE
