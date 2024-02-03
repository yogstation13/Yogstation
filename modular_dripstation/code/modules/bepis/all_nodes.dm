////////////////////////B.E.P.I.S. Locked Techs////////////////////////
/datum/techweb_node/light_apps
	id = "light_apps"
	display_name = "Illumination Applications"
	description = "Applications of lighting and vision technology not originally thought to be commercially viable."
	prereq_ids = list("base")
	design_ids = list("bright_helmet", "rld_mini")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/spec_eng
	id = "spec_eng"
	display_name = "Specialized Engineering"
	description = "Conventional wisdom has deemed these engineering products 'technically' safe, but far too dangerous to traditionally condone."
	prereq_ids = list("base")
	design_ids = list("eng_gloves", "lava_rods")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/aus_security
	id = "aus_security"
	display_name = "Australicus Security Protocols"
	description = "It is said that security in the Australicus sector is tight, so we took some pointers from their equipment. Thankfully, our sector lacks any signs of these, 'dropbears'."
	prereq_ids = list("base")
	design_ids = list("pin_explorer", "stun_boomerang")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/interrogation
	id = "interrogation"
	display_name = "Enhanced Interrogation Technology"
	description = "By cross-referencing several declassified documents from past dictatorial regimes, we were able to develop an incredibly effective interrogation device. \
	Ethical concerns about loss of free will do not apply to criminals, according to galactic law."
	prereq_ids = list("base")
	design_ids = list("hypnochair")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	hidden = TRUE
	experimental = TRUE
/*
/datum/techweb_node/tackle_advanced
	id = "tackle_advanced"
	display_name = "Advanced Grapple Technology"
	description = "Nanotrasen would like to remind its researching staff that it is never acceptable to \"glomp\" your coworkers, and further \"scientific trials\" on the subject will no longer be accepted in its academic journals."
	design_ids = list("tackle_dolphin", "tackle_rocket")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE
*/