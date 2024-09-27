/datum/traitor_faction
	/// The name of this faction
	var/name
	/// The name of this faction when shown to the player as their employer.
	var/employer_name
	/// The define tied to this faction
	var/key
	/// A short description of this faction, OOC
	var/description
	/// If this faction has access to codewords
	var/give_codewords = FALSE
	/// variable that controls the backstory themes
	var/faction_theme = "syndicate"


/datum/traitor_faction/lambda
	name = "Lambda"
	employer_name = "Jordan Gallow, Local Cell Leader"
	description = "Lambda has you as one of their agents. Destroy the combine, no matter the cost."
	key = TRAITOR_FACTION_INDEPENDENT
	faction_theme = PDA_THEME_GORLEX

/datum/traitor_faction/blackmarket
	name = "Blackmarket Rings"
	employer_name = "Renfield, Black Market Ring Leader"
	description = "Officially not a rebel cell, the black markets often work closely with rebels to smuggle goods and make profits. Either way, they have a common enemy in the combine."
	key = TRAITOR_FACTION_SELF
	faction_theme = PDA_THEME_TERMINAL
