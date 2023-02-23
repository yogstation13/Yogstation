/datum/component/zombie_infection
	//see code\modules\zombie\items.dm
    var/scaled_infection
    var/infection_chance
    var/organ_to_insert

/datum/component/zombie_infection/Initialize(scaled_infection = FALSE, infection_chance = 100, organ_to_insert = /obj/item/organ/zombie_infection)
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE
    src.scaled_infection = scaled_infection
    src.infection_chance = infection_chance
    src.organ_to_insert = organ_to_insert

/datum/component/zombie_infection/RegisterWithParent()
    RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/spread_infection)

/datum/component/zombie_infection/UnregisterFromParent()
    UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/zombie_infection/proc/spread_infection(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(!isliving(target))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/L = H.get_bodypart(check_zone(user.zone_selected))
		if(H.health <= HEALTH_THRESHOLD_FULLCRIT || (L && L.status != BODYPART_ROBOTIC))//no more infecting via metal limbs unless they're in hard crit and probably going to die
			var/flesh_wound = ran_zone(user.zone_selected)
			if(scaled_infection)
				var/scaled_infection = ((100 - H.getarmor(flesh_wound, MELEE))/100) ^ 1.5	//20 armor -> 71.5% chance of infection
				if(prob(infection_chance  * scaled_infection))								//40 armor -> 46.5% chance
					try_to_zombie_infect(target, organ_to_insert)							//60 armor -> 25.3% chance
			else																			//80 armor -> 8.9% chance
				if(prob(infection_chance  - H.getarmor(flesh_wound, MELEE)))
					try_to_zombie_infect(target, organ_to_insert)
	else
		check_feast(target, user)

/datum/component/zombie_infection/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat != DEAD)
		return
	var/hp_gained = target.maxHealth
	target.gib()
	// zero as argument for no instant health update
	user.adjustBruteLoss(-hp_gained, 0)
	user.adjustToxLoss(-hp_gained, 0)
	user.adjustFireLoss(-hp_gained, 0)
	user.adjustCloneLoss(-hp_gained, 0)
	user.updatehealth()
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
	user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
