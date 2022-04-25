/obj/effect/proc_holder/zombie/adrenaline
	name = "Adrenaline Boost"
	desc = "Makes you able to sprint for a second or two!"
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "adrenaline"
	cooldown_time = 3 MINUTES
	var/reagent_amount = 3


/obj/effect/proc_holder/zombie/adrenaline/proc/add_reagent(mob/living/carbon/user)
	user.SetSleeping(0)
	user.SetUnconscious(0)
	user.SetStun(0)
	user.SetKnockdown(0)
	user.SetImmobilized(0)
	user.SetParalyzed(0)
	user.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, reagent_amount)
	user.adjustStaminaLoss(-75)
	return TRUE



/obj/effect/proc_holder/zombie/adrenaline/fire(mob/living/carbon/user)
	if(user.incapacitated())
		return FALSE

	if(add_reagent(user))
		return ..()