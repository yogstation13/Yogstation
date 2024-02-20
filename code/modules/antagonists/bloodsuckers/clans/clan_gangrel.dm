/datum/bloodsucker_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to Animals than Bloodsuckers, known as Werewolves waiting to happen, \n\
		these are the most fearful of True Faith, being the most lethal thing they would ever see the night of. \n\
		Full Moons do not seem to have an effect, despite common-told stories. \n\
		The Favorite Vassal turns into a Werewolf whenever their Master does."
	clan_objective = /datum/objective/gangrel_clan_objective
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

/datum/bloodsucker_clan/gangrel/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	var/datum/action/cooldown/spell/shapeshift/bat/batform = new(vassaldatum.owner || vassaldatum.owner.current)
	batform.Grant(vassaldatum.owner.current)

/// Enter Frenzy repeatedly
/datum/objective/gangrel_clan_objective
	name = "frenzy"

/datum/objective/gangrel_clan_objective/New()
	target_amount = rand(1, 2)
	..()

/datum/objective/gangrel_clan_objective/update_explanation_text()
	. = ..()
	explanation_text = "Enter Frenzy [target_amount == 1 ? "at least once" : "2 times"] without succumbing to Final Death."

/datum/objective/gangrel_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	if(bloodsuckerdatum.frenzies >= target_amount)
		return TRUE
	return FALSE
