/datum/antagonist/grinch
	name = "The Grinch"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/grinch/on_gain()
	. = ..()
	give_equipment()
	give_objective()

	ADD_TRAIT(owner, TRAIT_CANNOT_OPEN_PRESENTS, TRAIT_GRINCH)
	ADD_TRAIT(owner, TRAIT_PRESENT_VISION, TRAIT_GRINCH)
  
/datum/antagonist/grinch/on_gain()(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = VENTCRAWLER_NUDE

datum/antagonist/grinch/on_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)

/datum/antagonist/grinch/greet()
	. = ..()
	to_chat(owner, "<span class='boldannounce'>You are The Grinch! Your objective is to bring misery to the people on this station. You have a bag which you should use to steal presents as long as you have it! You can examine the presents to take a peek inside, to make sure that what your stealing is worthwhile, do not cause any harm while trying to steal these gifts only fight in self defense.</span>")

/datum/antagonist/grinch/proc/give_equipment()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(/datum/outfit/santa)
		H.dna.update_dna_identity()

/datum/antagonist/grinch/proc/give_objective()
	var/datum/objective/grinch_objective = new()
	grinch_objective.explanation_text = "Bring sadness and misery to the station, by stealing there precious items and ruining there christmas spirit!"
	grinch_objective.completed = TRUE //lets cut our santas some slack.
	grinch_objective.owner = owner
	objectives |= grinch_objective
