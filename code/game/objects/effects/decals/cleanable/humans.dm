/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's weird and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	beauty = -100
	clean_type = CLEAN_TYPE_BLOOD
	decal_reagent = /datum/reagent/blood
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	color = COLOR_BLOOD
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	/// Can this blood dry out?
	var/can_dry = TRUE
	/// Is this blood dried out?
	var/dried = FALSE

	/// The "base name" of the blood, IE the "pool of" in "pool of blood"
	var/base_name = "pool of"
	/// When dried, this is prefixed to the name
	var/dry_prefix = "dried"
	/// When dried, this becomes the desc of the blood
	var/dry_desc = "Looks like it's been here a while. Eew."

	/// How long it takes to dry out
	var/drying_time = 5 MINUTES
	/// The process to drying out, recorded in deciseconds
	var/drying_progress = 0
	/// Color matrix applied to dried blood via filter to make it look dried
	var/static/list/blood_dry_filter_matrix = list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
		-0.5, -0.75, -0.75, 0,
	)
	var/count = 0
	var/footprint_sprite = null
	var/glows = FALSE
	var/handles_unique = FALSE

/obj/effect/decal/cleanable/blood/Initialize(mapload, blood_color = COLOR_BLOOD)
	. = ..()
	START_PROCESSING(SSblood_drying, src)
	if(color && can_dry && !dried)
		update_blood_drying_effect()

/obj/effect/decal/cleanable/blood/Destroy()
	STOP_PROCESSING(SSblood_drying, src)
	return ..()

/obj/effect/decal/cleanable/blood/on_entered(datum/source, atom/movable/AM)
	if(dried)
		return
	return ..()

#define DRY_FILTER_KEY "dry_effect"

/obj/effect/decal/cleanable/blood/update_overlays()
	. = ..()
	if(glows && !handles_unique)
		. += emissive_appearance(icon, icon_state, src)

/obj/effect/decal/cleanable/blood/proc/update_blood_drying_effect()
	if(!can_dry)
		remove_filter(DRY_FILTER_KEY) // I GUESS
		return

	var/existing_filter = get_filter(DRY_FILTER_KEY)
	if(dried)
		if(existing_filter)
			animate(existing_filter) // just stop existing animations and force it to the end state
			return
		add_filter(DRY_FILTER_KEY, 2, color_matrix_filter(blood_dry_filter_matrix))
		return

	if(existing_filter)
		remove_filter(DRY_FILTER_KEY)

	add_filter(DRY_FILTER_KEY, 2, color_matrix_filter())
	transition_filter(DRY_FILTER_KEY, color_matrix_filter(blood_dry_filter_matrix), drying_time - drying_progress)

#undef DRY_FILTER_KEY

/obj/effect/decal/cleanable/blood/proc/get_blood_string()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	var/list/all_blood_names = list()
	for(var/dna_sample in all_dna)
		var/datum/blood_type/blood = GLOB.blood_types[all_dna[dna_sample]]
		if(!blood)
			all_blood_names |= "blood"
			continue
		all_blood_names |= lowertext(initial(blood.reagent_type.name))
	return english_list(all_blood_names, nothing_text = "blood")

/obj/effect/decal/cleanable/blood/process(seconds_per_tick)
	if(dried || !can_dry)
		return PROCESS_KILL

	adjust_bloodiness(-0.4 * BLOOD_PER_UNIT_MODIFIER * seconds_per_tick)
	drying_progress += (seconds_per_tick * 1 SECONDS)
	if(drying_progress >= drying_time + SSblood_drying.wait) // Do it next tick when we're done
		dry()

/obj/effect/decal/cleanable/blood/update_name(updates)
	. = ..()
	name = initial(name)
	if(base_name)
		name = "[base_name] [get_blood_string()]"
	if(dried && dry_prefix)
		name = "[dry_prefix] [name]"

/obj/effect/decal/cleanable/blood/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(dried && dry_desc)
		desc = dry_desc

///This is what actually "dries" the blood. Returns true if it's all out of blood to dry, and false otherwise
/obj/effect/decal/cleanable/blood/proc/dry()
	dried = TRUE
	reagents?.clear_reagents()
	update_appearance()
	update_blood_drying_effect()
	STOP_PROCESSING(SSblood_drying, src)
	return TRUE

/obj/effect/decal/cleanable/blood/lazy_init_reagents()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	var/list/reagents_to_add = list()
	for(var/dna_sample in all_dna)
		var/datum/blood_type/blood = GLOB.blood_types[all_dna[dna_sample]]
		reagents_to_add += blood.reagent_type

	var/num_reagents = length(reagents_to_add)
	for(var/reagent_type in reagents_to_add)
		reagents.add_reagent(reagent_type, round((bloodiness * 0.2 * BLOOD_PER_UNIT_MODIFIER) / num_reagents, CHEMICAL_VOLUME_ROUNDING))

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/merger)
	if(merger.dried) // New blood will lie on dry blood
		return FALSE
	return ..()

