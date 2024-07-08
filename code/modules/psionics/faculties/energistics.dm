/datum/psionic_faculty/energistics
	id = PSI_ENERGISTICS
	name = "Energistics"
	armour_types = list("bomb", "laser", "energy")

/datum/psionic_power/energistics
	faculty = PSI_ENERGISTICS

/datum/psionic_power/energistics/spark
	name = "Spark"
	cost = 1
	cooldown = 1 SECONDS
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grants the ability to cause ignition with your hands. Upgrades with Psi Rank."

/datum/psionic_power/energistics/recharge
	name = "Recharge"
	cost = 30
	cooldown = 50 SECONDS
	min_rank = PSI_RANK_OPERANT
	use_description = "Grants the abilitiy to recharge technology or machinery."

/datum/psionic_power/energistics/temperature_regulation
	name = "Temperature Regulation"
	min_rank = PSI_RANK_OPERANT
	use_description = "Passively allows the user to regulate their body temperature."

/datum/psionic_power/energistics/shock_touch
	name = "Shock Touch"
	cost = 50
	heat = 100
	cooldown = 30 SECONDS
	min_rank =         PSI_RANK_MASTER
	use_description = "Grants the ability to charge electricity in the user's hand, shocking anyone touched."

/datum/psionic_power/energistics/disrupt
	name = "Disrupt"
	cost = 60
	heat = 60
	cooldown = 60 SECONDS
	min_rank =        PSI_RANK_GRANDMASTER
	use_description = "Target the head, eyes or mouth while on harm intent to use a melee attack that causes a localized electromagnetic pulse."




