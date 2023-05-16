/obj/effect/proc_holder/spell/aimed/animation
	name = "Animation"
	desc = "This spell fires an animation bolt at a target."
	charge_max = 60
	clothes_req = FALSE
	invocation = "ONA ANIMATUS"
	invocation_type = SPELL_INVOCATION_SAY
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/animate
	base_icon_state = "staffofanimation"
	action_icon_state = "staffofanimation"
	sound = 'sound/magic/staff_animation.ogg'
	active_msg = "You prepare to cast your animation spell!"
	deactive_msg = "You stop casting your animation spell... for now."
	active = FALSE
