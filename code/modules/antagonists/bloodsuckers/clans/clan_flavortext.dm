/datum/bloodsucker_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue Clan is extremely snobby with their meals, and refuse to drink blood from people without a mind. \n\
		There is additionally no way to rank themselves up, instead will have to rank their Favorite vassal through a Persuasion Rack. \n\
		The Favorite Vassal will slowly turn into a Bloodsucker this way, until they finally lose their last bits of Humanity."
	joinable_clan = FALSE
	clan_objective = /datum/objective/ventrue_clan_objective
	join_icon_state = "ventrue"
	join_description = "Lose the ability to drink from mindless mobs, can't level up or gain new powers, \
		instead you raise a vassal into a Bloodsucker."
//	rank_up_type = BLOODSUCKER_RANK_UP_VASSAL
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY

/**
 * Clan Objective
 * Ventrue's Clan objective is to upgrade the Favorite Vassal
 * enough to make them a Bloodsucker.
 */
/datum/objective/ventrue_clan_objective
	name = "embrace"
	explanation_text = "Use the Candelabrum to Rank your Favorite Vassal up enough to become a Bloodsucker and keep them alive until the end."
	martyr_compatible = TRUE

/datum/objective/ventrue_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	for(var/datum/antagonist/vassal/vassaldatum as anything in bloodsuckerdatum.vassals)
		if(!vassaldatum.owner || !vassaldatum.owner.current)
			continue
		if(IS_FAVORITE_VASSAL(vassaldatum.owner.current) && vassaldatum.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			return TRUE
	return FALSE

/datum/bloodsucker_clan/tremere
	name = CLAN_TREMERE
	description = "The Tremere Clan is extremely weak to True Faith, and will burn when entering areas considered such, like the Chapel. \n\
		Additionally, a whole new moveset is learned, built on Blood magic rather than Blood abilities, which are upgraded overtime. \n\
		More ranks can be gained by Vassalizing crewmembers. \n\
		The Favorite Vassal gains the Batform spell, being able to morph themselves at will."
	joinable_clan = FALSE
//	clan_objective = /datum/objective/tremere_clan_objective
	join_icon_state = "tremere"
	join_description = "You will burn if you enter the Chapel, lose all default powers, \
		but gain Blood Magic instead, powers you level up overtime."

/**
 * Clan Objective
 * Tremere's Clan objective is to upgrade a power to max
 * clan not implemented yet
/datum/objective/tremere_clan_objective
	name = "tremerepower"
	explanation_text = "Upgrade a Blood Magic power to the maximum level, remember that Vassalizing gives more Ranks!"

/datum/objective/tremere_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	for(var/datum/action/cooldown/bloodsucker/targeted/tremere/tremere_powers in bloodsuckerdatum.powers)
		if(tremere_powers.level_current >= 5)
			return TRUE
	return FALSE
*/

/datum/bloodsucker_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Bloodsucker upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanetly disfigured, and can also ventcrawl, but only while entirely nude."
	joinable_clan = FALSE
	clan_objective = /datum/objective/nosferatu_clan_objective
	join_icon_state = "nosferatu"
	join_description = "You are permanetly disfigured, look like a Bloodsucker to all who examine you, \
		lose your Masquerade ability, but gain the ability to Ventcrawl even while clothed."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/**
 * Clan objective
 * Nosferatu's objective is to steal the Curator's Archives of the Kindred.
 */
/datum/objective/nosferatu_clan_objective
	name = "steal kindred"
	explanation_text = "Ensure Nosferatu steals and keeps control over the Archive of the Kindred."

/datum/objective/nosferatu_clan_objective/check_completion()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		var/obj/item/book/kindred/the_book = locate() in bloodsucker_minds.current.get_all_contents()
		if(the_book)
			return TRUE
	return FALSE

/datum/bloodsucker_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Little is documented about Malkavians. Complete insanity is the most common theme. \n\
		The Favorite Vassal will suffer the same fate as the Master."
	join_icon_state = "malkavian"
	join_description = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, \
		and become the enforcer of the Masquerade code."
	joinable_clan = FALSE
	frenzy_stun_immune = TRUE
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY
