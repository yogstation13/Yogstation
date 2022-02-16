/obj/item/organ/tumor
	name = "benign tumor"
	desc = "Hope there aren't more of these."
	icon_state = "tumor"

	var/strength = 0.125
	var/spread_chance = 0.5

	var/helpful = FALSE //keeping track if they're helpful or not
	var/regeneration = FALSE //if limbs are regenerating
	var/datum/disease/advance/ownerdisease //what disease it comes from

/obj/item/organ/tumor/Insert(var/mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/tumor/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	var/tumors_left = FALSE
	for(var/obj/item/organ/tumor/IT in owner.internal_organs)
		if(IT.ownerdisease == ownerdisease)
			tumors_left = TRUE
	if(!tumors_left)
		//cure the disease, removing all tumors 
		ownerdisease.cure()
	STOP_PROCESSING(SSobj, src)

/obj/item/organ/tumor/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)
	if(helpful)
		if(owner.getBruteLoss() + owner.getFireLoss() > 0)
			owner.adjustToxLoss(strength/2)
			owner.adjustBruteLoss(-(strength/2))
			owner.adjustFireLoss(-(strength/2))
	else
		owner.adjustToxLoss(strength) //just take toxin damage
		//regerenation
	if(regeneration && prob(spread_chance))
		var/list/missing_limbs = owner.get_missing_limbs() - list(BODY_ZONE_HEAD, BODY_ZONE_CHEST) //don't regenerate the head or chest
		if(missing_limbs.len)
			var/limb_to_regenerate = pick(missing_limbs)
			owner.regenerate_limb(limb_to_regenerate,TRUE);
			var/obj/item/bodypart/new_limb = owner.get_bodypart(limb_to_regenerate)
			new_limb.receive_damage(45); //45 brute damage should be fine I think??????
			owner.emote("scream")
			owner.visible_message(span_warning("Gnarly tumors burst out of [owner]'s stump and form into a [parse_zone(limb_to_regenerate)]!"), span_notice("You scream as your [parse_zone(limb_to_regenerate)] reforms."))
	if(prob(spread_chance))
		spread()

/obj/item/organ/tumor/proc/spread()
	var/list/possibleZones = list(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_PRECISE_EYES,BODY_ZONE_PRECISE_GROIN) - owner.get_missing_limbs()
	//check if we can put an organ in there
	var/insertionZone = pick(possibleZones)
	var/insertionAvailable = TRUE
	for(var/obj/item/organ/tumor/IT in owner.internal_organs)
		if(IT.zone == insertionZone)
			insertionAvailable = FALSE
	if(insertionAvailable)
		var/obj/item/organ/tumor/T = new type()
		T.name = T.name + " (" + parse_zone(insertionZone) + ")"
		T.helpful = helpful
		T.regeneration = regeneration
		T.ownerdisease = ownerdisease
		T.Insert(owner,FALSE,FALSE,insertionZone)
		to_chat(owner, span_warning("Your [parse_zone(insertionZone)] hurts."))

/obj/item/organ/tumor/premalignant
	name = "premalignant tumor"
	desc = "It doesn't look too bad... at least you're not dead, right?"
	strength = 0.25
	spread_chance = 1

/obj/item/organ/tumor/malignant
	name = "malignant tumor"
	desc = "Yikes. There's probably more of these in you."
	strength = 0.5
	spread_chance = 2
