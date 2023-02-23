/datum/zombie_mutation/tongue_range
	sector = SECTOR_CLASS
	name = "Tongue Size"
	id = "big_tongue"
	desc = "Increases effective tongue range by 2."
	owner_class = SMOKER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/tongue_stun
	sector = SECTOR_CLASS
	name = "Tongue Spikes"
	id = "stickier_tongue"
	desc = "Increases stun time by 1 second on non-targets interacting with the tongue."
	owner_class = SMOKER_BITFLAG
	mutation_cost = 1

/datum/zombie_mutation/tongue_swing
	sector = SECTOR_CLASS
	name = "Tongue Myocytes"
	id = "strong_tongue"
	desc = "Gain the Tongue Swing ability."
	owner_class = SMOKER_BITFLAG
	mutation_cost = 2

/datum/zombie_mutation/tongue_swing/apply_effects()
	. = ..()
	var/datum/action/innate/zombie/swing/S = new
	S.Grant(zombie_owner.owner?.current)
