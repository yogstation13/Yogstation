/datum/action/cooldown/spell/pointed/projectile/lightningbolt/eldritchbolt
	name = "Eldritch Bolt"
	desc = "Fire a bolt of Eldritch energy that will strike the target, dealing moderate burn damage."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "lightning"
	active_overlay_icon_state = "bg_spell_border_active_yellow"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/magic/lightningbolt.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "EL'RICH BL'AS'T"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	base_icon_state = "lightning"
	active_msg = "You energize your hands with raw power!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/projectile/magic/aoe/lightning/eldritch
	
	bolt_range = 7
	bolt_power = 1000
