/obj/projectile/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'

/obj/projectile/jungle/heal_orb
	name = "Orb of healing"
	icon_state = "heal_orb"
	damage = -10
	homing = TRUE

/obj/projectile/jungle/damage_orb
	name = "Orb of vengeance"
	icon_state = "damage_orb"
	damage = 20
	armor_flag = MELEE

/obj/projectile/jungle/damage_orb/on_hit(atom/target, blocked)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad) || istype(target, /mob/living/simple_animal/hostile/asteroid/yog_jungle/corrupted_dryad))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/projectile/jungle/meduracha_spit
	name = "Glob of toxic goo"
	icon_state = "meduracha_spit"
	damage = 20
	damage_type = TOX
	armor_flag = BIO

/obj/projectile/jungle/meduracha_spit/on_hit(atom/target, blocked)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target 
	var/chance = 100 - H.getarmor(null,BIO)
	if(prob(max(10,chance * 0.75))) // higher chance than toxic water
		H.reagents.add_reagent(/datum/reagent/toxic_metabolites,15)
