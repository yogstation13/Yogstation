/obj/item/card/id/advanced/old
	icon_state = "retro"
	inhand_icon_state = "card-id"
	worn_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/datum/id_trim/away/old/cmo
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_COMMAND, ACCESS_AWAY_MEDICAL, ACCESS_AWAY_MAINTENANCE)
	assignment = "Charlie Station Chief Medical Officer"
	sechud_icon_state = SECHUD_CHIEF_MEDICAL_OFFICER_AWAY

/datum/id_trim/away/old/chef
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE)
	assignment = "Charlie Station Chef"
	sechud_icon_state = SECHUD_CHEF_AWAY

/datum/id_trim/away/old/explorer
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SCIENCE, ACCESS_AWAY_MAINTENANCE, ACCESS_AWAY_SUPPLY, ACCESS_AWAY_GENERIC1, ACCESS_AWAY_GENERIC2, ACCESS_AWAY_GENERIC3, ACCESS_AWAY_GENERIC4) //purposefully has the most msc. access giving them a advantage for having less equipment than a normal explorer upon start.
	assignment = "Charlie Station Explorer"
	sechud_icon_state = SECHUD_EXPLORER_AWAY

/datum/id_trim/away/old/sci
	sechud_icon_state = SECHUD_SCIENTIST_AWAY
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SCIENCE, ACCESS_RESEARCH)

/datum/id_trim/away/old/sec
	sechud_icon_state = SECHUD_SECURITY_OFFICER_AWAY

/datum/id_trim/away/old/eng
	sechud_icon_state = SECHUD_STATION_ENGINEER_AWAY

/datum/id_trim/away/old/robo
	sechud_icon_state = SECHUD_ROBOTICIST_AWAY
	access = list(ACCESS_AWAY_GENERAL, ACCESS_ROBOTICS, ACCESS_ORDNANCE, ACCESS_RESEARCH, ACCESS_AWAY_SCIENCE)

/datum/id_trim/away/old/apc
	sechud_icon_state = SECHUD_APC_AWAY

/datum/id_trim/pirate/lustrous
	sechud_icon_state = SECHUD_RADIANT
