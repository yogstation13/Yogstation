/datum/action/cooldown/spell/pointed/projectile/animation
	name = "Animation"
	desc = "This spell fires an animation bolt at a target."
	button_icon = 'icons/obj/guns/magic.dmi'
	button_icon_state = "staffofanimation"

	invocation = "ONA ANIMATUS"
	invocation_type = INVOCATION_SHOUT

	base_icon_state = "staffofanimation"
	sound = 'sound/magic/staff_animation.ogg'
	cast_range = 20
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS
	projectile_type = /obj/projectile/magic/animate
	active_msg = "You prepare to cast your animation spell!"
	deactive_msg = "You stop casting your animation spell... for now."
	spell_requirements = NONE
