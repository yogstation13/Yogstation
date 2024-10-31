/mob/living/carbon/update_body(is_creating = FALSE)
	. = ..()
	if(is_creating)
		dna?.update_body_height()
