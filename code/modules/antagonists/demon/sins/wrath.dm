/datum/action/cooldown/spell/shapeshift/demon/wrath //emergency get out of jail card, but better.
	name = "Wrath Demon Form"
	shapeshift_type = /mob/living/simple_animal/lesserdemon/wrath

/mob/living/simple_animal/lesserdemon/wrath //slightly more damage.
	name = "wrathful demon"
	real_name = "wrathful demon"
	melee_damage_lower = 24
	melee_damage_upper = 24
	icon_state = "lesserdaemon_wrath"
	icon_living = "lesserdaemon_wrath"

#define WRATHFUL_FIRE_AMOUNT 5

/datum/action/cooldown/spell/pointed/ignite
	name = "Ignite"
	desc = "This ranged spell sets a person on fire."
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	base_icon_state = "sacredflame"
	active_msg = "You prepare to ignite a target..."
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_TRANSMUTATION
	invocation = "BURN IN HELL!!"
	invocation_type = INVOCATION_SHOUT

	sound = 'sound/magic/fireball.ogg'
	cooldown_time = 1 MINUTES
	active_msg = span_notice("You ignite in a flash of hellfire!")
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/ignite/InterceptClickOn(mob/living/demon, params, atom/victim)
	. = ..()
	if(!.)
		return FALSE
	
	if(!isliving(victim))
		return FALSE
	var/mob/living/target = victim
	target.ignite_mob()
	target.adjust_fire_stacks(WRATHFUL_FIRE_AMOUNT)

	return TRUE

#undef WRATHFUL_FIRE_AMOUNT

