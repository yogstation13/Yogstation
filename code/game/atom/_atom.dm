/**
  * The base type for nearly all physical objects in SS13

  * Lots and lots of functionality lives here, although in general we are striving to move
  * as much as possible to the components/elements system
  */
/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND|LONG_GLIDE

	///If non-null, overrides a/an/some in all cases
	var/article

	/// How many tiles "up" this light is. 1 is typical, should only really change this if it's a floor light
	var/light_height = LIGHTING_HEIGHT

	///First atom flags var
	var/flags_1 = NONE
	///Intearaction flags
	var/interaction_flags_atom = NONE

	///Reagents holder
	var/datum/reagents/reagents = null

	///all of this atom's HUD (med/sec, etc) images. Associative list of the form: list(hud category = hud image or images for that category).
	///most of the time hud category is associated with a single image, sometimes its associated with a list of images.
	///not every hud in this list is actually used. for ones available for others to see, look at active_hud_list.
	var/list/image/hud_list = null
	///all of this atom's HUD images which can actually be seen by players with that hud
	var/list/image/active_hud_list = null
	///HUD images that this atom can provide.
	var/list/hud_possible

	var/list/alternate_appearances

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	/**
	  * used to store the different colors on an atom
	  *
	  * its inherent color, the colored paint applied on it, special color effect etc...
	  */
	var/list/atom_colours

	var/datum/wires/wires = null
	var/obj/effect/abstract/particle_holder/master_holder

	///Light systems, both shouldn't be active at the same time.
	var/light_system = STATIC_LIGHT
	///Range of the light in tiles. Zero means no light.
	var/light_range = 0
	///Intensity of the light. The stronger, the less shadows you will see on the lit area.
	var/light_power = 1
	///Hexadecimal RGB string representing the colour of the light. White by default.
	var/light_color = COLOR_WHITE
	/// Angle of light to show in light_dir
	/// 360 is a circle, 90 is a cone, etc.
	var/light_angle = 360
	/// What angle to project light in
	var/light_dir = NORTH
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	///Bitflags to determine lighting-related atom properties.
	var/light_flags = NONE
	///Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/light_source/light
	///Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/light_sources

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays
	var/list/managed_vis_overlays

	/// Lazylist of all images (or atoms, I'm sorry) (hopefully attached to us) to update when we change z levels
	/// You will need to manage adding/removing from this yourself, but I'll do the updating for you
	var/list/image/update_on_z

	/// Lazylist of all overlays attached to us to update when we change z levels
	/// You will need to manage adding/removing from this yourself, but I'll do the updating for you
	/// Oh and note, if order of addition is important this WILL break that. so mind yourself
	var/list/image/update_overlays_on_z
	
	///Proximity monitor associated with this atom
	var/datum/proximity_monitor/proximity_monitor
	///Cooldown tick timer for buckle messages
	var/buckle_message_cooldown = 0
	///Last fingerprints to touch this atom
	var/fingerprintslast

	///Economy cost of item
	var/custom_price
	///Economy cost of item in premium vendor
	var/custom_premium_price
	///Whether spessmen with an ID with an age below AGE_MINOR (21 by default) can buy this item
	var/age_restricted = FALSE
	//List of datums orbiting this atom
	var/datum/component/orbiter/orbiters

	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	var/list/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE

	var/chat_color_name // Last name used to calculate a color for the chatmessage overlays

	var/chat_color // Last color calculated for the the chatmessage overlays

	var/chat_color_darkened // A luminescence-shifted value of the last color calculated for chatmessage overlays

	///Default pixel x shifting for the atom's icon.
	var/base_pixel_x = 0
	///Default pixel y shifting for the atom's icon.
	var/base_pixel_y = 0
	///The config type to use for greyscaled sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config
	///A string of hex format colors to be used by greyscale sprites, ex: "#0054aa#badcff"
	var/greyscale_colors
	///the base icon state used for anything that changes their icon state.
	var/base_icon_state
	///Mobs that are currently do_after'ing this atom, to be cleared from on Destroy()
	var/list/targeted_by

	///Icon-smoothing behavior.
	var/smoothing_flags = NONE
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
	///Smoothing variable
	var/top_left_corner
	///Smoothing variable
	var/top_right_corner
	///Smoothing variable
	var/bottom_left_corner
	///Smoothing variable
	var/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it. Must be sorted.
	var/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself. Must be sorted.
	var/list/canSmoothWith = null

	var/atom/orbit_target //Reference to atom being orbited

	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE
	///Armor datum used by the atom
	var/datum/armor/armor
	///Current integrity, defaults to max_integrity on init
	VAR_PRIVATE/atom_integrity
	///Maximum integrity
	var/max_integrity = 500
	///Integrity level when this atom will "break" (whatever that means) 0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	var/integrity_failure = 0
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

