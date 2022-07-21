//////////////////////////////////////////
//                                      //
//              FEEDBACK                //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/feedback
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
	if(cultie && bad_cultie)   //It drains energy AND damages, if the target is a hostile cultist with energy. Otherwise it just empulses it.
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

//////////////////////////////////////////
//                                      //
//              CHAIN HEAL              //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/chain_heal
	name = "Chain Heal"
	desc = "Empowers your hand with positive energy, allowing you to launch healing waves into your allies."

/obj/item/melee/hog_magic/heal
	name = "\improper charged hand" 
	desc = "A hand, charged by positive energy. It can heal people."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/hog_magic/heal/ranged_attack(atom/target, mob/living/user)
	if(isliving(target))
		return FALSE
	var/mob/living/L = target
	if(L.stat == DEAD)
		return FALSE
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
	if(cultie && cultie.cult != antag.cult)  //You can target non-cultists, but you can't target hostile cultists
		return FALSE
	var/datum/chain_heal/healing_datum = new(antag.cult, user)
	INVOKE_ASYNC(healing_datum, /datum/chain_heal.proc/heal, L)
	return TRUE
	
/datum/chain_heal
	var/list/blacklist = list()
	var/healing_amount = 20
	var/datum/team/hog_cult/cult
	var/mob/living/last_healed
	var/charges = 2
	var/range = 4

/datum/chain_heal/New(var/datum/team/hog_cult/cult/team, var/mob/living/user)
	. = ..()
	cult = team
	blacklist += user
	last_healed = user

/datum/chain_heal/proc/heal(mob/living/target)
	if(!charges)
		return
	INVOKE_ASYNC(last_healed, /atom/.proc/Beam, target, icon_state = "warden_beam", time = 1.75 SECONDS) 
	sleep(0.5 SECONDS)
	var/brute_damage_to_heal
	var/burn_damage_to_heal
	brute_damage_to_heal = min(healing_amount, target.getBruteLoss())
	var/healing_left = healing_amount - brute_damage_to_heal
	if(healing_left > 0)
		burn_damage_to_heal = min(healing_left, target.getFireLoss())
	target.heal_overall_damage(brute = brute_damage_to_heal, burn = burn_damage_to_heal, updating_health = TRUE)
	charges--
	if(!charges)
		qdel(src)
		return
	healing_amount = healing_amount*0.7
	last_healed = target
	blacklist += last_healed
	find-targets()

/datum/chain_heal/proc/find-targets()
	var/list/valid_targets = list()
	for(var/mob/living/L in viewers(range, src)) 
		if(L.stat == DEAD)
			continue
		if(L in blacklist)
			continue
		if(!L.mind)
			continue
		var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
		if(cultie?.cult != cult)
			continue
		if(L.anti_magic_check())
			continue
		valid_targets += L
	if(!valid_targets)
		qdel(src)
		return
	heal(pick(valid_targets))


	
