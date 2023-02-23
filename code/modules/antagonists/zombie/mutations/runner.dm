/datum/zombie_mutation/leg_response
	sector = SECTOR_CLASS
	name = "Harder Leg Tissue"
	id = "leg_response"
	desc = "Doubles your possible Parkour jumps."
	owner_class = RUNNER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/pick_pocket
	sector = SECTOR_CLASS
	name = "Faster Neuron Response"
	id = "pick_pocket"
	desc = "Gain the Pickpocket ability."
	owner_class = RUNNER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/pick_pocket/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/pickpocket/P = new
	P.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/better_reflexes
	sector = SECTOR_CLASS
	name = "Better Brain Reaction"
	id = "better_reflexes"
	desc = "Bolt makes you immune to projectiles."
	owner_class = RUNNER_BITFLAG
	mutation_cost = 2
