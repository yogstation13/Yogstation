/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX

/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		nodamage = TRUE
	else if(iscarbon(target))
		var/mob/living/carbon/H = target
		H.reagents.add_reagent(/datum/reagent/toxin/staminatoxin/neurotoxin_alien, 10 * H.get_permeability_protection())
	return ..()
