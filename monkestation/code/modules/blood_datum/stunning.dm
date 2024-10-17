
#define COMSIG_BEAM_ENTERED "beam_entered"

/// Status effect tracking being tased by someone!
/datum/status_effect/tased
	id = "being_tased"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/tazed
	tick_interval = 0.25 SECONDS
	on_remove_on_mob_delete = TRUE
	/// What atom is tasing us?
	var/atom/taser
	/// What atom is using the atom tasing us? Sometimes the same as the taser, such as with turrets.
	var/atom/firer
	/// The beam datum representing the taser electrodes
	var/datum/beam/tase_line

/datum/status_effect/tased/on_creation(mob/living/new_owner, atom/fired_from, atom/firer)
	if(isnull(fired_from) || isnull(firer) || !can_tase_with(fired_from))
		qdel(src)
		return

	if(new_owner.has_status_effect(type) != src)
		alert_type = null

	. = ..()
	if(!.)
		return

	set_taser(fired_from)
	set_firer(firer)

/// Checks if the passed atom is captable of being used to tase someone
/datum/status_effect/tased/proc/can_tase_with(atom/with_what)
	if(istype(with_what, /obj/item/gun/energy))
		var/obj/item/gun/energy/taser_gun = with_what
		if(isnull(taser_gun.cell))
			return FALSE

	else if(istype(with_what, /obj/machinery))
		var/obj/machinery/taser_machine = with_what
		if(!taser_machine.is_operational)
			return FALSE

	return TRUE

/// Actually does the tasing with the passed atom
/// Returns TRUE if the tasing was successful, FALSE if it failed
/datum/status_effect/tased/proc/do_tase_with(atom/with_what, seconds_between_ticks)
	if(!can_see(taser, owner, 5))
		return FALSE
	if(istype(with_what, /obj/item/gun/energy))
		var/obj/item/gun/energy/taser_gun = with_what
		if(!taser_gun.cell?.use(60 * seconds_between_ticks))
			return FALSE
		taser_gun.update_appearance()
		return TRUE

	if(istype(taser, /obj/machinery))
		var/obj/machinery/taser_machine = taser
		if(!taser_machine.is_operational)
			return FALSE
		// We can't measure the output of this but if we use too much power the area will depower -> depower the machine -> stop taze next tick
		taser_machine.use_power(60 * seconds_between_ticks)
		return TRUE

	if(istype(taser, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/taser_equipment = taser
		if(!taser_equipment.chassis \
			|| !taser_equipment.activated \
			|| taser_equipment.get_integrity() <= 1 \
			|| taser_equipment.chassis.is_currently_ejecting \
			|| taser_equipment.chassis.equipment_disabled \
			|| !taser_equipment.chassis.use_power(60 * seconds_between_ticks))
			return FALSE
		return TRUE

	return TRUE

/datum/status_effect/tased/on_apply()
	if(issilicon(owner) \
		|| istype(owner, /mob/living/basic/bot) \
		|| istype(owner, /mob/living/simple_animal/bot) \
		|| HAS_TRAIT(owner, TRAIT_PIERCEIMMUNE))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(try_remove_taser))
	SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK)
	owner.add_mood_event("tased", /datum/mood_event/tased)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/being_tased)
	if(owner.pain_controller?.pain_modifier > 0.5)
		owner.pain_emote("scream")
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.force_say()
	return TRUE

/datum/status_effect/tased/on_remove()
	if(istype(taser, /obj/machinery/porta_turret))
		var/obj/machinery/porta_turret/taser_turret = taser
		taser_turret.manual_control = initial(taser_turret.manual_control)
		taser_turret.always_up = initial(taser_turret.always_up)
		taser_turret.check_should_process()
	else if(istype(taser, /obj/machinery/power/emitter))
		var/obj/machinery/power/emitter/taser_emitter = taser
		taser_emitter.manual = initial(taser_emitter.manual)

	var/mob/living/mob_firer = firer
	if(istype(mob_firer))
		mob_firer.remove_movespeed_modifier(/datum/movespeed_modifier/tasing_someone)

	owner.remove_movespeed_modifier(/datum/movespeed_modifier/being_tased)
	if(!QDELING(owner))
		owner.adjust_jitter_up_to(10 SECONDS, 1 MINUTES)

	taser = null
	firer = null
	QDEL_NULL(tase_line)

/datum/status_effect/tased/tick(seconds_between_ticks)
	if(!do_tase_with(taser, seconds_between_ticks))
		end_tase()
		return
	if(owner.check_stun_immunity(CANSTUN|CANKNOCKDOWN))
		return
	// You are damp, that's bad when you're being tased
	if(owner.fire_stacks < 0)
		owner.apply_damage(max(1, owner.fire_stacks * -0.5 * seconds_between_ticks), FIRE, spread_damage = TRUE)
		if(SPT_PROB(25, seconds_between_ticks))
			do_sparks(1, FALSE, owner)

	owner.set_stutter_if_lower(10 SECONDS)
	owner.set_jitter_if_lower(20 SECONDS)
	owner.cause_pain(BODY_ZONES_ALL, 2 * seconds_between_ticks, BURN)
	owner.apply_damage(120 * seconds_between_ticks * (owner.pain_controller?.pain_modifier || 1), STAMINA)
	if(owner.stat <= SOFT_CRIT)
		owner.do_jitter_animation(INFINITY) // maximum POWER

/// Sets the passed atom as the "taser"
/datum/status_effect/tased/proc/set_taser(atom/new_taser)
	taser = new_taser
	RegisterSignals(taser, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), PROC_REF(end_tase))
	RegisterSignal(taser, COMSIG_GUN_TRY_FIRE, PROC_REF(block_firing))
	if(istype(taser, /obj/machinery/porta_turret))
		var/obj/machinery/porta_turret/taser_turret = taser
		taser_turret.manual_control = TRUE
		taser_turret.always_up = TRUE
	else if(istype(taser, /obj/machinery/power/emitter))
		var/obj/machinery/power/emitter/taser_emitter = taser
		taser_emitter.manual = TRUE

