/datum/traitor_backstory
	/// The name of this traitor backstory type, displayed as a title
	var/name
	/// A description of the events leading up to this traitor's existence
	var/description
	/// Factions you can have as this backstory
	var/allowed_factions = list(
		TRAITOR_FACTION_INDEPENDENT,
		TRAITOR_FACTION_DONK,
		TRAITOR_FACTION_WAFFLE,
		TRAITOR_FACTION_CYBERSUN,
		TRAITOR_FACTION_VAHLEN,
		TRAITOR_FACTION_GORLEX,
		TRAITOR_FACTION_SELF,
		TRAITOR_FACTION_BOSYN
	)
	/// A list of motivation types for this backstory, used for filtering and searching
	var/list/motivations = list()
	/// If this backstory suggested for murderboning or hijacking
	var/murderbone = FALSE

/datum/traitor_backstory/proc/has_motivation(motivation)
	return motivation in motivations

// ------------------
// ACTUAL BACKSTORIES
// ------------------

/datum/traitor_backstory/loyalist
	name = "The Loyalist Redeemed"
	description = "I was once a loyalist to the combine. \
	Once the resistance got their hands one me, they threatened to kill me unless I did as they say."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_DEATH_THREAT)

/datum/traitor_backstory/destitute
	name = "The Destitute"
	description = "I was on the verge of death in the outlands. \
	When the resistance found me, they offered me life, credits, supplies, and more. So long as I did what they wanted me to."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_MONEY)

/datum/traitor_backstory/freedomfighter
	name = "The Freedom Fighter"
	description = "Finally, change is in the air! \
	I've always believed in the liberation of mankind at all costs. The resistance will succeed, no matter what!"
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_POLITICAL, TRAITOR_MOTIVATION_AUTHORITY)
	murderbone = TRUE

/datum/traitor_backstory/avenger
	name = "The Avenger"
	description = "The combine took everything. I will make them pay for the lives of my loved ones."
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_POLITICAL, TRAITOR_MOTIVATION_LOVE)
	murderbone = TRUE

/datum/traitor_backstory/savior
	name = "The Savior"
	description = "I want to help as many people as I can, and so I joined the resistance."
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED)