/**
  * Top level of the destroy chain for most atoms
  *
  * Cleans up the following:
  * * Removes alternate apperances from huds that see them
  * * qdels the reagent holder from atoms if it exists
  * * clears the orbiters list
  * * clears overlays and priority overlays
  * * clears the light object
  */
/atom/Destroy()
	if(alternate_appearances)
		for(var/current_alternate_appearance in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/selected_alternate_appearance = alternate_appearances[current_alternate_appearance]
			selected_alternate_appearance.remove_atom_from_hud(src)

	if(reagents)
		qdel(reagents)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	// Checking length(overlays) before cutting has significant speed benefits
	if (length(overlays))
		overlays.Cut()

	for(var/i in targeted_by)
		var/mob/M = i
		LAZYREMOVE(M.do_afters, src)

	targeted_by = null

	QDEL_NULL(light)
	if (length(light_sources))
		light_sources.Cut()
	
	if(smoothing_flags & SMOOTH_QUEUED)
		SSicon_smooth.remove_from_queues(src)

	return ..()

/atom/proc/handle_ricochet(obj/projectile/P)
	return

///Can the mover object pass this atom, while heading for the target turf
/atom/proc/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(mover.movement_type & PHASING)
		return TRUE
	. = CanAllowThrough(mover, target)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, target, .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return !density

/**
  * Is this atom currently located on centcom
  *
  * Specifically, is it on the z level and within the centcom areas
  *
  * You can also be in a shuttleshuttle during endgame transit
  *
  * Used in gamemode to identify mobs who have escaped and for some other areas of the code
  * who don't want atoms where they shouldn't be
  */
/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_reserved_level(T.z))
		for(var/A in SSshuttle.mobile_docking_ports)
			var/obj/docking_port/mobile/M = A
			if(M.launch_status == ENDGAME_TRANSIT)
				for(var/place in M.shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(T in shuttle_area)
						return TRUE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/A in SSshuttle.mobile_docking_ports)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			for(var/place in M.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(T in shuttle_area)
					return TRUE

/**
  * Is the atom in any of the centcom syndicate areas
  *
  * Either in the syndie base on centcom, or any of their shuttles
  *
  * Also used in gamemode code for win conditions
  */
/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/centcom/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

///This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		log_combat(user, src, "punched", "hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/**
  * Ensure a list of atoms/reagents exists inside this atom
  *
  * Goes throught he list of passed in parts, if they're reagents, adds them to our reagent holder
  * creating the reagent holder if it exists.
  *
  * If the part is a moveable atom and the  previous location of the item was a mob/living,
  * it calls the inventory handler transferItemToLoc for that mob/living and transfers the part
  * to this atom
  *
  * Otherwise it simply forceMoves the atom into this atom
  */
/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(ismovable(A))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.transferItemToLoc(M, src)
			else
				M.forceMove(src)

///Take air from the passed in gas mixture datum
/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/assume_air_moles(datum/gas_mixture/giver, moles)
	return null

/atom/proc/assume_air_ratio(datum/gas_mixture/giver, ratio)
	return null

///Remove air from this atom
/atom/proc/remove_air(amount)
	return null

/atom/proc/remove_air_ratio(ratio)
	return null

/atom/proc/transfer_air(datum/gas_mixture/taker, amount)
	return null

/atom/proc/transfer_air_ratio(datum/gas_mixture/taker, ratio)
	return null

///Return the current air environment in this atom
/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	return null

///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

///Check if this atoms eye is still alive (probably)
/atom/proc/check_eye(mob/user)
	SIGNAL_HANDLER
	return

/atom/proc/Bumped(atom/movable/bumped_atom)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, bumped_atom)

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (INJECTABLE | REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (DRAWABLE | DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (reagents.flags & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (reagents.flags & DRAINABLE)

/// Can this atom spill its reagents
/atom/proc/is_spillable()
	return reagents && (reagents.flags & SPILLABLE)

/// Are you allowed to drop this atom
/atom/proc/AllowDrop()
	return FALSE

/// Are you allowed to pass a sided object of the same dir
/atom/proc/CheckExit()
	return TRUE

///Is this atom within 1 tile of another atom
/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/**
  * React to an EMP of the given severity
  *
  * Default behaviour is to send the COMSIG_ATOM_EMP_ACT signal
  *
  * If the signal does not return protection, and there are attached wires then we call
  * emp_pulse() on the wires
  *
  * We then return the protection value
  */
/atom/proc/emp_act(severity)
	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	var/protection = NONE
	if(HAS_TRAIT(src, TRAIT_EMPPROOF_CONTENTS))
		protection |= EMP_PROTECT_CONTENTS
	if(HAS_TRAIT(src, TRAIT_EMPPROOF_SELF))
		protection |= EMP_PROTECT_SELF
	if(!(protection & EMP_PROTECT_CONTENTS) && istype(wires))
		wires.emp_pulse()
	return protection // Pass the protection value collected here upwards

/**
  * React to a hit by a projectile object
  *
  * Default behaviour is to send the COMSIG_ATOM_BULLET_ACT and then call on_hit() on the projectile
  */
/atom/proc/bullet_act(obj/projectile/P, def_zone)
	var/sig_return = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	if(sig_return != NONE)
		return sig_return
	. = P.on_hit(src, 0, def_zone)
	if(uses_integrity)
		playsound(src, P.hitsound, 50, 1)
		visible_message(span_danger("[src] is hit by \a [P]!"), null, null, COMBAT_MESSAGE_RANGE)
		if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
			var/demolition_mult = P.demolition_mod
			if(istype(src, /obj/mecha) && P.demolition_mod != 1)	//snowflake damage checks for mechs
				demolition_mult = istype(src, /obj/mecha/combat) ? min(1, (1 + P.demolition_mod)/2) : (1 + P.demolition_mod)/2
			take_damage(P.damage * demolition_mult, P.damage_type, P.armor_flag, 0, turn(P.dir, 180), P.armour_penetration)

///Return true if we're inside the passed in atom
/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/**
  * Get the name of this object for examine
  *
  * You can override what is returned from this proc by registering to listen for the
  * COMSIG_ATOM_GET_EXAMINE_NAME signal
  */
/atom/proc/get_examine_name(mob/user)
	. = "\a <b>[src]</b>"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] <b>[src]</b>"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/**
  * Called when a mob examines (shift click or verb) this atom
  *
  * Default behaviour is to get the name and icon of the object and it's reagents where
  * the TRANSPARENT flag is set on the reagents holder
  *
  * Produces a signal COMSIG_ATOM_EXAMINE
  */
/atom/proc/examine(mob/user)
	var/examine_string = get_examine_string(user, thats = TRUE)
	if(examine_string)
		. = list("[examine_string].")
	else
		. = list()

	if(desc)
		. += desc

	if(uses_integrity && atom_integrity < max_integrity)
		if(resistance_flags & ON_FIRE)
			. += span_warning("It's on fire!")
		var/integrity = atom_integrity*100/max_integrity
		switch(integrity)
			if(66 to 100)
				. += "It's slightly damaged."
			if(33 to 66)
				. += "It's heavily damaged."
			if(0 to 33)
				. += span_warning("It's falling apart!")

	if(custom_materials)
		for(var/i in custom_materials)
			var/datum/material/M = i
			. += "<u>It is made out of [M.name]</u>."

	if(reagents)
		if(reagents.flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list))
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/datum/reagent/current_reagent in reagents.reagent_list)
						. += "&bull; [round(current_reagent.volume, 0.01)] units of [current_reagent.name]"
				else //Otherwise, just show the total volume
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					. += "[total_volume] units of various reagents"
			else
				. += "Nothing."
		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += span_notice("It has [reagents.total_volume] unit\s left.")
			else
				. += span_danger("It's empty.")

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("\n")

