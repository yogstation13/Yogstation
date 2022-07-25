/datum/mutation/human/shock/far
	name = "Extended Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others at range."
	instability = 30
	text_gain_indication = "<span class='notice'>You feel unlimited power flow through your hands.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock/far
	conflicts = list(/datum/mutation/human/shock, /datum/mutation/human/insulated)

/obj/effect/proc_holder/spell/targeted/touch/shock/far
	name = "Extended Shock Touch"
	hand_path = /obj/item/melee/touch_attack/shock/far

/obj/item/melee/touch_attack/shock/far
	far = TRUE
