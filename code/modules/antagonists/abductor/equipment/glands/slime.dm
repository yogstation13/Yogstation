/obj/item/organ/heart/gland/slime
	abductor_hint = "gastric animation galvanizer. This gland makes the abductee know slime language, as well as making him vomit loyal to him slimes upon activation."
	cooldown_low = 1 MINUTES
	cooldown_high = 2 MINUTES
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 4 MINUTES

/obj/item/organ/heart/gland/slime/Insert(mob/living/carbon/M, special = 0)
	..()
	owner.faction |= "slime"
	owner.grant_language(/datum/language/slime)

/obj/item/organ/heart/gland/slime/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.faction -= "slime"
	owner.remove_language(/datum/language/slime)

/obj/item/organ/heart/gland/slime/activate()
	to_chat(owner, span_warning("You feel nauseated!"))
	owner.vomit(20)

	var/mob/living/simple_animal/slime/Slime = new(get_turf(owner), "grey")
	Slime.Friends = list(owner)
	Slime.Leader = owner