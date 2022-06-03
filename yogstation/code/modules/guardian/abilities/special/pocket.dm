GLOBAL_VAR_INIT(pocket_dim, 1)
GLOBAL_LIST_EMPTY(pocket_corners)
GLOBAL_LIST_EMPTY(pocket_mirrors)

/proc/get_final_z(atom/A)
	var/turf/T = get_turf(A)
	if (T)
		return T.z
	return A.z

/area/yogstation/pocket_dimension
	name = "Pocket Dimension"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	unique = FALSE
	requires_power = FALSE
	show_on_sensors = FALSE
	ambientsounds = SPACE
	parallax_movedir = EAST

/obj/effect/landmark/pocket_dimension_corner
	name = "pocket dimension corner (bottom left)"

/obj/effect/landmark/pocket_dimension_corner/Initialize()
	. = ..()
	var/datum/space_level/level = SSmapping.get_level(z)
	if (!level)
		debug_admins("uh oh, stinky!!")
		return INITIALIZE_HINT_QDEL
	GLOB.pocket_corners[level.name] = list(
		"bl-corner" = get_turf(src), // Bottom left corner
		"center" = locate(x + 4, y + 4, z),
		"tr-corner" = locate(x + 8, y + 8, z), // Top right corner
	)
	return INITIALIZE_HINT_QDEL

/obj/effect/interdimsional_wall
	name = "interdimensional wall"
	desc = "YOU SHALL NOT PASS"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	opacity = FALSE
	anchored = TRUE
	density = TRUE

/datum/guardian_ability/major/special/pocket
	name = "Dimensional Manifestation"
	desc = "The guardian has access to a pocket dimension, which it can manifest in realspace at will."
	cost = 5
	var/list/pocket_dim
	var/manifested_at_x
	var/manifested_at_y
	var/manifested_at_z
	var/mob/camera/aiEye/remote/pocket/eye
	var/manifesting = FALSE
	var/list/manifestations = list()
	var/obj/effect/proc_holder/spell/self/pocket_dim/manifest_spell
	var/obj/effect/proc_holder/spell/self/pocket_dim_move/move_spell

/datum/guardian_ability/major/special/pocket/Apply()
	manifest_spell = new
	manifest_spell.guardian = guardian
	move_spell = new
	move_spell.guardian = guardian
	guardian.AddSpell(manifest_spell)
	guardian.AddSpell(move_spell)
	RegisterSignal(guardian, COMSIG_MOVABLE_MOVED, .proc/auto_demanifest)
	if (!LAZYLEN(pocket_dim))
		var/list/errorList = list()
		var/pocket_dim_level = SSmapping.LoadGroup(errorList, "Pocket Dimension [GLOB.pocket_dim]", "templates", "pocket_dimension.dmm", default_traits = list("Pocket Dimension" = TRUE, "Pocket Dimension [GLOB.pocket_dim]" = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0), silent = TRUE)
		if (errorList.len)
			message_admins("A pocket dimension failed to load!")
			log_game("A pocket dimension failed to load!")
			return FALSE
		for (var/datum/parsed_map/PM in pocket_dim_level)
			PM.initTemplateBounds()
		pocket_dim = "Pocket Dimension [GLOB.pocket_dim++]"
		GLOB.pocket_mirrors[pocket_dim] = list()
		var/pz = get_pocket_z()
		for (var/turf/open/indestructible/pocketspace/pocketspace in world)
			if (pocketspace.z == pz)
				GLOB.pocket_mirrors[pocket_dim] += pocketspace
		eye = new
		eye.guardian = guardian
		eye.guardian_ability = src
		eye.name = "Inactive Guardian Eye ([guardian])"
		eye.forceMove(get_turf(guardian))

/datum/guardian_ability/major/special/pocket/Remove()
	guardian.RemoveSpell(manifest_spell)
	guardian.RemoveSpell(move_spell)
	UnregisterSignal(guardian, COMSIG_MOVABLE_MOVED)
	if (LAZYLEN(manifestations))
		demanifest_dimension()

/datum/guardian_ability/major/special/pocket/proc/get_pocket_z()
	if (!pocket_dim)
		return
	var/list/zs = SSmapping.levels_by_trait(pocket_dim)
	if (!LAZYLEN(zs))
		return null
	return zs[1]