/**
  * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1.5 seconds)
  *
  * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
  * moments, while allowing people to manually double-examine to take a closer look
  *
  * Produces a signal [COMSIG_ATOM_EXAMINE_MORE]
  */
/atom/proc/examine_more(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_MORE, user, .)
	if(!LAZYLEN(.)) // lol ..length
		return FALSE

/// Handles updates to greyscale value updates.
/// The colors argument can be either a list or the full color string.
/// Child procs should call parent last so the update happens after all changes.
/atom/proc/set_greyscale(list/colors, new_config)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(colors))
		colors = colors.Join("")
	if(!isnull(colors) && greyscale_colors != colors) // If you want to disable greyscale stuff then give a blank string
		greyscale_colors = colors

	if(!isnull(new_config) && greyscale_config != new_config)
		greyscale_config = new_config

	update_greyscale()

/// Checks if this atom uses the GAGS system and if so updates the icon
/atom/proc/update_greyscale()
	SHOULD_CALL_PARENT(TRUE)
	if(greyscale_colors && greyscale_config)
		icon = SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)
	if(!smoothing_flags) // This is a bitfield but we're just checking that some sort of smoothing is happening
		return
	update_atom_colour()
	QUEUE_SMOOTH(src)

/**
 * An atom we are buckled or is contained within us has tried to move
 *
 * Default behaviour is to send a warning that the user can't move while buckled as long
 * as the [buckle_message_cooldown][/atom/var/buckle_message_cooldown] has expired (50 ticks)
 */
