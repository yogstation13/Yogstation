/datum/psi_complexus
	/// Whether or not we have been announced to our holder yet.
	var/announced = FALSE
	/// Whether or not we are suppressing our psi powers.
	var/suppressed = TRUE
	/// Whether or not we should automatically deflect/block incoming damage.
	var/use_psi_armour = TRUE
	/// Whether or not we should automatically heal damage damage.
	var/use_autoredaction = TRUE
	/// Whether or not zorch uses lethal projectiles.
	var/zorch_harm = FALSE
	/// What amount of heat the user wants to stop at.
	var/limiter = 100
	/// Whether or not we need to rebuild our cache of psi powers.
	var/rebuild_power_cache = TRUE

	/// Overall psi rating.
	var/rating = 0
	/// Multiplier for power use stamina costs.
	var/cost_modifier = 1
	/// Number of process ticks we are stunned for.             
	var/stun = 0
	/// world.time minimum before next power use.
	var/next_power_use = 0

	// Stamina / Heat
	/// Current psi pool.
	var/stamina = 50
	/// Max psi pool.
	var/max_stamina = 50
	/// Multiplier for the recharge rate of psi heat.
	var/stamina_recharge_mult = 1
	/// Current psi heat.
	var/heat = 0
	/// Max psi heat. 100 is safe, 300 has minor consequences, 500 is dangerous, max is death.
	var/max_heat = 500
	/// Multiplier for the decay rate of psi heat.
	var/heat_decay_mult = 1

	/// List of all currently latent faculties.
	var/list/latencies
	/// Assoc list of psi faculties to current rank.
	var/list/ranks
	/// Assoc list of psi faculties to base rank, in case reset is needed
	var/list/base_ranks
	/// List of atoms manifested/maintained by psychic power.
	var/list/manifested_items
	/// world.time minimum before a trigger can be attempted again.
	var/next_latency_trigger = 0
	var/last_aura_size
	var/last_aura_alpha
	var/last_aura_color
	var/aura_color = "#ff0022"

	// Cached powers.
	var/list/learned_powers            // All powers known
	var/list/powers_by_faculty
	var/datum/psionic_power/selected_power  // Power currently selected

	var/obj/screen/psi/hub/ui	      // Reference to the master psi UI object.
	var/mob/living/owner              // Reference to our owner.
	var/datum/mind/thinker
	var/image/_aura_image             // Client image
	var/obj/effect/overlay/aura/image_holder //holder so we don't have to apply the image directly to the mob, making it's clickbox massive

/datum/psi_complexus/New(mob/M)
	owner = M
	image_holder = new(src)
	owner.vis_contents += image_holder
	START_PROCESSING(SSpsi, src)
	RegisterSignal(owner, COMSIG_PSI_SELECTION, PROC_REF(select_power))
	RegisterSignal(owner, COMSIG_PSI_INVOKE, PROC_REF(invoke_power))
	if(HAS_TRAIT(M, TRAIT_PSIONICALLY_TUNED))
		max_stamina = initial(max_stamina) + 25
		stamina = max_stamina
	thinker = owner.mind
	if(thinker && istype(thinker))
		RegisterSignal(thinker, COMSIG_MIND_TRANSFERRED, PROC_REF(mind_swap))

/datum/psi_complexus/proc/mind_swap(datum/mind/brain, mob/living/oldbody)
	if(!brain || !istype(brain) || !brain.current)
		return
	UnregisterSignal(owner, COMSIG_PSI_SELECTION)
	UnregisterSignal(owner, COMSIG_PSI_INVOKE)
	owner.vis_contents -= image_holder
	owner.psi = null
	owner = brain.current
	owner.vis_contents += image_holder
	RegisterSignal(owner, COMSIG_PSI_SELECTION, PROC_REF(select_power))
	RegisterSignal(owner, COMSIG_PSI_INVOKE, PROC_REF(invoke_power))
	owner.psi = src
	update(TRUE, TRUE)

/datum/psi_complexus/Destroy()
	destroy_aura_image(_aura_image)
	STOP_PROCESSING(SSpsi, src)
	if(thinker && istype(thinker))
		UnregisterSignal(thinker, COMSIG_MIND_TRANSFERRED)
	if(owner)
		UnregisterSignal(owner, COMSIG_PSI_SELECTION)
		UnregisterSignal(owner, COMSIG_PSI_INVOKE)
		cancel()
		if(owner.client)
			owner.client.screen -= ui.components
			owner.client.screen -= ui
			for(var/thing in SSpsi.all_aura_images)
				owner.client.images -= thing
		QDEL_NULL(ui)
		owner.psi = null
		owner = null
	QDEL_NULL(image_holder)

	if(manifested_items)
		for(var/thing in manifested_items)
			qdel(thing)
		manifested_items.Cut()
	. = ..()

/datum/psi_complexus/proc/select_power(mob/user)
	if(suppressed)
		return
	rebuild_power_cache()
	if(!LAZYLEN(learned_powers))
		return
	var/list/choice_list = LAZYCOPY(learned_powers)
	for(var/datum/psionic_power/I as anything in choice_list)
		choice_list[I] = image(I.icon, null, I.icon_state)
	var/selection = show_radial_menu(user, user, choice_list, null, 40, tooltips = TRUE, autopick_single_option = FALSE)
	selected_power = selection
	if(selection) //wipe the selected power unless something was actually chosen
		selected_power.on_select(user)
		user.balloon_alert(user, "Selected [selected_power.name]")

/datum/psi_complexus/proc/invoke_power(mob/user, atom/target, proximity, parameters)
	if(suppressed)
		return
	if(!selected_power)
		return
	. = selected_power.invoke(user, target, proximity, parameters)
	if(.)
		selected_power.handle_post_power(user, target)

/datum/psi_complexus/proc/get_aura_image()
	if(_aura_image && !istype(_aura_image))
		var/atom/A = _aura_image
		destroy_aura_image(_aura_image)
		_aura_image = null
		CRASH("Non-image found in psi complexus: \ref[A] - \the [A] - [istype(A) ? A.type : "non-atom"]")
	if(!_aura_image)
		_aura_image = create_aura_image(image_holder)
	return _aura_image

/obj/effect/overlay/aura
	name = ""
	// icon = 'icons/effects/psi_aura_small.dmi'
	// icon_state = "aura"
	// pixel_x = -64
	// pixel_y = -64
	plane = GAME_PLANE
	appearance_flags = NO_CLIENT_COLOR | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	layer = TURF_LAYER + 0.5
	alpha = 0

/proc/create_aura_image(newloc)
	var/image/aura_image = image('icons/effects/psi_aura_small.dmi', newloc, "aura")
	aura_image.blend_mode = BLEND_MULTIPLY
	aura_image.appearance_flags = NO_CLIENT_COLOR | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	aura_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	aura_image.layer = TURF_LAYER + 0.5
	aura_image.alpha = 0
	aura_image.pixel_x = -64
	aura_image.pixel_y = -64
	for(var/datum/psi_complexus/psychic in SSpsi.processing)
		if(!psychic.suppressed)
			psychic?.owner?.client?.images += aura_image
	SSpsi.all_aura_images[aura_image] = TRUE
	return aura_image

/proc/destroy_aura_image(image/aura_image)
	for(var/datum/psi_complexus/psychic in SSpsi.processing)
		psychic?.owner?.client?.images -= aura_image
	SSpsi.all_aura_images -= aura_image
