// 7.62x38mmR (Nagant Revolver)

/obj/item/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 20

// .50AE (Desert Eagle)

/obj/item/projectile/bullet/a50AE
	name = ".50AE bullet"
	damage = 40

// .38 (Detective's Gun)

/obj/item/projectile/bullet/c38
	name = ".38 bullet"
	damage = 15 // yogs - Nerfed revolver damage
	//knockdown = 60 //yogs - commented out
	stamina = 35 // yogs
	wound_bonus = -20
	bare_wound_bonus = 10

/obj/item/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 15
	stamina = 0

/obj/item/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.IgniteMob()

/obj/item/projectile/bullet/c38/iceblox //see /obj/item/projectile/temp for the original code
	name = ".38 Iceblox bullet"
	damage = 15
	stamina = 0
	var/temperature = 100

/obj/item/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

/obj/item/projectile/bullet/c38/gutterpunch //Vomit bullets my favorite
	name = ".38 Gutterpunch bullet"
	damage = 15
	stamina = 0

/obj/item/projectile/bullet/c38/gutterpunch/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target 
		M.adjust_disgust(20)

// .32 TRAC (Caldwell Tracking Revolver)

/obj/item/projectile/bullet/tra32
	name = ".32 TRAC bullet"
	damage = 5

/obj/item/projectile/bullet/tra32/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/carbon/M = target
	var/obj/item/implant/tracking/tra32/imp
	for(var/obj/item/implant/tracking/tra32/TI in M.implants) //checks if the target already contains a tracking implant
		imp = TI
		return
	if(!imp)
		imp = new /obj/item/implant/tracking/tra32(M)
		imp.implant(M)

// .357 (Syndie Revolver)

/obj/item/projectile/bullet/a357
	name = ".357 bullet"
	damage = 40
	wound_bonus = -70

/obj/item/projectile/bullet/pellet/a357_ironfeather
	name = ".357 Ironfeather pellet"
	damage = 8.5 //Total of 51 damage assuming PBS
	wound_bonus = 7 //So it might be able to actually wound things
	bare_wound_bonus = 7
	tile_dropoff = 0.4 //Loses 0.05 damage less per tile than standard damaging pellets
	wound_falloff_tile = -1.5 //Still probably won't cause wounds at range

/obj/item/projectile/bullet/a357/nutcracker
	name = ".357 Nutcracker bullet"
	damage = 20 //Twice the damage of a breaching slug
	wound_bonus = -60

/obj/item/projectile/bullet/a357/nutcracker/on_hit(atom/target) //Basically breaching slug with 1.5x damage
	if(istype(target, /obj/structure/window) || istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		damage = 750 //One shot to break a window, two shots for a door, three if reinforced
	..()

/obj/item/projectile/bullet/a357/metalshock
	name = ".357 Metalshock bullet"
	damage = 30

/obj/item/projectile/bullet/a357/metalshock/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(10, src, 1, FALSE, FALSE, FALSE, FALSE, FALSE)) //10 extra burn damage
			C.confused += 5
			return ..()
	
	else if(isliving(target)) //So that it works on simple mobs, too
		var/mob/living/L = target
		L.electrocute_act(10, src, 1, FALSE, FALSE, FALSE, FALSE)
		return ..()

/obj/item/projectile/bullet/a357/heartpiercer
	name = ".357 Heartpiercer bullet"
	damage = 35
	armour_penetration = 35
	var/penetrations = 2 //Number of mobs the bullet will go through

/obj/item/projectile/bullet/a357/heartpiercer/on_hit(atom/target)
	. = ..()
	penetrations -= 1
	if(ismob(target) && penetrations > 0)
		return BULLET_ACT_FORCE_PIERCE

/obj/item/projectile/bullet/a357/wallstake
	name = ".357 Wallstake bullet"
	damage = 25 //Consider that they're also being thrown into the wall
	wound_bonus = -50 //Minor chance of dislocation from the bullet itself
	sharpness = SHARP_NONE //Blunt

/obj/item/projectile/bullet/a357/wallstake/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target) && ismovable(target)) //Unlike meteorslugs, these are smaller and meant to knock bodies around, not ANYTHING
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 2, 2) //Extra ten damage if they hit a wall
