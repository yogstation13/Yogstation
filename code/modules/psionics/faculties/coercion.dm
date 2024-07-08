#define COGMANIP_HYPNOTIZE "Hypnotize"
#define COGMANIP_ERASE_MEMORY "Erase Memory"
#define COGMANIP_THRALL "Thrall"

/datum/psionic_faculty/coercion
	id = PSI_COERCION
	name = "Coercion"

/datum/psionic_power/coercion
	faculty = PSI_COERCION

/datum/psionic_power/coercion/telepathy
	name = "Telepathy"
	cost = 30
	cooldown = 5 SECONDS
	min_rank =	PSI_RANK_OPERANT
	use_description =	"Grants the ability to telepathically communicate with other sentient beings."

/datum/psionic_power/coercion/disarm
	name = "Disarm"
	cost = 50
	cooldown = 30 SECONDS
	min_rank =	PSI_RANK_OPERANT
	use_description =	"Grants the ability to telepathically disarm someone's weapons. Upgrades with your Psi Rank"

/datum/psionic_power/coercion/mental_cooling
	name = "Mental Cooling"
	min_rank =	PSI_RANK_OPERANT
	use_description = "Passively upgrades your heat-cooldown by 20%."

/datum/psionic_power/coercion/psychic_scream
	name =	"Psychic Scream"
	cost =	50
	cooldown =	30 SECONDS
	min_rank =	PSI_RANK_MASTER
	use_description =	"Send a blast of psychic energy to another person's mind, applying stamina damage to them."

/datum/psionic_power/coercion/mental_freezing
	name =	"Cognitive Manipulation"
	min_rank =	PSI_RANK_GRANDMASTER
	use_description =	"Further increase heat cooldown by another 30%"





