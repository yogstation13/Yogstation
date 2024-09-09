/mob/living/basic/mouse/plague
	name = "plague rat"

	icon = 'monkestation/code/modules/virology/icons/animal.dmi'
	icon_state = "mouse_plague"
	icon_living = "mouse_plague"
	icon_dead = "mouse_plague_dead"

	maxHealth = 30
	health = 30

	melee_damage_lower = 4
	melee_damage_upper = 7
	chooses_bodycolor = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB|PASSDOORS

/mob/living/basic/mouse/plague/Initialize(mapload, tame, new_body_color)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/plague_rat)


/mob/living/basic/mouse/plague/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if (ishuman(user)||ismonkey(user))
		var/block = user.check_contact_sterility(HANDS)
		var/bleeding = user.check_bodypart_bleeding(HANDS)
		share_contact_diseases(user ,block,bleeding)

/mob/living/basic/mouse/plague/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (ishuman(target)||ismonkey(target))
		var/mob/living/user = target
		var/block = user.check_contact_sterility(HANDS)
		var/bleeding = user.check_bodypart_bleeding(HANDS)
		share_contact_diseases(target ,block,bleeding)

/mob/living/basic/mouse/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	attacking_item.disease_contact(src, BODY_ZONE_CHEST)

/datum/movespeed_modifier/plague_rat
	multiplicative_slowdown = 0.5
