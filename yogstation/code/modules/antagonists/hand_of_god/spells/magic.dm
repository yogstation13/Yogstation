/datum/action/innate/hog_cult/emp
	name = "Feedback"
	desc = "Empowers your hand to shoot a projectile, that will drain energy from heretical cultists and EMP other targets."

/obj/item/melee/hog_magic/feedback
	name = "\improper charged hand" 
	desc = "A hand, charged by ancient magic. it can shoot EMP projectiles."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/hog_magic/feedback/ranged_attack(atom/target, mob/living/user)
	var/turf/startloc = get_turf(user)
	var/obj/item/projectile/magic/feedback/F = null
	var/target_turf = get_turf(target)
	var/angle_to_target = Get_Angle(user, target_turf)
	F = new /obj/item/projectile/magic/feedback(startloc)
	F.cult = antag.cult
	F.preparePixelProjectile(startloc, startloc)
	F.firer = user
	F.fire(angle_to_target)
	return TRUE

/obj/item/projectile/magic/feedback
	name = "energy bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	var/datum/team/hog_cult/cult
	var/energy_drain = 30
	var/bad_cultie = FALSE

/obj/item/projectile/magic/feedback/on_hit(atom/target, blocked = FALSE)
	var/datum/antagonist/hog/cultie
	if(isliving(target))
		var/mob/living/L = target
		cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == cult)
			bad_cultie = FALSE
			. = BULLET_ACT_FORCE_PIERCE
		else if(cultie)
			bad_cultie = TRUE
	..()
	if(cultie && bad_cultie)
		var/damage_to_deal = min(cultie.energy, energy_drain)
		if(damage_to_deal)
			cultie.get_energy(-damage_to_deal)
			var/mob/living/L = target
			L.adjustFireLoss(damage_to_deal)
			L.emote("scream")
			to_chat(L, span_cult("You feel your magic leave you, as the bolt of heretical energy hits your body!"))
		else
			empulse(target, 1, 1)
	else
		empulse(target, 1, 1)
	return BULLET_ACT_HIT
