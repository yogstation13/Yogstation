/datum/mutation/human/juggernaut
	name = "Juggernaut"
	desc = "Allows the subject to charge through walls unstoppably for a short period of time."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = span_notice("You feel <i>unstoppable</i>.")
	instability = 20
	difficulty = 20
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/targeted/juggernaut


/obj/effect/proc_holder/spell/targeted/juggernaut
	name = "Juggernaut"
	desc = "Become unstoppable."
	charge_max = 150
	cooldown_min = 150
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"

/obj/effect/proc_holder/spell/juggernaut/cast(list/targets,mob/user = usr)
	user.move_force = MOVE_FORCE_UNSTOPPABLE
	user.move_resist = MOVE_FORCE_UNSTOPPABLE
	