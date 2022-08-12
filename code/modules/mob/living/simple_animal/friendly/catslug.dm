//No relation to slugcat

/mob/living/simple_animal/pet/catslug
	name = "catslug"
	desc = "It seems to be both a cat and a slug!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "catslug"
	icon_living = "catslug"
	icon_dead = "catslug_dead"
	gender = MALE
	emote_see = list("stares at the ceiling.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "hugs"
	response_disarm = "rudely paps"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN

	attack_vis_effect = ATTACK_EFFECT_SLASH
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "stabs"
	var/obj/item/twohanded/spear/weapon

/mob/living/simple_animal/pet/catslug/UnarmedAttack(atom/A)
	. = ..()
	if(!isitem(A))
		return
	
	if(!weapon && istype(A, /obj/item/twohanded/spear))
		visible_message(span_notice("[src] wields the [A]."), span_notice("You wield the [A]."))
		weapon = A
		weapon.forceMove(src)
		melee_damage_lower = weapon.force + weapon.force_wielded
		melee_damage_upper = weapon.force + weapon.force_wielded
		armour_penetration = weapon.armour_penetration
		melee_damage_type = weapon.damtype
		sharpness = weapon.sharpness
		attack_sound = weapon.hitsound
		update_icons()
	else if(!weapon && !istype(A, /obj/item/twohanded/spear))
		to_chat(src, span_warning("You do not know how to wield the [A]!"))

/mob/living/simple_animal/pet/catslug/RangedAttack(atom/A, params)
	. = ..()
	if(!weapon)
		return
	visible_message(span_warning("[src] throws the [weapon] at [A]!"), span_warning("You throw the [weapon] at [A]!"))
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	armour_penetration = initial(armour_penetration)
	melee_damage_type = initial(melee_damage_type)
	sharpness = initial(sharpness)
	attack_sound = initial(attack_sound)
	weapon.forceMove(get_turf(src))
	weapon.throw_at(A, weapon.throw_range, weapon.throw_speed, src)
	weapon = null
	update_icons()

/mob/living/simple_animal/pet/catslug/update_icons()
	. = ..()
	if(stat == DEAD || resting)
		return
	icon_state = weapon ? initial(icon_state) + "_spear" : initial(icon_state)

/mob/living/simple_animal/pet/catslug/death(gibbed)
	. = ..()
	if(weapon)
		weapon.forceMove(get_turf(src))
		weapon = null
	update_icons()