/atom/proc/relaymove(mob/living/user, direction)
	if(SEND_SIGNAL(src, COMSIG_ATOM_RELAYMOVE, user, direction) & COMSIG_BLOCK_RELAYMOVE)
		return
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, span_warning("You can't move while buckled to [src]!"))
	return

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
  * React to being hit by an explosion
  *
  * Default behaviour is to call contents_explosion() and send the COMSIG_ATOM_EX_ACT signal
  */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)

/**
  * React to a hit by a blob objecd
  *
  * default behaviour is to send the COMSIG_ATOM_BLOB_ACT signal
  */
/atom/proc/blob_act(obj/structure/blob/B)
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)
	return

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/**
  * React to being hit by a thrown object
  *
  * Default behaviour is to call hitby_react() on ourselves after 2 seconds if we are dense
  * and under normal gravity.
  *
  * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
  * deleted shortly after hitting something (during explosions or other massive events that
  * throw lots of items around - singularity being a notable example)
  */
/atom/proc/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, hitting_atom, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(hitting_atom)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), hitting_atom), 2)

/**
  * We have have actually hit the passed in atom
  *
  * Default behaviour is to move back from the item that hit us
  */
/atom/proc/hitby_react(atom/movable/harmed_atom)
	if(harmed_atom && isturf(harmed_atom.loc))
		step(harmed_atom, REVERSE_DIR(harmed_atom.dir))

///Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube, stun, force_drop)
	return

///returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	return list("ANIMAL DNA" = get_blood_type("Y-"))

///Get the mobs dna list
/mob/living/carbon/get_blood_dna_list()
	if(!(get_blood_id() in list(/datum/reagent/blood, /datum/reagent/toxin/acid, /datum/reagent/consumable/liquidelectricity))) //polysmorphs have DNA located in literal acid, don't ask me why
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = get_blood_type("X"))

/mob/living/silicon/get_blood_dna_list()
	return list("SYNTHETIC COOLANT" = get_blood_type("Coolant"))

///to add a mob's dna info into an object's blood_dna list.
/atom/proc/transfer_mob_blood_dna(mob/living/injected_mob)
	// Returns 0 if we have that blood already
	var/new_blood_dna = injected_mob.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = blood_DNA_length()
	add_blood_DNA(new_blood_dna)
	if(blood_DNA_length() == old_length)
		return FALSE
	return TRUE

///to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna)

///wash cream off this object
///
///(for the love of space jesus please make this a component)
/atom/proc/wash_cream()
	return TRUE

/**
  * Wash this atom
  *
  * This will clean it off any temporary stuff like blood. Override this in your item to add custom cleaning behavior.
  * Returns true if any washing was necessary and thus performed
  * Arguments:
  * * clean_types: any of the CLEAN_ constants
  */
/atom/proc/wash(clean_types)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, clean_types))
		. = TRUE

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOUR_PRIORITY && atom_colours[WASHABLE_COLOUR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return TRUE
	return FALSE //needs this here so it won't return true if things don't wash

///Is this atom in space
/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

///Called when gravity returns after floating I think
/atom/proc/handle_fall()
	return

///Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
  * Respond to the singularity pulling on us
  *
  * Default behaviour is to send COMSIG_ATOM_SING_PULL and return
  */
/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)


/**
  * Respond to acid being used on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_ACID_ACT and return
  */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/**
  * Respond to an emag being used on our atom
  *
  * Args:
  * * mob/user: The mob that used the emag. Nullable.
  * * obj/item/card/emag/emag_card: The emag that was used. Nullable.
  *
  * Returns:
  * TRUE if the emag had any effect, falsey otherwise.
  */
/atom/proc/emag_act(mob/user, obj/item/card/emag/emag_card)
	SHOULD_CALL_PARENT(FALSE) // Emag act should either be: overridden (no signal) or default (signal).
	return (SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user, emag_card))

/**
  * Respond to a radioactive wave hitting this atom
  *
  * Default behaviour is to send COMSIG_ATOM_RAD_ACT and return
  */
/atom/proc/rad_act(strength, collectable_radiation)
	if(flags_1 & RAD_CONTAIN_CONTENTS)
		return
	if(loc && (loc.flags_1 & RAD_CONTAIN_CONTENTS))
		return
	SEND_SIGNAL(src, COMSIG_ATOM_RAD_ACT, strength, collectable_radiation)

/**
  * Respond to narsie eating our atom
  *
  * Default behaviour is to send COMSIG_ATOM_NARSIE_ACT and return
  */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)

/**
  * Respond to ratvar eating our atom
  *
  * Default behaviour is to send COMSIG_ATOM_RATVAR_ACT and return
  */
/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/**
  * Respond to honkmother eating our atom
  *
  * Default behaviour is to send COMSIG_ATOM_HONK_ACT and return
  */
/atom/proc/honk_act()
	SEND_SIGNAL(src, COMSIG_ATOM_HONK_ACT)

///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE


/**
  * Respond to an RCD acting on our item
  *
  * Default behaviour is to send COMSIG_ATOM_RCD_ACT and return FALSE
  */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/**
  * Implement the behaviour for when a user click drags a storage object to your atom
  *
  * This behaviour is usually to mass transfer, but this is no longer a used proc as it just
  * calls the underyling /datum/component/storage dump act if a component exists
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(GetComponent(/datum/component/storage))
		return component_storage_contents_dump_act(src_object, user)
	return FALSE

/**
  * Implement the behaviour for when a user click drags another storage item to you
  *
  * In this case we get as many of the tiems from the target items compoent storage and then
  * put everything into ourselves (or our storage component)
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/component_storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	var/list/things = src_object.contents()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	//yogs start -- stops things from dumping into themselves
	if(STR == src_object)
		to_chat(user,span_warning("You can't dump the contents of [src_object.parent] into itself!"))
		return
	//yogs end
	while (do_after(user, 1 SECONDS, src, TRUE, FALSE, CALLBACK(STR, TYPE_PROC_REF(/datum/component/storage, handle_mass_item_insertion), things, src_object, user)))
		stoplag(1)
	to_chat(user, span_notice("You dump as much of [src_object.parent]'s contents into [STR.insert_preposition]to [src] as you can."))
	STR.orient2hud(user)
	src_object.orient2hud(user)
	if(user.active_storage) //refresh the HUD to show the transfered contents
		user.active_storage.close(user)
		user.active_storage.show_to(user)
	return TRUE

///Get the best place to dump the items contained in the source storage item?
/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/**
  * This proc is called when an atom in our contents has it's Destroy() called
  *
  * Default behaviour is to simply send COMSIG_ATOM_CONTENTS_DEL
  */
/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/**
  * called when the turf the atom resides on is ChangeTurfed
  *
  * Default behaviour is to loop through atom contents and call their HandleTurfChange() proc
  */
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)

/**
  * the vision impairment to give to the mob whose perspective is set to that atom
  *
  * (e.g. an unfocused camera giving you an impaired vision when looking through it)
  */
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

/**
  * the sight changes to give to the mob whose perspective is set to that atom
  *
  * (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
  */
/atom/proc/update_remote_sight(mob/living/user)
	return


/**
  * Hook for running code when a dir change occurs
  *
  * Not recommended to use, listen for the COMSIG_ATOM_DIR_CHANGE signal instead (sent by this proc)
  */
/atom/proc/setDir(newdir)
	SHOULD_CALL_PARENT(TRUE)
	if (SEND_SIGNAL(src, COMSIG_ATOM_PRE_DIR_CHANGE, dir, newdir) & COMPONENT_ATOM_BLOCK_DIR_CHANGE)
		newdir = dir
		return
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir
	SEND_SIGNAL(src, COMSIG_ATOM_POST_DIR_CHANGE, dir, newdir)
	if(smoothing_flags & SMOOTH_BORDER_OBJECT)
		QUEUE_SMOOTH_NEIGHBORS(src)

/**
  * Used to change the pixel shift of an atom
  */
/atom/proc/setShift(dir)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_SHIFT_CHANGE, dir)

	var/new_x = pixel_x
	var/new_y = pixel_y

	if (dir & NORTH)
		new_y++

	if (dir & EAST)
		new_x++

	if (dir & SOUTH)
		new_y--

	if (dir & WEST)
		new_x--

	pixel_x = clamp(new_x, -16, 16)
	pixel_y = clamp(new_y, -16, 16)

