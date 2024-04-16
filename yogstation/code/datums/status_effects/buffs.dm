/datum/status_effect/dodging
	id = "dodging"
	duration = 0.5 SECONDS
	examine_text = span_notice("They're deftly dodging all incoming attacks!")
	alert_type = /atom/movable/screen/alert/status_effect/dodging

/datum/status_effect/dodging/on_apply()
	owner.visible_message(span_notice("[owner] dodges!"))
	owner.status_flags |= GODMODE
	return ..()

/datum/status_effect/dodging/on_remove()
	owner.status_flags &= ~GODMODE
	owner.visible_message(span_warning("[owner] returns to a neutral stance."))

/atom/movable/screen/alert/status_effect/dodging
	name = "Dodging"
	desc = "You're sure to win because your speed is superior!"
	icon_state = "evading"

/datum/status_effect/dodging/stalwart
	id = "dodging_stalwart"
	duration = 10 SECONDS
	examine_text = span_boldwarning("An inpenetrable shield surrounds the Stalwart!")
	alert_type = /atom/movable/screen/alert/status_effect/dodging/stalwart

/datum/status_effect/dodging/stalwart/on_apply()
	owner.visible_message(span_boldwarning("The hit is absorbed by the shield!"))
	owner.status_flags |= GODMODE
	return ..()

/datum/status_effect/dodging/stalwart/on_remove()
	owner.status_flags &= ~GODMODE
	owner.visible_message(span_boldwarning("The Stalwart's shield cracks apart!"))

/atom/movable/screen/alert/status_effect/dodging/stalwart
	name = "Invulnerability"
	desc = "You're protected by an impenetrable shield!"
	icon_state = "evading"

/datum/status_effect/soulshield
	id = "soulshield"
	duration = 0.5 SECONDS
	var/mutable_appearance/shield
	examine_text = span_notice("There's a shield absorbing all incoming attacks!")
	alert_type = /atom/movable/screen/alert/status_effect/soulshield
	var/startingbrute = 0
	var/startingburn = 0
	var/startingstamina = 0
	var/difference = 0
	var/obj/item/bloodbook/grimoire = null
	var/static/list/grimoire_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
	)

/datum/status_effect/soulshield/on_creation(mob/living/owner, obj/item/melee/grim)
	. = ..()
	if(!.)
		return
	grimoire = grim

/datum/status_effect/soulshield/on_apply()
	owner.visible_message(span_warning("[owner] braces [owner.p_them()]self!"))
	startingbrute = owner.getBruteLoss()
	startingburn = owner.getFireLoss()
	startingstamina = owner.getStaminaLoss()
	shield = mutable_appearance('icons/effects/effects.dmi', "shield-red")
	owner.Immobilize(1.0 SECONDS)
	shield.pixel_x = -owner.pixel_x
	shield.pixel_y = -owner.pixel_y
	owner.overlays += shield
	owner.weather_immunities |= WEATHER_ASH //no free charges/heals
	for(var/traits in grimoire_traits)
		ADD_TRAIT(owner, traits, GRIMOIRE_TRAIT)
	return ..()

/datum/status_effect/soulshield/on_remove()
	var/brutechange = (owner.getBruteLoss() - startingbrute)
	var/burnchange = (owner.getFireLoss() - startingburn)
	var/stamchange = (owner.getStaminaLoss() - startingstamina)
	difference = (brutechange + burnchange + stamchange)
	if(difference)
		grimoire.shieldcharge()
		grimoire.blowback(owner)
		owner.SetImmobilized(0) 
		owner.adjustBruteLoss(-5)
		owner.adjustFireLoss(-5)
		playsound(owner.loc, 'sound/weapons/ricochet.ogg', 40, 1)
	if(owner)
		for(var/traits in grimoire_traits)
			REMOVE_TRAIT(owner, traits, GRIMOIRE_TRAIT)
		owner.weather_immunities -= WEATHER_ASH
		owner.overlays -= shield
		owner.extinguish_mob()
		owner.AdjustStun(-200)
		owner.AdjustParalyzed(-200)
		owner.visible_message(span_warning("[owner] returns to a neutral stance."))
		addtimer(CALLBACK(grimoire, TYPE_PROC_REF(/obj/item/bloodbook, retaliate), owner, difference))
	owner.heal_overall_damage(brutechange, burnchange, stamchange)
	

/atom/movable/screen/alert/status_effect/soulshield
	name = "Deflecting"
	desc = "You're preparing for a counterattack!"
	icon_state = "stun"
/datum/status_effect/dodging/battleroyale
	id = "dodging_gamer"
	duration = 1 MINUTES
	examine_text = span_boldwarning("An inpenetrable ligma shield surrounds the gamer!")
	alert_type = /atom/movable/screen/alert/status_effect/dodging/battleroyale

/datum/status_effect/dodging/battleroyale/on_apply()
	owner.status_flags |= GODMODE
	return ..()

/datum/status_effect/dodging/battleroyale/on_remove()
	owner.status_flags &= ~GODMODE
	owner.visible_message(span_boldwarning("[owner.name]'s ligma shield has broken!"))

/atom/movable/screen/alert/status_effect/dodging/battleroyale
	name = "Invulnerability"
	desc = "You're protected by a ligma shield!"
	
/datum/status_effect/speedboost
	id = "speedboost"
	duration = 30 SECONDS
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null //might not even be a speedbuff, so don't show it
	var/speedstrength
	var/identifier //id for the speed boost

/datum/status_effect/speedboost/on_creation(mob/living/new_owner, strength, length, identifier)
	duration = length
	speedstrength = strength
	src.identifier = identifier
	. = ..()

/datum/status_effect/speedboost/on_apply()
	. = ..()
	if(. && speedstrength && identifier)
		owner.add_movespeed_modifier(identifier, TRUE, 101, override=TRUE,  multiplicative_slowdown = speedstrength)

/datum/status_effect/speedboost/on_remove()
	owner.remove_movespeed_modifier(identifier)
