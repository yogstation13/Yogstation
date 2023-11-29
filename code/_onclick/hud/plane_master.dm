/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0
	/// If our plane master allows for offsetting
	/// Mostly used for planes that really don't need to be duplicated, like the hud planes
	var/allows_offsetting = TRUE
	//--rendering relay vars--
	/// list of planes we will relay this plane's render to
	var/list/render_relay_planes = list(RENDER_PLANE_GAME)
	/// If this plane master is being forced to hide.
	/// Hidden PMs will dump ANYTHING relayed or drawn onto them. Be careful with this
	/// Remember: a hidden plane master will dump anything drawn directly to it onto the output render. It does NOT hide its contents
	/// Use alpha for that
	var/force_hidden = FALSE
	/// If this plane master is outside of our visual bounds right now
	var/is_outside_bounds = FALSE
	/// Our offset from our "true" plane, see below
	var/offset
	/// list of current relays this plane is utilizing to render
	var/list/atom/movable/render_plane_relay/relays = list()
	/// if render relays have already be generated
	var/relays_generated = FALSE
	/// See [code\__DEFINES\layers.dm] for our bitflags
	var/critical = NONE
	/// The plane master group we're a member of, our "home"
	var/datum/plane_master_group/home
	/// blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	/// Our real alpha value, so alpha can persist through being hidden/shown
	var/true_alpha = 255
	/// Tracks if we're using our true alpha, or being manipulated in some other way
	var/alpha_enabled = TRUE


/atom/movable/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/atom/movable/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/atom/movable/screen/plane_master/proc/backdrop(mob/mymob)

///Things rendered on "openspace"; holes in multi-z
/atom/movable/screen/plane_master/openspace
	name = "open space plane master"
	plane = FLOOR_OPENSPACE_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

/atom/movable/screen/plane_master/proc/disable_alpha()
	alpha_enabled = FALSE
	alpha = 0

/atom/movable/screen/plane_master/proc/enable_alpha()
	alpha_enabled = TRUE
	alpha = true_alpha
/atom/movable/screen/plane_master/openspace/backdrop(mob/mymob)
	filters = list()
	filters += filter(type="alpha", render_source = LIGHTING_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -10)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -15)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -20)

/atom/movable/screen/plane_master/proc/outline(_size, _color)
	filters += filter(type = "outline", size = _size, color = _color)

/atom/movable/screen/plane_master/proc/shadow(_size, _border, _offset = 0, _x = 0, _y = 0, _color = "#04080FAA")
	filters += filter(type = "drop_shadow", x = _x, y = _y, color = _color, size = _size, offset = _offset)

/atom/movable/screen/plane_master/proc/clear_filters()
	filters = list()

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_GAME, LIGHT_MASK_PLANE)

/atom/movable/screen/plane_master/transparent_floor
	name = "Transparent Floor"
	// documentation = "Really just openspace, stuff that is a turf but has no color or alpha whatsoever.
	// 	<br>We use this to draw to just the light mask plane, cause if it's not there we get holes of blackness over openspace"
	plane = TRANSPARENT_FLOOR_PLANE
	render_relay_planes = list(LIGHT_MASK_PLANE)
	// Needs to be critical or it uh, it'll look white
	critical = PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_NO_RELAY

/atom/movable/screen/plane_master/floor/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))
	// Should be moved to the world render plate when render plates get ported in
	filters += filter(type="displace", render_source = SINGULARITY_RENDER_TARGET, size=75)

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		filters += AMBIENT_OCCLUSION
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))
	// Should be moved to the world render plate when render plates get ported in
	filters += filter(type="displace", render_source = SINGULARITY_RENDER_TARGET, size=75)


/atom/movable/screen/plane_master/wall
	name = "Wall"
	// documentation = "Holds all walls. We render this onto the game world. Separate so we can use this + space and floor planes as a guide for where byond blackness is NOT."
	plane = WALL_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, LIGHT_MASK_PLANE)

/atom/movable/screen/plane_master/wall/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset), relay_layer = EMISSIVE_WALL_LAYER, relay_color = GLOB.em_block_color)

