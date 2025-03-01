/obj/item/card/id/advanced/old
	icon_state = "retro"
	inhand_icon_state = "card-id"
	worn_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/datum/id_trim/job/away/old/cmo
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_MAINTENANCE
	)
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_SCIENCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)
	assignment = "Charlie Station Chief Medical Officer"
	sechud_icon_state = SECHUD_CHIEF_MEDICAL_OFFICER_AWAY

/datum/id_trim/job/away/old/chef
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_MAINTENANCE
	)
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_SCIENCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)
	assignment = "Charlie Station Chef"
	sechud_icon_state = SECHUD_CHEF_AWAY

/datum/id_trim/job/away/old/explorer
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_SCIENCE,
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4
	) //purposefully has the most msc. access giving them a advantage for having less equipment than a normal explorer upon start.
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)
	assignment = "Charlie Station Explorer"
	sechud_icon_state = SECHUD_EXPLORER_AWAY

/datum/id_trim/job/away/old/sci
	sechud_icon_state = SECHUD_SCIENTIST_AWAY
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_SCIENCE,
		ACCESS_RESEARCH
	)
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)

/datum/id_trim/job/away/old/sec
	sechud_icon_state = SECHUD_SECURITY_OFFICER_AWAY

/datum/id_trim/job/away/old/eng
	sechud_icon_state = SECHUD_STATION_ENGINEER_AWAY

/datum/id_trim/job/away/old/robo
	sechud_icon_state = SECHUD_ROBOTICIST_AWAY
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_SCIENCE
	)
	extra_access = list(
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)

/datum/id_trim/job/away/old/equipment
	sechud_icon_state = SECHUD_APC_AWAY

/datum/id_trim/pirate/lustrous
	sechud_icon_state = SECHUD_RADIANT
