////////////////////
/////BODYPARTS/////
////////////////////


/obj/item/bodypart
	var/should_draw_yogs = FALSE

/mob/living/carbon/proc/draw_yogs_parts(undo = FALSE)
	if(!undo)
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_yogs = TRUE
	else
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_yogs = FALSE