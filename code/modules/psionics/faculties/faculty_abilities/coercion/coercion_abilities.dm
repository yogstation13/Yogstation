///operant level spells
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

	antimagic_flags = MAGIC_RESISTANCE_MIND

	active_msg = "You prepare to disarm a target..."

/datum/action/cooldown/spell/pointed/disarm/master 

	desc = "This spell will allow you to disarm someone within 3 tile."
	cooldown_time = 25 SECONDS
	cast_range = 3

/datum/action/cooldown/spell/pointed/disarm/grandmaster

	desc = "This spell will allow you to disarm someone within 5 tile."
	cooldown_time = 15 SECONDS
	cast_range = 5

/datum/action/cooldown/spell/pointed/disarm/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

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

/datum/action/cooldown/spell/pointed/dis_arm

	name = "Dis-arm"
	desc = "This spell will allow you to dis-arm someone within 10 tile."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/effects/psi/power_used.ogg'
	school = SCHOOL_PSIONIC
	cooldown_time = 60 SECONDS
	cast_range = 10

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	antimagic_flags = MAGIC_RESISTANCE_MIND

	active_msg = "You prepare to disarm a target..."

/datum/action/cooldown/spell/pointed/dis_arm/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

/datum/action/cooldown/spell/pointed/dis_arm/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel like someone just tried to shake your hand..."))
		to_chat(owner, span_warning("The psionic had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("You feel an invisible force rip off your arms!"))
	if(iscarbon(cast_on))
		var/mob/living/carbon/CM = cast_on
		for(var/obj/item/bodypart/bodypart in CM.bodyparts)
			if(!(bodypart.body_part & (HEAD|CHEST|LEGS)))
				if(bodypart.dismemberable)
					bodypart.dismember()
	return TRUE

/datum/action/cooldown/spell/list_target/telepathy/psionic
	
	name = "Psionic Telepathy"
	desc = "Telepathically transmits a message to the target."
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"

	cooldown_time = 5 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	antimagic_flags = MAGIC_RESISTANCE_MIND

	choose_target_message = "Choose a target to whisper to."

///master level spells

/datum/action/cooldown/spell/pointed/psychic_scream
	name = "Psychic Scream"
	desc = "This spell sends a blast of psychic energy to another person, heavily damaging their mental stamina."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/effects/psi/power_used.ogg'
	school = SCHOOL_PSIONIC
	cooldown_time = 30 SECONDS
	cast_range = 3

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	antimagic_flags = MAGIC_RESISTANCE_MIND

	active_msg = "You prepare to send a blast of psionic energy at a target..."


/datum/action/cooldown/spell/pointed/psychic_scream/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !is_blind(human_target)

/datum/action/cooldown/spell/pointed/psychic_scream/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel like someone turned their speakers on too loud..."))
		to_chat(owner, span_warning("The psionic had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("You feel an invisible force punch your brain!"))
	cast_on.adjustStaminaLoss(25)
	return TRUE