/datum/guardian_ability/major/special/pocket/proc/auto_demanifest()
	if (!pocket_dim || manifesting || !LAZYLEN(manifestations) || !(manifested_at_x && manifested_at_y && manifested_at_z))
		return
	var/turf/center = locate(manifested_at_x, manifested_at_y, manifested_at_z)
	if (!center)
		return
	var/turf/guardian_loc = get_turf(guardian)
	if (guardian_loc.z != center.z)
		to_chat(guardian, span_warning("Your pocket dimension demanifests, as you can't keep it manifested from so far away!"))
		demanifest_dimension()
		return
	var/list/screen_size = getviewsize(world.view)
	var/max_dist = max(screen_size[1], screen_size[2]) + 1
	var/dist_from_manifestation = get_dist_euclidian(center, guardian_loc) - 4
	if (dist_from_manifestation > max_dist)
		to_chat(guardian, span_warning("Your pocket dimension demanifests, as you can't keep it manifested from so far away!"))
		demanifest_dimension()

/datum/guardian_ability/major/special/pocket/proc/get_targets(require_neck_grab = FALSE)
	. = list()
	if (guardian.summoner?.current)	
		var/mob/living/summoner = guardian.summoner.current
		. += summoner
		var/bring_pull_in = FALSE
		if (summoner.pulling && !summoner.pulling.anchored)
			if (isobj(summoner.pulling))
				bring_pull_in = TRUE
			else if (isliving(summoner.pulling))
				var/mob/living/pulling = summoner.pulling
				bring_pull_in = !require_neck_grab || pulling.stat >= UNCONSCIOUS || summoner.grab_state >= GRAB_NECK
		if(bring_pull_in)
			. += summoner.pulling
		for (var/G in guardian.summoner.hasparasites())
			var/mob/living/simple_animal/hostile/guardian/guardian = G
			if (guardian.is_deployed())
				. += guardian
	else if (guardian.is_deployed())
		. |= guardian

/datum/guardian_ability/major/special/pocket/proc/manifest_dimension(pos_already_set = FALSE)
	destroy_pocket_mirror(pocket_dim)
	manifesting = TRUE
	if (LAZYLEN(GLOB.pocket_mirrors[pocket_dim]))
		for (var/turf/open/indestructible/pocketspace/PS in GLOB.pocket_mirrors[pocket_dim])
			PS.vis_contents.Cut()
	var/corrected_max = manifested_at_x
	var/corrected_may = manifested_at_y
	if (!pos_already_set) // don't subtract 4 if the pos is set, because we will have already subtracted by 4.
		manifested_at_x = clamp(guardian.x - 4, 1, world.maxx)
		corrected_max = manifested_at_x
		manifested_at_y = clamp(guardian.y - 4, 1, world.maxy)
		corrected_may = manifested_at_y
		manifested_at_z = get_final_z(guardian)

	var/list/us = block(locate(corrected_max, corrected_may, manifested_at_z), locate(min(corrected_max + 8, world.maxx), min(corrected_may + 8, world.maxy), manifested_at_z))
	var/list/them = block(GLOB.pocket_corners[pocket_dim]["bl-corner"], GLOB.pocket_corners[pocket_dim]["tr-corner"])
	for (var/idx in 1 to min(LAZYLEN(us), LAZYLEN(them)))
		var/turf/manifestation_turf = us[idx]
		var/turf/dimension_turf = them[idx]
		if (manifestation_turf && dimension_turf)
			var/obj/effect/manifestation/manifestation = new(manifestation_turf)
			manifestation.vis_contents += dimension_turf
			manifestations += manifestation

			var/matrix/normally_scaled_matrix = new
			normally_scaled_matrix.Scale(1)
			var/matrix/downscaled_matrix = new
			downscaled_matrix.Scale(0.1)
			manifestation.transform = downscaled_matrix
			var/manifestation_relative_x = manifested_at_x - manifestation_turf.x + 4
			var/manifestation_relative_y = manifested_at_y - manifestation_turf.y + 4
			var/pixel_x_shift = manifestation_relative_x * world.icon_size
			var/pixel_y_shift = manifestation_relative_y * world.icon_size
			manifestation.pixel_x = pixel_x_shift
			manifestation.pixel_y = pixel_y_shift

			animate(manifestation, alpha = 127, transform = normally_scaled_matrix, pixel_x = 0, pixel_y = 0, time = 3 SECONDS, easing = LINEAR_EASING)

	addtimer(VARSET_CALLBACK(src, manifesting, FALSE), 3 SECONDS)

