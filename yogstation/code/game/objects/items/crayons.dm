#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

/obj/item/toy/crayon
	var/datum/team/gang/gang //For marking territory, spraycans are gang-locked to their initial gang due to colors

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !check_allowed_items(target))
		return

	var/cost = 1
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		cost = 5
	if(istype(target, /obj/item/canvas))
		cost = 0

	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc

	if(!is_type_in_list(target,validSurfaces))
		return

	var/drawing = drawtype
	switch(drawtype)
		if(RANDOM_LETTER)
			drawing = pick(letters)
		if(RANDOM_GRAFFITI)
			drawing = pick(graffiti)
		if(RANDOM_RUNE)
			drawing = pick(runes)
		if(RANDOM_ORIENTED)
			drawing = pick(oriented)
		if(RANDOM_NUMBER)
			drawing = pick(numerals)
		if(RANDOM_ANY)
			drawing = pick(all_drawables)

	var/temp = "rune"
	if(drawing in letters)
		temp = "letter"
	else if(drawing in graffiti)
		temp = "graffiti"
	else if(drawing in numerals)
		temp = "number"

	var/gangcheck = hippie_gang_check(user,target)
	if(!gangcheck) return // hippie
	var/graf_rot
	if(drawing in oriented)
		switch(user.dir)
			if(EAST)
				graf_rot = 90
			if(SOUTH)
				graf_rot = 180
			if(WEST)
				graf_rot = 270
			else
				graf_rot = 0

	var/list/click_params = params2list(params)
	var/clickx
	var/clicky

	if(click_params && click_params["icon-x"] && click_params["icon-y"])
		clickx = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		clicky = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)

	if(!instant)
		to_chat(user, "<span class='notice'>You start drawing a [temp] on the [target.name]...</span>")

	if(pre_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/takes_time = !instant

	var/wait_time = 50
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		wait_time *= 3
	if(gang) takes_time = TRUE // hippie
	if(takes_time)
		if(!do_after(user, 50, target = target))
			return

	if(length(text_buffer))
		drawing = copytext(text_buffer,1,2)


	var/list/turf/affected_turfs = list()

	if(!gang) // hippie - drawing is done in gang_final() if it's a gang type
		if(actually_paints)
			switch(paint_mode)
				if(PAINT_NORMAL)
					var/obj/effect/decal/cleanable/crayon/C = new(target, paint_color, drawing, temp, graf_rot)
					C.add_hiddenprint(user)
					C.pixel_x = clickx
					C.pixel_y = clicky
					affected_turfs += target
				if(PAINT_LARGE_HORIZONTAL)
					var/turf/left = locate(target.x-1,target.y,target.z)
					var/turf/right = locate(target.x+1,target.y,target.z)
					if(is_type_in_list(left, validSurfaces) && is_type_in_list(right, validSurfaces))
						var/obj/effect/decal/cleanable/crayon/C = new(left, paint_color, drawing, temp, graf_rot, PAINT_LARGE_HORIZONTAL_ICON)
						C.add_hiddenprint(user)
						affected_turfs += left
						affected_turfs += right
						affected_turfs += target
					else
						to_chat(user, "<span class='warning'>There isn't enough space to paint!</span>")
						return
	else // hippie
		if(gang_final(user, target, affected_turfs)) return // hippie

	if(!instant)
		to_chat(user, "<span class='notice'>You finish drawing \the [temp].</span>")
	else
		to_chat(user, "<span class='notice'>You spray a [temp] on \the [target.name]</span>")

	var/charges_used = use_charges(user, cost)
	if(!charges_used)
		return
	. = charges_used

	if(length(text_buffer))
		text_buffer = copytext(text_buffer,2)

	if(post_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/fraction = min(1, . / reagents.maximum_volume)
	if(affected_turfs.len)
		fraction /= affected_turfs.len
	for(var/t in affected_turfs)
		reagents.reaction(t, TOUCH, fraction * volume_multiplier)
		reagents.trans_to(t, ., volume_multiplier)
	check_empty(user)

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return

	if(check_empty(user))
		return

	if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light = target
		if(actually_paints)
			light.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
			light.bulb_colour = paint_color
			light.update()
		. = use_charges(user, 2)
	. = ..()

/obj/item/toy/crayon/proc/hippie_gang_check(mob/user, atom/target) // hooked into afterattack
	var/gang_mode = FALSE
	if(gang && user.mind)
		var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(G)
			if(G.gang != gang)
				to_chat(user, "<span class='danger'>This spraycan's color isn't your gang's one! You cannot use it.</span>")
				return FALSE
			gang_mode = TRUE
			instant = FALSE
			. = "graffiti"
	// discontinue if we're not in gang modethe area isn't valid for tagging because gang "honour"
	if(gang_mode && (!can_claim_for_gang(user, target)))
		return FALSE
	return TRUE

/obj/item/toy/crayon/proc/gang_final(mob/user, atom/target, list/affected_turfs) // hooked into afterattack
	// Double check it wasn't tagged in the meanwhile
	if(!can_claim_for_gang(user, target))
		return TRUE
	tag_for_gang(user, target)
	affected_turfs += target

/obj/item/toy/crayon/proc/can_claim_for_gang(mob/user, atom/target)
	// Check area validity.
	// Reject space, player-created areas, and non-station z-levels.
	var/area/A = get_area(target)
	if(!A || (!is_station_level(A.z)) || !A.valid_territory)
		to_chat(user, "<span class='warning'>[A] is unsuitable for tagging.</span>")
		return FALSE

	var/spraying_over = FALSE
	for(var/G in target)
		var/obj/effect/decal/cleanable/crayon/gang/gangtag = G
		if(istype(gangtag))
			var/datum/antagonist/gang/GA = user.mind.has_antag_datum(/datum/antagonist/gang)
			if(gangtag.gang != GA.gang)
				spraying_over = TRUE
				break

	for(var/obj/machinery/power/apc in target)
		to_chat(user, "<span class='warning'>You can't tag an APC.</span>")
		return FALSE

	var/occupying_gang = territory_claimed(A, user)
	if(occupying_gang && !spraying_over)
		to_chat(user, "<span class='danger'>[A] has already been tagged by the [occupying_gang] gang! You must get rid of or spray over the old tag first!</span>")
		return FALSE

	// If you pass the gaunlet of checks, you're good to proceed
	return TRUE

/obj/item/toy/crayon/proc/territory_claimed(area/territory, mob/user)
	for(var/datum/team/gang/G in GLOB.gangs)
		if(territory.type in (G.territories|G.new_territories))
			. = G.name
			break

/obj/item/toy/crayon/proc/tag_for_gang(mob/user, atom/target)
	//Delete any old markings on this tile, including other gang tags
	for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
		qdel(old_marking)

	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	var/area/territory = get_area(target)

	new /obj/effect/decal/cleanable/crayon/gang(target,G.gang,"graffiti",0,user)
	to_chat(user, "<span class='notice'>You tagged [territory] for your gang!</span>")

/obj/item/toy/crayon/spraycan/gang
	//desc = "A modified container containing suspicious paint."
	charges = 20
	gang = TRUE

	pre_noise = FALSE
	post_noise = TRUE

/obj/item/toy/crayon/spraycan/gang/Initialize(loc, datum/team/gang/G)
	..()
	if(G)
		gang = G
		paint_color = G.color
		update_icon()

/obj/item/toy/crayon/spraycan/gang/examine(mob/user)
	. = ..()
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/gang) || isobserver(user))
		to_chat(user, "This spraycan has been specially modified for tagging territory.")

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_NUMBER
#undef RANDOM_ORIENTED
#undef RANDOM_RUNE
#undef RANDOM_ANY
