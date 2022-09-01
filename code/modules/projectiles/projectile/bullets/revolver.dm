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
