/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(return_blood_DNA())
	if (bloodiness)
		if (C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/whiteblood
	name = "\"blood\""
	desc = "It's an unsettling colour. Maybe it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "genericsplatter1"
	random_icon_states = list("genericsplatter1", "genericsplatter2", "genericsplatter3", "genericsplatter4", "genericsplatter5", "genericsplatter6")

/obj/effect/decal/cleanable/whiteblood/ethereal
	name = "glowing \"blood\""
	desc = "It has a fading glow. Surely it's just the chef's cooking?"
	light_power = 1
	light_range = 2
	light_color = "#eef442"

/obj/effect/decal/cleanable/whiteblood/ethereal/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	add_atom_colour(light_color, FIXED_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, PROC_REF(Fade)), 1 MINUTES)

/obj/effect/decal/cleanable/whiteblood/ethereal/proc/Fade()
	name = "faded \"blood\""
	light_power = 0
	light_range = 0
	update_light()

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while.  Eew."
	bloodiness = 0
	icon_state = "floor1-old"

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type())) // Needs to happen before ..()
	. = ..()
	icon_state = "[icon_state]-old" //change from the normal blood icon selected from random_icon_states in the parent's Initialize to the old dried up blood.

/obj/effect/decal/cleanable/blood/old/can_bloodcrawl_in() //Yogs -- dried blood bloodcrawl
	return TRUE

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	turf_loc_check = FALSE
	alpha = 180

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	icon_state = "tracks"
	random_icon_states = null

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon = 'icons/effects/blood.dmi'
	desc = "Your instincts say you shouldn't be following these."
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/trail_holder/proc/Etherealify()
	name = "glowing \"blood\""
	light_power = 1
	light_range = 2
	light_color = "#eef442"
	update_light()
	add_atom_colour(light_color, FIXED_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, PROC_REF(Fade)), 1 MINUTES)

/obj/effect/decal/cleanable/trail_holder/proc/Fade()
	name = "faded \"blood\""
	light_power = 0
	light_range = 0
	update_light()

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE

	var/already_rotting = FALSE

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/liquidgibs, 5)
	if(already_rotting)
		start_rotting(rename=FALSE)
	else
		addtimer(CALLBACK(src, PROC_REF(start_rotting)), 2 MINUTES)

/obj/effect/decal/cleanable/blood/gibs/proc/start_rotting(rename=TRUE)
	if(rename)
		name = "rotting [initial(name)]"
		desc += " They smell terrible."
	AddComponent(/datum/component/rot/gibs)

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return

/obj/effect/decal/cleanable/blood/gibs/Crossed(atom/movable/L)
	if(isliving(L) && has_gravity(loc))
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, TRUE)
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions, mapload=FALSE)
	set waitfor = FALSE
	var/list/diseases = list()
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions, diseases)
	var/direction = pick(directions)
	for(var/i in 0 to pick(0, 200; 1, 150; 2, 50))
		if (!mapload)
			sleep(0.2 SECONDS)
		if(i > 0)
			new /obj/effect/decal/cleanable/blood/splatter(loc, diseases)
		if(!step_to(src, get_step(src, direction), 0))
			break

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
	bloodiness = 0
	already_rotting = TRUE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1,2,4,8))
	icon_state += "-old"
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE


//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "nothingwhatsoever"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon_state = "blood1"
	random_icon_states = null
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/entered_dirs = 0
	var/exited_dirs = 0
	var/list/shoe_types = list()

/obj/effect/decal/cleanable/blood/footprints/Crossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types |= S.type
			if (!(entered_dirs & H.dir))
				entered_dirs |= H.dir
				update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/blood/footprints/Uncrossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && istype(S) && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types  |= S.type
			if (!(exited_dirs & H.dir))
				exited_dirs |= H.dir
				update_appearance(UPDATE_ICON)


/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]1", dir = Ddir)
			. += bloodstep_overlay
		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]2", dir = Ddir)
			. += bloodstep_overlay

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA + bloodiness


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(shoe_types.len)
		. += "You recognise the footprints as belonging to:\n"
		for(var/shoe in shoe_types)
			var/obj/item/clothing/shoes/S = shoe
			. += "[icon2html(initial(S.icon), user)] Some <B>[initial(S.name)]</B>.\n"

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE
	
/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
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

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, splatter_strength)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/Destroy()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		if(blood_dna_info)
			loc.add_blood_DNA(blood_dna_info)
	return ..()

/// Set the splatter up to fly through the air until it rounds out of steam or hits something. Contains sleep() pending imminent moveloop rework, don't call without async'ing it
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	if(range <= 0)
		qdel(src)
		return

	step_towards(src,target_turf)
	prev_loc = loc
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
				splashed_human.update_inv_wear_suit()    //updates mob overlays to show the new blood (no refresh)
			if(splashed_human.w_uniform)
				splashed_human.w_uniform.add_blood_DNA(blood_dna_info)
				splashed_human.update_inv_w_uniform()    //updates mob overlays to show the new blood (no refresh)
			splatter_strength--

	if(splatter_strength <= 0) // we used all the puff so we delete it.
		qdel(src)
		return

	addtimer(CALLBACK(src, PROC_REF(fly_towards), target_turf, range -1), 2)

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
	else // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		qdel(src)

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!the_window.fulltile)
		return
	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	the_window.bloodied = TRUE
	qdel(src)

/obj/effect/decal/cleanable/blood/kilo
	name = "remember kilo"
	desc = "Someone really wasted their time writing this before dying."
	icon = 'yogstation/icons/effects/station_blood.dmi'
	icon_state = "kilo"
	random_icon_states = null
