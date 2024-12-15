/datum/ert
	var/mobtype = /mob/living/carbon/human
	var/team = /datum/team/ert
	var/opendoors = TRUE
	var/leader_role = /datum/antagonist/ert/commander
	var/enforce_human = TRUE
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer) //List of possible roles to be assigned to ERT members.
	var/rename_team
	var/code
	var/mission = "Assist the station."
	var/teamsize = 5
	var/polldesc
	/// If TRUE, gives the team members "[role] [random last name]" style names
	var/random_names = TRUE
	/// If TRUE, the admin who created the response team will be spawned in the briefing room in their preferred briefing outfit (assuming they're a ghost)
	var/spawn_admin = FALSE
	/// If TRUE, we try and pick one of the most experienced players who volunteered to fill the leader slot
	var/leader_experience = TRUE
	/// A custom map template to spawn the ERT at. If this is null or use_custom_shuttle is FALSE, the ERT will spawn at Centcom.
	var/datum/map_template/ert_template
	/// If we should actually _use_ the ert_template custom shuttle
	var/use_custom_shuttle = TRUE
	//MONKESTATION EDIT START
	//If we want a custom name for the poll title
	var/poll_title = "Emergency Response Team"
	//If we want a custom poll icon
	var/poll_icon = /obj/item/clothing/head/helmet/space/ert
	//MONKESTATION EDIT END

/datum/ert/New()
	if (!polldesc)
		polldesc = "a Code [code] Nanotrasen Emergency Response Team"

/datum/ert/blue
	opendoors = FALSE
	code = "Blue"

/datum/ert/amber
	code = "Amber"

/datum/ert/red
	leader_role = /datum/antagonist/ert/commander/red
	roles = list(/datum/antagonist/ert/security/red, /datum/antagonist/ert/medic/red, /datum/antagonist/ert/engineer/red)
	code = "Red"

/datum/ert/deathsquad
	roles = list(/datum/antagonist/ert/deathsquad)
	leader_role = /datum/antagonist/ert/deathsquad/leader
	rename_team = "Deathsquad"
	code = "Delta"
	mission = "Leave no witnesses."
	polldesc = "an elite Nanotrasen Strike Team"

/datum/ert/marine
	leader_role = /datum/antagonist/ert/marine
	roles = list(/datum/antagonist/ert/marine/security, /datum/antagonist/ert/marine/engineer, /datum/antagonist/ert/marine/medic)
	rename_team = "Marine Squad"
	polldesc = "an 'elite' Nanotrasen Strike Team"
	opendoors = FALSE

/datum/ert/centcom_official
	code = "Green"
	teamsize = 1
	opendoors = FALSE
	leader_role = /datum/antagonist/ert/official
	roles = list(/datum/antagonist/ert/official)
	rename_team = "CentCom Officials"
	polldesc = "a CentCom Official"
	random_names = FALSE
	leader_experience = FALSE

/datum/ert/centcom_official/New()
	mission = "Conduct a routine performance review of [station_name()] and its Captain."

/datum/ert/inquisition
	roles = list(/datum/antagonist/ert/chaplain/inquisitor, /datum/antagonist/ert/security/inquisitor, /datum/antagonist/ert/medic/inquisitor)
	leader_role = /datum/antagonist/ert/commander/inquisitor
	rename_team = "Inquisition"
	mission = "Destroy any traces of paranormal activity aboard the station."
	polldesc = "a Nanotrasen paranormal response team"

/datum/ert/janitor
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	leader_role = /datum/antagonist/ert/janitor/heavy
	teamsize = 4
	opendoors = FALSE
	rename_team = "Janitor"
	mission = "Clean up EVERYTHING."
	polldesc = "a Nanotrasen Janitorial Response Team"

/datum/ert/intern
	roles = list(/datum/antagonist/ert/intern)
	leader_role = /datum/antagonist/ert/intern/leader
	teamsize = 7
	opendoors = FALSE
	rename_team = "Horde of Interns"
	mission = "Assist in conflict resolution."
	polldesc = "an unpaid internship opportunity with Nanotrasen"
	random_names = FALSE

/datum/ert/intern/unarmed
	roles = list(/datum/antagonist/ert/intern/unarmed)
	leader_role = /datum/antagonist/ert/intern/leader/unarmed
	rename_team = "Unarmed Horde of Interns"

/datum/ert/erp
	roles = list(/datum/antagonist/ert/security/party, /datum/antagonist/ert/clown/party, /datum/antagonist/ert/engineer/party, /datum/antagonist/ert/janitor/party)
	leader_role = /datum/antagonist/ert/commander/party
	opendoors = FALSE
	rename_team = "Emergency Response Party"
	mission = "Create entertainment for the crew."
	polldesc = "a Code Rainbow Nanotrasen Emergency Response Party"
	code = "Rainbow"

/datum/ert/bounty_hunters
	roles = list(/datum/antagonist/ert/bounty_armor, /datum/antagonist/ert/bounty_hook, /datum/antagonist/ert/bounty_synth)
	leader_role = /datum/antagonist/ert/bounty_armor
	teamsize = 3
	opendoors = FALSE
	rename_team = "Bounty Hunters"
	mission = "Assist the station in catching perps, dead or alive."
	polldesc = "a Centcom-hired bounty hunting gang"
	random_names = FALSE
	ert_template = /datum/map_template/shuttle/ert/bounty

