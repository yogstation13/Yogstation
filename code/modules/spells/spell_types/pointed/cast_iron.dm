/datum/action/cooldown/spell/pointed/projectile/cast_iron
	name = "Cast Iron"
	desc = "This spell fires a cast iron bolt."
	button_icon = 'yogstation/icons/obj/pan.dmi'
	button_icon_state = "frying_pan"

	school = SCHOOL_EVOCATION
	cooldown_time = 4 SECONDS
	cooldown_reduction_per_rank = 0.6 SECONDS

	invocation = "CL'AHNG!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast a cast iron!"
	deactive_msg = "You decide to give these peasants a break."
	cast_range = 8
	projectile_type = /obj/projectile/magic/cast_iron

/datum/action/cooldown/spell/pointed/projectile/cast_iron/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(spell_level == spell_max_level)
		to_fire.color = "#ffd700"

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
