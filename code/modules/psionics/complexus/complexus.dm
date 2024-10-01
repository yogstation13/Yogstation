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

	
	///weakref to button to access the complexus interface
	var/datum/weakref/info_button_ref

/datum/psi_complexus/New(mob/M)
	owner = M
	image_holder = new(src)
	owner.vis_contents += image_holder
	START_PROCESSING(SSpsi, src)
	RegisterSignal(owner, COMSIG_PSI_INVOKE, PROC_REF(invoke_power))
	thinker = owner.mind
	if(thinker && istype(thinker))
		RegisterSignal(thinker, COMSIG_MIND_TRANSFERRED, PROC_REF(mind_swap))

	var/datum/action/complexus_info/info_button = new(src)
	info_button_ref = WEAKREF(info_button)

/datum/psi_complexus/proc/mind_swap(datum/mind/brain, mob/living/oldbody)
	if(!brain || !istype(brain) || !brain.current)
		return
	UnregisterSignal(owner, COMSIG_PSI_INVOKE)
	owner.vis_contents -= image_holder
	owner.psi = null
	owner = brain.current
	owner.vis_contents += image_holder
	RegisterSignal(owner, COMSIG_PSI_INVOKE, PROC_REF(invoke_power))
	owner.psi = src
	update(TRUE, TRUE)

/datum/psi_complexus/Destroy()
	destroy_aura_image(_aura_image)
	STOP_PROCESSING(SSpsi, src)
	if(thinker && istype(thinker))
		UnregisterSignal(thinker, COMSIG_MIND_TRANSFERRED)
	if(owner)
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

	if(image_holder)
		QDEL_NULL(image_holder)

	if(info_button_ref)
		QDEL_NULL(info_button_ref)

	if(manifested_items)
		for(var/thing in manifested_items)
			qdel(thing)
		manifested_items.Cut()
	. = ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Ability selection stuff-----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_complexus/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PsionicComplexus", "Psi Complexus")
		ui.open()

/datum/psi_complexus/ui_data(mob/user)
	var/list/data = list()
	var/use_rating
	var/effective_rating = rating
	if(effective_rating > 1 && suppressed)
		effective_rating = max(0, rating-2)
	var/rating_descriptor
	if(!use_rating)
		switch(effective_rating)
			if(1)
				use_rating = "[effective_rating]-Epsilon"
				rating_descriptor = "This indicates the presence of minor latent psi potential with little or no operant capabilities."
			if(2)
				use_rating = "[effective_rating]-Delta"
				rating_descriptor = "This indicates the presence of minor psi capabilities of the Operant rank or higher."
			if(3)
				use_rating = "[effective_rating]-Gamma"
				rating_descriptor = "This indicates the presence of psi capabilities of the Master rank or higher."
			if(4)
				use_rating = "[effective_rating]-Beta"
				rating_descriptor = "This indicates the presence of significant psi capabilities of the Grandmaster rank or higher."
			if(5)
				use_rating = "[effective_rating]-Alpha"
				rating_descriptor = "This indicates the presence of major psi capabilities of the Paramount rank or higher."
			else
				use_rating = "[effective_rating]-Lambda"
				rating_descriptor = "This indicates the presence of trace latent psi capabilities."

	if(selected_power && istype(selected_power))
		data["selected_power"] = initial(selected_power.name)
	data["use_rating"] = use_rating
	data["rating_descriptor"] = rating_descriptor
	data["faculties"] = list()
	for(var/faculty_id in ranks)
		var/list/check_powers = get_powers_by_faculty(faculty_id)
		if(LAZYLEN(check_powers))
			var/list/details = list()
			var/datum/psionic_faculty/faculty = SSpsi.get_faculty(faculty_id)
			details["name"] += faculty.name
			details["rank"] += ranks[faculty_id]
			for(var/datum/psionic_power/power in check_powers)
				var/list/power_data = list()
				power_data["name"] = power.name
				power_data["description"] = power.use_description
				power_data["path"] = power.type
				details["powers"] += list(power_data)
			data["faculties"] += list(details)
	return data

/datum/psi_complexus/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select")
			var/ability = text2path(params["ability"])
			var/datum/psionic_power/finder = locate(ability) in learned_powers
			if(!finder || !istype(finder))
				return
			selected_power = finder
			owner.balloon_alert(owner, "Selected [selected_power.name]")
		if("deselect")
			selected_power = null
			owner.balloon_alert(owner, "Deselected power")
	update_button_icon()

/datum/psi_complexus/ui_state()
	return GLOB.always_state

/datum/psi_complexus/ui_assets(mob/user)
    return list(
        get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
    )

/datum/asset/spritesheet/psi_icons
    name = "psi_icons"

/datum/asset/spritesheet/psi_icons/create_spritesheets()
    InsertAll("", 'icons/obj/psychic_powers.dmi')
	
/**
 * Update the button icon
 */
/datum/psi_complexus/proc/update_button_icon()
	var/datum/action/complexus_info/info_button = info_button_ref?.resolve()
	if(info_button)
		if(selected_power)
			info_button.desc = "Selected power: [selected_power.name]"
			info_button.button_icon = selected_power.icon
			info_button.button_icon_state = selected_power.icon_state
		else
			info_button.desc = initial(info_button.desc)
			info_button.button_icon = initial(info_button.button_icon)
			info_button.button_icon_state = initial(info_button.button_icon_state)
		info_button.build_all_button_icons()

/**
 * The ability in question
 */
/datum/action/complexus_info
	name = "Open psi complexus"
	desc = "No currently selected power."
	button_icon = 'icons/obj/telescience.dmi'
	button_icon_state = "psionic_null_skull"
	show_to_observers = FALSE

/datum/action/complexus_info/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		var/datum/psi_complexus/host = target
		if(istype(host))
			if(!host.selected_power)
				return
			host.selected_power = null
			owner.balloon_alert(owner, "Deselected power")
			host.update_button_icon()
			return
		
	target.ui_interact(owner)

/datum/action/complexus_info/IsAvailable(feedback = FALSE)
	if(!target)
		stack_trace("[type] was used without a target psi complexus datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind)
		return FALSE
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Invoke the power----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_complexus/proc/invoke_power(mob/user, atom/target, proximity, parameters)
	if(suppressed)
		return
	if(!selected_power)
		return
	. = selected_power.invoke(user, target, proximity, parameters)
	if(.)
		selected_power.handle_post_power(user, target)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Aura image stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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
