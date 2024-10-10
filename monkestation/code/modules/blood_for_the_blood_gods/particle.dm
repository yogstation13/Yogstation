/// Blood drip subtype meant to be thrown around as a particle
/obj/effect/decal/cleanable/blood/particle
	name = "blood droplet"
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	plane = GAME_PLANE
	layer = BELOW_MOB_LAYER
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.2
	mergeable_decal = FALSE
	/// Splatter type we create when we bounce on the floor
	var/obj/effect/decal/cleanable/splatter_type_floor = /obj/effect/decal/cleanable/blood/splatter/stacking
	/// Splatter type we create when we bump on a wall
	var/obj/effect/decal/cleanable/splatter_type_wall = /obj/effect/decal/cleanable/blood/splatter/over_window
	/// Whether or not we transfer our pixel_x and pixel_y to the splatter, only works for floor splatters though
	var/messy_splatter = TRUE

/obj/effect/decal/cleanable/blood/particle/Initialize(mapload)
	. = ..()
	if(QDELETED(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/decal/cleanable/blood/particle/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/particle/proc/start_movement(movement_angle)
	get_or_init_physics()?.set_angle(movement_angle)

/obj/effect/decal/cleanable/blood/particle/proc/get_or_init_physics() as /datum/component/movable_physics
	RETURN_TYPE(/datum/component/movable_physics)
	if(QDELETED(src))
		return
	return LoadComponent(/datum/component/movable_physics, \
		horizontal_velocity = rand(3 * 100, 5.5 * 100) * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * 0.01, \
		horizontal_friction = rand(0.05 * 100, 0.1 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		vertical_conservation_of_momentum = 0.1, \
		z_floor = 0, \
		bounce_callback = CALLBACK(src, PROC_REF(on_bounce)), \
		bump_callback = CALLBACK(src, PROC_REF(on_bump)), \
	)

/obj/effect/decal/cleanable/blood/particle/proc/on_bounce()
	if(QDELETED(src))
		return
	else if(!isturf(loc) || QDELING(loc) || !splatter_type_floor)
		qdel(src)
		return
	var/obj/effect/decal/cleanable/splatter
	if(!ispath(splatter_type_floor, /obj/effect/decal/cleanable/blood/splatter/stacking))
		splatter = new splatter_type_floor(loc)
		splatter.color = color
		if(messy_splatter)
			splatter.pixel_x = src.pixel_x
			splatter.pixel_y = src.pixel_y
	else
		var/obj/effect/decal/cleanable/blood/splatter/stacking/stacker = locate(splatter_type_floor) in loc
		if(!stacker)
			stacker = new splatter_type_floor(loc)
			stacker.color = color
			if(messy_splatter && length(stacker.splat_overlays))
				var/mutable_appearance/existing_appearance = stacker.splat_overlays[1]
				existing_appearance.pixel_x = src.pixel_x
				existing_appearance.pixel_y = src.pixel_y
			stacker.bloodiness = src.bloodiness
			stacker.update_appearance(UPDATE_ICON)
		else
			var/obj/effect/decal/cleanable/blood/splatter/stacking/other_splatter = new splatter_type_floor()
			other_splatter.color = color
			if(messy_splatter && length(other_splatter.splat_overlays))
				var/mutable_appearance/existing_appearance = other_splatter.splat_overlays[1]
				existing_appearance.pixel_x = src.pixel_x
				existing_appearance.pixel_y = src.pixel_y
			other_splatter.bloodiness = src.bloodiness
			other_splatter.handle_merge_decal(stacker)
			qdel(other_splatter)
		splatter = stacker
	var/list/blood_dna = GET_ATOM_BLOOD_DNA(src)
	if(blood_dna)
		splatter.add_blood_DNA(blood_dna)
	qdel(src)

/obj/effect/decal/cleanable/blood/particle/proc/on_bump(atom/bumped_atom)
	if(QDELETED(src) || !isturf(loc) || QDELING(loc) || QDELETED(bumped_atom) || !splatter_type_wall)
		return
	if(iswallturf(bumped_atom))
		//Adjust pixel offset to make splatters appear on the wall
		var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new splatter_type_wall(loc)
		var/dir_to_wall = get_dir(src, bumped_atom)
		final_splatter.pixel_x = (dir_to_wall & EAST ? world.icon_size : (dir_to_wall & WEST ? -world.icon_size : 0))
		final_splatter.pixel_y = (dir_to_wall & NORTH ? world.icon_size : (dir_to_wall & SOUTH ? -world.icon_size : 0))
		final_splatter.color = color
		var/list/blood_dna = GET_ATOM_BLOOD_DNA(src)
		if(blood_dna)
			final_splatter.add_blood_DNA(blood_dna)
		qdel(src)
	else if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/the_window = bumped_atom
		if(!the_window.fulltile)
			return
		if(the_window.bloodied)
			qdel(src)
			return
		var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new splatter_type_wall()
		final_splatter.forceMove(the_window)
		final_splatter.color = color
		the_window.vis_contents += final_splatter
		the_window.bloodied = TRUE
		qdel(src)

/// subtype of splatter capable of doing proper "stacking" behavior
/obj/effect/decal/cleanable/blood/splatter/stacking
	/// Maximum amount of blood overlays we can have visually
	var/maximum_splats = 50
	/// Listing containing overlays of all the splatters we've merged with
	var/list/splat_overlays = list()

/obj/effect/decal/cleanable/blood/splatter/stacking/Initialize(mapload, blood_color = COLOR_BLOOD)
	color = blood_color
	. = ..()
	var/mutable_appearance/our_appearance = mutable_appearance(src.icon, src.icon_state)
	our_appearance.color = src.color
	our_appearance.pixel_x = src.pixel_x
	our_appearance.pixel_y = src.pixel_y
	if(glows)
		our_appearance.plane = EMISSIVE_PLANE
	icon_state = null
	color = null
	pixel_x = 0
	pixel_y = 0
	splat_overlays += our_appearance
	update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/blood/splatter/stacking/Destroy()
	splat_overlays = null
	return ..()

/obj/effect/decal/cleanable/blood/splatter/stacking/update_overlays()
	. = ..()
	var/splat_length = length(splat_overlays)
	if(splat_length > maximum_splats)
		splat_overlays = splat_overlays.Splice(splat_length  - maximum_splats, splat_length)
	. += splat_overlays

/obj/effect/decal/cleanable/blood/splatter/stacking/handle_merge_decal(obj/effect/decal/cleanable/blood/splatter/stacking/merger)
	. = ..()
	merger.splat_overlays |= splat_overlays
	merger.update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/blood/line
	name = "blood line"
	desc = "Raining blood, from a lacerated sky, bleeding its horror!"
	icon_state = "line"
	random_icon_states = null
	base_name = "dried blood line"
	dry_desc = "Creating my structure - Now I shall reign in blood!"

/obj/effect/decal/cleanable/blood/line/Initialize(mapload, direction)
	if(!isnull(direction))
		//has to be done before we call replace_decal()
		setDir(direction)
	return ..()

/obj/effect/decal/cleanable/blood/line/replace_decal(obj/effect/decal/cleanable/merger)
	. = ..()
	if(!.)
		return
	//squirts of the same dir are redundant, but not if they're different
	if(merger.dir != src.dir)
		return FALSE

