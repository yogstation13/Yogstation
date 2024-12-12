/datum/quirk/extra_sensory_paranoia
	name = "Extra-Sensory Paranoia"
	desc = "You feel like something wants to kill you..."
	mob_trait = TRAIT_PARANOIA
	value = -8
	icon = FA_ICON_OPTIN_MONSTER

/datum/quirk/extra_sensory_paranoia/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/extra_sensory_paranoia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.cure_trauma_type(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/challenge/paranoia
	challenge_name = "Paranoia"
	challenge_payout = 600
	difficulty = "Hellish"
	applied_trait = TRAIT_PARANOIA
	var/added = FALSE

/datum/challenge/paranoia/on_apply()
	. = ..()
	var/mob/living/carbon/human/current_human = host.find_current_mob()
	if(!ishuman(current_human))
		return
	current_human.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)
	added = TRUE

/datum/challenge/paranoia/on_process()
	if(added)
		return
	var/mob/living/carbon/human/current_human = host.find_current_mob()
	if(!ishuman(current_human))
		return
	current_human.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)
	added = TRUE

/datum/challenge/paranoia/on_transfer(datum/mind/source, mob/previous_body)
	. = ..()
	var/mob/living/carbon/human/previous_human = previous_body
	if(ishuman(previous_human))
		previous_human.cure_trauma_type(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

	var/mob/living/carbon/human/current_human = source.current
	if(ishuman(current_human))
		current_human.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)
