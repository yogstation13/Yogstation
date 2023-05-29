/datum/bloodsucker_clan/hecata
	name = CLAN_HECATA
	description = "This Clan is composed of curious practioners of dark magic who enjoy toying with the dead. \n\
		Often compared to the Lasombra, they sometimes act in similar ways and draw power from the void. \n\
		However, they are also very different, and place an emphasis on creating zombie like puppets from the dead. \n\
		They are able to raise the dead as temporary vassals, permanently revive dead vassals, communicate to their vassals from afar, and summon wraiths. \n\
		Their Favorite Vassal also has inherited a small fraction of their power, being able to call wraiths into the world as well."
	clan_objective = /datum/objective/bloodsucker/necromance
	join_icon_state = "hecata"
	join_description = "Raise zombie hordes from the dead, and then coordinate them from anywhere anytime."
	blood_drink_type = BLOODSUCKER_DRINK_PAINFUL

/datum/bloodsucker_clan/hecata/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/hecata/necromancy)
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/hecata/spiritcall)
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/hecata/communion)
	bloodsuckerdatum.owner.current.faction |= "bloodhungry"
	bloodsuckerdatum.owner.current.update_body()

/datum/bloodsucker_clan/hecata/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	vassaldatum.BuyPower(new /datum/action/cooldown/bloodsucker/hecata/spiritcall)