/datum/guardian_ability/major/special/pocket/proc/manifest_mobs_into_real_world()
	var/list/targets = get_targets()
	var/turf/corner = GLOB.pocket_corners[pocket_dim]["bl-corner"]
	var/mob/living/pull_target
	var/mob/living/summoner
	for (var/M in targets)
		var/mob/living/target = M
		var/target_x = manifested_at_x + (target.x - corner.x)
		var/target_y = manifested_at_y + (target.y - corner.y)
		var/turf/target_turf = locate(target_x, target_y, manifested_at_z)
		if (!target_turf)
			continue
		if (target == guardian.summoner?.current?.pulling)
			pull_target = target
		else if (target == guardian.summoner?.current)
			summoner = target
		take_effects(target)
		if (target.alpha == 255)
			target.alpha = 0
			animate(target, alpha = 255, time = 3 SECONDS, easing = LINEAR_EASING)
		target.forceMove(target_turf)
	if (pull_target)
		to_chat(pull_target, span_danger("All of existence fades out for a moment..."))
		summoner.start_pulling(pull_target)
		pull_target.Paralyze(5 SECONDS)

/datum/guardian_ability/major/special/pocket/proc/bring_mobs_into_pocket_dimension()
	var/turf/corner = GLOB.pocket_corners[pocket_dim]["bl-corner"]
	var/bl_safe_x = manifested_at_x + 1
	var/bl_safe_y = manifested_at_y + 1
	var/tr_safe_x = min(world.maxx, manifested_at_x + 7)
	var/tr_safe_y = min(world.maxy, manifested_at_y + 7)
	var/list/safe_locations = block(locate(bl_safe_x, bl_safe_y, manifested_at_z), locate(tr_safe_x, tr_safe_y, manifested_at_z))
	var/pocket_z = get_pocket_z()
	var/list/targets = get_targets(TRUE)
	var/mob/living/pull_target
	var/mob/living/summoner
	for (var/M in targets)
		var/mob/living/target = M
		if (!(target.loc in safe_locations))
			continue
		var/target_x = corner.x + (target.x - manifested_at_x)
		var/target_y = corner.y + (target.y - manifested_at_y)
		var/turf/target_turf = locate(target_x, target_y, pocket_z)
		if (!target_turf)
			continue
		if (target == guardian.summoner?.current?.pulling)
			pull_target = target
		else if (target == guardian.summoner?.current)
			summoner = target
		if (target != pull_target)
			add_effects(target)
		target.forceMove(target_turf)
	if (pull_target)
		to_chat(pull_target, span_danger("All of existence fades out for a moment..."))
		summoner.start_pulling(pull_target)
		pull_target.Paralyze(5 SECONDS)


/datum/guardian_ability/major/special/pocket/proc/demanifest_dimension()
	manifesting = TRUE
	for (var/obj/effect/manifestation/manifestation in manifestations)
		// FANCY ANIMATION TIME!
		// Create a new matrix, with a scale of 10%
		var/matrix/downscaled_matrix = new
		downscaled_matrix.Scale(0.1)
		// Calculate the relative x and y of this manifestation
		var/manifestation_relative_x = manifested_at_x - manifestation.x + 4
		var/manifestation_relative_y = manifested_at_y - manifestation.y + 4
		// Calculate the pixel_x and y shift needed to have this effect converge to the center
		var/pixel_x_shift = manifestation_relative_x * world.icon_size
		var/pixel_y_shift = manifestation_relative_y * world.icon_size
		// Animate all this!
		animate(manifestation, alpha = 0, transform = downscaled_matrix, pixel_x = pixel_x_shift, pixel_y = pixel_y_shift,  time = 3 SECONDS, easing = LINEAR_EASING)
		manifestations -= manifestation
		QDEL_IN(manifestation, 3 SECONDS)

	if (pocket_dim)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/update_pocket_mirror, pocket_dim, manifested_at_x, manifested_at_y, manifested_at_z), 3.5 SECONDS)

	addtimer(VARSET_CALLBACK(src, manifesting, FALSE), 3 SECONDS)

/datum/guardian_ability/major/special/pocket/proc/check_if_teleport(mob/living/L)
	var/list/pocket_z = get_pocket_z()
	if (!pocket_z)
		return
	if (get_final_z(L) != pocket_z)
		take_effects(L)

