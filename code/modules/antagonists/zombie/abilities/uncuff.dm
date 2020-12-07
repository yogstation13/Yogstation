/obj/effect/proc_holder/zombie/uncuff
	name = "Break Free"
	desc = "Breaks you free from handcuffs."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "biodegrade"
	cooldown_time = 60 SECONDS

/obj/effect/proc_holder/zombie/uncuff/fire(mob/living/carbon/user)

	if(uncuff(user))
		return ..()

/obj/effect/proc_holder/zombie/uncuff/proc/uncuff(mob/living/carbon/user)
	user.uncuff()