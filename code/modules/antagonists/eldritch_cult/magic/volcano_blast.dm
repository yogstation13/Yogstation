/datum/action/cooldown/spell/pointed/projectile/fireball/eldritch
	name = "Volcano Blast"
	desc = "Fire a ball of raw volcanic magma at a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	sound = 'sound/magic/fireball.ogg'

	active_msg = "You prepare to cast your fireball spell!"
	deactive_msg = "You extinguish your fireball... for now."
	cast_range = 8
	projectile_type = /obj/projectile/magic/fireball/eldritch

	school = SCHOOL_FORBIDDEN
	cooldown_time = 25 SECONDS

	invocation = "FIR'AGA!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
