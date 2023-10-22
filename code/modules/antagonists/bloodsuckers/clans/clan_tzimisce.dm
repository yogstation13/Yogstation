/datum/bloodsucker_clan/tzimisce
	name = CLAN_TZIMISCE
	description = "The page is covered in blood..."
	join_icon_state = "tzimisce"
//	clan_objective = TBD
	joinable_clan = FALSE //important
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY
	control_type = BLOODSUCKER_CONTROL_FLESH

/datum/bloodsucker_clan/tzimisce/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	bloodsuckerdatum.AddHumanityLost(5.6)
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/dice)
	bloodsuckerdatum.owner.current.faction |= "bloodhungry" //flesh monster's clan
	var/list/powerstoremove = list(/datum/action/cooldown/bloodsucker/veil, /datum/action/cooldown/bloodsucker/masquerade)
	for(var/datum/action/cooldown/bloodsucker/banned_power in bloodsuckerdatum.powers)
		if(is_type_in_list(banned_power, powerstoremove))
			bloodsuckerdatum.RemovePower(banned_power)

/datum/bloodsucker_clan/tzimisce/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	if(!ishuman(vassaldatum.owner.current))
		return
	var/mob/living/carbon/human/vassal = vassaldatum.owner.current
	if(!INVOKE_ASYNC(src, PROC_REF(slash_vassal), bloodsuckerdatum.owner.current, 1 SECONDS, vassal))
		return
	playsound(vassal.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	if(!INVOKE_ASYNC(src, PROC_REF(slash_vassal), bloodsuckerdatum.owner.current, 1 SECONDS, vassal))
		return
	playsound(vassal.loc, 'sound/effects/splat.ogg', 50, TRUE)
	INVOKE_ASYNC(vassal, TYPE_PROC_REF(/mob/, set_species), /datum/species/szlachta)

/datum/bloodsucker_clan/tzimisce/proc/slash_vassal(mob/living/bloodsucker, time, mob/living/vassal)
	do_after(bloodsucker, time, vassal, timed_action_flags = IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM) //necessary becaues of how signal handler works
