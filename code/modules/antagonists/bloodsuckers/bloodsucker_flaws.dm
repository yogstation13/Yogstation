/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane()
	var/static/list/clans = list(
		CLAN_GANGREL,
        "None",
	)
	var/list/options = list()
	options = clans
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:\n\
		Gangrel - Prone to Frenzy, special power.\n\
		None - Continue living without a clan."))

	var/answer = input("You have Ranked up far enough to remember your clan. Which clan are you part of?", "Our mind feels luxurious...") in options
	if(!answer || answer == "None") 
		to_chat(owner, span_warning("You have wilingfully decided to stay ignorant."))
		return
	if(answer == CLAN_GANGREL)
		my_clan = CLAN_GANGREL
		var/mob/living/carbon/human/user = owner
		to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Gangrel Clan!\n\
			* As part of the Gangrel Clan, your inner beast has a stronger impact in your undead life.\n\
			* You are prone to falling into a frenzy, and will unleash a wild beast form when doing so,\n\
			* Though once per night you are able to unleash your inner beast to help you in combat.\n\
			* Due to growing more feral you've also strayed away from other bloodsuckers and will only be able to maintain one vassal.\n\
			* Finally, your Favorite Vassal will gain the Minor Beast Form ability to help you in combat."))
		AddHumanityLost(22.4)
		BuyPower(new /datum/action/bloodsucker/gangrel/transform)
		user.faction |= "bloodhungry" //i love animals i love animals
		
	owner.announce_objectives()