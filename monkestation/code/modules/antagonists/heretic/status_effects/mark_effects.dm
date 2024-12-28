/datum/status_effect/eldritch/rust/on_effect(mob/living/activator)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/static/list/organs_to_damage = list(
			ORGAN_SLOT_BRAIN,
			ORGAN_SLOT_EARS,
			ORGAN_SLOT_EYES,
			ORGAN_SLOT_LIVER,
			ORGAN_SLOT_LUNGS,
			ORGAN_SLOT_STOMACH,
			ORGAN_SLOT_HEART,
		)

		// Roughly 25% of their organs will take a bit of damage
		for(var/organ_slot in organs_to_damage)
			if(prob(25))
				carbon_owner.adjustOrganLoss(organ_slot, 20)

		var/list/grenades = list()
		// And roughly 50% of their items will take a smack, too
		for(var/obj/item/thing in carbon_owner.get_all_gear())
			if(QDELETED(thing) || prob(50))
				continue
			// ignore abstract items and such
			if(thing.item_flags & (ABSTRACT | EXAMINE_SKIP | HAND_ITEM))
				continue
			// don't delete people's ID cards
			if(istype(thing, /obj/item/card/id))
				continue
			// special handling for grenades
			if(istype(thing, /obj/item/grenade))
				var/obj/item/grenade/grenade = thing
				if(grenade.active) // primed grenades are just turned into duds
					grenade.dud_flags |= GRENADE_DUD
					continue
				if(!grenade.dud_flags)
					grenades["[grenade::name]"]++ // so you can't name/label a grenade something stupidly long to annoy them
					log_bomber(activator, "has primed a", grenade, "via damage from Mark of Rust")
					grenade.arm_grenade(delayoverride = max(round(grenade.det_time * 0.75, 0.5 SECONDS), 2 SECONDS))
					continue
			thing.take_damage(RUST_MARK_DAMAGE)

		var/grenade_amt = length(grenades)
		if(grenade_amt)
			var/list/msg = list()
			for(var/name in grenades)
				msg += "[grenades[name]]x [name]"
			owner.balloon_alert(activator, "triggered [english_list(msg)]")
			owner.balloon_alert_to_viewers("[grenade_amt > 1 ? "several grenades" : "grenade"] damaged and activated!", ignored_mobs = activator)
	return ..()
