/datum/action/cooldown/spell/touch/vort_heal
	name = "Mend"
	desc = "Use the vortessence and ready your hand to be able to heal someone other than yourself."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "fleshmend"

	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation_type = INVOCATION_NONE

	hand_path = /obj/item/melee/touch_attack/vort_heal

/obj/item/melee/touch_attack/vort_heal
	name = "Mending Hand"
	desc = "A healing ball of vortal energy."
	icon_state = "mansus"
	item_state = "vort"

/datum/action/cooldown/spell/touch/vort_heal/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	playsound(caster, 'sound/weapons/halflife/attack_shoot.ogg', 50, TRUE)
	victim.adjustBruteLoss(-20)
	victim.adjustFireLoss(-20)
	victim.visible_message(span_bold("[victim] appears to flash colors of green, before seemingly appearing healthier!"))
	to_chat(victim, span_warning("You feel soothed."))
	return TRUE
