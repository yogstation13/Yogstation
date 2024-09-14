#define BASE_MAX_ACTIVATORS 2
#define BASE_MAX_EFFECTS 2
#define STIMULI_CD_TIME 5 SECONDS

/datum/component/artifact
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//The object we are attached to
	var/obj/holder
	///size class for visuals (ARTIFACT_SIZE_TINY,ARTIFACT_SIZE_SMALL,ARTIFACT_SIZE_LARGE)
	var/artifact_size = ARTIFACT_SIZE_LARGE
	///type name for displaying on analysis forms
	var/type_name = "Generic Artifact Type"
	/// fake name for when unanalyzed
	var/fake_name
	///the randomly generated name using our origin
	var/generated_name
	///Is the artifact active?
	var/active = FALSE
	///activators that activate the artifact
	var/list/datum/artifact_activator/activators = list()
	var/max_activators = BASE_MAX_ACTIVATORS
	///Valid activators to pick,mostly legacy code.
	var/list/valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/touch/data,

		/datum/artifact_activator/range/force,
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation,
	)
	///this artifacts origin
	var/datum/artifact_origin/artifact_origin
	///Just any effect that is real and can be added to an artifact. Mostly legacy
	var/list/valid_origins = list(
		/datum/artifact_origin/narsie,
		/datum/artifact_origin/wizard,
		/datum/artifact_origin/silicon,
		/datum/artifact_origin/precursor,
		/datum/artifact_origin/martian
	)
	var/activation_message
	var/activation_sound
	var/deactivation_message
	var/deactivation_sound
	var/mutable_appearance/act_effect
	///Have we been xray scanned at least once?
	var/researched = FALSE

	///we store our analysis form var here
	var/obj/item/sticker/analysis_form/analysis

	var/mutable_appearance/extra_effect
	///the fault we picked from the listed ones. Can be null!
	var/datum/artifact_fault/chosen_fault
	///the amount of times an artifact WONT do something bad, even though it should have
	var/freebies = 3
	///if we have a special examine IE borgers
	var/explict_examine
	///Fault = weight
	var/static/list/datum/artifact_fault/fault_weight_list

	///The activators we have discovered.
	var/list/datum/artifact_activator/discovered_activators = list()
	///Have we discovered what the bad is?
	var/fault_discovered = FALSE
	///A list of effects the artifact has
	var/list/datum/artifact_effect/artifact_effects = list()
	///A list of effects that have been discovered
	var/list/datum/artifact_effect/discovered_effects = list()

	COOLDOWN_DECLARE(reactivate_cooldown)

