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


/datum/traitor_faction/independent
	name = "Independent"
	employer_name = "You"
	description = "Not for the faint of heart, being an independent traitor requires superior roleplay abilities, and superior traitor skills. \n\
	You are a person who holds grudges, and has been hurt greatly by Nanotrasen.\n\
	You will have no allies."
	key = TRAITOR_FACTION_INDEPENDENT
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/donk_co
	name = "Donk Co."
	employer_name = "Donk Co."
	description = "Every Donk Co board member has been where you are now.\n\
	Whatever your objectives are, they’re just another stepping stone on your path to the top, another page for your résumé. Hop to it, the C-Suite is waiting. "
	key = TRAITOR_FACTION_DONK
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/waffle_co
	name = "Waffle Co."
	employer_name = "Waffle Co."
	description = "You hail from a family of beloved toy manyfacturers with a robust firearms development wing. \n\
	This station has significant business with our rival, Donk Co., and needs to be undermined."
	key = TRAITOR_FACTION_WAFFLE
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/cybersun
	name = "Cybersun Industries"
	employer_name = "Your handler"
	description = "You're an agent of Cybersun Industries, a prominent player in The Syndicate, and Nanotrasen's biggest competitor in cutting-edge robotics and cybernetics.\n\
   	Apart from any personal vendettas or debt you might owe, you may have been enticed with the promise of augments, enhancements, or life extending medical procedures.\n\ That is, if you succeed..."
	key = TRAITOR_FACTION_CYBERSUN
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/vahlen
	name = "Vahlen Pharmaceuticals"
	employer_name = "Vahlen Pharmaceuticals"
	description = "You've been deployed to this sector because of an incredible bounty of test subjects detected in local crew/shipment manifests.\n\
	Your next grant has been greenlit, with the condition that you collect samples, be that biological products, equipment, or cadavers."
	key = TRAITOR_FACTION_VAHLEN
	faction_theme = PDA_THEME_TERMINAL
	
/datum/traitor_faction/gorlex
	name = "Gorlex Marauders"
	employer_name = "Gorlex Marauders"
	description = "All across known space, ships go in fear of the Gorlex Marauder fleets.\n\
	Vicious pirates known for their brutality and audacity, only the ceaseless effort of NT security keeps them at bay. Except they failed. You’re already here."
	key = TRAITOR_FACTION_GORLEX
	faction_theme = PDA_THEME_SYNDICATE