///Handle melee attack by a mech
/atom/proc/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	if(!uses_integrity)
		return
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	punch_force *= M.demolition_mod
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				if(M.meleesound)
					playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				if(M.meleesound)
					playsound(src, 'sound/items/welder.ogg', 50, 1)
			if(TOX)
				if(M.meleesound)
					playsound(src, 'sound/effects/spray2.ogg', 50, 1)
				return 0
			else
				return 0
	visible_message(span_danger("[M.name] has hit [src]."), null, null, COMBAT_MESSAGE_RANGE)
	return take_damage(punch_force, mech_damtype, MELEE, play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/**
  * Called when the atom log's in or out
  *
  * Default behaviour is to call on_log on the location this atom is in
  */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()

/atom/proc/update_atom_colour()
///Resets the atom's color to null, and then sets it to the highest priority colour available
	color = null
	if(!atom_colours)
		return
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/**
  * call back when a var is edited on this atom
  *
  * Can be used to implement special handling of vars
  *
  * At the atom level, if you edit a var named "color" it will add the atom colour with
  * admin level priority to the atom colours list
  *
  * Also, if GLOB.Debug2 is FALSE, it sets the ADMIN_SPAWNED_1 flag on flags_1, which signifies
  * the object has been admin edited
  */
/atom/vv_edit_var(var_name, var_value)
	var/old_light_flags = light_flags
	// Disable frozen lights for now, so we can actually modify it
	light_flags &= ~LIGHT_FROZEN	
	switch(var_name)
		
		if(NAMEOF(src, light_range))
			if(light_system == STATIC_LIGHT)
				set_light(l_range = var_value)
			else
				set_light_range(var_value)
			. = TRUE
		if(NAMEOF(src, light_power))
			if(light_system == STATIC_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			. = TRUE
		if(NAMEOF(src, light_color))
			if(light_system == STATIC_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			. = TRUE
		if(NAMEOF(src, light_angle))
			if(light_system == STATIC_LIGHT)
				set_light(l_angle = var_value)
				. = TRUE
		if(NAMEOF(src, light_dir))
			if(light_system == STATIC_LIGHT)
				set_light(l_dir = var_value)
				. = TRUE
		if(NAMEOF(src, light_on))
			set_light_on(var_value)
			. = TRUE
		if(NAMEOF(src, light_flags))
			set_light_flags(var_value)
			// I'm sorry
			old_light_flags = var_value
			. = TRUE

	light_flags = old_light_flags
	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1

	. = ..()	
	
	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)
			update_appearance()
		if(NAMEOF(src, opacity))
			set_opacity(var_value)
			. = TRUE

/**
  * Return the markup to for the dropdown list for the VV panel for this atom
  *
  * Override in subtypes to add custom VV handling in the VV panel
  */
/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_SEPERATOR
	if(!ismovable(src))
		var/turf/curturf = get_turf(src)
		if (curturf)
			. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_SHOW_HIDDENPRINTS, "Show Hiddenprint log")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_RADIATE, "Radiate")
	if(greyscale_colors)
		VV_DROPDOWN_OPTION(VV_HK_MODIFY_GREYSCALE, "Modify greyscale colors")