/datum/component/artifact/Initialize(forced_origin,forced_effect,forced_size)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	holder = parent
	GLOB.running_artifact_list[holder] = src

	if(forced_size != null)
		artifact_size = forced_size

	if(!length(fault_weight_list))
		var/list/datum/artifact_fault/valid_faults_pre = typecacheof(/datum/artifact_fault,ignore_root_path = TRUE)
		var/list/datum/artifact_fault/valid_faults = list()
		for(var/datum/artifact_fault/fault as anything in valid_faults_pre)
			valid_faults += fault
			valid_faults[fault] = fault.weight
		fault_weight_list = valid_faults
	if(forced_origin)
		valid_origins = list(forced_origin)
	var/datum/artifact_origin/picked_origin = pick(valid_origins)
	artifact_origin = new picked_origin
	fake_name = "[pick(artifact_origin.name_vars["adjectives"])] [pick(isitem(holder) ? artifact_origin.name_vars["small-nouns"] : artifact_origin.name_vars["large-nouns"])]"
	if(prob(95))
		var/picked_fault = pick_weight(fault_weight_list)
		chosen_fault = new picked_fault
		chosen_fault.our_artifact = src
		chosen_fault.on_added(src)

	generated_name = artifact_origin.generate_name()
	if(!generated_name)
		generated_name  = "[pick(artifact_origin.name_vars["adjectives"])] [pick(isitem(holder) ? artifact_origin.name_vars["small-nouns"] : artifact_origin.name_vars["large-nouns"])]"

	holder.name = fake_name
	holder.desc = "Some sort of artifact from a time long past."

	var/dat_icon
	switch(artifact_size)
		if(ARTIFACT_SIZE_LARGE)
			holder.icon = artifact_origin.icon_file_large
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_icons)]"
		if(ARTIFACT_SIZE_SMALL)
			holder.icon = artifact_origin.icon_file_medium
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_item_icons)]"
		if(ARTIFACT_SIZE_TINY)
			holder.icon = artifact_origin.icon_file_small
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_item_icons_small)]"
	holder.icon_state = dat_icon

	//wizards got an extract MA for the gem coloring, if we have extras add them below this
	if(artifact_origin.type_name == ORIGIN_WIZARD)
		extra_effect = mutable_appearance(holder.icon, "[holder.icon_state]-gem", ABOVE_OBJ_LAYER, offset_spokesman = holder)
		extra_effect.color = random_rgb_pairlists(artifact_origin.overlays_reds, artifact_origin.overlays_blues, artifact_origin.overlays_greens, artifact_origin.overlays_alpha)

	holder.update_appearance() // force an all update specifically to try and apply secondary overlays

	act_effect = mutable_appearance(holder.icon, "[holder.icon_state]fx", offset_spokesman = holder, alpha = rand(artifact_origin.overlays_alpha[1], artifact_origin.overlays_alpha[2]))
	act_effect.color = random_rgb_pairlists(artifact_origin.overlays_reds, artifact_origin.overlays_blues, artifact_origin.overlays_greens, artifact_origin.overlays_alpha)
	act_effect.overlays += emissive_appearance(act_effect.icon, act_effect.icon_state, holder, alpha = act_effect.alpha)
	activation_sound = pick(artifact_origin.activation_sounds)
	if(LAZYLEN(artifact_origin.deactivation_sounds))
		deactivation_sound = pick(artifact_origin.deactivation_sounds)
	setup()
	var/activator_amount = rand(1,max_activators)
	for(var/i in 1 to activator_amount)
		var/selection = pick(valid_activators)
		valid_activators -= selection
		var/datum/artifact_activator/activator = new selection()
		activators += activator
		var/potency = rand(0,100)
		activator.setup(potency)
	if(forced_effect)
		var/datum/artifact_effect/added_boogaloo = new forced_effect
		artifact_effects += added_boogaloo
		added_boogaloo.our_artifact = src
		added_boogaloo.setup()
	if(!length(GLOB.artifact_effect_rarity["all"]))
		build_weighted_rarities()
	var/list/datum/artifact_effect/dont_touch = GLOB.artifact_effect_rarity["all"] //Dont touch because below.
	var/list/datum/artifact_effect/all_possible_effects = dont_touch.Copy() //If you touch it, it actually edits the list, we need a copy. We cant call copy directly because its not a static type list.
	var/effects_amount = rand(1,BASE_MAX_EFFECTS)

	while(effects_amount > 0)
		if(effects_amount <= 0)
			logger.Log(LOG_CATEGORY_ARTIFACT, "[src] has ran out of possible artifact effects! It may not have any at all!")
			break
		var/datum/artifact_effect/effect = pick_weight(all_possible_effects)
		all_possible_effects -= effect
		if(try_add_effect(effect))
			effects_amount--

/datum/component/artifact/Destroy(force)
	QDEL_NULL(artifact_origin)
	QDEL_NULL(analysis)
	QDEL_NULL(chosen_fault)
	QDEL_LIST(activators)
	QDEL_LIST(artifact_effects)
	discovered_activators.Cut()
	discovered_effects.Cut()
	return ..()