/atom/movable/screen/plane_master/wall_upper
	name = "Upper wall"
	// documentation = "There are some walls that want to render above most things (mostly minerals since they shift over.
	// 	<br>We draw them to their own plane so we can hijack them for our emissive mask stuff"
	plane = WALL_PLANE_UPPER
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, LIGHT_MASK_PLANE)

///Contains all lighting objects
/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lighting/Initialize(mapload)
	. = ..()
	filters += filter(type="alpha", render_source = EMISSIVE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type="alpha", render_source = EMISSIVE_UNBLOCKABLE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type="alpha", render_source = O_LIGHTING_VISUAL_RENDER_TARGET, flags = MASK_INVERSE)
	// Should be moved to the world render plate when render plates get ported in
	filters += filter(type="displace", render_source = SINGULARITY_RENDER_TARGET, size=75)

/**
  * Things placed on this mask the lighting plane. Doesn't render directly.
  *
  * Gets masked by blocking plane. Use for things that you want blocked by
  * mobs, items, etc.
  */
/atom/movable/screen/plane_master/emissive
	name = "emissive plane master"
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET

/atom/movable/screen/plane_master/emissive/Initialize(mapload)
	. = ..()
	filters += filter(type="alpha", render_source=EMISSIVE_BLOCKER_RENDER_TARGET, flags=MASK_INVERSE)
	// Should be moved to the world render plate when render plates get ported in
	filters += filter(type="displace", render_source = SINGULARITY_RENDER_TARGET, size=75)

/**
  * Things placed on this always mask the lighting plane. Doesn't render directly.
  *
  * Always masks the light plane, isn't blocked by anything. Use for on mob glows,
  * magic stuff, etc.
  */

/atom/movable/screen/plane_master/emissive_unblockable
	name = "unblockable emissive plane master"
	plane = EMISSIVE_UNBLOCKABLE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_UNBLOCKABLE_RENDER_TARGET

/**
  * Things placed on this layer mask the emissive layer. Doesn't render directly
  *
  * You really shouldn't be directly using this, use atom helpers instead
  */
/atom/movable/screen/plane_master/emissive_blocker
	name = "emissive blocker plane master"
	plane = EMISSIVE_BLOCKER_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_BLOCKER_RENDER_TARGET

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/parallax/Initialize(mapload)
	. = ..()
	// Should be moved to the world render plate when render plates get ported in
	filters += filter(type="displace", render_source = SINGULARITY_RENDER_TARGET, size=75)

/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_GAME, LIGHT_MASK_PLANE)
	critical = PLANE_CRITICAL_FUCKO_PARALLAX // goes funny when touched. no idea why I don't trust byond

/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)

/atom/movable/screen/plane_master/singularity_effect
	name = "singularity plane master"
	plane = SINGULARITY_EFFECT_PLANE
	render_target = SINGULARITY_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/runechat
	name = "runechat plane master"
	plane = RUNECHAT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/runechat/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		filters += AMBIENT_OCCLUSION

/atom/movable/screen/plane_master/o_light_visual
	name = "overlight light visual plane master"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY

/// Gets the relay atom we're using to connect to the target plane, if one exists
/atom/movable/screen/plane_master/proc/get_relay_to(target_plane)
	for(var/atom/movable/render_plane_relay/relay in relays)
		if(relay.plane == target_plane)
			return relay

/proc/get_plane_master_render_base(name)
	return "*[name]: AUTOGENERATED RENDER TGT"