/// Sets the passed atom as the person operating the taser, the "firer"
/datum/status_effect/tased/proc/set_firer(atom/new_firer)
	firer = new_firer
	if(taser != firer) // Turrets, notably, are both
		RegisterSignal(firer, COMSIG_QDELETING, PROC_REF(end_tase))

	// RegisterSignals(firer, list(COMSIG_MOB_SWAP_HANDS), PROC_REF(end_tase))
	RegisterSignal(firer, COMSIG_MOB_CLICKON, PROC_REF(user_cancel_tase))

	// Ensures AI mobs or turrets don't tase players until they run out of power
	var/mob/living/mob_firer = new_firer
	if(!istype(mob_firer) || isnull(mob_firer.client))
		// If multiple things are tasing the same mob, give up sooner, so they can select a new target potentially
		addtimer(CALLBACK(src, PROC_REF(end_tase)), (owner.has_status_effect(type) != src) ? 2 SECONDS : 8 SECONDS)
	if(istype(mob_firer))
		mob_firer.add_movespeed_modifier(/datum/movespeed_modifier/tasing_someone)

	tase_line = firer.Beam(
		BeamTarget = owner,
		icon = 'monkestation/code/modules/blood_datum/icons/beam.dmi',
		icon_state = "electrodes",
		maxdistance = 6,
		beam_type = /obj/effect/ebeam/react_to_entry/electrodes,
	)
	RegisterSignal(tase_line, COMSIG_BEAM_ENTERED, PROC_REF(disrupt_tase))
	RegisterSignal(tase_line, COMSIG_QDELETING, PROC_REF(end_tase))
	tase_line.RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, TYPE_PROC_REF(/datum/beam, redrawing))

/datum/status_effect/tased/proc/block_firing(...)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_GUN_FIRE

/datum/status_effect/tased/proc/user_cancel_tase(mob/living/source, atom/clicked_on, modifiers)
	SIGNAL_HANDLER
	if(clicked_on != owner)
		return NONE
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return NONE
	end_tase()
	return COMSIG_MOB_CANCEL_CLICKON

/datum/status_effect/tased/proc/end_tase(...)
	SIGNAL_HANDLER
	if(QDELING(src))
		return
	owner.visible_message(
		span_warning("The electrodes stop shocking [owner], and fall to the ground."),
		span_notice("The electrodes stop shocking you, and fall to the ground."),
	)
	qdel(src)

/datum/status_effect/tased/proc/try_remove_taser(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_remove_taser_async), source)

/datum/status_effect/tased/proc/try_remove_taser_async()
	owner.visible_message(
		span_warning("[owner] tries to remove the electrodes!"),
		span_notice("You try to remove the electrodes!"),
	)
	// If embedding was less... difficult to work with, I would make tasers rely on an embedded object to handle this
	if(!do_after(owner, 5 SECONDS, extra_checks = CALLBACK(src, PROC_REF(try_remove_taser_checks)), interaction_key = "tazed"))
		return
	owner.visible_message(
		span_warning("[owner] removes the electrodes from [owner.p_their()] body!"),
		span_notice("You remove the electrodes!"),
	)
	end_tase()

/datum/status_effect/tased/proc/try_remove_taser_checks()
	return !QDELETED(src)

/datum/status_effect/tased/proc/disrupt_tase(datum/beam/source, obj/effect/ebeam/beam_effect, atom/movable/entering)
	SIGNAL_HANDLER

	if(!isliving(entering) || entering == taser || entering == firer || entering == owner)
		return
	if(entering.pass_flags & (PASSMOB|PASSGRILLE|PASSTABLE))
		return
	var/mob/living/disruptor = entering
	if(disruptor.body_position == LYING_DOWN)
		return
	disruptor.visible_message(
		span_warning("[disruptor] gets tangled in the electrodes!"),
		span_warning("You get tangled in the electrodes!"),
	)
	disruptor.apply_damage(90, STAMINA)
	disruptor.Knockdown(5 SECONDS)
	disruptor.adjust_jitter_up_to(10 SECONDS, 30 SECONDS)
	qdel(src)

/// Screen alert for being tased, clicking does a resist (like being on fire or w/e)
/atom/movable/screen/alert/status_effect/tazed
	name = "Tased!"
	desc = "Taser electrodes are shocking you! You can resist to try to remove them."
	icon_state = "stun"

/atom/movable/screen/alert/status_effect/tazed/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/living/clicker = usr
	clicker.resist()

/// Beam subtype which sends a signal to the beam itself when someone walks inside it
/obj/effect/ebeam/react_to_entry

/obj/effect/ebeam/react_to_entry/Initialize(mapload, beam_owner)
	. = ..()
	if(isnull(owner))
		return
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	// Technically the beam is entering the mob but we'll count it
	for(var/thing in loc)
		on_entered(src, thing)

/obj/effect/ebeam/react_to_entry/proc/on_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	SEND_SIGNAL(owner, COMSIG_BEAM_ENTERED, src, entering)

/obj/effect/ebeam/react_to_entry/electrodes
	name = "electrodes"
	light_system = OVERLAY_LIGHT
	light_on = TRUE
	light_color = COLOR_YELLOW
	light_power = 1
	light_outer_range = 1.5

/datum/movespeed_modifier/tasing_someone
	multiplicative_slowdown = 2

/datum/movespeed_modifier/being_tased
	multiplicative_slowdown = 4

#undef COMSIG_BEAM_ENTERED
