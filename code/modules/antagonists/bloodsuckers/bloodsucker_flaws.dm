/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane()
	var/static/list/clans = list(
		CLAN_GANGREL
        "None"
	)
	var/list/options = list()
	options = clans
	var/mob/living/carbon/human/bloodsucker = owner.current
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:\n\
		Gangrel - Prone to Frenzy, harder management, one vassal.\n\
		None - Continue living without a clan."))

	var/answer = input("You have Ranked up far enough to remember your clan. Which clan are you part of?", "Our mind feels luxurious...") in options
	if(!answer || answer == "None") 
		to_chat(owner, span_warning("You have wilingfully decided to stay ignorant."))
		return
	if(answer == CLAN_GANGREL)
		my_clan = CLAN_GANGREL
		to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Gangrel Clan!\n\
			* As part of the Gangrel Clan, though you are more prone to falling into Frenzy, which turns you into a savage beast, and can enter it whenever you want!\n\
			* Additionally, some of your powers have been upgraded. Use this to your advantage!\n\
			* Finally, your Favorite Vassal will gain the Minor Beast Form ability to help you in combat."))
		AddHumanityLost(17.5)
	owner.announce_objectives()