/atom/movable/screen/plane_master/proc/generate_relay_to(target_plane, relay_loc, client/show_to, blend_override, relay_layer)
	if(!length(relays) && !initial(render_target))
		render_target = OFFSET_RENDER_TARGET(get_plane_master_render_base(name), offset)
	if(!relay_loc)
		relay_loc = "CENTER"
		// If we're using a submap (say for a popup window) make sure we draw onto it
		if(home?.map)
			relay_loc = "[home.map]:[relay_loc]"
	var/blend_to_use = blend_override
	if(isnull(blend_to_use))
		blend_to_use = blend_mode_override || initial(blend_mode)

	var/atom/movable/render_plane_relay/relay = new()
	relay.render_source = render_target
	relay.plane = target_plane
	relay.screen_loc = relay_loc
	// There are two rules here
	// 1: layer needs to be positive (negative layers are treated as float layers)
	// 2: lower planes (including offset ones) need to be layered below higher ones (because otherwise they'll render fucky)
	// By multiplying LOWEST_EVER_PLANE by 30, we give 30 offsets worth of room to planes before they start going negative
	// Bet
	// We allow for manuel override if requested. careful with this
	relay.layer = relay_layer || (plane + abs(LOWEST_EVER_PLANE * 30)) //layer must be positive but can be a decimal
	relay.blend_mode = blend_to_use
	relay.mouse_opacity = mouse_opacity
	relay.name = render_target
	relay.critical_target = PLANE_IS_CRITICAL(target_plane)
	relays += relay
	// Relays are sometimes generated early, before huds have a mob to display stuff to
	// That's what this is for
	if(show_to)
		show_to.screen += relay
	return relay

/// Creates a connection between this plane master and the passed in plane
/// Helper for out of system code, shouldn't be used in this file
/// Build system to differenchiate between generated and non generated render relays
/atom/movable/screen/plane_master/proc/add_relay_to(target_plane, blend_override, relay_layer, relay_color)
	if(get_relay_to(target_plane))
		return
	render_relay_planes += target_plane
	var/client/display_lad = home?.our_hud?.mymob?.canon_client
	var/atom/movable/render_plane_relay/relay = generate_relay_to(target_plane, show_to = display_lad, blend_override = blend_override, relay_layer = relay_layer)
	relay.color = relay_color

/**
 * Render relay object assigned to a plane master to be able to relay it's render onto other planes that are not it's own
 */
/atom/movable/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	/// If we render into a critical plane master, or not
	var/critical_target = FALSE

/// Hook to allow planes to work around is_outside_bounds
/// Return false to allow a show, true otherwise
/atom/movable/screen/plane_master/proc/check_outside_bounds()
	return is_outside_bounds

/atom/movable/screen/plane_master/fullscreen
	name = "Fullscreen"
	plane = FULLSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/parallax
	name = "Parallax"
	// documentation = "Contains parallax, or to be more exact the screen objects that hold parallax.
	// 	<br>Note the BLEND_MULTIPLY. The trick here is how low our plane value is. Because of that, we draw below almost everything in the game.
	// 	<br>We abuse this to ensure we multiply against the Parallax whitifier plane, or space's plane. It's set to full white, so when you do the multiply you just get parallax out where it well, makes sense to be.
	// 	<br>Also notice that the parent parallax plane is mirrored down to all children. We want to support viewing parallax across all z levels at once."
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/// Hides a plane master from the passeed in mob
/// Do your effect cleanup here
/atom/movable/screen/plane_master/proc/hide_from(mob/oldmob)
	SHOULD_CALL_PARENT(TRUE)
	var/client/their_client = oldmob?.client
	if(!their_client)
		return
	their_client.screen -= src
	their_client.screen -= relays