/datum/ert/militia
	roles = list(/datum/antagonist/ert/militia, /datum/antagonist/ert/militia/general)
	leader_role = /datum/antagonist/ert/militia/general
	teamsize = 4
	opendoors = FALSE
	rename_team = "Frontier Militia"
	mission = "Having heard the station's request for aid, assist the crew in defending themselves."
	polldesc = "an independent station defense militia"
	random_names = TRUE

//MONKESTATION EDIT START
/datum/ert/code
	leader_role = /datum/antagonist/ert/generic/commander
	roles = list(
		/datum/antagonist/ert/generic,
	)
	teamsize = 6
	opendoors = FALSE
	polldesc = "an Uncoded Emergency Response Team"
	ert_template = /datum/map_template/shuttle/ert/dropship

/datum/ert/code/green
	leader_role = /datum/antagonist/ert/generic/commander
	roles = list(
		/datum/antagonist/ert/generic/medical,
		/datum/antagonist/ert/generic/security,
		/datum/antagonist/ert/generic/engineer,
		/datum/antagonist/ert/generic/janitor,
		/datum/antagonist/ert/generic/chaplain,
	)
	code = "Green"
	polldesc = NONE
	opendoors = FALSE
	ert_template = /datum/map_template/shuttle/ert/generic

/datum/ert/code/green/with_clown
	teamsize = 7
	roles = list(
		/datum/antagonist/ert/generic/medical,
		/datum/antagonist/ert/generic/security,
		/datum/antagonist/ert/generic/engineer,
		/datum/antagonist/ert/generic/janitor,
		/datum/antagonist/ert/generic/chaplain,
		/datum/antagonist/ert/generic/clown, // Honk
	)

/datum/ert/code/blue
	leader_role = /datum/antagonist/ert/generic/commander/blue
	roles = list(
		/datum/antagonist/ert/generic/medical/blue,
		/datum/antagonist/ert/generic/security/blue,
		/datum/antagonist/ert/generic/engineer/blue,
		/datum/antagonist/ert/generic/janitor/blue,
		/datum/antagonist/ert/generic/chaplain/blue,
	)
	code = "Blue"
	polldesc = NONE
	opendoors = FALSE
	ert_template = /datum/map_template/shuttle/ert/generic

/datum/ert/code/blue/with_clown
	teamsize = 7
	roles = list(
		/datum/antagonist/ert/generic/medical/blue,
		/datum/antagonist/ert/generic/security/blue,
		/datum/antagonist/ert/generic/engineer/blue,
		/datum/antagonist/ert/generic/janitor/blue,
		/datum/antagonist/ert/generic/chaplain/blue,
		/datum/antagonist/ert/generic/clown/funny, // Honk
	)

/datum/ert/code/red
	leader_role = /datum/antagonist/ert/generic/commander/red
	roles = list(
		/datum/antagonist/ert/generic/medical/red,
		/datum/antagonist/ert/generic/security/red,
		/datum/antagonist/ert/generic/engineer/red,
		/datum/antagonist/ert/generic/janitor/red,
		/datum/antagonist/ert/generic/chaplain/red,
	)
	code = "Red"
	polldesc = NONE
	opendoors = TRUE
	ert_template = /datum/map_template/shuttle/ert/generic

/datum/ert/code/red/with_clown
	teamsize = 7
	roles = list(
		/datum/antagonist/ert/generic/medical/red,
		/datum/antagonist/ert/generic/security/red,
		/datum/antagonist/ert/generic/engineer/red,
		/datum/antagonist/ert/generic/janitor/red,
		/datum/antagonist/ert/generic/chaplain/red,
		/datum/antagonist/ert/generic/clown/funnier, // Honk
	)

/datum/ert/code/honk
	leader_role = /datum/antagonist/ert/generic/clown/funny
	roles = list(
		/datum/antagonist/ert/generic/clown,
	)
	code = "Honk"
	polldesc = NONE
	opendoors = FALSE
	ert_template = /datum/map_template/shuttle/ert/dropship/clown

/datum/ert/code/purple
	leader_role = /datum/antagonist/ert/generic/janitor/blue
	roles = list(
		/datum/antagonist/ert/generic/janitor,
	)
	opendoors = FALSE
	ert_template = /datum/map_template/shuttle/ert/dropship/janitor
	mission = "Clean up EVERYTHING."
	poll_icon = /obj/item/clothing/head/helmet/space/ert/janitor
	polldesc = "a Nanotrasen Janitorial Response Team"

/datum/ert/code/lambda
	leader_role = /datum/antagonist/ert/generic/chaplain/red
	roles = list(
		/datum/antagonist/ert/generic/chaplain/red,
	)
	code = "Lambda"
	polldesc = NONE
	opendoors = FALSE
	teamsize = 5
	poll_icon = /obj/item/clothing/head/helmet/space/ert/chaplain
	ert_template = /datum/map_template/shuttle/ert/dropship

/datum/ert/code/epsilon
	leader_role = /datum/antagonist/ert/generic/deathsquad
	roles = list(
		/datum/antagonist/ert/generic/deathsquad,
	)
	opendoors = FALSE
	rename_team = "Deathsquad"
	code = "Epsilon"
	mission = "Leave no witnesses."
	teamsize = 5
	poll_title = "Deathsquad"
	poll_icon = /obj/item/clothing/mask/gas/sechailer/swat
	polldesc = "an elite Nanotrasen Strike Team"
	ert_template = /datum/map_template/shuttle/ert/deathsquad

/datum/ert/code/epsilon/dust
	leader_role = /datum/antagonist/ert/generic/deathsquad/dust
	roles = list(
		/datum/antagonist/ert/generic/deathsquad/dust,
	)
//MONKESTATION EDIT END
