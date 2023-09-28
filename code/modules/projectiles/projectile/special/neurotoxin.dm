/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	flag = BIO // why was this bullet protection

/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		nodamage = TRUE
	else if(iscarbon(target))
		var/mob/living/carbon/H = target
		H.reagents.add_reagent(/datum/reagent/toxin/staminatoxin/neurotoxin_alien, 10 * H.get_permeability())
	return ..()

/obj/item/projectile/bullet/acid
	name = "acid spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = BURN
	flag = BIO
	range = 7
	speed = 1.8 // spit is not very fast

obj/item/projectile/bullet/acid/on_hit(atom/target, blocked = FALSE)
	if(isalien(target)) // shouldn't work on xenos
		nodamage = TRUE
	else if(iscarbon(target))
		target.acid_act(acidpwr = 18, acid_volume = 25) // balanced
	else if(!isopenturf(target))
		target.acid_act(acidpwr = 50, acid_volume = 25) // does good damage to objects and structures
	return ..()