/// Shows a plane master to the passed in mob
/// Override this to apply unique effects and such
/// Returns TRUE if the call is allowed, FALSE otherwise
/atom/movable/screen/plane_master/proc/show_to(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	if(force_hidden)
		return FALSE
	var/client/our_client = mymob?.client
	// Alright, let's get this out of the way
	// Mobs can move z levels without their client. If this happens, we need to ensure critical display settings are respected
	// This is done here. Mild to severe pain but it's nessesary
	if(check_outside_bounds())
		if(!(critical & PLANE_CRITICAL_DISPLAY))
			return FALSE
		if(!our_client)
			return TRUE
		our_client.screen += src

		if(!(critical & PLANE_CRITICAL_NO_RELAY))
			our_client.screen += relays
			return TRUE
		
		return TRUE

	if(!our_client)
		return TRUE

	our_client.screen += src
	our_client.screen += relays
	return TRUE
	
/atom/movable/screen/plane_master/proc/outside_bounds(mob/relevant)
	if(force_hidden || is_outside_bounds)
		return
	is_outside_bounds = TRUE
	// If we're of critical importance, AND we're below the rendering layer
	if(critical & PLANE_CRITICAL_DISPLAY)
		// We here assume that your render target starts with *
		if(critical & PLANE_CRITICAL_CUT_RENDER && render_target)
			render_target = copytext_char(render_target, 2)
		if(!(critical & PLANE_CRITICAL_NO_RELAY))
			return
		var/client/our_client = relevant.client
		if(our_client)
			for(var/atom/movable/render_plane_relay/relay as anything in relays)
				our_client.screen -= relay

		return
	hide_from(relevant)

/// Datum that represents one "group" of plane masters
/// So all the main window planes would be in one, all the spyglass planes in another
/// Etc
/datum/plane_master_group
	/// Our key in the group list on /datum/hud
	/// Should be unique for any group of plane masters in the world
	var/key
	/// Our parent hud
	var/datum/hud/our_hud
	/// List in the form "[plane]" = object, the plane masters we own
	var/list/atom/movable/screen/plane_master/plane_masters = list()
	/// The visual offset we are currently using
	var/active_offset = 0
	/// What, if any, submap we render onto
	var/map = ""

/// Nice wrapper for the "[]"ing
/datum/plane_master_group/proc/get_plane(plane)
	return plane_masters["[plane]"]

///Contains all lighting objects
/atom/movable/screen/plane_master/rendering_plate/lighting
	name = "Lighting plate"
	// documentation = "Anything on this plane will be <b>multiplied</b> with the plane it's rendered onto (typically the game plane).
	// 	<br>That's how lighting functions at base. Because it uses BLEND_MULTIPLY and occasionally color matrixes, it needs a backdrop of blackness.
	// 	<br>See <a href=\"https://secure.byond.com/forum/?post=2141928\">This byond post</a>
	// 	<br>Lemme see uh, we're masked by the emissive plane so it can actually function (IE: make things glow in the dark).
	// 	<br>We're also masked by the overlay lighting plane, which contains all the movable lights in the game. It draws to us and also the game plane.
	// 	<br>Masks us out so it has the breathing room to apply its effect.
	// 	<br>Oh and we quite often have our alpha changed to achive night vision effects, or things of that sort."
	plane = RENDER_PLANE_LIGHTING
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY
	/// A list of light cutoffs we're actively using, (mass, r, g, b) to avoid filter churn
	var/list/light_cutoffs

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/set_light_cutoff(light_cutoff, list/color_cutoffs)
	var/list/new_cutoffs = list(light_cutoff)
	new_cutoffs += color_cutoffs
	if(new_cutoffs ~= light_cutoffs)
		return

	remove_filter(list("light_cutdown", "light_cutup"))

	var/ratio = light_cutoff/100
	if(!color_cutoffs)
		color_cutoffs = list(0, 0, 0)

	var/red = color_cutoffs[1] / 100
	var/green = color_cutoffs[2] / 100
	var/blue = color_cutoffs[3] / 100
	add_filter("light_cutdown", 3, color_matrix_filter(list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, -(ratio + red),-(ratio+green),-(ratio+blue),0)))
	add_filter("light_cutup", 4, color_matrix_filter(list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, ratio+red,ratio+green,ratio+blue,0)))

/*!
 * This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.
 *
 * Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.
 * Emissive blockers are pasted with an atom color that converts them to be entirely some different color.
 * Emissive overlays and emissive blockers are put onto the same plane.
 * The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.
 * A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.
 * This is then used to alpha mask the lighting plane.
 * 
 */
/atom/movable/screen/plane_master/rendering_plate/lighting/Initialize(mapload)
	. = ..()
	add_filter("emissives", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(EMISSIVE_RENDER_TARGET, offset), flags = MASK_INVERSE))
	add_filter("object_lighting", 2, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(O_LIGHTING_VISUAL_RENDER_TARGET, offset), flags = MASK_INVERSE))
	set_light_cutoff(10)

/// Breaks a connection between this plane master, and the passed in place
/atom/movable/screen/plane_master/proc/remove_relay_from(target_plane)
	render_relay_planes -= target_plane
	var/atom/movable/render_plane_relay/existing_relay = get_relay_to(target_plane)
	if(!existing_relay)
		return
	relays -= existing_relay
	if(!length(relays) && !initial(render_target))
		render_target = null
	var/client/lad = home?.our_hud?.mymob?.canon_client
	if(lad)
		lad.screen -= existing_relay

