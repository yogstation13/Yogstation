/datum/guardian_ability/major/predator
	name = "Predator"
	desc = "The guardian can track down any living being with just a fingerprint or blood sample."
	cost = 2
	spell_type = /datum/action/cooldown/spell/predator
	has_mode = TRUE
	mode_on_msg = span_bolddanger("You switch to analysis mode")
	mode_off_msg = span_bolddanger("You switch to combat mode.")
	var/list/can_track = list()

/datum/guardian_ability/major/predator/Apply()
	. = ..()
	guardian.apply_status_effect(/datum/status_effect/agent_pinpointer/predator)

/datum/guardian_ability/major/predator/Remove()
	. = ..()
	guardian.remove_status_effect(/datum/status_effect/agent_pinpointer/predator)

/datum/guardian_ability/major/predator/Attack(atom/target)
	if (mode)
		if (!guardian.Adjacent(target))
			return ..()
		if (istype(target, /obj/effect/decal/cleanable/blood) || istype(target, /obj/effect/decal/cleanable/blood/trail_holder))
			guardian.visible_message(span_notice("[guardian] swirls it's finger around in [target] for a bit, before shaking it off."))
			var/obj/effect/decal/D = target
			var/list/blood = D.return_blood_DNA()
			if (LAZYLEN(blood))
				for (var/mob/living/carbon/human/H in GLOB.alive_mob_list)
					if (H.dna && blood[H.dna.unique_enzymes])
						if (!(H in can_track))
							to_chat(guardian, span_italics(span_notice("We learn the identity of [H.real_name].")))
							can_track += H
			return TRUE
		if (isobj(target))
			guardian.visible_message(span_notice("[guardian] picks up [target], and looks at it for a second, before setting it down."))
			var/obj/O = target
			var/list/prints = O.return_fingerprints()
			if (LAZYLEN(prints))
				for (var/mob/living/carbon/human/H in GLOB.alive_mob_list)
					if (H.dna && prints[md5(H.dna.unique_identity)])
						if (!(H in can_track))
							to_chat(guardian, span_italics(span_notice("We learn the identity of [H.real_name].")))
							can_track += H
			var/list/blood = O.return_blood_DNA()
			if (LAZYLEN(blood))
				for (var/mob/living/carbon/human/H in GLOB.alive_mob_list)
					if (H.dna && blood[H.dna.unique_enzymes])
						if (!(H in can_track))
							to_chat(guardian, span_italics(span_notice("We learn the identity of [H.real_name].")))
							can_track += H
			return TRUE

/datum/action/cooldown/spell/predator
	name = "All-Seeing Predator"
	desc = "Track down a target whose identity you know of."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "predator"
	background_icon_state = "bg_demon"
	
	cooldown_time = 1 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/predator/cast(mob/living/user)
	. = ..()
	if (!isguardian(user))
		return
	var/mob/living/simple_animal/hostile/guardian/G = user
	if (!G.stats || !G.stats.ability || !istype(G.stats.ability, /datum/guardian_ability/major/predator))
		return
	var/datum/guardian_ability/major/predator/P = G.stats.ability
	if (!LAZYLEN(P.can_track))
		to_chat(G, span_notice("You don't have anyone to track!"))
		return
	var/mob/living/carbon/human/prey = tgui_input_list(G, "Select your prey!", "All-Seeing Eyes", P.can_track)
	if (!prey)
		to_chat(G, span_notice("You didn't select anyone to track!"))
		return
	to_chat(G, span_notice("We begin to track [span_bold(prey.real_name)].[get_final_z(prey) == get_final_z(G) ? "" : " They are far away from here[G.stats.potential >= 4 ? ", on z-level [get_final_z(prey)]." : "."]"]"))
	log_game("[key_name(G)] began to track [key_name(prey)] using Predator.") // why log this? Simple. Some idiot will eventually cry metacomms because someone used this ability to track them to their autistic maint base or random-ass locker. //this post was fact-checked by real byond experts: TRUE
	for (var/datum/status_effect/agent_pinpointer/predator/status in G.status_effects)
		status.scan_target = prey
		status.point_to_target()

/atom/movable/screen/alert/status_effect/agent_pinpointer/predator
	name = "Predator's All-Seeing Eyes"

/datum/status_effect/agent_pinpointer/predator
	id = "predator"
	minimum_range = 1
	range_fuzz_factor = 0
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/predator

/datum/status_effect/agent_pinpointer/predator/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/predator/point_to_target()
	if (!isguardian(owner))
		return
	var/mob/living/simple_animal/hostile/guardian/G = owner
	if (!G.stats || !G.stats.ability || !istype(G.stats.ability, /datum/guardian_ability/major/predator))
		return
	range_fuzz_factor = (10 / G.stats.potential) - 1 // at potential F, you'll just be able to tell what room they're in. At potential A, you'll know whether you're standing next to them or not.
	return ..()
