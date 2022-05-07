/obj/item/storage/belt/champion/wrestling/dna_locked
	var/dna_lock = null

/obj/item/storage/belt/champion/wrestling/dna_locked/can_learn(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if (!istype(H))
		return FALSE
	if (!isnull(dna_lock) && dna_lock != H.dna.unique_enzymes) 
		return FALSE

/obj/item/storage/belt/champion/wrestling/dna_locked/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/human/H = user
	if (!istype(H))
		return
	if (isnull(dna_lock))
		dna_lock = H.dna.unique_enzymes
		