/datum/component/artifact/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_DESTRUCTION, COMSIG_QDELETING), PROC_REF(on_destroy))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_STICKER_STICKED, PROC_REF(on_sticker))
	RegisterSignal(parent, COMSIG_STICKER_UNSTICKED, PROC_REF(on_desticker))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_unarmed))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(on_robot_attack))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(ex_act))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_PULLED, PROC_REF(log_pull))
	RegisterSignal(parent, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(log_stop_pull))

/datum/component/artifact/UnregisterFromParent()
	GLOB.running_artifact_list -= parent
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_STICKER_STICKED,
		COMSIG_STICKER_UNSTICKED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_EMP_ACT,
		COMSIG_ATOM_NO_LONGER_PULLED,
		COMSIG_ATOM_PULLED,
	))
///This just clears all the effects,activators,and faults of the artifact, so we can add new ones with a proc.
/datum/component/artifact/proc/clear_out()
	QDEL_LIST(activators)
	QDEL_NULL(chosen_fault)
	QDEL_LIST(artifact_effects)
	fault_discovered = FALSE
	discovered_effects = list()
	return
///Adds an activator, returns TRUE/FALSE based on success.
/datum/component/artifact/proc/add_activator(datum/artifact_activator/new_activator,forced_potency = 0)
	if(!new_activator)
		return FALSE
	if(length(activators) >= BASE_MAX_ACTIVATORS)
		return FALSE
	var/datum/artifact_activator/created
	if(ispath(new_activator))
		created = new new_activator()
	else
		created = new new_activator.type
	activators += created
	if(forced_potency > 0 )
		created.setup(forced_potency)
	else
		created.setup(rand(1,100))
	return TRUE
///changes the fault of the artifact, returns TRUE/FALSE based on success.
/datum/component/artifact/proc/change_fault(datum/artifact_fault/new_fault)
	if(new_fault)
		return force_replace_fault(new_fault.type)
	else
		qdel(chosen_fault)
		chosen_fault = new new_fault
	return TRUE

/*
* Long function, but basically:
* For given effect:
* If it has valid types, check to make sure its of the right type path. So you cant roll something that requires a structure on an item.
* If it has valid origins, and the artifact isnt that origin, return FALSE.
* If it has valid activators, and the artifact has none of them,  return FALSE.
* If it has a valid size, and the artifact isnt that size,  return FALSE.
* Then, if all is well, slam it on the artifact, call setup() on the effect, return TRUE
*/
/datum/component/artifact/proc/try_add_effect(datum/artifact_effect/effect)
	var/datum/artifact_effect/added
	if(ispath(effect))
		added = new effect //We need it now, becasue for some reason we cant read the lists from just the raw datum.
	else
		added = new effect.type //Skip the checks, just add it.
		artifact_effects += added
		added.our_artifact = src
		added.setup()
		return TRUE
	if(length(added.valid_type_paths))
		var/bad_path = FALSE
		for(var/path in added.valid_type_paths)
			if(!istype(holder,path))
				bad_path = TRUE
				break
		if(bad_path)
			QDEL_NULL(added)
			return FALSE
	if(length(added.valid_origins))
		if(!(artifact_origin.type_name in added.valid_origins))
			QDEL_NULL(added)
			return FALSE
	if(length(added.valid_activators))
		var/good_activators = FALSE
		for(var/datum/artifact_activator/activator as anything in activators) //Only need one to be correct.
			if(activator.type in added.valid_activators)
				good_activators = TRUE
				break
		if(!good_activators)
			QDEL_NULL(added)
			return FALSE
	if(added.artifact_size)
		if(artifact_size != added.artifact_size)
			QDEL_NULL(added)
			return FALSE
	artifact_effects += added
	added.our_artifact = src
	added.setup()
	return TRUE

///Kinda a legacy proc, but if you need something super special I guess.
/datum/component/artifact/proc/setup()
	return

