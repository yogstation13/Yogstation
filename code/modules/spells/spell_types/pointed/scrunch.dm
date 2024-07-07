/datum/action/cooldown/spell/pointed/scrunch
	name = "Scrunch"
	desc = "This spell scrunches a target."
	button_icon = 'icons/mob/human.dmi'
	button_icon_state = "human_basic"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 4 SECONDS // 4 second reduction per rank

	sound = 'sound/effects/gravhit.ogg'
	invocation = "SCRUNCH!" //no modification, just scrunch
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to scrunch!"
	deactive_msg = "You decide to not scrunch."
	cast_range = 8

/datum/action/cooldown/spell/pointed/scrunch/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/scrunch/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel... not scrunched."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	if(spell_level == spell_max_level)
		cast_on.AddElement(/datum/element/squish)
	cast_on.AddElement(/datum/element/squish)
	cast_on.apply_damage(60, BRUTE, wound_bonus = 50, bare_wound_bonus = 50) //brute wounds all over the body
	cast_on.emote("scream")
	playsound(cast_on, 'sound/effects/blobattack.ogg', 40, TRUE)
	playsound(cast_on, 'sound/effects/splat.ogg', 50, TRUE)
	return TRUE
