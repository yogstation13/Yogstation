/datum/bloodsucker_clan/tzimisce
	name = CLAN_TZIMISCE
	description = "The page is covered in blood..."
	join_icon_state = "tzimisce"
	joinable_clan = FALSE //important
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY
	control_type = BLOODSUCKER_CONTROL_FLESH

/datum/bloodsucker_clan/tzimisce/New(mob/living/carbon/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	bloodsuckerdatum.AddHumanityLost(5.6)
	bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/dice)
	user.faction |= "bloodhungry" //flesh monster's clan
	var/list/powerstoremove = list(/datum/action/bloodsucker/veil, /datum/action/bloodsucker/masquerade)
	for(var/datum/action/bloodsucker/P in bloodsuckerdatum.powers)
		if(is_type_in_list(P, powerstoremove))
			bloodsuckerdatum.RemovePower(P)

/datum/bloodsucker_clan/tzimisce/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/bloodsucker)
	if(!ishuman(vassaldatum.owner.current))
		return
	var/mob/living/carbon/human/vassal = vassaldatum.owner.current
	if(!INVOKE_ASYNC(src, PROC_REF(slash_vassal), bloodsucker, 1 SECONDS, vassal))
		return
	playsound(vassal.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	if(!INVOKE_ASYNC(src, PROC_REF(slash_vassal), bloodsucker, 1 SECONDS, vassal))
		return
	playsound(vassal.loc, 'sound/effects/splat.ogg', 50, TRUE)
	INVOKE_ASYNC(vassal, TYPE_PROC_REF(/mob/, set_species), /datum/species/szlachta)

/datum/bloodsucker_clan/tzimisce/proc/slash_vassal(mob/living/bloodsucker, time, mob/living/vassal)
	do_after(bloodsucker, time, vassal, FALSE, TRUE, null, FALSE) //necessary becaues of how signal handler works
