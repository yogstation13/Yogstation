// 7.62x38mmR (Nagant Revolver)

/obj/item/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 20
	wound_bonus = -5
	wound_falloff_tile = -2.5

// .50AE (Desert Eagle)

/obj/item/projectile/bullet/a50AE
	name = ".50AE bullet"
	damage = 40
	wound_bonus = -35
	wound_falloff_tile = -2.5

// .38 (Detective's Gun)

/obj/item/projectile/bullet/c38
	name = ".38 bullet"
	damage = 25 //High damaging but...
	armour_penetration = -40 //Almost doubles the armor of any bullet armor it hits
	wound_bonus = -30
	wound_falloff_tile = -2.5
	bare_wound_bonus = 15

/obj/item/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 20

/obj/item/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.IgniteMob()
	return ..()

/obj/item/projectile/bullet/c38/iceblox //see /obj/item/projectile/temp for the original code
	name = ".38 Iceblox bullet"
	damage = 20
	var/temperature = 100

/obj/item/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

/obj/item/projectile/bullet/c38/gutterpunch //Vomit bullets my favorite
	name = ".38 Gutterpunch bullet"
	damage = 20

/obj/item/projectile/bullet/c38/gutterpunch/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/M = target 
		M.adjust_disgust(20)
	return ..()

// .32 TRAC (Caldwell Tracking Revolver)

/obj/item/projectile/bullet/tra32
	name = ".32 TRAC bullet"
	damage = 5

/obj/item/projectile/bullet/tra32/on_hit(atom/target, blocked = FALSE)
	if(blocked != 100)
		var/mob/living/carbon/M = target
		var/obj/item/implant/tracking/tra32/imp
		for(var/obj/item/implant/tracking/tra32/TI in M.implants) //checks if the target already contains a tracking implant
			imp = TI
			return
		if(!imp)
			imp = new /obj/item/implant/tracking/tra32(M)
			imp.implant(M)
	return ..()

// .357 (Syndie Revolver)

/obj/item/projectile/bullet/a357
	name = ".357 bullet"
	damage = 40
	wound_bonus = -45
	wound_falloff_tile = -2.5

/obj/item/projectile/bullet/pellet/a357_ironfeather
	name = ".357 Ironfeather pellet"
	damage = 8 //Total of 48 damage assuming PBS
	armour_penetration = 10 //In between normal pellets and flechette for AP
	wound_bonus = 7 //So it might be able to actually wound things
	bare_wound_bonus = 7
	tile_dropoff = 0.35 //Loses 0.05 damage less per tile than standard damaging pellets
	wound_falloff_tile = -1.5 //Still probably won't cause wounds at range

/obj/item/projectile/bullet/a357/nutcracker
	name = ".357 Nutcracker bullet"
	damage = 30

/obj/item/projectile/bullet/a357/nutcracker/on_hit(atom/target) //Basically breaching slug with 1.5x damage
	if(istype(target, /obj/structure/window) || istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		damage = 750 //One shot to break a window, two shots for a door, three if reinforced
	..()

/obj/item/projectile/bullet/a357/metalshock
	name = ".357 Metalshock bullet"
	damage = 15
	wound_bonus = -5

/obj/item/projectile/bullet/a357/metalshock/on_hit(atom/target, blocked = FALSE)
	..()
	tesla_zap(target, 4, 20000, TESLA_MOB_DAMAGE) //Should do around 33 burn to the first target hit, assume no siemens coefficient (black gloves have 0.5)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/a357/heartpiercer
	name = ".357 Heartpiercer bullet"
	damage = 35
	armour_penetration = 30
	penetrating = TRUE //Goes through a single mob before ending on the next target
	penetrations = 1

/obj/item/projectile/bullet/a357/wallstake
	name = ".357 Wallstake bullet"
	damage = 36 //Almost entirely a meme round at this point. 36 damage barely four-shots standard armor
	wound_bonus = -35
	sharpness = SHARP_NONE //Blunt

/obj/item/projectile/bullet/a357/wallstake/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target)) //Unlike meteorslugs, these are smaller and meant to knock bodies around, not ANYTHING
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 2, 2) //Extra ten damage if they hit a wall, resolves against melee armor
