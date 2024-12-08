/obj/projectile/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'
	speed = 3

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

/obj/projectile/reagent/meduracha_spit
	name = "Glob of toxic goo"
	icon_state = "meduracha_spit"
	transfer_methods = TOUCH
	reagents_list = list(/datum/reagent/toxic_metabolites = 10)
