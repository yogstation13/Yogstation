/datum/zombie_mutation/strong_arm
	sector = SECTOR_CLASS
	name = "Muscular Fibers"
	desc = "Increased damage resistence on defense mode."
	id = "strong_arm"
	owner_class = JUGGERNAUT_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/jab
	sector = SECTOR_CLASS	
	name = "Neuron Repathing"
	desc = "Gain the Quick Jab ability."
	id = "quick_jab"
	owner_class = JUGGERNAUT_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/jab/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/jab/J = new
	J.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/increased_rage
	sector = SECTOR_CLASS
	name = "Adapted Pain Receptors"
	desc = "Doubled Rage gain on damage."
	id = "increased_rage"
	owner_class = JUGGERNAUT_BITFLAG
	mutation_cost = 2

/datum/zombie_mutation/increased_rage/apply_effects()
	. = ..()
	var/mob/living/carbon/human/user = zombie_owner.owner?.current
	var/datum/species/zombie/infectious/gamemode/juggernaut/jugg = user?.dna?.species
	jugg.infection_regen = 2.5
