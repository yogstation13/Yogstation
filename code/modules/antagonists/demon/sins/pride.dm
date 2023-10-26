/datum/action/cooldown/spell/conjure/summon_mirror
	name = "Summon Mirror"
	desc = "Summon forth a temporary mirror of sin that will allow you and others to change anything they want about themselves."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "magic_mirror"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	invocation = "Aren't I so amazing?"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cooldown_time = 30 SECONDS
	summon_lifespan = 1 MINUTES
	summon_radius = 0
	summon_type = list(/obj/structure/mirror/magic/lesser)

/datum/action/cooldown/spell/touch/mend
	name = "Mend"
	desc = "Engulfs your arm in a healing powers. Striking someone with it will heal them a moderate amount. Can't target yourself."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "fleshmend"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	school = SCHOOL_EVOCATION
	invocation = "Taste of Sin"
	invocation_type = INVOCATION_WHISPER

	cooldown_time = 12 SECONDS
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/mend

/obj/item/melee/touch_attack/mend
	name = "Mending Hand"
	desc = "A seemingly pleasant mass of mending energy, ready to heal."
	icon_state = "flagellation"
	item_state = "hivemind"

/datum/action/cooldown/spell/touch/mend/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(victim.can_block_magic())
		to_chat(caster, span_warning("[victim] resists your pride!"))
		to_chat(victim, span_warning("A deceptive feeling of pleasre dances around your mind before being suddenly dispelled."))
		..()
		return TRUE
	playsound(caster, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.adjustBruteLoss(-20)
	victim.adjustFireLoss(-20)
	victim.visible_message(span_bold("[victim] appears to flash colors of red, before seemingly appearing healthier!"))
	to_chat(victim, span_warning("You feel a sinister feeling of recovery."))
	return TRUE
