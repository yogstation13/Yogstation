/datum/bloodsucker_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to Animals than Bloodsuckers, known as Werewolves waiting to happen, \n\
		these are the most fearful of True Faith, being the most lethal thing they would ever see the night of. \n\
		Full Moons do not seem to have an effect, despite common-told stories. \n\
		The Favorite Vassal turns into a Werewolf whenever their Master does."
	clan_objective = /datum/objective/bloodsucker/frenzy
	join_icon_state = "gangrel"
	join_description = "Purely animalistic, full of transformation abilities, and special frenzy, an active threat at all times."
	frenzy_stun_immune = TRUE
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/gangrel/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	bloodsuckerdatum.AddHumanityLost(16.8)
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/gangrel/transform)
	bloodsuckerdatum.owner.current.faction |= "bloodhungry" //i love animals i love animals
	for(var/datum/action/cooldown/bloodsucker/masquerade/masquerade_power in bloodsuckerdatum.powers)
		bloodsuckerdatum.RemovePower(masquerade_power)

/datum/bloodsucker_clan/malkavian/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	var/datum/action/cooldown/spell/shapeshift/bat/batform = new(vassaldatum.owner || vassaldatum.owner.current)
	batform.Grant(vassaldatum.owner.current)
