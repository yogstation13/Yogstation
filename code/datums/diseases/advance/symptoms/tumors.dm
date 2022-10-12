//benign, premalignant, malignant tumors

/datum/symptom/tumor
	name = "Benign tumors"
	desc = "The virus causes benign growths all over your body."
	stealth = 0
	resistance = 4
	stage_speed = -4
	transmittable = -4
	level = 3
	severity = 2
	symptom_delay_min = 5
	symptom_delay_max = 35
	threshold_descs = list(
		"Transmission 7" = "Gives visible growths on the host's body, eventually preventing some clothes from being worn.",
		"Stealth 4" = "Regenerates limbs that are incredibly fragile.",
		"Resistance 8" = "Heals brute and burn damage in exchange for toxin damage."
	)
	var/regeneration = FALSE
	var/helpful = FALSE
	var/tumor_chance = 0.5
	var/obj/item/organ/tumor/tumortype = /obj/item/organ/tumor
	var/datum/disease/advance/disease //what disease we are owned by

/datum/symptom/tumor/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	disease = A
	if(A.totalTransmittable() >= 7) //visible growths
		if(ishuman(A.affected_mob))
			A.affected_mob.visible_tumors = TRUE
	if(A.totalStealth() >= 4) //regeneration of limbs
		regeneration = TRUE
	if(A.totalResistance() >= 8) //helpful healing instead of just toxin
		helpful = TRUE

/datum/symptom/tumor/Activate(datum/disease/advance/A)
	. = ..()

	if(!.)
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(!M) 
		return

	if(M.visible_tumors)
		//clothes wearing
		if(A.stage > 2)
			var/datum/species/S = M.dna?.species
			if(S)
				S.add_no_equip_slot(M, SLOT_WEAR_MASK)
				S.add_no_equip_slot(M, SLOT_HEAD)

		if(A.stage == 5)
			var/datum/species/S = M.dna?.species
			if(S)
				S.add_no_equip_slot(M, SLOT_WEAR_SUIT)

	//spreading
	if(prob(tumor_chance)) //2% chance to make a new tumor somewhere
		spread(M)

/datum/symptom/tumor/proc/spread(mob/living/carbon/human/M, from_tumor = FALSE)
	if(!M)
		return
	var/list/possibleZones = list(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_PRECISE_EYES,BODY_ZONE_PRECISE_GROIN) - M.get_missing_limbs() //no inserting into magic limbs you dont have
	//check if we can put an organ in there
	var/insertionZone = pick(possibleZones)
	var/insertionAvailable = TRUE
	for(var/obj/item/organ/tumor/IT in M.internal_organs)
		if(IT.zone == insertionZone)
			insertionAvailable = FALSE
	if(insertionAvailable)
		var/obj/item/organ/tumor/T = new tumortype()
		T.name = T.name + " (" + parse_zone(insertionZone) + ")"
		T.helpful = helpful
		T.regeneration = regeneration
		T.owner_symptom = src
		T.Insert(M,FALSE,FALSE,insertionZone)
		if(from_tumor)
			to_chat(M, span_warning("[pick("Your insides writhe.", "You feel your insides squirm.")]"))
		else
			to_chat(M, span_warning("Your [parse_zone(insertionZone)] hurts."))
				
/datum/symptom/tumor/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		//unfuck their tumors
		var/mob/living/carbon/human/M = A.affected_mob
		M.visible_tumors = FALSE
		var/datum/species/S = M.dna?.species
		if(S)
			S.remove_no_equip_slot(M, SLOT_WEAR_MASK)
			S.remove_no_equip_slot(M, SLOT_HEAD)
			S.remove_no_equip_slot(M, SLOT_WEAR_SUIT)

/datum/symptom/tumor/premalignant
	name = "Premalignant tumors"
	desc = "The virus causes premalignant growths all over your body."
	level = 5
	severity = 4
	tumor_chance = 1
	tumortype = /obj/item/organ/tumor/premalignant

/datum/symptom/tumor/malignant
	name = "Malignant tumors"
	desc = "The virus causes malignant growths all over your body."
	level = 7
	severity = 6
	tumor_chance = 2
	tumortype = /obj/item/organ/tumor/malignant
