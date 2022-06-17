/obj/item/organ/heart/gland/ventcrawling
	abductor_hint = "pliant cartilage enabler. Upon activation, it makes the abductee capable of ventcrawling."
	cooldown_low = 3 MINUTES
	cooldown_high = 4 MINUTES
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 3 MINUTES
	var/previous_ventcrawling

/obj/item/organ/heart/gland/ventcrawling/activate()
	to_chat(owner, span_notice("You feel very stretchy."))
	previous_ventcrawling = owner.ventcrawler
	owner.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/organ/heart/gland/ventcrawling/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.ventcrawler = previous_ventcrawling
	previous_ventcrawling = VENTCRAWLER_NONE