//////////////////////////////////////////
//                                      //
//              FEEDBACK                //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/feedback
	name = "Feedback"
	desc = "Empowers your hand to shoot a projectile, that will drain energy from heretical cultists and EMP other targets."
	hand_type = /obj/item/melee/hog_magic/feedback

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
	if(HAS_TRAIT(user, TRAIT_CULTIST_ROBED))
		F.energy_drain = initial(F.energy_drain) + 5
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
	hand_type = /obj/item/melee/hog_magic/heal

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
	if(dude && dude.cult != antag.cult)  //You can target non-cultists, but you can't target hostile cultists
		return FALSE
	var/datum/chain_heal/healing_datum = new(antag.cult, user)
	if(HAS_TRAIT(user, TRAIT_CULTIST_ROBED))
		healing_datum.charges = initial(healing_datum.charges) + 1
	INVOKE_ASYNC(healing_datum, /datum/chain_heal.proc/heal, L)
	return TRUE
	
/datum/chain_heal
	var/list/blacklist = list()
	var/healing_amount = 20
	var/datum/team/hog_cult/cult
	var/mob/living/last_healed
	var/charges = 2
	var/range = 4

/datum/chain_heal/New(var/datum/team/hog_cult/team, var/mob/living/user)
	. = ..()
	cult = team
	blacklist += user
	last_healed = user

/datum/chain_heal/proc/heal(mob/living/target)
	if(!charges)
		return
	INVOKE_ASYNC(last_healed, /atom/.proc/Beam, target, "warden_beam", 'icons/effects/beam.dmi', 1.5 SECONDS, 10, /obj/effect/ebeam, 0) 
	var/brute_damage_to_heal
	var/burn_damage_to_heal
	brute_damage_to_heal = min(healing_amount, target.getBruteLoss())
	var/healing_left = healing_amount - brute_damage_to_heal
	if(healing_left > 0)
		burn_damage_to_heal = min(healing_left, target.getFireLoss())
	target.heal_overall_damage(brute = brute_damage_to_heal, burn = burn_damage_to_heal, updating_health = TRUE)
	target.visible_message(span_notice("[target] is healed by a wave of positive energy!"),span_notice("You are healed by a wave of positive energy!"))
	charges--
	if(!charges)
		qdel(src)
		return
	healing_amount = healing_amount*0.7
	last_healed = target
	blacklist += last_healed
	find_targets()

/datum/chain_heal/proc/find_targets()
	var/list/valid_targets = list()
	for(var/mob/living/L in viewers(range, src)) 
		if(L.stat == DEAD)
			continue
		if(L in blacklist)
			continue
		if(!L.mind)
			continue
		var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
		if(dude?.cult != cult)
			continue
		if(L.anti_magic_check())
			continue
		valid_targets += L
	if(!valid_targets)
		qdel(src)
		return
	heal(pick(valid_targets))

//////////////////////////////////////////
//                                      //
//              BERSERKER               //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/berserker
	name = "Enrage"
	desc = "Fall into state of a berserker, making you more resistant to stuns and damage slowdown, at the cost of making you unable to use advanced tools, magic and communicate with other people."
	hand_type = null

/datum/action/innate/hog_cult/berserker/Activate()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.apply_status_effect(STATUS_EFFECT_BERSERKER)
		qdel(src)
	else
		to_chat(owner, span_warning("You need to be a carbon in order to use this spell!"))

//////////////////////////////////////////
//                                      //
//          LIFEFORCE TRADE             //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/lifeforce
	name = "Lifeforce Trade"
	desc = "Target a fellow cultist with this spell, and they will get quickly healed of immobility effects(sleeping, knockdown, etc.), but you will get 65% of effect duration."
	hand_type =  /obj/item/melee/hog_magic/lifeforce

/obj/item/melee/hog_magic/lifeforce
	name = "\improper charged hand" 
	desc = "A hand, that can link you and someone else for a lifeforce trade."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/hog_magic/lifeforce/ranged_attack(atom/target, mob/living/user)
	if(isliving(target))
		return FALSE
	var/mob/living/L = target
	if(L.stat == DEAD)
		return FALSE
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
	if(!dude || dude.cult != antag.cult) 
		return FALSE
	L.apply_status_effect(/datum/status_effect/lifeforce_trade, user)
	to_chat(user, span_warning("You link yourself with [L]."))
	return TRUE

//////////////////////////////////////////
//                                      //
//                CLEAVE                //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/cleave
	name = "Cleave"
	desc = "Charges your hand, allowing to deal bleeding wounds and damage to multiple people when used."
	hand_type =  /obj/item/melee/hog_magic/cleave

