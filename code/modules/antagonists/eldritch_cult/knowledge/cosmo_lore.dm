/datum/eldritch_knowledge/base_cosmic
	name = "Eternal Gate"
	desc = "Opens up the Path of Cosmos to you. \
		Allows you to transmute a sheet of plasma and a knife into an Cosmic Blade. \
		You can only create two at a time."
	gain_text = "A nebula appeared in the sky, its infernal birth shone upon me. This was the start of a great transcendence."
	banned_knowledge = list(
		/datum/eldritch_knowledge/base_ash,
		/datum/eldritch_knowledge/base_rust,
		/datum/eldritch_knowledge/base_flesh,
		/datum/eldritch_knowledge/base_mind,
		/datum/eldritch_knowledge/base_void,
		/datum/eldritch_knowledge/base_blade,
		/datum/eldritch_knowledge/ash_mark,
		/datum/eldritch_knowledge/rust_mark,
		/datum/eldritch_knowledge/flesh_mark,
		/datum/eldritch_knowledge/mind_mark,
		/datum/eldritch_knowledge/void_mark,
		/datum/eldritch_knowledge/blade_mark,
		/datum/eldritch_knowledge/ash_blade_upgrade,
		/datum/eldritch_knowledge/rust_blade_upgrade,
		/datum/eldritch_knowledge/flesh_blade_upgrade,
		/datum/eldritch_knowledge/mind_blade_upgrade,
		/datum/eldritch_knowledge/void_blade_upgrade,
		/datum/eldritch_knowledge/blade_blade_upgrade,
		/datum/eldritch_knowledge/ash_final,
		/datum/eldritch_knowledge/rust_final,
		/datum/eldritch_knowledge/flesh_final,
		/datum/eldritch_knowledge/mind_final,
		/datum/eldritch_knowledge/void_final,
		/datum/eldritch_knowledge/blade_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/cosmic_knife)
	cost = 1
	route = PATH_COSMIC
	tier = TIER_PATH

/datum/eldritch_knowledge/base_cosmic/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/melee/sickly_blade/cosmic
	user.put_in_hands(realknife)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_cosmic/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/// Aplies the effect of the mansus grasp when it hits a target.
// /datum/eldritch_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
// 	SIGNAL_HANDLER

// 	to_chat(target, span_danger("A cosmic ring appeared above your head!"))
// 	target.apply_status_effect(/datum/status_effect/star_mark, source)
// 	new /obj/effect/forcefield/cosmic_field(get_turf(source))
/datum/eldritch_knowledge/base_cosmic/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/human/human_target = target
	to_chat(target, span_danger("A cosmic ring appeared above your head!"))
	human_target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))
