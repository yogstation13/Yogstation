#define REVELATION_MIN_COOLDOWN	20 SECONDS
#define REVELATION_MAX_COOLDOWN	1 MINUTES

/datum/bloodsucker_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Little is documented about Malkavians. Complete insanity is the most common theme. \n\
		The Favorite Vassal will suffer the same fate as the Master."
	join_icon_state = "malkavian"
	join_description = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, \
		and become the enforcer of the Masquerade code."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY
	COOLDOWN_DECLARE(revelation_cooldown)

/datum/bloodsucker_clan/malkavian/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE, PROC_REF(on_bloodsucker_broke_masquerade))
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)
	var/mob/living/carbon/carbon_owner = bloodsuckerdatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	owner_datum.owner.current.update_sight()

	bloodsuckerdatum.owner.current.playsound_local(get_turf(bloodsuckerdatum.owner.current), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(bloodsuckerdatum.owner.current, span_hypnophrase("Welcome to the Malkavian..."))

/datum/bloodsucker_clan/malkavian/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)
	var/mob/living/carbon/carbon_owner = bloodsuckerdatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	bloodsuckerdatum.owner.current.update_sight()
	return ..()

/datum/bloodsucker_clan/malkavian/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	if(!COOLDOWN_FINISHED(src, revelation_cooldown) || prob(85) || bloodsuckerdatum.owner.current.stat != CONSCIOUS || HAS_TRAIT(bloodsuckerdatum.owner.current, TRAIT_MASQUERADE))
		return
	var/message = pick(strings("malkavian_revelations.json", "revelations", "monkestation/strings"))
	COOLDOWN_START(src, revelation_cooldown, rand(REVELATION_MIN_COOLDOWN, REVELATION_MAX_COOLDOWN))
	INVOKE_ASYNC(bloodsuckerdatum.owner.current, TYPE_PROC_REF(/atom/movable, say), message, , , , , , CLAN_MALKAVIAN)

/datum/bloodsucker_clan/malkavian/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	var/mob/living/carbon/carbonowner = vassaldatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you now suffer the same fate as your Master."))

/datum/bloodsucker_clan/malkavian/on_exit_torpor(datum/antagonist/bloodsucker/source)
	var/mob/living/carbon/carbonowner = bloodsuckerdatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/bloodsucker_clan/malkavian/on_final_death(datum/antagonist/bloodsucker/source)
	var/obj/item/soulstone/bloodsucker/stone = new /obj/item/soulstone/bloodsucker(get_turf(bloodsuckerdatum.owner.current))
	INVOKE_ASYNC(stone, TYPE_PROC_REF(/obj/item/soulstone/bloodsucker, capture_soul), bloodsuckerdatum.owner.current, forced = TRUE, bloodsuckerdatum = bloodsuckerdatum)
	return DONT_DUST

/datum/bloodsucker_clan/malkavian/proc/on_bloodsucker_broke_masquerade(datum/source, datum/antagonist/bloodsucker/masquerade_breaker)
	SIGNAL_HANDLER
	if(masquerade_breaker == bloodsuckerdatum)
		return
	var/mob/living/target_body = masquerade_breaker.owner.current
	var/vampiric_name = masquerade_breaker.return_full_name()
	var/mortal_name = masquerade_breaker.owner.name || target_body.real_name || target_body.name
	to_chat(bloodsuckerdatum.owner.current, span_userdanger("[vampiric_name], also known as [mortal_name], has broken the Masquerade! Ensure [target_body.p_they()] [target_body.p_are()] eliminated at all costs!"))
	var/datum/objective/enforce_masquerade/masquerade_objective = new(null, masquerade_breaker)
	masquerade_objective.owner = bloodsuckerdatum.owner
	bloodsuckerdatum.objectives += masquerade_objective
	bloodsuckerdatum.owner.announce_objectives()

/datum/objective/enforce_masquerade
	name = "kill masquerade breaker"
	objective_name = "Clan Objective"
	var/datum/antagonist/bloodsucker/masquerade_breaker

/datum/objective/enforce_masquerade/New(text, datum/antagonist/bloodsucker/masquerade_breaker)
	. = ..()
	if(!istype(masquerade_breaker) || !masquerade_breaker.owner)
		CRASH("Attempted to create [type] objective without a valid target bloodsucker datum!")
	RegisterSignal(masquerade_breaker, BLOODSUCKER_FINAL_DEATH, PROC_REF(on_target_final_death))
	src.target = masquerade_breaker.owner
	src.masquerade_breaker = masquerade_breaker
	update_explanation_text()

/datum/objective/enforce_masquerade/Destroy()
	if(masquerade_breaker)
		UnregisterSignal(masquerade_breaker, BLOODSUCKER_FINAL_DEATH)
		masquerade_breaker = null
	return ..()

/datum/objective/enforce_masquerade/update_explanation_text()
	var/target_name = target.name || target.current?.real_name || target.current?.name
	explanation_text = "Ensure that [target_name], who has broken the Masquerade, succumbs to Final Death."

// Simple signal handler to mark the objective as completed when the target succumbs to the final death.
/datum/objective/enforce_masquerade/proc/on_target_final_death(datum/source)
	SIGNAL_HANDLER
	completed = TRUE

/datum/objective/enforce_masquerade/check_completion()
	return ..() || QDELETED(target?.current)


#undef REVELATION_MAX_COOLDOWN
#undef REVELATION_MIN_COOLDOWN
