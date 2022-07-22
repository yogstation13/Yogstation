#define TUMOR_STRENGTH_WEAK 0.125
#define TUMOR_STRENGTH_AVERAGE 0.25
#define TUMOR_STRENGTH_STRONG 0.5

#define TUMOR_SPREAD_WEAK 0.5
#define TUMOR_SPREAD_AVERAGE 1
#define TUMOR_SPREAD_STRONG 2

/obj/item/organ/tumor
	name = "benign tumor"
	desc = "Hope there aren't more of these."
	icon_state = "tumor"

	var/strength = TUMOR_STRENGTH_WEAK
	var/spread_chance = TUMOR_SPREAD_WEAK

	var/helpful = FALSE //keeping track if they're helpful or not
	var/regeneration = FALSE //if limbs are regenerating
	var/datum/symptom/tumor/owner_symptom //what symptom of the disease it comes from

/obj/item/organ/tumor/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/tumor/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	var/tumors_left = FALSE
	for(var/obj/item/organ/tumor/IT in owner.internal_organs)
		if(IT.owner_symptom == owner_symptom)
			tumors_left = TRUE
	if(!tumors_left)
		//cure the disease, removing all tumors 
		owner_symptom.disease.cure(FALSE)
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
		//regeneration
	if(regeneration && prob(spread_chance))
		var/list/missing_limbs = owner.get_missing_limbs() - list(BODY_ZONE_HEAD, BODY_ZONE_CHEST) //don't regenerate the head or chest
		if(missing_limbs.len)
			var/limb_to_regenerate = pick(missing_limbs)
			owner.regenerate_limb(limb_to_regenerate,TRUE)
			var/obj/item/bodypart/new_limb = owner.get_bodypart(limb_to_regenerate)
			new_limb.receive_damage(45); //45 brute damage should be fine I think??????
			owner.emote("scream")
			owner.visible_message(span_warning("Gnarly tumors burst out of [owner]'s stump and form into a [parse_zone(limb_to_regenerate)]!"), span_notice("You scream as your [parse_zone(limb_to_regenerate)] reforms."))
	if(prob(spread_chance))
		owner_symptom?.spread(owner, TRUE)


/obj/item/organ/tumor/premalignant
	name = "premalignant tumor"
	desc = "It doesn't look too bad... at least you're not dead, right?"
	strength = TUMOR_STRENGTH_AVERAGE
	spread_chance = TUMOR_SPREAD_AVERAGE

/obj/item/organ/tumor/malignant
	name = "malignant tumor"
	desc = "Yikes. There's probably more of these in you."
	strength = TUMOR_STRENGTH_STRONG
	spread_chance = TUMOR_SPREAD_STRONG

#undef TUMOR_STRENGTH_WEAK 
#undef TUMOR_STRENGTH_AVERAGE 
#undef TUMOR_STRENGTH_STRONG 
#undef TUMOR_SPREAD_WEAK
#undef TUMOR_SPREAD_AVERAGE
#undef TUMOR_SPREAD_STRONG
