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
		"Transmission 7" = "Gives visible growths on the host's body.",
		"Stealth 4" = "Regenerates limbs that are incredibly fragile.",
		"Resistance 8" = "Heals brute and burn damage in exchange for toxin damage."
	)
	var/regeneration = FALSE
	var/helpful = FALSE
	var/tumor_chance = 0.25
	var/obj/item/organ/tumor/tumortype = /obj/item/organ/tumor
	var/datum/disease/advance/ownerdisease //what disease it comes from

/datum/symptom/tumor/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	ownerdisease = A;
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
	if(!M) return

	if(A.stage > 2)
		if(istype(M.wear_mask, /obj/item/clothing/mask))
			var/obj/item/clothing/mask/wearing_mask = M.wear_mask
			if(M.canUnEquip(wearing_mask))
				M.dropItemToGround(wearing_mask)
		if(istype(M.wear_mask, /obj/item/clothing/head))
			var/obj/item/clothing/head/wearing_hat = M.head
			if(M.canUnEquip(wearing_hat))
				M.dropItemToGround(wearing_hat)
		M.dna.species.no_equip.Add(SLOT_WEAR_MASK,SLOT_HEAD)

	if(A.stage == 5)
		if(istype(M.wear_mask, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/wearing_suit = M.wear_suit
			if(M.canUnEquip(wearing_suit))
				M.dropItemToGround(wearing_suit)
		M.dna.species.no_equip.Add(SLOT_WEAR_SUIT)


	if(prob(tumor_chance)) //2% chance to make a new tumor somewhere
		var/list/possibleZones = list(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_PRECISE_EYES,BODY_ZONE_PRECISE_GROIN)
		//check if we can put an organ in there
		var/insertionZone = pick(possibleZones)
		var/insertionAvailable = TRUE
		for(var/obj/item/organ/tumor/IT in M.internal_organs)
			if(IT.zone == insertionZone)
				insertionAvailable = FALSE
		if(insertionAvailable)
			var/obj/item/organ/tumor/T = new tumortype()
			T.name = T.name + " (" + insertionZone + ")"
			T.helpful = helpful
			T.ownerdisease = ownerdisease
			T.Insert(M,FALSE,FALSE,insertionZone)

/datum/symptom/tumor/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		//unfuck their tumors
		A.affected_mob.visible_tumors = FALSE
		A.affected_mob.dna.species.no_equip.Remove(SLOT_WEAR_MASK,SLOT_HEAD)
		A.affected_mob.dna.species.no_equip.Remove(SLOT_WEAR_SUIT)

/datum/symptom/tumor/premalignant
	name = "Premalignant tumors"
	desc = "The virus causes premalignant growths all over your body."
	level = 5
	severity = 4
	tumor_chance = 0.5
	tumortype = /obj/item/organ/tumor/premalignant

/datum/symptom/tumor/malignant
	name = "Malignant tumors"
	desc = "The virus causes malignant growths all over your body."
	level = 7
	severity = 6
	tumor_chance = 1
	tumortype = /obj/item/organ/tumor/malignant