/obj/effect/decal/cleanable/blood/handle_merge_decal(obj/effect/decal/cleanable/blood/merger)
	. = ..()
	merger.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	merger.adjust_bloodiness(bloodiness)
	merger.drying_progress -= (bloodiness * BLOOD_PER_UNIT_MODIFIER) // goes negative = takes longer to dry
	merger.update_blood_drying_effect()

/obj/effect/decal/cleanable/blood/old
	bloodiness = 0
	icon_state = "floor1-old"

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("UNKNOWN DNA" = random_human_blood_type()))
	. = ..()
	dry()

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	turf_loc_check = FALSE
	alpha = 180

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null
	beauty = -50
	base_name = ""
	dry_desc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/blood/trail_holder
	name = "trail of blood"
	desc = "Your instincts say you shouldn't be following these."
	beauty = -50
	icon_state = null
	random_icon_states = null
	base_name = "trail of"
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	plane = GAME_PLANE
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE
	turf_loc_check = FALSE

	base_name = ""
	dry_prefix = "rotting"
	dry_desc = "They look bloody and gruesome while some terrible smell fills the air."
	decal_reagent = /datum/reagent/consumable/liquidgibs
	reagent_amount = 5
	///Information about the diseases our streaking spawns
	var/list/streak_diseases

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	LAZYNULL(streak_diseases)
	return ..()


/obj/effect/decal/cleanable/blood/gibs/get_blood_string()
	return ""

/obj/effect/decal/cleanable/blood/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return FALSE //Never fail to place us

/obj/effect/decal/cleanable/blood/gibs/dry()
	. = ..()
	if(!.)
		return
	AddComponent(/datum/component/rot, 0, 5 MINUTES, 0.7)

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/on_entered(datum/source, atom/movable/L)
	if(isliving(L) && has_gravity(loc))
		playsound(loc, 'sound/effects/footstep/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, TRUE)
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions, mapload=FALSE)
	LAZYINITLIST(streak_diseases)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions, streak_diseases)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i in 1 to range)
			var/turf/my_turf = get_turf(src)
			if(!isgroundlessturf(my_turf) || GET_TURF_BELOW(my_turf))
				new /obj/effect/decal/cleanable/blood/splatter(my_turf)
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = SSmove_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/blood/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/blood/splatter(loc, streak_diseases)

/obj/effect/decal/cleanable/blood/gibs/up
	icon_state = "gibup1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	icon_state = "gibtorso"
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/torso
	icon_state = "gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	icon_state = "gib1-old"
	bloodiness = 0
	dry_prefix = ""
	dry_desc = ""

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("UNKNOWN DNA" = random_human_blood_type()))
	. = ..()
	setDir(pick(GLOB.cardinals))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)
	dry()

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "A spattering."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.2 * BLOOD_PER_UNIT_MODIFIER
	base_name = "drips of"
	dry_desc = "A dried spattering."
	drying_time = 1 MINUTES


//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "blood_shoes_enter"
	random_icon_states = null
	bloodiness = 0 // set based on the bloodiness of the foot
	base_name = ""
	dry_desc = "HMM... SOMEONE WAS HERE!"
	handles_unique = TRUE
	var/entered_dirs = 0
	var/exited_dirs = 0

	/// List of shoe or other clothing that covers feet types that have made footprints here.
	var/list/shoe_types = list()

	/// List of species that have made footprints here.
	var/list/species_types = list()

/obj/effect/decal/cleanable/blood/footprints/Initialize(mapload, footprint_sprite)
	src.footprint_sprite = footprint_sprite
	. = ..()
	icon_state = "" //All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir //Keep the same appearance as in the map editor
	update_appearance(mapload ? (ALL) : (UPDATE_NAME | UPDATE_DESC))