///Replaces the fault on the artifact with a new one.
/datum/component/artifact/proc/force_replace_fault(new_fault)
	if(new_fault)
		qdel(chosen_fault)
		if(ispath(new_fault))
			chosen_fault = new new_fault
			chosen_fault.our_artifact = src
			chosen_fault.on_added(src)
		else
			chosen_fault = new_fault
			chosen_fault.our_artifact = src
			chosen_fault.on_added(src)
		return TRUE
	return FALSE

///Adds a new artifact effect to the artifact. Ignores all normal checks. Admin Proc. Not called.
/datum/component/artifact/proc/force_add_effect(new_effect_path,effect_power = null)
	if(new_effect_path && ispath(new_effect_path,/datum/artifact_effect))
		var/datum/artifact_effect/added_boogaloo = new new_effect_path
		artifact_effects += added_boogaloo
		added_boogaloo.our_artifact = src
		if(effect_power)
			added_boogaloo.potency = effect_power
		added_boogaloo.setup()
		return TRUE
	return FALSE

///Activates the artifact.
/datum/component/artifact/proc/artifact_activate(silent)
	if(active) //dont activate activated objects
		return FALSE

	if(activation_sound && !silent)
		playsound(holder, activation_sound, 75, TRUE)
	if(activation_message && !silent)
		holder.visible_message(span_notice("[holder] [activation_message]"))
	active = TRUE
	holder.add_overlay(act_effect)
	logger.Log(LOG_CATEGORY_ARTIFACT, "[parent] has been activated")
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.effect_activate(silent)
	return TRUE

///The opposite of activates the artifact
/datum/component/artifact/proc/artifact_deactivate(silent = FALSE)
	if(!active)
		return
	if(deactivation_sound && !silent)
		playsound(holder, deactivation_sound, 75, TRUE)
	if(deactivation_message && !silent)
		holder.visible_message(span_notice("[holder] [deactivation_message]"))
	active = FALSE
	holder.cut_overlay(act_effect)
	logger.Log(LOG_CATEGORY_ARTIFACT, "[parent] has been deactivated")
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.effect_deactivate(silent)

/datum/component/artifact/effect_touched(mob/living/user)
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.effect_touched(user)
	return

///Called when the artifact gets something that may activate it. Skips re-activation of artifacts, but passes their triggers to faults.
/datum/component/artifact/proc/process_stimuli(stimuli, stimuli_value, triggers_faults = TRUE)
	if(!stimuli)
		return
	var/checked_fault = FALSE
	var/correct_trigger = FALSE
	for(var/datum/artifact_activator/listed_activator in activators)
		if(!(listed_activator.required_stimuli & stimuli) && chosen_fault)
			if(!triggers_faults)
				continue
			if(freebies >= 1)
				freebies--
				continue
			if(checked_fault)
				continue
			checked_fault = TRUE
			if(prob(chosen_fault.trigger_chance))
				logger.Log(LOG_CATEGORY_ARTIFACT, "[parent]'s fault has been triggered, trigger type [chosen_fault].")
				chosen_fault.on_trigger(src)
				if(chosen_fault.visible_message)
					holder.visible_message("[holder] [chosen_fault.visible_message]")
			continue
		checked_fault = TRUE
		if((listed_activator.required_stimuli & stimuli) && istype(listed_activator, /datum/artifact_activator/range))
			if(stimuli_value < listed_activator.amount)
				continue
		correct_trigger = TRUE
		break
	if(active || !correct_trigger)
		return
	if(COOLDOWN_FINISHED(src,reactivate_cooldown))
		artifact_activate()
	COOLDOWN_START(src,reactivate_cooldown,STIMULI_CD_TIME)

/datum/component/artifact/proc/stimulate_from_turf_heat(turf/target)
	if(!QDELETED(target))
		process_stimuli(STIMULUS_HEAT, target.return_air().temperature, FALSE)

/datum/component/artifact/proc/stimulate_from_rad_act(intensity)
	process_stimuli(STIMULUS_RADIATION, intensity)

#undef BASE_MAX_ACTIVATORS
#undef BASE_MAX_EFFECTS
#undef STIMULI_CD_TIME
