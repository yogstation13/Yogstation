/// Ticking buff to overheated mobs that causes burn wounds
/datum/status_effect/stacking/heat_exposure
	id = "heat_exposure"
	status_type = STATUS_EFFECT_UNIQUE
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_TEMP
	max_stacks = 40
	stack_threshold = 10 // added to in init
	stack_decay = 0 // handled manually

	var/warned = TRUE

	/// How hot before we gain stacks rather than losing them
	var/temp_threshold = -1

/datum/status_effect/stacking/heat_exposure/on_creation(mob/living/new_owner, stacks_to_apply, temp_threshold)
	src.stack_threshold += rand(0, 20)
	src.temp_threshold = temp_threshold
	return ..()

/datum/status_effect/stacking/heat_exposure/can_have_status()
	return ishuman(owner) && !HAS_TRAIT(src, TRAIT_RESISTHEAT)

/datum/status_effect/stacking/heat_exposure/can_gain_stacks()
	return can_have_status() && owner.bodytemperature > temp_threshold

/datum/status_effect/stacking/heat_exposure/tick(seconds_between_ticks)
	if(owner.bodytemperature > temp_threshold)
		add_stacks(0.5 * seconds_between_ticks)
	else
		add_stacks(-2 * seconds_between_ticks)
	if(QDELETED(src)) // either we dropped off or we applied a wound
		return
	if(stacks >= max(stack_threshold - (10 + rand(-2, 5)), 8) && SPT_PROB(33, seconds_between_ticks) && !warned)
		to_chat(owner, span_warning("You feel overheated!"))
		warned = TRUE
	return ..()

/datum/status_effect/stacking/heat_exposure/stacks_consumed_effect()
	var/mob/living/carbon/human/human_owner = owner
	// Lets pick a random body part and check for an existing burn
	var/obj/item/bodypart/bodypart = pick(human_owner.bodyparts)
	var/datum/wound/existing_burn
	for (var/datum/wound/iterated_wound as anything in bodypart.wounds)
		var/datum/wound_pregen_data/pregen_data = iterated_wound.get_pregen_data()
		if (pregen_data.wound_series in GLOB.wounding_types_to_series[WOUND_BURN])
			existing_burn = iterated_wound
			break

	// If we have an existing burn try to upgrade it
	var/severity = WOUND_SEVERITY_MODERATE
	var/heat_damage = 2 * HEAT_DAMAGE * human_owner.physiology.heat_mod
	if(human_owner.bodytemperature > temp_threshold * 8)
		if(existing_burn?.severity < WOUND_SEVERITY_CRITICAL)
			severity = WOUND_SEVERITY_CRITICAL
		heat_damage *= 8

	else if(human_owner.bodytemperature > temp_threshold * 2)
		if(existing_burn?.severity < WOUND_SEVERITY_SEVERE)
			severity = WOUND_SEVERITY_SEVERE
		heat_damage *= 3

	human_owner.cause_wound_of_type_and_severity(WOUND_BURN, bodypart, severity, wound_source = "hot temperatures")
	human_owner.apply_damage(HEAT_DAMAGE, BURN, bodypart, wound_bonus = CANT_WOUND)
