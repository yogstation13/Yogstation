/datum/action/changeling/lesserform
	/// Whether to drop our stuff when we finish turning into a monkey.
	var/drop_stuff = FALSE

/datum/action/changeling/lesserform/Trigger(trigger_flags)
	drop_stuff = (trigger_flags & TRIGGER_SECONDARY_ACTION)
	return ..()

/datum/action/changeling/lesserform/become_monkey(mob/living/carbon/human/user)
	if(drop_stuff)
		RegisterSignal(user, COMSIG_HUMAN_MONKEYIZE, PROC_REF(on_monkeyize))
	return ..()

/datum/action/changeling/lesserform/proc/on_monkeyize(mob/living/carbon/human/user)
	UnregisterSignal(user, COMSIG_HUMAN_MONKEYIZE)
	user.unequip_everything()