/atom/movable/screen/plane_master/rendering_plate/master/proc/offset_change(new_offset)
	if(new_offset == offset) // If we're on our own z layer, relay to nothing, just draw
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))
	else // Otherwise, regenerate the relay
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))

/atom/movable/screen/plane_master/rendering_plate/master/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(new_offset)

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(new_offset)

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/offset_change(mob_offset)
	// Offsets stack down remember. This implies that we're above the mob's view plane, and shouldn't render
	if(offset < mob_offset)
		disable_alpha()
	else
		enable_alpha()

/atom/movable/screen/plane_master/rendering_plate/lighting/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	// This applies a backdrop to our lighting plane
	// Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
	// Basically, we need something to brighten
	// unlit is perhaps less needed rn, it exists to provide a fullbright for things that can't see the lighting plane
	// but we don't actually use invisibility to hide the lighting plane anymore, so it's pointless
	var/atom/movable/screen/backdrop = mymob.overlay_fullscreen("lighting_backdrop_lit_[home.key]#[offset]", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	// Need to make sure they're on our plane, ALL the time. We always need a backdrop
	SET_PLANE_EXPLICIT(backdrop, PLANE_TO_TRUE(backdrop.plane), src)
	backdrop = mymob.overlay_fullscreen("lighting_backdrop_unlit_[home.key]#[offset]", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)
	SET_PLANE_EXPLICIT(backdrop, PLANE_TO_TRUE(backdrop.plane), src)
	// Sorry, this is a bit annoying
	// Basically, we only want the lighting plane we can actually see to attempt to render
	// If we don't our lower plane gets totally overriden by the black void of the upper plane
	var/datum/hud/hud = home.our_hud
	// show_to can be called twice successfully with no hide_from call. Ensure no runtimes off the registers from this
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change), override = TRUE)
	offset_change(hud?.current_plane_offset || 0)
	set_light_cutoff(mymob.lighting_cutoff, mymob.lighting_color_cutoffs)

/atom/movable/screen/plane_master/rendering_plate/lighting/hide_from(mob/oldmob)
	. = ..()
	oldmob.clear_fullscreen("lighting_backdrop_lit_[home.key]#[offset]")
	oldmob.clear_fullscreen("lighting_backdrop_unlit_[home.key]#[offset]")
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change))

/atom/movable/screen/plane_master/rendering_plate/emissive_slate/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	add_filter("em_block_masking", 2, color_matrix_filter(GLOB.em_mask_matrix))
	if(offset != 0)
		add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset - 1), relay_layer = EMISSIVE_Z_BELOW_LAYER)

/atom/movable/screen/plane_master/rendering_plate/light_mask
	name = "Light Mask"
	// documentation = "Any part of this plane that is transparent will be black below it on the game rendering plate.
	// 	<br>This is done to ensure emissives and overlay lights don't light things up \"through\" the darkness that normally sits at the bottom of the lighting plane.
	// 	<br>We relay copies of the space, floor and wall planes to it, so we can use them as masks. Then we just boost any existing alpha to 100% and we're done.
	// 	<br>If we ever switch to a sight setup that shows say, mobs but not floors, we instead mask just overlay lighting and emissives.
		// <br>This avoids dumb seethrough without breaking stuff like thermals."
	plane = LIGHT_MASK_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	// Fullwhite where there's any color, no alpha otherwise
	color = list(255,255,255,255, 255,255,255,255, 255,255,255,255, 0,0,0,0, 0,0,0,0)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = LIGHT_MASK_RENDER_TARGET
	// We blend against the game plane, so she's gotta multiply!
	blend_mode = BLEND_MULTIPLY
	render_relay_planes = list(RENDER_PLANE_GAME)

