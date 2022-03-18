/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(wear_neck)
		if(wear_neck.type == /obj/item/clothing/neck/petcollar)
			return ..(user, TRUE)
	.=..()

/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = 0)	
	if(user == src && pulling && !pulling.anchored && grab_state >= GRAB_AGGRESSIVE && (HAS_TRAIT(src, TRAIT_FAT)) && ismonkey(pulling))	
		devour_mob(pulling)	
	else	
		.=..()
