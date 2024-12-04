/mob/common_trait_examine()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_FEEBLE))
		. += span_warning("[p_they(capitalized=TRUE)] look[p_s()] really weak.")
