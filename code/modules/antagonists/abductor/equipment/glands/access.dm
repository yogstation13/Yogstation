/obj/item/organ/heart/gland/access
	abductor_hint = "anagraphic electro-scrambler. After it activates, grants the abductee intrinsic all access."
	cooldown_low = 1 MINUTES
	cooldown_high = 2 MINUTES
	uses = 1
	icon_state = "mindshock"
	mind_control_uses = 3
	mind_control_duration = 90 SECONDS

/obj/item/organ/heart/gland/access/activate()
	to_chat(owner, span_notice("You feel like a VIP for some reason."))
	RegisterSignal(owner, COMSIG_MOB_ALLOWED, .proc/free_access)

/obj/item/organ/heart/gland/access/proc/free_access(datum/source, obj/O)
	return TRUE

/obj/item/organ/heart/gland/access/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(owner, COMSIG_MOB_ALLOWED)
	..()