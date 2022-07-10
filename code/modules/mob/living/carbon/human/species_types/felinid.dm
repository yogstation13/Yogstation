//Subtype of human
/datum/species/human/felinid
	name = "Felinid Human"
	id = "felinid"
	limbs_id = "human"

	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "tail_human" = "Cat", "ears" = "Cat", "wings" = "None")
	rare_say_mod = list("meows"= 10)
	liked_food = SEAFOOD | DAIRY | MICE
	disliked_food = GROSS | RAW
	toxic_food = TOXIC | CHOCOLATE
	mutantears = /obj/item/organ/ears/cat
	mutanttail = /obj/item/organ/tail/cat
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	swimming_component = /datum/component/swimming/felinid
	species_language_holder = /datum/language_holder/felinid

	screamsound = list('sound/voice/feline/scream1.ogg', 'sound/voice/feline/scream2.ogg', 'sound/voice/feline/scream3.ogg')

/datum/species/human/felinid/qualifies_for_rank(rank, list/features)
	return TRUE

//Curiosity killed the cat's wagging tail.

/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load)			//Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Cat"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Cat"
		if(H.dna.features["ears"] == "Cat")
			var/obj/item/organ/ears/cat/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Cat")
			var/obj/item/organ/tail/cat/tail = new
			tail.Insert(H, drop_if_replaced = FALSE)
		else
			mutanttail = null

/datum/species/human/felinid/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/cat/ears = H.getorgan(/obj/item/organ/ears/cat)
	var/obj/item/organ/tail/cat/tail = H.getorgan(/obj/item/organ/tail/cat)

	if(ears)
		var/obj/item/organ/ears/NE
		if(new_species && new_species.mutantears)
			// Roundstart cat ears override new_species.mutantears, reset it here.
			new_species.mutantears = initial(new_species.mutantears)
			if(new_species.mutantears)
				NE = new new_species.mutantears
		if(!NE)
			// Go with default ears
			NE = new /obj/item/organ/ears
		NE.Insert(H, drop_if_replaced = FALSE)

	if(tail)
		var/obj/item/organ/tail/NT
		if(new_species && new_species.mutanttail)
			// Roundstart cat tail overrides new_species.mutanttail, reset it here.
			new_species.mutanttail = initial(new_species.mutanttail)
			if(new_species.mutanttail)
				NT = new new_species.mutanttail
		if(NT)
			NT.Insert(H, drop_if_replaced = FALSE)
		else
			tail.Remove(H)

///turn everyone into catgirls. Technically not girls specifically but you get the point.
/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_apply(M)
		CHECK_TICK

///turn all catgirls back
/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_remove(M)
		CHECK_TICK

///used to transmogrificate spacemen into or from catboys/girls. Arguments H = target spaceman and silent = TRUE/FALSE whether or not we alert them to their transformation with cute flavortext
/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		var/catgirlcheck = istype(H.getorganslot(ORGAN_SLOT_EARS), /obj/item/organ/ears/cat) || istype(H.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/cat) //if they've got cat parts they are likely an unfortunate victim of admin black magic AKA "fun", turn them back
		if(catgirlcheck)
			purrbation_remove(H, silent)
			return FALSE
		else
			purrbation_apply(H, silent)
			return TRUE
	if(!iscatperson(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_toggle_onlyhumans(mob/living/carbon/human/H, silent = FALSE) //same as above but doesn't work on nonhumans - used by donor purrbation to reduce *accidental* double-cursed double-mutants
	if(!ishumanbasic(H))
		return
	if(!iscatperson(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

///turns our poor spaceman into a CATGIRL. Point and laugh.
/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	if(iscatperson(H))
		return
	if(!silent)
		to_chat(H, "Something is nya~t right.")
		playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, 1, -1)

	if(!ishumanbasic(H))
		var/obj/item/organ/cattification = new /obj/item/organ/tail/cat()
		var/old_part = H.getorganslot(ORGAN_SLOT_TAIL)
		cattification.Insert(H)
		qdel(old_part)
		cattification = new /obj/item/organ/ears/cat()
		old_part = H.getorganslot(ORGAN_SLOT_EARS)
		cattification.Insert(H)
		qdel(old_part)
		H.regenerate_icons()
		return

	H.set_species(/datum/species/human/felinid)

///return the degenerates to their original form
/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(!silent)
		to_chat(H, "You are no longer a cat.")
	if(!ishumanbasic(H)) //not a basic human, nonhumans tend to have different appearances so turning them into humans would be lazy. Give them their normal ears and shit back
		var/obj/item/organ/decattification = H.dna?.species.mutanttail
		var/old_part = H.getorganslot(ORGAN_SLOT_TAIL)
		qdel(old_part) //do this here since they potentially don't normally have a tail
		if(decattification)
			decattification = new decattification
			if(istype(decattification, /obj/item/organ/tail/lizard))
				var/obj/item/organ/tail/lizard/nyaamrrow = decattification
				nyaamrrow.tail_type = H.dna.features["tail_lizard"]
				nyaamrrow.spines = H.dna.features["spines"]
			decattification.Insert(H)
		decattification = H.dna?.species.mutantears
		old_part = H.getorganslot(ORGAN_SLOT_EARS)
		qdel(old_part) //do this here since they potentially don't normally have ears which would SUCK
		if(decattification)
			decattification = new decattification
			decattification.Insert(H)
		return

	H.set_species(/datum/species/human)

/datum/species/human/felinid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()

/datum/species/human/felinid/get_scream_sound(mob/living/carbon/human/H)
	return pick(screamsound)

/datum/species/human/felinid/spec_life(mob/living/carbon/human/H)
	. = ..()
	if((H.client && H.client.prefs.mood_tail_wagging) && !is_wagging_tail() && H.mood_enabled)
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(!istype(mood) || !(mood.shown_mood >= MOOD_LEVEL_HAPPY2)) 
			return
		var/chance = 0
		switch(mood.shown_mood)
			if(0 to MOOD_LEVEL_SAD4)
				chance = -0.1
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				chance = -0.01
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				chance = 0.001
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				chance = 0.1
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				chance = 1
		if(prob(abs(chance)))
			switch(SIGN(chance))
				if(1)
					H.emote("wag")
				if(-1)
					stop_wagging_tail(H)