/atom/movable/screen/plane_master/rendering_plate/light_mask/show_to(mob/mymob)
	. = ..()
	if(!.)
		return

	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(handle_sight))
	handle_sight(mymob, mymob.sight, NONE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/hide_from(mob/oldmob)
	. = ..()
	var/atom/movable/screen/plane_master/overlay_lights = home.get_plane(GET_NEW_PLANE(O_LIGHTING_VISUAL_PLANE, offset))
	overlay_lights.remove_filter("lighting_mask")
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	emissive.remove_filter("lighting_mask")
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, offset))
	UnregisterSignal(oldmob, COMSIG_MOB_SIGHT_CHANGE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/proc/handle_sight(datum/source, new_sight, old_sight)
	// If we can see something that shows "through" blackness, and we can't see turfs, disable our draw to the game plane
	// And instead mask JUST the overlay lighting plane, since that will look fuckin wrong
	var/atom/movable/screen/plane_master/overlay_lights = home.get_plane(GET_NEW_PLANE(O_LIGHTING_VISUAL_PLANE, offset))
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	if(new_sight & SEE_AVOID_TURF_BLACKNESS && !(new_sight & SEE_TURFS))
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, offset))
		overlay_lights.add_filter("lighting_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(LIGHT_MASK_RENDER_TARGET, offset)))
		emissive.add_filter("lighting_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(LIGHT_MASK_RENDER_TARGET, offset)))
	// If we CAN'T see through the black, then draw er down brother!
	else
		overlay_lights.remove_filter("lighting_mask")
		emissive.remove_filter("lighting_mask")
		// We max alpha here, so our darkness is actually.. dark
		// Can't do it before cause it fucks with the filter
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME, offset), relay_color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,1))
// It would be nice to setup parallaxing for stairs and things when doing this
// So they look nicer. if you can't it's all good, if you think you can sanely look at monster's work
// It's hard, and potentially expensive. be careful
/datum/plane_master_group/proc/transform_lower_turfs(datum/hud/source, new_offset, use_scale = TRUE)
	// Check if this feature is disabled for the client, in which case don't use scale.
	// var/mob/our_mob = our_hud?.mymob

	// No offset? piss off
	if(!SSmapping.max_plane_offset)
		return

	active_offset = new_offset

	// Each time we go "down" a visual z level, we'll reduce the scale by this amount
	// Chosen because mothblocks liked it, didn't cause motion sickness while also giving a sense of height
	var/scale_by = 0.965
	if(!use_scale)
		// This is a workaround for two things
		// First of all, if a mob can see objects but not turfs, they will not be shown the holder objects we use for
		// What I'd like to do is revert to images if this case throws, but image vis_contents is broken
		// https://www.byond.com/forum/post/2821969
		// If that's ever fixed, please just use that. thanks :)
		scale_by = 1

	var/list/offsets = list()
	// var/multiz_boundary = our_mob?.client?.prefs?.read_preference(/datum/preference/numeric/multiz_performance)

	// We accept negatives so going down "zooms" away the drop above as it goes
	for(var/offset in -SSmapping.max_plane_offset to SSmapping.max_plane_offset)
		// Multiz boundaries disable transforms
		// if(multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && (multiz_boundary < abs(offset)))
		// 	offsets += null
		// 	continue

		// No transformations if we're landing ON you
		if(offset == 0)
			offsets += null
			continue

		var/scale = scale_by ** (offset)
		var/matrix/multiz_shrink = matrix()
		multiz_shrink.Scale(scale)
		offsets += multiz_shrink

	// So we can talk in 1 -> max_offset * 2 + 1, rather then -max_offset -> max_offset
	var/offset_offset = SSmapping.max_plane_offset + 1

	for(var/plane_key in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[plane_key]
		if(!plane.allows_offsetting)
			continue

		var/visual_offset = plane.offset - new_offset

		// Basically uh, if we're showing something down X amount of levels, or up any amount of levels
		// if(multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && (visual_offset > multiz_boundary || visual_offset < 0))
		// 	plane.outside_bounds(our_mob)
		// else if(plane.is_outside_bounds)
		// 	plane.inside_bounds(our_mob)

		// if(!plane.multiz_scaled)
		// 	continue

		if(plane.force_hidden || plane.is_outside_bounds || visual_offset < 0)
			// We don't animate here because it should be invisble, but we do mark because it'll look nice
			plane.transform = offsets[visual_offset + offset_offset]
			continue

		animate(plane, transform = offsets[visual_offset + offset_offset], 0.05 SECONDS, easing = LINEAR_EASING)
