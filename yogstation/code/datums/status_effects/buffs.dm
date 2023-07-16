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
	examine_text = span_notice("They're deftly dodging all incoming attacks!")
	alert_type = /atom/movable/screen/alert/status_effect/dodging
	var/static/list/gauntlet_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE
	)

/datum/status_effect/soulshield/on_apply()
	shield = mutable_appearance('icons/effects/effects.dmi', "shield-red")
	owner.Immobilize(1.0 SECONDS)
	shield.pixel_x = -owner.pixel_x
	shield.pixel_y = -owner.pixel_y
	owner.underlays += shield
	for(var/traits in gauntlet_traits) ///adds demon traits
		ADD_TRAIT(owner, traits, GAUNTLET_TRAIT)
	return ..()

/datum/status_effect/soulshield/on_remove()
	if(owner)
		for(var/traits in gauntlet_traits) ///adds demon traits
			REMOVE_TRAIT(owner, traits, GAUNTLET_TRAIT)
		owner.underlays -= shield
		owner.visible_message(span_warning("[owner] returns to a neutral stance."))

/atom/movable/screen/alert/status_effect/soulshield
	name = "Deflecting"
	desc = "You're sure to win because your speed is superior!"
	icon_state = "evading"
