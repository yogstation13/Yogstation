/datum/action/cooldown/spell/pointed/projectile/cast_iron
	name = "Cast iron bolt"
	desc = "This spell fires a cast iron bolt."
	button_icon = 'yogstation/icons/obj/pan.dmi'
	button_icon_state = "frying_pan"

	school = SCHOOL_EVOCATION
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS // 1 second reduction per rank

	invocation = "CL'AHNG!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast a cast iron!"
	deactive_msg = "You decide to give these peasants a break."
	cast_range = 8
	projectile_type = /obj/projectile/magic/cast_iron

/obj/projectile/magic/cast_iron
	name = "cast iron"
	icon = 'yogstation/icons/obj/pan.dmi'
	icon_state = "frying_pan"
	damage = 20
	damage_type = BRUTE
	nodamage = FALSE
	hitsound = 'yogstation/sound/weapons/pan.ogg'
	stutter = 4 SECONDS

/obj/projectile/magic/cast_iron/vol_by_damage()
	return 100 // BONK!
	
/obj/projectile/magic/cast_iron/on_hit(atom/target, blocked)
	. = ..()
	if(. && isliving(target))
		var/mob/living/victim = target
		victim.adjust_confusion(4 SECONDS)
