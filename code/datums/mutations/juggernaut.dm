/datum/mutation/human/juggernaut
	name = "Juggernaut"
	desc = "Allows the subject to charge through walls unstoppably for a short period of time."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = span_notice("You feel <i>unstoppable</i>.")
	instability = 80
	difficulty = 20
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/targeted/juggernaut


/obj/effect/proc_holder/spell/targeted/juggernaut
	name = "Juggernaut"
	desc = "Become unstoppable."
	charge_max = 120 SECONDS
	cooldown_min = 120 SECONDS
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = -1
	include_user = TRUE
	action_icon_state = "juggernaut"
	action_icon = 'icons/mob/actions/actions_genetic.dmi'

/obj/effect/proc_holder/spell/targeted/juggernaut/proc/end_juggernaut(mob/user)
	user.move_force = initial(user.move_force)
	user.move_resist = initial(user.move_resist)
	//user.remove_movespeed_modifier("juggernaut")
	REMOVE_TRAIT(user, TRAIT_STUNIMMUNE, "juggernaut")

/obj/effect/proc_holder/spell/targeted/juggernaut/cast(list/targets,mob/user = usr)
	user.move_force = MOVE_FORCE_UNSTOPPABLE
	user.move_resist = MOVE_FORCE_UNSTOPPABLE
	//user.add_movespeed_modifier("juggernaut", update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))
	ADD_TRAIT(user, TRAIT_STUNIMMUNE, "juggernaut")
	addtimer(CALLBACK(src, .proc/end_juggernaut, user), 1.5 SECONDS)
	user.say(pick("DON'T YOU KNOW WHO I AM??", "I'M THE JUGGERNAUT, BITCH!", "OUT OF THE WAY!!!"))
