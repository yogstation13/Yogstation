// Less vulnerable to pain (lower pain modifier)
/datum/quirk/pain_resistance
	name = "Hypoalgesia"
	desc = "You're more resistant to pain - Your pain naturally decreases faster and you receive less overall."
	icon = FA_ICON_FIST_RAISED
	value = 8
	gain_text = "<span class='notice'>You feel duller.</span>"
	lose_text = "<span class='danger'>You feel sharper.</span>"
	medical_record_text = "Patient has Hypoalgesia, and is less susceptible to pain stimuli than most."
	mail_goodies = list(/obj/item/temperature_pack/heat)

/datum/quirk/pain_resistance/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.set_pain_mod(PAIN_MOD_QUIRK, 0.9)

/datum/quirk/pain_resistance/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.unset_pain_mod(PAIN_MOD_QUIRK)

// More vulnerabile to pain (increased pain modifier)
/datum/quirk/pain_vulnerability
	name = "Hyperalgesia"
	desc = "You're less resistant to pain - Your pain naturally decreases slower and you receive more overall."
	icon = FA_ICON_USER_INJURED
	value = -6
	gain_text = span_danger("You feel sharper.")
	lose_text = span_notice("You feel duller.")
	medical_record_text = "Patient has Hyperalgesia, and is more susceptible to pain stimuli than most."
	mail_goodies = list(/obj/item/temperature_pack/cold)

/datum/quirk/pain_vulnerability/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.set_pain_mod(PAIN_MOD_QUIRK, 1.15)

/datum/quirk/pain_vulnerability/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.unset_pain_mod(PAIN_MOD_QUIRK)


// More vulnerable to pain + get pain from more actions (Glass bones and paper skin)
/datum/quirk/allodynia
	name = "Allodynia"
	desc = "Your nerves are extremely sensitive - you may receive pain from things that wouldn't normally be painful, such as hugs."
	icon = FA_ICON_TIRED
	value = -10
	gain_text = span_danger("You feel fragile.")
	lose_text = span_notice("You feel less delicate.")
	medical_record_text = "Patient has Allodynia, and is extremely sensitive to touch, pain, and similar stimuli."
	mail_goodies = list(/obj/item/temperature_pack/cold, /obj/item/temperature_pack/heat)
	COOLDOWN_DECLARE(time_since_last_touch)

/datum/quirk/allodynia/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.set_pain_mod(PAIN_MOD_QUIRK, 1.2)
	RegisterSignals(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(cause_body_pain))

/datum/quirk/allodynia/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.unset_pain_mod(PAIN_MOD_QUIRK)
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/**
 * Causes pain to arm zones if they're targeted, and the chest zone otherwise.
 *
 * source - quirk_holder / the mob being touched
 * toucher - the mob that's interacting with source (pulls, hugs, etc)
 */
/datum/quirk/allodynia/proc/cause_body_pain(datum/source, mob/living/toucher)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, time_since_last_touch))
		return

	if(quirk_holder.stat != CONSCIOUS)
		return

	to_chat(quirk_holder, span_danger("[toucher] touches you, causing a wave of sharp pain throughout your [parse_zone(toucher.zone_selected)]!"))
	actually_hurt(toucher.zone_selected, 9)

/**
 * Actually cause the pain to the target limb, causing a visual effect, emote, and a negative moodlet.
 *
 * zone - the body zone being affected
 * amount - the amount of pain being added
 */
/datum/quirk/allodynia/proc/actually_hurt(zone, amount)
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!istype(carbon_holder))
		return

	new /obj/effect/temp_visual/annoyed(quirk_holder.loc)
	carbon_holder.cause_pain(zone, amount)
	INVOKE_ASYNC(quirk_holder, TYPE_PROC_REF(/mob/living, pain_emote))
	quirk_holder.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	COOLDOWN_START(src, time_since_last_touch, 30 SECONDS)
