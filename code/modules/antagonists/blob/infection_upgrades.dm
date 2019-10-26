/datum/infection_upgrade
	var/id = "test"
	var/name = "TEST"
	var/desc = "Contact an admin"
	var/desc_req
	var/cost = 0
	var/bought = FALSE
	var/required_upgrades = list()

/datum/infection_upgrade/proc/onPurchase(mob/camera/blob/infection/infection)
	if(bought)
		return FALSE

	for(var/requirement in required_upgrades)
		for(var/U in infection.available_upgrades)
			var/datum/infection_upgrade/foreign = U
			if(foreign.id == requirement)
				if(!foreign.bought)
					return 2

	if(infection.biopoints >= cost)
		infection.biopoints -= cost
		bought = TRUE
		return TRUE
	return FALSE


/datum/infection_upgrade/gel_resistance
	id = "ballistic_gel"
	name = "Ballistic Gel"
	desc = "Gives +10% resistance to brute damage"
	cost = 1

/datum/infection_upgrade/gel_resistance/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.brute_resistance += 0.1
		return TRUE
	return FALSE

/datum/infection_upgrade/reflective_fibers
	id = "reflective_fibers"
	name = "Reflective Fibers"
	desc = "Gives +10% resistance to brute damage, but -15% resistance to fire damage"
	desc_req = "Requires the Ballistic Gel upgrade!"
	cost = 2
	required_upgrades = list("ballistics_gel")

/datum/infection_upgrade/reflective_fibers/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.brute_resistance += 0.1
		infection.fire_resistance -= 0.15
		return TRUE
	return FALSE

/datum/infection_upgrade/light_reflective_fibers
	id = "light_reflective_fibers"
	name = "Lightweight Reflective Fibers"
	desc = "Gives Blobbernauts +10% brute resistance, and -15% fire resistance"
	desc_req = "Requires the Supported Spores & Reflective Fibers upgrade!"
	cost = 2
	required_upgrades = list("reflective_fibers", "supported_spores")

/datum/infection_upgrade/light_reflective_fibers/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.blobber_melee_defence += 0.1
		infection.blobber_fire_defence -= 0.15
		return TRUE
	return FALSE

/datum/infection_upgrade/asbestos
	id = "asbestos"
	name = "Asbestos Coating"
	desc = "Gives +20% fire resistance"
	cost = 2

/datum/infection_upgrade/asbestos/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.fire_resistance += 0.2
		return TRUE
	return FALSE

/datum/infection_upgrade/light_fibers
	id = "light_fibers"
	name = "Lightweight Fibers"
	desc = "Gives Blobbernauts +10% health"
	desc_req = "Requires the Supported Spores upgrade"
	cost = 2
	required_upgrades = list("reflective_fibers", "supported_spores")

/datum/infection_upgrade/light_fibers/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.blobber_health_bonus += 0.1
		return TRUE
	return FALSE

/datum/infection_upgrade/focused_impacts
	id = "focused_impacts"
	name = "Focused Impacts"
	desc = "Gives Blobbernauts +15% damage!"
	desc_req = "Requires the Supported Spores upgrade!"
	cost = 3
	required_upgrades = list("supported_spores")

/datum/infection_upgrade/focused_impacts/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.blobber_attack_bonus += 0.15
		return TRUE
	return FALSE

/datum/infection_upgrade/swarm_tactics
	id = "swarm_tactics"
	name = "Swarm Tactics"
	desc = "Makes blob spores spawn 2x as fast, but reduces their health by 50% and damage by 15%"
	cost = 1

/datum/infection_upgrade/swarm_tactics/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.spore_health_modifier -= 0.5
		infection.spore_damage_modifier -= 0.15
		infection.spore_creation_modifier += 1
		return TRUE
	return FALSE

/datum/infection_upgrade/reanimating_spores
	id = "reanimating_spores"
	name = "Reanimating Spores"
	desc = "Allows blob spores to create blob zombies"
	cost = 2

/datum/infection_upgrade/reanimating_spores/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.blob_zombies = TRUE
		return TRUE
	return FALSE

