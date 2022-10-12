/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane(tzimisce = FALSE)
	var/mob/living/carbon/human/bloodsucker = owner.current
	if(tzimisce)
		my_clan = CLAN_TZIMISCE
		to_chat(owner, span_announce("As you arrive near the station, you recall all you know and why you are here.\n\
			* As a part of the Tzimisce Clan, you are able to <i>Dice</i> corpses into muscle pieces.\n\
			* With muscle pieces you are able to mutilate dead husked vassals into greater beings,\n\
			* The more you climb up the Ranks the more research you gather about fleshcrafting and beings you can make.\n\
			* Remember to fuel a vassalrack with the muscles to be able to toy with those dead vassals, you are also able to ressurect people this way.\n\
			* Finally, your Favorite Vassal will turn into a battle monster to help you in combat."))
		AddHumanityLost(5.6)
		BuyPower(new /datum/action/bloodsucker/targeted/dice)
		bloodsucker.faction |= "bloodhungry" //flesh monster's clan
		var/list/powerstoremove = list(/datum/action/bloodsucker/veil, /datum/action/bloodsucker/masquerade)
		for(var/datum/action/bloodsucker/P in powers)
			if(is_type_in_list(P, powerstoremove))
				RemovePower(P)
		return
	var/static/list/clans = list(
		CLAN_GANGREL,
		CLAN_LASOMBRA,
		CLAN_TOREADOR,
	)
	var/list/options = list()
	options = clans
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:\n\
		Gangrel - Prone to Frenzy, strange outcomes from being on frenzy, special power.\n\
		Lasombra - Life in the shadows, very weak to fire but no brute damage, upgradable abilities through tasks.\n\
		Toreador - More human then other bloodsucker, easily disguise among crew, but bound with morals."))

	var/answer = input("You have Ranked up far enough to remember your clan. Which clan are you part of?", "Your mind feels luxurious...") in options
	if(!answer) 
		to_chat(owner, span_warning("You have willfully decided to stay ignorant."))
		return
	switch(answer)
		if(CLAN_GANGREL)
			my_clan = CLAN_GANGREL
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Gangrel Clan!\n\
				* As part of the Gangrel Clan, your inner beast has a stronger impact in your undead life.\n\
				* You are prone to falling into a frenzy, and will unleash a wild beast form when doing so,\n\
				* Though once per night you are able to unleash your inner beast to help you in combat.\n\
				* Due to growing more feral you've also strayed away from other bloodsuckers and will only be able to maintain one vassal.\n\
				* Finally, your Favorite Vassal will gain the Minor Beast Form ability to help you in combat."))
			AddHumanityLost(16.8)
			BuyPower(new /datum/action/bloodsucker/gangrel/transform)
			bloodsucker.faction |= "bloodhungry" //i love animals i love animals
			RemovePower(/datum/action/bloodsucker/masquerade)
			var/datum/objective/bloodsucker/frenzy/gangrel_objective = new
			gangrel_objective.owner = owner
			objectives += gangrel_objective
		if(CLAN_LASOMBRA)
			my_clan = CLAN_LASOMBRA
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Lasombra Clan!\n\
				* As part of the Lasombra Clan, your past teachings have shown you how to become in touch with the Abyss and practice its prophecies.\n\
				* It'll take long before the Abyss can break through this plane's veil, but you'll try to salvage any of the energy that comes through,\n\
				* To harness it's energy you must first find an influence and make a Resting Place altar to feed the harvested essence to.\n\
				* On the Resting Place you can give ranks or blood in exchange for shadowpoints, that can be spent on the table to ascend your abilities.\n\
				* The Abyss has blackened your veins and made you immune to brute damage but highly receptive to burn, so you might need to be extra careful when in Torpor.\n\
				* Finally, your Favorite Vassal will gain the Lesser Glare and Shadow Walk abilities to help you in combat."))
			bloodsucker.physiology.burn_mod *= 2
			bloodsucker.physiology.brute_mod *= 0
			bloodsucker.eye_color = "f00"
			ADD_TRAIT(bloodsucker, CULT_EYES, BLOODSUCKER_TRAIT)
			bloodsucker.update_body()
			var/obj/item/organ/heart/nightmare/nightmarish_heart = new
			nightmarish_heart.Insert(bloodsucker)
			nightmarish_heart.Stop()
			for(var/obj/item/light_eater/blade in bloodsucker.held_items)
				QDEL_NULL(blade)
			GLOB.reality_smash_track.AddMind(owner)
			var/datum/objective/bloodsucker/hierarchy/lasombra_objective = new
			lasombra_objective.owner = owner
			objectives += lasombra_objective
			to_chat(owner, span_notice("You have also learned how to channel the abyss's power into an iron knight's armor that can be build in the structure ta and activated as a trap for your lair."))
			owner.teach_crafting_recipe(/datum/crafting_recipe/possessedarmor)
			owner.teach_crafting_recipe(/datum/crafting_recipe/restingplace)
		if(CLAN_TOREADOR)
			my_clan = CLAN_TOREADOR
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Toreador Clan!\n\
				* As part of the Toreador, you can't ignore your own emotions and you disrespect inhuman actions.\n\
				* Being in Masquerade doesn't spend your blood, or have any negative effects on your immortal powers.\n\
				* You passively raise morale of your living vassals around you.\n\
				* Also you get really sad when comitting inhumane actions, but your humanity loss can't go above a certain threshold.\n\
				* Remember that those bloodsuckers who dare to act inhuman or break the Masquerade shouldn't be forgiven, and deserve only <span class='red'>death</span>.\n\
				* Finally, your Favorite Vassal will gain the Mesmerise ability to help you in non-lethally dealing with enemies or vassalising people."))
			if(owner.current && ishuman(owner.current) && !owner.current.GetComponent(/datum/component/mood))
				owner.current.AddComponent(/datum/component/mood) //You are not a emotionless beast!

			for(var/datum/action/bloodsucker/masquerade/masquarade_spell in powers)
				if(!istype(masquarade_spell))
					continue
				masquarade_spell.bloodcost = 0
				masquarade_spell.constant_bloodcost = 0 //Wow very cool code, good job

	owner.announce_objectives()
