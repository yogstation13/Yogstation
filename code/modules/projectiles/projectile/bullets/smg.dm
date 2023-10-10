// .45 (M1911 & Surplus Carbine & C-20r SMG)

/obj/projectile/bullet/c45
	name = ".45 ACP bullet"
	damage = 30
	wound_bonus = -10

/obj/projectile/bullet/c45/ap
	name = ".45 armor-piercing bullet"
	damage = 27
	armour_penetration = 40

/obj/projectile/bullet/c45/hp
	name = ".45 hollow-point bullet"
	damage = 45
	armour_penetration = -45
	sharpness = SHARP_EDGED
	wound_bonus = -5 //Basically L6 HP treatment on these values because it's, well, nukies
	bare_wound_bonus = 5

/obj/projectile/bullet/c45/venom
	name = ".45 venom bullet"
	damage = 20

/obj/projectile/bullet/c45/venom/on_hit(atom/target, blocked)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/victim = target
		victim.reagents.add_reagent(/datum/reagent/toxin/venom, 4)
	return ..()

// 4.6x30mm (WT-550 Autocarbine)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 15
	wound_bonus = -5
	bare_wound_bonus = 5

/obj/projectile/bullet/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 12
	armour_penetration = 40

/obj/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 9
	fire_stacks = 1

/obj/projectile/bullet/c46x30mm/rubber
	name = "4.6x30mm rubber bullet"
	damage = 5
	stamina = 22
	sharpness = SHARP_NONE

/obj/projectile/bullet/c46x30mm/snakebite
	name = "4.6x30mm snakebite bullet" 
	damage = 6

/obj/projectile/bullet/c46x30mm/snakebite/on_hit(atom/target, blocked)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/victim = target // Both injects toxin, and applies 6 tox damage on hit.
		victim.reagents.add_reagent(/datum/reagent/toxin, 4)
		victim.adjustToxLoss(6)

	return ..()
/obj/projectile/bullet/c46x30mm/kraken
	name = "4.6x30mm kraken bullet"
	damage = 22
	armour_penetration = -60
	wound_bonus = -30 // we arent dismembering people here
	bare_wound_bonus = 3

/obj/projectile/bullet/c46x30mm/airburst_pellet
	name = "4.6x30mm airburst pellet"
	damage = 10

/obj/projectile/bullet/c46x30mm/airburst
	name = "4.6x30mm airburst bullet"
	damage = 2 // its just a casing
	range = 5

/obj/projectile/bullet/c46x30mm/airburst/on_range()
	var/obj/item/ammo_casing/c46x30mm/airburst_pellet/P = new(get_turf(src))
	var/mob/living/L = new (get_turf(src))//it's jank, but casings can only be shot via a mob's location
	P.fire_casing(get_edge_target_turf(firer, get_dir(firer, original)), L)
	playsound(L, 'sound/weapons/shotgunshot.ogg', 40, 0, 2)
	qdel(L)
	..()
