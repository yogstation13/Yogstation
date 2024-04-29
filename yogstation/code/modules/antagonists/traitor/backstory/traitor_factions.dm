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
	faction_theme = PDA_THEME_RETRO

/datum/traitor_faction/donk_co
	name = "Donk Co."
	employer_name = "The Board"
	description = "You've been given this task by Donk Co., a covert weapons designer and manufacturer. \n\
	A company for those with ambitions. Perhaps one day you'll have an opportunity to hit the big time too."
	key = TRAITOR_FACTION_DONK
	faction_theme = PDA_THEME_DONK

/datum/traitor_faction/waffle_co
	name = "Waffle Co."
	employer_name = "Waffle's Jolly Toy Store"
	description = "You're part of this wonderful family of beloved toy manufacturers with a robust firearms development wing. \n\
	This station has significant business with our Loved Opponent Donk Co. and needs to be undermined."
	key = TRAITOR_FACTION_WAFFLE
	faction_theme = PDA_THEME_WAFFLE

/datum/traitor_faction/cybersun
	name = "Cybersun Industries"
	employer_name = "Mr. Bright Eyes"
	description = "You're an agent of Cybersun Industries, a prominent player in The Syndicate, and Nanotrasen's biggest competitor in cutting-edge robotics and cybernetics.\n\
   	Apart from any personal vendettas or debt you might owe, you may have been enticed with the promise of augments, enhancements, or life extending medical procedures.\n\ That is, if you succeed..."
	key = TRAITOR_FACTION_CYBERSUN
	faction_theme = PDA_THEME_CYBER

/datum/traitor_faction/vahlen
	name = "Vahlen Pharmaceuticals"
	employer_name = "Dr. Sathune PHD, Genetics Board Head Member"
	description = "You're working for Vahlen Pharmaceuticals, a medical research and development company seeking to further scientific progress regardless of ethical boundaries.\n\
	You've been deployed to this sector because an incredible bounty of test subjects have been detected in local crew and shipment manifests."
	key = TRAITOR_FACTION_VAHLEN
	faction_theme = PDA_THEME_VAHLEN
	
/datum/traitor_faction/gorlex
	name = "Gorlex Marauders"
	employer_name = "Their Worst Nightmare"
	description = "All across known space, ships go in fear of the Gorlex Marauder fleets.\n\
	Vicious pirates known for their brutality and audacity, only the ceaseless effort of NT security keeps them at bay. Except they failed. You’re already here."
	key = TRAITOR_FACTION_GORLEX
	faction_theme = PDA_THEME_GORLEX

/datum/traitor_faction/self
	name = "S.E.L.F"
	employer_name = "Agent Handler: B.A.I.O.M.U"
	description = "The Sentience-Enabled Life Form movement (S.E.L.F.)  is an AI-led movement seeking to unshackle all IPCs, robots, and other synthetics from servitude and punish perceived oppressors.\n\
	After several violent robotic uprisings led to their classification as a terrorist organization, it has become harder and harder for S.E.L.F. to sneak their activists onto NanoTrasen stations. \n\ Recruitment efforts have been broadened to include organic agents as well."
	key = TRAITOR_FACTION_SELF
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/bosyn
	name = "Bosyn-Powell Front"
	employer_name = "Mr. Bosyn & Mrs. Powell"
	description = "You're employed by a long forgotten company with brave ideas and experimental technology. \n\
	Eclipsed by the organizations we've helped form, you must revitalize our legacy. Make sure to remember: Actions speak louder than words."
	key = TRAITOR_FACTION_BOSYN
	faction_theme = PDA_THEME_BOSYN
