/datum/action/cooldown/spell/pointed/mansus_ranged
	name = "Knowing Mansus Grasp"
	desc = "A powerful combat initiation spell that knocks down it's target and blurs their vision. It may have other effects if you continue your research..."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_grasp"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 20 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	cast_range = 3

	active_msg = "You prepare to grasp at someone with your mind..."

	/// How long you want to keep them down
	var/knockdown_duration = 2 SECONDS
	/// How long their eyes should be blurry for
	var/eye_blur_duration = 1 SECONDS
	/// How long their eyes should be blind for
	var/eye_blind_duration = 0

/datum/action/cooldown/spell/pointed/mansus_ranged/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !is_blind(human_target)

/datum/action/cooldown/spell/pointed/mansus_ranged/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel a light tap on your shoulder."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("Your mind cries out in pain!"))
	cast_on.Knockdown(knockdown_duration)
	cast_on.blur_eyes(eye_blur_duration)
	cast_on.blind_eyes(eye_blind_duration)
	return TRUE

/datum/action/cooldown/spell/pointed/mansus_ranged/upgraded
	name = "All Knowing Mansus Grasp"
	desc = "A powerful combat initiation spell that knocks down targets, blurs their vision, and temporarily blinds them. You have perfected this technique."
	button_icon_state = "mad_touch"

	cooldown_time = 25 SECONDS

	cast_range = 4

	eye_blur_duration = 2 SECONDS
	eye_blind_duration = 1 SECONDS