/obj/effect/decal/cleanable/blood/footprints/get_blood_string()
	return ""

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/blood/footprints/setDir(newdir)
	if(dir == newdir)
		return ..()

	var/ang_change = dir2angle(newdir) - dir2angle(dir)
	var/old_entered_dirs = entered_dirs
	var/old_exited_dirs = exited_dirs
	entered_dirs = 0
	exited_dirs = 0

	for(var/Ddir in GLOB.cardinals)
		if(old_entered_dirs & Ddir)
			entered_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)
		if(old_exited_dirs & Ddir)
			exited_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)

	update_appearance()
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_desc(updates)
	desc = "WHOSE [uppertext(name)] ARE THESE?"
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	. = ..()
	alpha = min(BLOODY_FOOTPRINT_BASE_ALPHA + (255 - BLOODY_FOOTPRINT_BASE_ALPHA) * bloodiness / ((BLOOD_ITEM_MAX * BLOOD_PER_UNIT_MODIFIER) / 2), 255)

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()
	var/icon_state_to_use = "blood"
	if(SPECIES_MONKEY in species_types)
		icon_state_to_use += "paw"
	else if(BODYPART_ID_DIGITIGRADE in species_types)
		icon_state_to_use += "claw"

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[icon_state_to_use]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[icon_state_to_use]-[Ddir]"] = bloodstep_overlay = image(icon, "[icon_state_to_use]1", dir = Ddir)
			. += bloodstep_overlay

		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[icon_state_to_use]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[icon_state_to_use]-[Ddir]"] = bloodstep_overlay = image(icon, "[icon_state_to_use]2", dir = Ddir)
			. += bloodstep_overlay


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if((shoe_types.len + species_types.len) > 0)
		. += "You recognise the [name] as belonging to:"
		for(var/sole in shoe_types)
			var/obj/item/clothing/item = sole
			var/article = initial(item.gender) == PLURAL ? "Some" : "A"
			. += "[icon2html(initial(item.icon), user, initial(item.icon_state))] [article] <B>[initial(item.name)]</B>."
		for(var/species in species_types)
			// god help me
			if(species == "unknown")
				. += "Some <B>feet</B>."
			else if(species == SPECIES_MONKEY)
				. += "[icon2html('icons/mob/species/human/human.dmi', user, "monkey")] Some <B>monkey paws</B>."
			else if(species == SPECIES_SIMIAN)
				. += "[icon2html('monkestation/icons/mob/species/monkey/bodyparts.dmi', user, "monkey_l_leg")] Some <B>simian paws</B>."
			else if(species == SPECIES_LIZARD)
				. += "[icon2html('icons/mob/species/lizard/bodyparts.dmi', user, "digitigrade_l_leg")] Some <B>lizard claws</B>."
			else if(species == SPECIES_HUMAN)
				. += "[icon2html('icons/mob/species/human/bodyparts.dmi', user, "default_human_l_leg")] Some <B>human feet</B>."
			else
				. += "[icon2html('icons/mob/species/human/bodyparts.dmi', user, "[species]_l_leg")] Some <B>[species] feet</B>."

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")

	base_name = ""
	can_dry = FALSE // No point

	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc
	/// The cached info about the blood
	var/list/blood_dna_info
	/// Skip making the final blood splatter when we're done, like if we're not in a turf
	var/skip = FALSE
	/// How many tiles/items/people we can paint red
	var/splatter_strength = 3
	/// Insurance so that we don't keep moving once we hit a stoppoint
	var/hit_endpoint = FALSE
	/// Type of squirt decals we should try to create when moving
	var/line_type = /obj/effect/decal/cleanable/blood/line

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, splatter_strength, blood_color = COLOR_BLOOD)
	. = ..()
	color = blood_color
	blood_dna_info = GET_ATOM_BLOOD_DNA(src)
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/Destroy()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		if(!length(blood_dna_info))
			blood_dna_info = GET_ATOM_BLOOD_DNA(src)
		if(blood_dna_info)
			loc.add_blood_DNA(blood_dna_info)
	return ..()

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/delay = 2
	var/datum/move_loop/loop = SSmove_manager.move_towards(src, target_turf, delay, timeout = delay * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	for(var/atom/iter_atom in get_turf(src))
		if(hit_endpoint)
			return
		if(splatter_strength <= 0)
			break

		if(isitem(iter_atom))
			iter_atom.add_blood_DNA(blood_dna_info)
			splatter_strength--
		else if(ishuman(iter_atom))
			var/mob/living/carbon/human/splashed_human = iter_atom
			if(splashed_human.wear_suit)
				splashed_human.wear_suit.add_blood_DNA(blood_dna_info)
				splashed_human.update_worn_oversuit()    //updates mob overlays to show the new blood (no refresh)
			if(splashed_human.w_uniform)
				splashed_human.w_uniform.add_blood_DNA(blood_dna_info)
				splashed_human.update_worn_undersuit()    //updates mob overlays to show the new blood (no refresh)
			splatter_strength--
	if(splatter_strength <= 0) // we used all the puff so we delete it.
		qdel(src)
		return
	if(line_type && isturf(loc))
		var/obj/effect/decal/cleanable/line = locate(line_type) in loc
		if(line)
			line.color = color
			line.add_blood_DNA(blood_dna_info)
		else
			line = new line_type(loc, get_dir(prev_loc, loc))
			line.color = color
			line.add_blood_DNA(blood_dna_info)
			line.alpha = 0
			animate(line, alpha = initial(line.alpha), time = 2)


/obj/effect/decal/cleanable/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/bumped_atom)
	if(!iswallturf(bumped_atom) && !istype(bumped_atom, /obj/structure/window))
		qdel(src)
		return

	if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/bumped_window = bumped_atom
		if(!bumped_window.fulltile)
			qdel(src)
			return

	hit_endpoint = TRUE
	if(isturf(prev_loc))
		abstract_move(bumped_atom)
		skip = TRUE
		//Adjust pixel offset to make splatters appear on the wall
		if(istype(bumped_atom, /obj/structure/window))
			land_on_window(bumped_atom)
		else
			var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new(prev_loc)
			final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
			final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
			final_splatter.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
			final_splatter.add_blood_DNA(blood_dna_info)
	else // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		qdel(src)

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!the_window.fulltile)
		return
	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new
	final_splatter.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	final_splatter.add_blood_DNA(blood_dna_info)
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	the_window.bloodied = TRUE
	qdel(src)

