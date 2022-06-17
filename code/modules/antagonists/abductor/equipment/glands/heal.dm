/obj/item/organ/heart/gland/heals
	abductor_hint = "coherency harmonizer. When activates, heals the abductee some damage."
	cooldown_low = 20 SECONDS
	cooldown_high = 40 SECONDS
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 5 MINUTES

/obj/item/organ/heart/gland/heals/activate()
	to_chat(owner, span_notice("You feel curiously revitalized."))
	owner.adjustToxLoss(-20, FALSE, TRUE)
	owner.heal_bodypart_damage(20, 20, 0, TRUE)
	owner.adjustOxyLoss(-20)