/datum/guardian_ability/major/special/pocket/proc/add_effects(mob/living/L)
	L.status_flags |= GODMODE
	ADD_TRAIT(L, TRAIT_NOHARDCRIT, GUARDIAN_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSOFTCRIT, GUARDIAN_TRAIT)
	ADD_TRAIT(L, TRAIT_NODEATH, GUARDIAN_TRAIT)
	if (!isguardian(L))
		RegisterSignal(L, COMSIG_MOVABLE_MOVED, .proc/check_if_teleport)
	for (var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.status_flags |= GODMODE

/datum/guardian_ability/major/special/pocket/proc/take_effects(mob/living/L)
	L.status_flags &= ~GODMODE
	REMOVE_TRAIT(L, TRAIT_NOHARDCRIT, GUARDIAN_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSOFTCRIT, GUARDIAN_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NODEATH, GUARDIAN_TRAIT)
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
	for (var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.status_flags &= ~GODMODE

/obj/effect/manifestation
	layer = ABOVE_LIGHTING_LAYER
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	alpha = 0
	mouse_opacity = FALSE
	var/next_animate = 0

/obj/effect/manifestation/Initialize()
	. = ..()
	var/X,Y,i,rsq
	for (i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while (rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)

/obj/effect/manifestation/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/manifestation/process()
	if (next_animate > world.time)
		return
	var/i,f
	for (i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+(1 SECONDS)
		animate(f, offset=f:offset, time=0 SECONDS, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

/obj/effect/proc_holder/spell/self/pocket_dim
	name = "Dimensional Intersection"
	desc = "(De)manifest a pocket dimension."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 45 SECONDS
	action_icon = 'icons/obj/objects.dmi'
	action_icon_state = "anom"
	var/mob/living/simple_animal/hostile/guardian/guardian

/obj/effect/proc_holder/spell/self/pocket_dim/Click()
	if (!guardian || !istype(guardian))
		return
	if (!guardian.is_deployed())
		to_chat(guardian, span_red(span_bold("You must be manifested to summon the pocket dimension!</span>")))
		return
	var/datum/guardian_ability/major/special/pocket/PD = guardian?.stats?.ability
	if (!PD || !istype(PD))
		return
	var/pocket_z = PD.get_pocket_z()
	if (!pocket_z)
		to_chat(guardian, span_red(span_bold("ERROR: You do not have a pocket dimension generated! Report this bug on Github!</span>")))
		return
	if (PD.manifesting)
		to_chat(guardian, span_red(span_bold("Wait! Your pocket dimension is currently (de)manifesting!</span>")))
		return
	if (guardian.remote_control == PD.eye)
		for (var/V in PD.eye.visibleCameraChunks)
			var/datum/camerachunk/C = V
			C.remove(PD.eye)
		if (guardian.client)
			guardian.reset_perspective(null)
			if (PD.eye.visible_icon)
				guardian.client.images -= PD.eye.user_image
		PD.eye.eye_user = null
		guardian.remote_control = null
	if (LAZYLEN(PD.manifestations))
		guardian.visible_message(span_warning("The distorted space surronding [guardian] is sucked in!"))
		PD.eye.forceMove(get_turf(guardian))
		PD.bring_mobs_into_pocket_dimension()
		PD.demanifest_dimension()
		charge_counter = 0
		start_recharge()
		action.UpdateButtonIcon()
	else
		if (get_final_z(guardian) == pocket_z)
			PD.manifest_dimension(TRUE)
			PD.manifest_mobs_into_real_world()
			PD.eye.forceMove(get_turf(guardian))
		else
			guardian.visible_message(span_warning("[guardian] emits a burst of energy, distorting the space around it!"))
			PD.manifest_dimension()
			PD.eye.forceMove(get_turf(guardian))
		charge_counter = max(0, charge_max - 3 SECONDS)
		start_recharge()
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/self/pocket_dim_move
	name = "Dimensional Movement"
	action_icon = 'icons/mob/actions/actions_silicon.dmi'
	action_icon_state = "camera_jump"
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 0
	var/mob/living/simple_animal/hostile/guardian/guardian


/obj/effect/proc_holder/spell/self/pocket_dim_move/cast(list/targets, mob/living/user)
	if (!guardian || !istype(guardian))
		return
	var/datum/guardian_ability/major/special/pocket/PD = guardian?.stats?.ability
	if (!PD || !istype(PD))
		return
	var/pocket_z = PD.get_pocket_z()
	if (!pocket_z)
		to_chat(guardian, span_red(span_bold("ERROR: You do not have a pocket dimension generated! Report this bug on Github!")))
		return
	if (!PD.eye)
		to_chat(guardian, span_red(span_bold("ERROR: You do not have a camera eye generated! Report this bug on Github!</span>")))
		return
	var/turf/T = get_turf(guardian)
	if (T.z != pocket_z)
		to_chat(guardian, span_notice(span_bold("You must be inside a demanifested pocket dimension to move it!")))
		return
	if (PD.manifesting)
		to_chat(guardian, span_red(span_bold("Wait! Your pocket dimension is currently (de)manifesting!</span>")))
		return
	var/mob/camera/aiEye/remote/pocket/eyeobj = PD.eye
	if (eyeobj.eye_user)
		for (var/V in eyeobj.visibleCameraChunks)
			var/datum/camerachunk/C = V
			C.remove(eyeobj)
		if (guardian.client)
			guardian.reset_perspective(null)
			if (eyeobj.visible_icon)
				guardian.client.images -= eyeobj.user_image
		eyeobj.eye_user = null
		guardian.remote_control = null
	else
		give_eye(eyeobj)
		eyeobj.setLoc(locate(PD.manifested_at_x || T.x, PD.manifested_at_y || T.y, PD.manifested_at_z || T.z))

/obj/effect/proc_holder/spell/self/pocket_dim_move/proc/give_eye(mob/camera/aiEye/remote/pocket/eyeobj)
	eyeobj.eye_user = guardian
	eyeobj.name = "Guardian Eye ([guardian.name])"
	guardian.remote_control = eyeobj

/turf/open/indestructible/pocketspace
	name = "interdimensional distortion"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	planetary_atmos = TRUE
	flags_1 = NOJAUNT_1
	var/next_animate = 0

/turf/open/indestructible/pocketspace/Initialize()
	. = ..()
	var/X,Y,i,rsq
	for (i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)

/turf/open/indestructible/pocketspace/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/indestructible/pocketspace/process()
	if (next_animate > world.time)
		return
	var/i,f
	for (i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+(1 SECONDS)
		animate(f, offset=f:offset, time=0 SECONDS, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

/mob/camera/aiEye/remote/pocket
	name = "Inactive Guardian Eye"
	move_on_shuttle = TRUE
	use_static = FALSE
	var/mob/living/simple_animal/hostile/guardian/guardian
	var/datum/guardian_ability/major/special/pocket/guardian_ability

/mob/camera/aiEye/remote/pocket/setLoc()
	. = ..()
	var/turf/T = get_turf(src)
	if (T)
		guardian_ability.manifested_at_x = clamp(T.x, 1, world.maxx)
		guardian_ability.manifested_at_y = clamp(T.y, 1, world.maxy)
		guardian_ability.manifested_at_z = T.z
		if (guardian_ability.manifesting || LAZYLEN(guardian_ability.manifestations))
			destroy_pocket_mirror(guardian_ability.pocket_dim)
		else
			update_pocket_mirror(guardian_ability.pocket_dim, T.x, T.y, T.z)

/proc/update_pocket_mirror(pocket_dim, sx, sy, sz)
	var/turf/bl_corner = GLOB.pocket_corners[pocket_dim]["bl-corner"]
	var/turf/tr_corner = GLOB.pocket_corners[pocket_dim]["tr-corner"]
	for (var/T in block(bl_corner, tr_corner))
		var/turf/open/indestructible/pocketspace/pocket_space = T
		if (pocket_space && istype(pocket_space))
			pocket_space.vis_contents.Cut()
			pocket_space.vis_contents += locate(sx + (pocket_space.x - bl_corner.x), sy + (pocket_space.y - bl_corner.y), sz)

/proc/destroy_pocket_mirror(pocket_dim)
	var/turf/bl_corner = GLOB.pocket_corners[pocket_dim]["bl-corner"]
	var/turf/tr_corner = GLOB.pocket_corners[pocket_dim]["tr-corner"]
	for (var/T in block(bl_corner, tr_corner))
		var/turf/open/indestructible/pocketspace/PS = T
		if (PS && istype(PS))
			PS.vis_contents.Cut()