/atom/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADD_REAGENT] && check_rights(R_VAREDIT))
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num|null
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/chosen_id
			switch(tgui_alert(usr, "Choose a method.", "Add Reagents", list("Search", "Choose from a list", "I'm feeling lucky")))
				if("Search")
					var/valid_id
					while(!valid_id)
						chosen_id = input(usr, "Enter the ID of the reagent you want to add.", "Search reagents") as null|text
						if(isnull(chosen_id)) //Get me out of here!
							break
						if (!ispath(text2path(chosen_id)))
							chosen_id = pick_closest_path(chosen_id, make_types_fancy(subtypesof(/datum/reagent)))
							if (ispath(chosen_id))
								valid_id = TRUE
						else
							valid_id = TRUE
						if(!valid_id)
							to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
				if("Choose from a list")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in sortList(subtypesof(/datum/reagent), /proc/cmp_typepaths_asc)
				if("I'm feeling lucky")
					chosen_id = pick(subtypesof(/datum/reagent))
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num|null
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins(span_notice("[key_name(usr)] has added [amount] units of [chosen_id] to [src]"))

	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)

	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)

	if(href_list[VV_HK_SHOW_HIDDENPRINTS])
		usr.client.cmd_show_hiddenprints(src)

	if(href_list[VV_HK_RADIATE] && check_rights(R_FUN))
		var/strength = input(usr, "Choose the radiation strength.", "Choose the strength.") as num|null
		if(!isnull(strength))
			AddComponent(/datum/component/radioactive, strength)

	if(href_list[VV_HK_MODIFY_TRANSFORM] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = transform
		if(!result)
			return
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(isnull(x) || isnull(y))
					return
				transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod (negative = left, positive = right)","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod (negative = down, positive = up)","Transform Mod") as null|num
				if(isnull(x) || isnull(y))
					return
				transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
				if(isnull(angle))
					return
				transform = M.Turn(angle)

	if(href_list[VV_HK_AUTO_RENAME] && check_rights(R_VAREDIT))
		var/newname = input(usr, "What do you want to rename this to?", "Automatic Rename") as null|text
		// Check the new name against the chat filter. If it triggers the IC chat filter, give an option to confirm.
		if(newname)
			log_admin("[key_name(usr)] renamed [src] to [newname].")
			message_admins("Admin [key_name_admin(usr)] renamed [ADMIN_FLW(src)] to [newname].")
			vv_auto_rename(newname)

/atom/proc/vv_auto_rename(newname)
	name = newname

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

///Where atoms should drop if taken from this atom
/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()

/**
  * An atom has entered this atom's contents
  *
  * Default behaviour is to send the COMSIG_ATOM_ENTERED
  */
/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/**
  * An atom is attempting to exit this atom's contents
  *
  * Default behaviour is to send the COMSIG_ATOM_EXIT
  *
  * Return value should be set to FALSE if the moving atom is unable to leave,
  * otherwise leave value the result of the parent call
  */
/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/**
  * An atom has exited this atom's contents
  *
  * Default behaviour is to send the COMSIG_ATOM_EXITED
  */
/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

///Return atom temperature
/atom/proc/return_temperature()
	return

///Generate a tag for this /datum, if it implements one
///Should be called as early as possible, best would be in New, to avoid weakref mistargets
///Really just don't use this, you don't need it, global lists will do just fine MOST of the time
///We really only use it for mobs to make id'ing people easier
/datum/proc/GenerateTag()
	datum_flags |= DF_USE_TAG

///Connect this atom to a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return

/obj/item/update_filters()
	. = ..()
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

/atom/proc/intercept_zImpact(atom/movable/falling_movables, levels = 1)
	SHOULD_CALL_PARENT(TRUE)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, falling_movables, levels)

///Setter for the `density` variable to append behavior related to its changing.
/atom/proc/set_density(new_value)
	SHOULD_CALL_PARENT(TRUE)
	if(density == new_value)
		return
	. = density
	density = new_value

/**
  * Causes effects when the atom gets hit by a rust effect from heretics
  *
  * Override this if you want custom behaviour in whatever gets hit by the rust
  */
/atom/proc/rust_heretic_act()

/**
 * Used to set something as 'open' if it's being used as a supplypod
 *
 * Override this if you want an atom to be usable as a supplypod.
 */
/atom/proc/setOpened()
	return

/**
 * Used to set something as 'closed' if it's being used as a supplypod
 *
 * Override this if you want an atom to be usable as a supplypod.
 */
/atom/proc/setClosed()
	return

///Passes Stat Browser Panel clicks to the game and calls client click on an atom
/atom/Topic(href, list/href_list)
	. = ..()
	if(!usr?.client)
		return
	var/client/usr_client = usr.client
	var/list/paramslist = list()
	if(href_list["statpanel_item_shiftclick"])
		paramslist["shift"] = "1"
	if(href_list["statpanel_item_ctrlclick"])
		paramslist["ctrl"] = "1"
	if(href_list["statpanel_item_altclick"])
		paramslist["alt"] = "1"
	if(href_list["statpanel_item_click"])
		// first of all make sure we valid
		var/mouseparams = list2params(paramslist)
		usr_client.Click(src, loc, null, mouseparams)
		return TRUE
