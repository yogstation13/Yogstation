/atom/movable/screen/alert/status_effect/changeling
	icon = 'icons/mob/actions/actions_changeling.dmi'

/atom/movable/screen/alert/status_effect/changeling/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	underlays += mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_changeling")
	add_overlay(mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_changeling_border"))

/datum/movespeed_modifier/changeling_adrenaline
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.8

/atom/movable/screen/alert/status_effect/changeling/adrenaline
	name = "Adrenaline"
	desc = "Energy is surging through us. If we wish to escape, the time is now!"
	icon_state = "adrenaline"

/datum/status_effect/changeling_adrenaline
	id = "changeling_adrenaline"
	duration = 20 SECONDS
	show_duration = TRUE
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/changeling/adrenaline
	status_type = STATUS_EFFECT_REFRESH

	var/static/list/traits = list(TRAIT_SLEEPIMMUNE, TRAIT_BATON_RESISTANCE, TRAIT_CANT_STAMCRIT)

	var/movespeed_timer

/datum/status_effect/changeling_adrenaline/on_apply()
	. = ..()
	to_chat(owner, span_notice("Energy rushes through us."))
	owner.add_traits(traits, TRAIT_STATUS_EFFECT(id))

	owner.SetAllImmobility(0)
	owner.set_resting(FALSE, silent = TRUE, instant = TRUE)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/changeling_adrenaline)
	movespeed_timer = addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier)), 6 SECONDS, TIMER_STOPPABLE)

/datum/status_effect/changeling_adrenaline/on_remove()
	. = ..()
	to_chat(owner, span_notice("Our energy fizzles out."))
	owner.remove_traits(traits, TRAIT_STATUS_EFFECT(id))
	remove_movespeed_modifier()

/datum/status_effect/changeling_adrenaline/refresh(effect, ...)
	duration = min(duration + initial(duration), world.time + initial(duration) * 3)
	remove_movespeed_modifier()
	on_apply()

/datum/status_effect/changeling_adrenaline/tick(seconds_per_tick, times_fired)
	owner.AdjustAllImmobility(-1 SECOND * seconds_per_tick)
	owner.stamina.adjust(STAMINA_MAX / 20 * seconds_per_tick)
	owner.set_jitter_if_lower(10 SECONDS)
	owner.adjustToxLoss(0.5 * seconds_per_tick) // 10 toxin damage total.

/datum/status_effect/changeling_adrenaline/proc/remove_movespeed_modifier()
	deltimer(movespeed_timer)
	movespeed_timer = null
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/changeling_adrenaline)

/atom/movable/screen/alert/status_effect/changeling/panacea
	name = "Panacea"
	desc = "We return to a pure form of being."
	icon_state = "panacea"

/datum/status_effect/changeling_panacea
	id = "changeling_panacea"
	duration = 1 MINUTE
	show_duration = TRUE
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/changeling/panacea
	status_type = STATUS_EFFECT_REFRESH

	var/static/list/bad_organ_types = list(
		/obj/item/organ/internal/body_egg,
		/obj/item/organ/internal/legion_tumour,
		/obj/item/organ/internal/zombie_infection,
		/obj/item/organ/internal/empowered_borer_egg,
	)

	var/static/list/traits = list(TRAIT_VIRUSIMMUNE)

	COOLDOWN_DECLARE(extra_effects_cooldown)

/datum/status_effect/changeling_panacea/on_apply()
	. = ..()
	to_chat(owner, span_notice("We cleanse impurities from our form."))
	owner.immune_system?.AntibodyCure()
	owner.add_traits(traits, TRAIT_STATUS_EFFECT(id))
	handle_extra_effects()

