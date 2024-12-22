/datum/status_effect/hippocratic_oath/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_PERFECT_SURGEON, HIPPOCRATIC_OATH_TRAIT)

/datum/status_effect/hippocratic_oath/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PERFECT_SURGEON, HIPPOCRATIC_OATH_TRAIT)

/datum/movespeed_modifier/mayhem
	multiplicative_slowdown = -0.6

/atom/movable/screen/alert/status_effect/mayhem
	name = "<span class='cult'>Mayhem</span>"
	desc = "<span class='bolddanger'>RIP AND TEAR!!</span>"
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw_on"
	alerttooltipstyle = "cult"

/datum/status_effect/mayhem
	show_duration = TRUE
	tick_interval = STATUS_EFFECT_NO_TICK // Just pass me the SSfastprocess ticks please.

	alert_type = /atom/movable/screen/alert/status_effect/mayhem

	var/list/traits = list(
		TRAIT_NO_SPRINT, // It makes you go really fast already, also makes you focus more on hitting people.
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_SLEEPIMMUNE,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_NOCRITOVERLAY,
	)

/datum/status_effect/mayhem/on_remove()
	. = ..()

	owner.remove_movespeed_modifier(/datum/movespeed_modifier/mayhem)
	owner.remove_client_colour(/datum/client_colour/mayhem)

	owner.remove_traits(traits, CHAINSAW_FRENZY_TRAIT)

/datum/status_effect/mayhem/on_apply()
	. = ..()

	owner.SetAllImmobility(0)
	owner.set_resting(FALSE, silent = TRUE, instant = TRUE)

	owner.add_traits(traits, CHAINSAW_FRENZY_TRAIT)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/mayhem)

	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, add_client_colour), /datum/client_colour/mayhem), 2.1 SECONDS) // So that it lines up with the bloodlust colour perfectly.

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/user = owner

	if(user.handcuffed)
		shatter(user, ITEM_SLOT_HANDCUFFED)

	if(user.legcuffed)
		shatter(user, ITEM_SLOT_LEGCUFFED)

	if(user.wear_suit?.breakouttime)
		shatter(user, ITEM_SLOT_OCLOTHING)

/datum/status_effect/mayhem/proc/shatter(mob/living/carbon/human/user, slot)
	var/obj/item/restraints = user.get_item_by_slot(slot)

	owner.visible_message(
		message = span_warning("[user] shatters [user.p_their()] [restraints.name]!"),
		self_message = span_notice("You shatter your [restraints.name]!"),
		blind_message = span_hear("You hear something shatter!")
	)

	qdel(restraints)

/datum/status_effect/mayhem/tick(seconds_per_tick, times_fired) // Replacement for the Adminordazine it used before.
	. = ..()

	var/healing_amount = 5 * seconds_per_tick

	owner.heal_overall_damage(healing_amount, healing_amount, STAMINA_MAX / 10 * seconds_per_tick, updating_health = FALSE)
	owner.adjustToxLoss(-healing_amount, updating_health = FALSE)
	owner.adjustOxyLoss(-healing_amount, updating_health = FALSE)

	owner.blood_volume = min(owner.blood_volume + BLOOD_VOLUME_NORMAL / 10 * seconds_per_tick, BLOOD_VOLUME_NORMAL)

	if(iscarbon(owner))
		var/mob/living/carbon/user = owner
		if(length(user.all_wounds) && SPT_PROB(20, seconds_per_tick))
			qdel(pick(user.all_wounds))
			to_chat(user, span_green("One of your ailments leaves you.")) // Static message so it gets collapsed in chat.

	owner.updatehealth() // Because we healed, what, 5 different damage types on SSfastprocess, this is way more efficient.
