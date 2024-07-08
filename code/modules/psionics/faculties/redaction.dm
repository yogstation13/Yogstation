/datum/psionic_faculty/redaction
	id = PSI_REDACTION
	name = "Redaction"
	armour_types = list(BIO, RAD)

/datum/psionic_power/redaction
	faculty = PSI_REDACTION
	admin_log = FALSE

/datum/psionic_power/redaction/Mend
	name = "Mend"
	cost = 15
	heat = 15
	cooldown = 15 SECONDS
	min_rank = PSI_RANK_OPERANT
	use_description = "Grants the ability to heal physical wounds of others with your touch. Upgrades with Psi Level."

/datum/psionic_power/redaction/cleanse
	name = "Cleanse"
	cost = 15
	heat = 15
	cooldown = 15 SECONDS
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grants the ability to cleanse others of toxins and radiation."

/datum/psionic_power/redaction/healers_visage
	name = "Healer's Visage"
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grants the user passive sight of those harmed, or affected by maladies."

/datum/psionic_power/redaction/revivification
	name = "Revivification"
	min_rank = PSI_RANK_MASTER
	use_description = "Grants the user the ability to revive another. Upgrades with Psi Level."

/datum/psionic_power/healing_aura
	name = "Healing Aura"
	min_rank =        PSI_RANK_PARAMOUNT
	use_description = "Grants the user an aura of healing of themselves and others over time."

