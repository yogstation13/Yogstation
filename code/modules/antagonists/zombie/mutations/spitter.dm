/datum/zombie_mutation/stronger_acid
	sector = SECTOR_CLASS
	name = "Effecient Glands"
	id = "stronger_acid"
	desc = "Increases acid effectiveness on walls."
	owner_class = SPITTER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/bubble_blood
	sector = SECTOR_CLASS
	name = "Lipid Sacs"
	id = "stronger_acid"
	desc = "Gain the Bubble ability."
	owner_class = SPITTER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/bubble_blood/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/default/bubble/B = new
	B.Grant(zombie_owner.owner?.current)

/datum/zombie_mutation/acid_puke
	sector = SECTOR_CLASS
	name = "Reinforced Esophagus"
	id = "stronger_acid"
	desc = "Gain the Puke ability."
	owner_class = SPITTER_BITFLAG
	mutation_cost = 2

/datum/zombie_mutation/acid_puke/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/default/puke/P = new
	P.Grant(zombie_owner.owner?.current)