/datum/status_effect/changeling_panacea/on_remove()
	. = ..()
	owner.remove_traits(traits, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/changeling_panacea/refresh(effect, ...)
	duration = min(duration + initial(duration), world.time + initial(duration) * 2)
	on_apply()

/datum/status_effect/changeling_panacea/tick(seconds_per_tick, times_fired)
	. = ..()
	owner.adjustToxLoss(-10 * seconds_per_tick)
	owner.adjustCloneLoss(-20 * seconds_per_tick)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -20 * seconds_per_tick)
	owner.adjust_drunk_effect(-10 * seconds_per_tick)
	owner.adjust_disgust(DISGUST_LEVEL_MAXEDOUT * -0.1 * seconds_per_tick)

	if(length(owner.reagents?.reagent_list))
		owner.reagents.remove_all(10 * length(owner.reagents.reagent_list) * seconds_per_tick)

	handle_extra_effects()

/// Basically stuff you need in both on_apply() and tick(), these also have a cooldown for performance reasons.
/datum/status_effect/changeling_panacea/proc/handle_extra_effects()
	if(!COOLDOWN_FINISHED(src, extra_effects_cooldown))
		return
	COOLDOWN_START(src, extra_effects_cooldown, 1 SECOND)

	var/mob/living/basic/cortical_borer/brain_pest = owner.has_borer()
	if(istype(brain_pest))
		brain_pest.leave_host()

	if(!iscarbon(owner))
		return
	var/mob/living/carbon/user = owner

	if(user.has_embedded_objects(include_harmless = TRUE))
		user.remove_all_embedded_objects()
		user.visible_message(
			message = span_danger("[user] violently rejects everything embedded into [user.p_them()]!"),
			self_message = span_notice("We reject everything embedded into us.")
		)

	user.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)

	if(user.has_dna())
		user.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA), mutadone = TRUE) // DO NOT SET MUTADONE TO FALSE. It removes a lot of things we don't want to.

	var/removed_something = FALSE
	for(var/obj/item/organ/organ as anything in bad_organ_types)
		organ = user.get_organ_by_type(organ)
		if(!istype(organ))
			continue

		organ.Remove(user)
		organ.forceMove(user.drop_location())
		removed_something = TRUE

	if(removed_something)
		user.vomit(0, stun = FALSE)

/atom/movable/screen/alert/status_effect/changeling/muscles
	name = "Strained Muscles"
	desc = "Our musculature is in overdrive, enhancing our agility at the cost of exhaustion."
	icon_state = "strained_muscles"

/datum/status_effect/changeling_muscles
	id = "changeling_muscles"
	tick_interval = 1 SECONDS
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/changeling/muscles

	/// How long this has been on in seconds.
	var/accumulation = 0

	/// Whether we've warned the user about their impending collapse.
	var/warning_given = FALSE

/datum/status_effect/changeling_muscles/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	owner.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/exhaustion)

	RegisterSignal(owner, COMSIG_LIVING_STAMINA_STUN, PROC_REF(on_stamina_stun))
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

	to_chat(owner, span_notice("Our muscles tense and strengthen."))

/datum/status_effect/changeling_muscles/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	owner.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/exhaustion)

	UnregisterSignal(owner, list(COMSIG_LIVING_STAMINA_STUN, COMSIG_MOB_STATCHANGE))

	if(owner.stat != CONSCIOUS || HAS_TRAIT_FROM(owner, TRAIT_INCAPACITATED, STAMINA))
		to_chat(owner, span_warning("Our muscles relax, stripped of energy to strengthen them."))
	else
		to_chat(owner, span_notice("Our muscles relax."))

	if(accumulation > 40)
		owner.balloon_alert(owner, "you collapse!")
		owner.Paralyze(6 SECONDS)
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "gasp")

/datum/status_effect/changeling_muscles/tick(seconds_per_tick, times_fired)
	accumulation += DELTA_WORLD_TIME(SSprocessing)

	if(accumulation > 40 && !warning_given)
		to_chat(owner, span_userdanger("Our legs are really starting to hurt..."))
		warning_given = TRUE

	owner.stamina?.adjust(STAMINA_MAX * -0.001 * accumulation * seconds_per_tick)

/datum/status_effect/changeling_muscles/proc/on_stamina_stun(mob/living/carbon/user)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/changeling_muscles/proc/on_stat_change(mob/living/carbon/user, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat != CONSCIOUS)
		qdel(src)
