////////////////////
/////BODYPARTS/////
////////////////////
/obj/item/bodypart
	var/should_draw_yogs = FALSE

/mob/living/carbon/proc/draw_yogs_parts(do_it)
	for(var/O in bodyparts)
		var/obj/item/bodypart/B = O
		B.should_draw_yogs = do_it