/obj/item/melee/hog_magic/cleave
	name = "\improper bloody hand" 
	desc = "A hand, that can cause bleeding wounds on multiple people."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/hog_magic/cleave/melee_attack(atom/target, mob/living/user)
	if(isliving(target))
		return FALSE
	var/mob/living/L = target
	if(L.stat == DEAD)
		return FALSE
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
	if(dude && dude.cult == antag.cult)
		return FALSE
	L.apply_damage(16, BRUTE, user.zone_selected, 0, sharpness = SHARP_EDGED)
	to_chat(user, span_warning("You cut [L]'s veins with your magic."))
	L.visible_message(span_danger("[L] is cut by [user]'s magic!"), \
					  span_userdanger("[user] cuts you with their magic!"))
	var/already_damaged_people_amount = 1
	if(HAS_TRAIT(user, TRAIT_CULTIST_ROBED))
		already_damaged_people_amount--
	for(var/mob/living/aoe_target in view_or_range(1, L, "range")) 
		if(aoe_target.stat == DEAD)
			continue
		var/datum/antagonist/hog/man = IS_HOG_CULTIST(aoe_target)
		if(man?.cult != antag.cult)
			continue
		if(aoe_target.anti_magic_check())
			continue
		aoe_target.apply_damage(max(16 - already_damaged_people_amount*3, 5), BRUTE, user.zone_selected, 0, sharpness = SHARP_EDGED)
		to_chat(aoe_target, span_userdanger("You are cut by [user]'s magic!"))
		already_damaged_people_amount++
	return TRUE

//////////////////////////////////////////
//                                      //
//              LIFESTEAL               //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/lifesteel
	name = "Lifesteel"
	desc = "Enchant your blade attacks, making them heal you. Works ONLY on cult blades."
	hand_type = null

/datum/action/innate/hog_cult/lifesteel/Activate()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.apply_status_effect(/datum/status_effect/hog_blade_effect/lifesteal)
		qdel(src)
	else
		to_chat(owner, span_warning("You need to be a carbon in order to use this spell!"))

//////////////////////////////////////////
//                                      //
//                BLINK                 //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/blink
	name = "Teleport"
	desc = "Charges your hand with bluespace energy, allowing to teleport yourself or your allied cultist."
	hand_type =  /obj/item/melee/hog_magic/blink
	charges = 2

/obj/item/melee/hog_magic/blink
	name = "\improper bluespace charged hand" 
	desc = "A hand, that can teleport people."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	uses = 2
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/melee/hog_magic/blink/melee_attack(atom/target, mob/living/user)
	if(isliving(target))
		return FALSE
	var/mob/living/L = target
	if(L.stat == DEAD)
		return FALSE
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
	if(!dude || dude.cult != antag.cult)
		return FALSE

	if(HAS_TRAIT(user, TRAIT_CULTIST_ROBED))
		outer_tele_radius = initial(outer_tele_radius) + 1
	else 
		outer_tele_radius = initial(outer_tele_radius)

	playsound(get_turf(L), 'sound/magic/blink.ogg', 50,1)
	var/list/turfs = new/list()
	for(var/turf/T in range(target,outer_tele_radius))
		if(T in range(target,inner_tele_radius))
			continue
		if(isspaceturf(T))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)
			continue
		turfs += T

	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in orange(target,outer_tele_radius))
			if(!(T in orange(target,inner_tele_radius)))
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)

	var/turf/picked = pick(turfs)

	if(!picked || !isturf(picked))
		return FALSE

	if(do_teleport(L, picked, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC))
		playsound(get_turf(L), 'sound/magic/blink.ogg', 50,1)
		return TRUE
	return FALSE

//////////////////////////////////////////
//                                      //
//           ARCANE BARRAGE             //
//                                      //
//////////////////////////////////////////

/datum/action/innate/hog_cult/arcane_barrage
	name = "Arcane Barrage"
	desc = "Empowers your hand to shoot a 5 projectiles that deal 12 damage on hit."
	hand_type = /obj/item/melee/hog_magic/arcane_barrage
	charges = 5

/obj/item/melee/hog_magic/arcane_barrage
	name = "\improper charged hand" 
	desc = "A hand, that can shoot magical projectiles into enemies. There is 5 projectiles left."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	uses = 5

/obj/item/melee/hog_magic/arcane_barrage/New(loc, spell)
	. = ..()
	desc = "A hand, that can shoot magical projectiles into enemies. There is [uses] projectiles left."

/obj/item/melee/hog_magic/arcane_barrage/ranged_attack(atom/target, mob/living/user)
	var/turf/startloc = get_turf(user)
	var/obj/item/projectile/magic/arcane_barrage/B = null
	var/target_turf = get_turf(target)
	var/angle_to_target = Get_Angle(user, target_turf)
	B = new /obj/item/projectile/magic/arcane_barrage(startloc)
	B.cult = antag.cult
	B.preparePixelProjectile(startloc, startloc)
	B.firer = user
	if(HAS_TRAIT(user, TRAIT_CULTIST_ROBED))
		B.damage = 14
	B.fire(angle_to_target)
	desc = "A hand, that can shoot magical projectiles into enemies. There is [uses-1] projectiles left."
	return TRUE

/obj/item/projectile/magic/arcane_barrage
	name = "arcane barrage"
	icon_state = "magicm"
	damage = 12
	damage_type = BURN
	hitsound = 'sound/magic/mm_hit.ogg'
	var/datum/team/hog_cult/cult

/obj/item/projectile/magic/arcane_barrage/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		var/datum/antagonist/hog/dude = IS_HOG_CULTIST(L)
		if(dude?.cult == cult)
			nodamage = TRUE
	return ..()