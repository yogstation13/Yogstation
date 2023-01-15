/obj/item/projectile/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'

/obj/item/projectile/jungle/heal_orb
	name = "Orb of healing"
	icon_state = "heal_orb"
	damage = -10
	speed = 2
	homing = TRUE

/obj/item/projectile/jungle/damage_orb
	name = "Orb of vengeance"
	icon_state = "damage_orb"
	damage = 20
	speed = 1

/obj/item/projectile/jungle/meduracha_spit
	name = "Glob of toxic goo"
	icon_state = "meduracha_spit"
	damage = 20
	speed = 3
	damage_type = TOX

/obj/item/projectile/jungle/meduracha_spit/on_hit(atom/target, blocked)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target 
	var/chance = ((H.wear_suit ? 100 - H.wear_suit.armor.bio : 100)  +  (H.head ? 100 - H.head.armor.bio : 100) )/2
	if(prob(chance * 0.5))
		H.apply_status_effect(/datum/status_effect/toxic_buildup)
