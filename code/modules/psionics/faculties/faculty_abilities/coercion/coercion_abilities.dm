/datum/action/cooldown/spell/pointed/disarm
	name = "Disarm"
	desc = "This spell will allow you to disarm someone within 1 tile."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/effects/psi/power_used.ogg'
	school = SCHOOL_PSIONIC
	cooldown_time = 30 SECONDS
	cast_range = 1

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to disarm a target..."


/datum/action/cooldown/spell/pointed/disarm/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !is_blind(human_target)

/datum/action/cooldown/spell/pointed/disarm/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel like someone just tried to shake your hand..."))
		to_chat(owner, span_warning("The psionic had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("You feel an invisible force disarm you!"))
	for(var/V in cast_on.held_items)
		var/obj/item/I = V
		if(istype(I))
			cast_on.dropItemToGround(I)
	return TRUE
