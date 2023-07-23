GLOBAL_LIST_EMPTY(map_delamination_counters)

/obj/structure/sign/delamination_counter
	name = "delamination counter"
	desc = "A pair of flip signs describe how long it's been since the last delamination incident."
	icon_state = "days_since_explosion"
	var/since_last = 0

/obj/structure/sign/delamination_counter/Initialize(mapload)
	. = ..()
	GLOB.map_delamination_counters += src
	if (!mapload)
		update_count(SSpersistence.rounds_since_engine_exploded)

/obj/structure/sign/delamination_counter/Destroy()
	GLOB.map_delamination_counters -= src
	return ..()

/obj/structure/sign/delamination_counter/proc/update_count(new_count)
	since_last = min(new_count, 99)
	update_appearance(UPDATE_ICON)

/obj/structure/sign/delamination_counter/update_overlays()
	. = ..()

	var/ones = since_last % 10
	var/mutable_appearance/ones_overlay = mutable_appearance('icons/obj/decals.dmi', "days_[ones]")
	ones_overlay.pixel_x = 4
	. += ones_overlay

	var/tens = (since_last / 10) % 10
	var/mutable_appearance/tens_overlay = mutable_appearance('icons/obj/decals.dmi', "days_[tens]")
	tens_overlay.pixel_x = -5
	. += tens_overlay

/obj/structure/sign/delamination_counter/examine(mob/user)
	. = ..()
	. += span_info("It has been [since_last] day\s since the last delamination event at a Nanotrasen facility.")
	switch (since_last)
		if (0)
			. += span_info("In case you didn't notice.")
		if(1)
			. += span_info("Let's do better today.")
		if(2 to 5)
			. += span_info("There's room for improvement.")
		if(6 to 10)
			. += span_info("Good work!")
		if(11 to INFINITY)
			. += span_info("Incredible!")
