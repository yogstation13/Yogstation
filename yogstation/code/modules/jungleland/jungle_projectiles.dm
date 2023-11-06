/obj/projectile/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'

/obj/projectile/jungle/heal_orb
	name = "Orb of healing"
	icon_state = "heal_orb"
	damage = -10
	speed = 2
	homing = TRUE

/obj/projectile/jungle/damage_orb
	name = "Orb of vengeance"
	icon_state = "damage_orb"
	damage = 20
	speed = 1

/obj/projectile/jungle/meduracha_spit
	name = "Glob of toxic goo"
	icon_state = "meduracha_spit"
	damage = 20
	speed = 3
	damage_type = TOX

/obj/projectile/jungle/meduracha_spit/on_hit(atom/target, blocked)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target 
	var/chance = 100 - H.getarmor(null,BIO)
	if(prob(max(10,chance * 0.75))) // higher chance than toxic water
		H.reagents.add_reagent(/datum/reagent/toxic_metabolities,15)
