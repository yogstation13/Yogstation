/datum/mutation/human/shock/far
	name = "Extended Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others at range."
	instability = 30
	text_gain_indication = span_notice("You feel unlimited power flow through your hands.")
	power_path = /datum/action/cooldown/spell/touch/shock/far
	conflicts = list(/datum/mutation/human/shock, /datum/mutation/human/insulated)

/datum/action/cooldown/spell/touch/shock/far
	name = "Extended Shock Touch"
	hand_path = /obj/item/melee/touch_attack/shock/far

/datum/action/cooldown/spell/touch/shock/far/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	. = ..()
	caster.Beam(victim, icon_state="red_lightning", time = 1.5 SECONDS)

/obj/item/melee/touch_attack/shock/far
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 5, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
