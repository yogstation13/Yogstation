/obj/machinery/power/bluespace_tap
	name = "\improper Bluespace Harvester"
	desc = "An elaborate device used to convert power into confusing bluespace science research." // The original didn't even have a description, so...

/obj/machinery/power/bluespace_tap/examine(mob/user)
	. = ..()
	if(total_points >= BLUESPACE_TAP_POINT_GOAL)
		. += span_notice("<span class='nicegreen'>Green text</span> displayed on the device informs you that the [src] has reached [src.p_their()] research goal!")
