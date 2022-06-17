/obj/item/organ/heart/gland/trauma
	abductor_hint = "white matter randomiser. Upon activation, it grants the abductee a random brain trauma."
	cooldown_low = 80 SECONDS
	cooldown_high = 2 MINUTES
	uses = 5
	icon_state = "emp"
	mind_control_uses = 3
	mind_control_duration = 3 MINUTES

/obj/item/organ/heart/gland/trauma/activate()
	to_chat(owner, span_warning("You feel a spike of pain in your head."))
	if(prob(33))
		owner.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))
	else
		if(prob(20))
			owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))
		else
			owner.gain_trauma_type(BRAIN_TRAUMA_MILD, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))