/datum/infection_upgrade/dispersed_fibers
	id = "dispersed_fibers"
	name = "Dispersed Fibers"
	desc = "Reduces the cost of expanding by 25%, but reduces the health of tiles by 30%"
	cost = 2

/datum/infection_upgrade/light_reflective_fibers/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.health_modifier -= 0.3
		infection.expansion_cost_modifier -= 0.25
		return TRUE
	return FALSE

/datum/infection_upgrade/supported_spores
	id = "supported_spores"
	name = "Supported Spores"
	desc = "Enables Blobbernauts!"
	cost = 2

/datum/infection_upgrade/supported_spores/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.blobbers_enabled = TRUE
		return TRUE
	return FALSE

/datum/infection_upgrade/reinforced_gel
	id = "reinforced_gel"
	name = "Reinforced Gel"
	desc = "Gives tiles +15% health"
	cost = 2

/datum/infection_upgrade/reinforced_gel/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.health_modifier += 0.15
		return TRUE
	return FALSE

/datum/infection_upgrade/solidifying_gel
	id = "solidifying_gel"
	name = "Solidifying Gel"
	desc = "Gives tiles an additional +10% health"
	desc_req = "Requires the Reinforced Gel upgrade!"
	cost = 3
	required_upgrades = list("reinforced_gel")

/datum/infection_upgrade/solidifying_gel/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.health_modifier += 0.1
		return TRUE
	return FALSE

/datum/infection_upgrade/aerial_spores
	id = "aerial_spores"
	name = "Aerial Spores"
	desc = "Decreases the time to stage up by 5%"
	cost = 2

/datum/infection_upgrade/aerial_spores/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.stage_speed_modifier -= 0.05
		return TRUE
	return FALSE

/datum/infection_upgrade/aerodynamic_spores
	id = "aerodynamic_spores"
	name = "Aerodynamic Spores"
	desc = "Decreases the time to stage up by an additional 5%"
	desc_req = "Requires the Aerial Spores upgrade!"
	cost = 3
	required_upgrades = list("aerial_spores")

/datum/infection_upgrade/aerodynamic_spores/onPurchase(mob/camera/blob/infection/infection)
	if(..())
		infection.stage_speed_modifier -= 0.05
		return TRUE
	return FALSE

/datum/infection_upgrade/biodynamic_dispersal
	id = "biodynamic_dispersal"
	name = "Biodynamic Spore Dispersal"
	desc = "Decreases the time to stage up by an additional 7.5%"
	desc_req = "Requires the Aerodynamic Spores upgrade!"
	cost = 6
	required_upgrades = list("aerodynamic_spores")

/datum/infection_upgrade/biodynamic_dispersal/onPurchase(mob/camera/blob/infection/infection)
	var/returned = ..()
	if(returned == TRUE)
		infection.stage_speed_modifier -= 0.075
		return TRUE
	return returned

/datum/infection_upgrade/alloyed_biomass
	id = "alloyed_biomass"
	name = "Alloyed Biomass"
	desc = "Gives 'strong blobs' +25% health."
	desc_req = "Requires the Reinforced Gel upgrade!"
	cost = 3
	required_upgrades = list("reinforced_gel")

/datum/infection_upgrade/alloyed_biomass/onPurchase(mob/camera/blob/infection/infection)
	var/returned = ..()
	if(returned == TRUE)
		infection.strong_blob_bonus += 0.25
		return TRUE
	return returned

/datum/infection_upgrade/hardlight_blob
	id = "hardlight_blob"
	name = "Hardlight Biomass"
	desc = "Gives 'strong blobs' +25% health, and regular blob +30% health"
	desc_req = "Requires the Alloyed Biomass upgrade!"
	cost = 5
	required_upgrades = list("alloyed_biomass")

/datum/infection_upgrade/hardlight_blob/onPurchase(mob/camera/blob/infection/infection)
	var/returned = ..()
	if(returned == TRUE)
		infection.strong_blob_bonus += 0.25
		infection.health_modifier += 0.3
		return TRUE
	return returned