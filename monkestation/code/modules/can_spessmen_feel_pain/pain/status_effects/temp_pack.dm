/// Status effects applied when pressing a hot or cold item onto a bodypart, to soothe pain.
/datum/status_effect/temperature_pack
	id = "temp_pack"
	status_type = STATUS_EFFECT_MULTIPLE
	on_remove_on_mob_delete = TRUE
	tick_interval = 5 SECONDS
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = null
	/// The item we're using to heal pain.
	var/obj/item/pressed_item
	/// The mob holding the [pressed_item] to [owner]. Can be [owner].
	var/mob/living/holder
	/// The zone we're healing.
	var/targeted_zone = BODY_ZONE_CHEST
	/// The amount we heal per tick. Positive number.
	var/pain_heal_amount = 0
	/// The pain modifier placed on the limb.
	var/pain_modifier = 1
	/// The change in temperature while applied.
	var/temperature_change = 0

/datum/status_effect/temperature_pack/on_creation(
	mob/living/new_owner,
	mob/living/holder,
	obj/item/pressed_item,
	targeted_zone = BODY_ZONE_CHEST,
	pain_heal_amount = 0,
	pain_modifier = 1,
	temperature_change = 0,
)

	src.holder = holder
	src.pressed_item = pressed_item
	src.targeted_zone = targeted_zone
	src.pain_heal_amount = pain_heal_amount
	src.pain_modifier = pain_modifier
	src.temperature_change = temperature_change
	return ..()

/datum/status_effect/temperature_pack/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner.pain_controller || human_owner.stat == DEAD)
		return FALSE

	if(QDELETED(pressed_item))
		return FALSE

	if(QDELETED(holder))
		return FALSE

	for(var/datum/status_effect/temperature_pack/pre_existing_effect in owner.status_effects)
		if(pre_existing_effect == src)
			continue
		if(pre_existing_effect.targeted_zone == targeted_zone)
			return FALSE

	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	if(!held_bodypart)
		return FALSE

	held_bodypart.bodypart_pain_modifier *= pain_modifier
	pressed_item.AddComponent(/datum/component/make_item_slow)
	RegisterSignal(pressed_item, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_TEMPERATURE_PACK_EXPIRED), PROC_REF(stop_effects))
	if(holder != owner)
		RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(check_adjacency))
	return TRUE

/datum/status_effect/temperature_pack/tick()
	if(QDELETED(holder) || QDELETED(pressed_item) || owner.stat == DEAD || !holder.is_holding(pressed_item))
		stop_effects(silent = TRUE)
		return

	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner.get_bodypart_pain(targeted_zone, TRUE))
		stop_effects(silent = FALSE)
		return

	if(temperature_change)
		owner.adjust_bodytemperature(temperature_change, human_owner.bodytemp_cold_damage_limit + 5 KELVIN, human_owner.bodytemp_heat_damage_limit - 5 KELVIN)
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	if(held_bodypart && prob(66))
		human_owner.cause_pain(targeted_zone, -pain_heal_amount)
		if(prob(10))
			to_chat(human_owner, span_italics(span_notice("[pressed_item] dulls the pain in your [held_bodypart.name] a little.")))

/**
 * Check on move whether [holder] is still adjacent to [owner].
 */
/datum/status_effect/temperature_pack/proc/check_adjacency(datum/source)
	SIGNAL_HANDLER

	if(!in_range(holder, owner))
		stop_effects(silent = FALSE)

/**
 * Stop the effects of this status effect, deleting it, and sending a message if [silent] is TRUE.
 */
/datum/status_effect/temperature_pack/proc/stop_effects(datum/source, silent = FALSE)
	SIGNAL_HANDLER

	if(!silent && !QDELETED(holder) && !QDELETED(pressed_item))
		to_chat(holder, span_notice("You stop pressing [pressed_item] against [owner == holder ? "yourself":"[owner]"]."))
	qdel(src)

/datum/status_effect/temperature_pack/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller?.body_zones[targeted_zone]
	held_bodypart?.bodypart_pain_modifier /= pain_modifier
	qdel(pressed_item.GetComponent(/datum/component/make_item_slow))
	UnregisterSignal(pressed_item, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_TEMPERATURE_PACK_EXPIRED))
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)

	pressed_item = null
	holder = null

/// Cold stuff needs to stay cold.
/datum/status_effect/temperature_pack/cold
	id = "cold_pack"
	temperature_change = -2

/datum/status_effect/temperature_pack/cold/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	to_chat(human_owner, span_green("You wince as [owner == holder ? "you press" : "[holder] presses"] [pressed_item] against your [parse_zone(held_bodypart.body_zone)], but eventually the chill starts to dull the pain."))
	human_owner.pain_emote("wince", 3 SECONDS)

/datum/status_effect/temperature_pack/cold/get_examine_text()
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	return span_danger("[holder == owner ? "[owner.p_Theyre()]" : "[holder] is"] pressing a cold [pressed_item.name] against [owner.p_their()] [parse_zone(held_bodypart.body_zone)].")

/datum/status_effect/temperature_pack/cold/tick()
	if(pressed_item.resistance_flags & ON_FIRE)
		stop_effects(silent = TRUE)
		return

	return ..()

/// And warm stuff needs to stay warm.
/datum/status_effect/temperature_pack/heat
	id = "heat_pack"
	temperature_change = 2

/datum/status_effect/temperature_pack/heat/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	to_chat(human_owner, span_green("You gasp as [owner == holder ? "you press" : "[holder] presses"] [pressed_item] against your [held_bodypart.name], but eventually the warmth starts to dull the pain."))
	human_owner.pain_emote("gasp", 3 SECONDS)

/datum/status_effect/temperature_pack/head/get_examine_text()
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/held_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	return span_danger("[holder == owner ? "[owner.p_Theyre()]" : "[holder] is"] pressing a warm [pressed_item.name] against [owner.p_their()] [held_bodypart.name].")

/datum/status_effect/temperature_pack/heat/tick()
	if(HAS_TRAIT(pressed_item, TRAIT_FROZEN))
		stop_effects(silent = TRUE)
		return

	return ..()
