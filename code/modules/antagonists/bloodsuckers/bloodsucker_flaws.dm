/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane()
	var/static/list/clans = list(
		CLAN_BRUJAH,
		CLAN_NOSFERATU,
		CLAN_TREMERE,
		CLAN_VENTRUE,
		CLAN_MALKAVIAN,
	)
	var/list/options = list()
	options = clans
	var/mob/living/carbon/human/bloodsucker = owner.current
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:\n\
		Brujah - Prone to Frenzy, Brawn buffed.\n\
		Nosferatu - Disfigured, no Masquerade, Ventcrawl.\n\
		Tremere - Burn in the Chapel, Blood Magic.\n\
		Ventrue - Cant drink from mindless mobs, can't level up, raise a vassal instead.\n\
		Malkavian - Complete insanity."))
	to_chat(owner, span_announce("* Read more about Clans here: https://wiki.fulp.gg/en/Bloodsucker. (we'll change it to yogs wiki when we get the page)"))

	var/answer = input("You have Ranked up far enough to remember your clan. Which clan are you part of?", "Our mind feels luxurious...") in options
	if(!answer)
		to_chat(owner, span_warning("You have wilingfully decided to stay ignorant."))
		return
	switch(answer)
		if(CLAN_BRUJAH)
			my_clan = CLAN_BRUJAH
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Brujah Clan!\n\
				* As part of the Bujah Clan, you are more prone to falling into Frenzy, though you are used to it, and can enter it whenever you want!\n\
				* Additionally, Brawn and punches deal more damage than other Bloodsuckers. Use this to your advantage!\n\
				* Finally, your Favorite Vassal will gain the Brawn ability to help you in combat."))
			/// Makes their max punch, and by extension Brawn, stronger - Stolen from SpendRank()
			var/datum/species/user_species = bloodsucker.dna.species
			user_species.punchdamagehigh += 1.5
			AddHumanityLost(17.5)
			BuyPower(new /datum/action/bloodsucker/brujah)
			var/datum/objective/bloodsucker/gourmand/brujah/brujah_objective = new
			brujah_objective.owner = owner
			objectives += brujah_objective
		if(CLAN_NOSFERATU)
			my_clan = CLAN_NOSFERATU
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Nosferatu Clan!\n\
				* As part of the Nosferatu Clan, you unable to disguise yourself within the crew, as such you do not know how to use the Masquerade or Veil ability.\n\
				* Additionally, in exchange for having a bad back, always looking like Pale death, and not being identifiable, you can fit into vents using Alt+Click.\n\
				* Finally, your Favorite Vassal will become disfigured and will be able to ventcrawl wile naked."))
			for(var/datum/action/bloodsucker/power in powers)
				if(istype(power, /datum/action/bloodsucker/masquerade) || istype(power, /datum/action/bloodsucker/veil))
					powers -= power
					if(power.active)
						power.DeactivatePower()
					power.Remove(owner.current)
			if(!bloodsucker.has_quirk(/datum/quirk/badback))
				bloodsucker.add_quirk(/datum/quirk/badback)
			if(bloodsucker.ventcrawler == !VENTCRAWLER_ALWAYS)
				bloodsucker.ventcrawler = VENTCRAWLER_ALWAYS
			if(!HAS_TRAIT(bloodsucker, TRAIT_DISFIGURED))
				ADD_TRAIT(bloodsucker, TRAIT_DISFIGURED, BLOODSUCKER_TRAIT)
			var/datum/objective/bloodsucker/kindred/kindred_objective = new
			kindred_objective.owner = owner
			objectives += kindred_objective
		if(CLAN_TREMERE)
			my_clan = CLAN_TREMERE
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Tremere Clan!\n\
				* As part of the Tremere Clan, you are weak to True Faith, as such are unable to enter the Chapel.\n\
				* Additionally, you cannot learn new Powers, instead you will upgrade your Blood Magic to grow stronger.\n\
				* You have been given a spare Rank to spend immediately, and you can get more manually by Vassalizing people."))
			remove_nondefault_powers()
			bloodsucker_level_unspent++
			var/datum/objective/bloodsucker/tremere_power/bloodmagic_objective = new
			bloodmagic_objective.owner = owner
			objectives += bloodmagic_objective
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/dominate)
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/auspex)
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/thaumaturgy)
		if(CLAN_VENTRUE)
			my_clan = CLAN_VENTRUE
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Ventrue Clan!\n\
				* As part of the Ventrue Clan, you are extremely snobby with your meals, and refuse to drink blood from people without a Mind.\n\
				* Additionally, you will no longer Rank up. You are now instead able to get a Favorite vassal, by putting a Vassal on the persuasion rack and attempting to Tortute them.\n\
				* Finally, you may Rank your Favorite Vassal (and your own powers) up by buckling them onto a Candelabrum and using it, this will cost a Rank or Blood to do."))
			to_chat(owner, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack/Candelabrum to see how they operate!"))
			var/datum/objective/bloodsucker/embrace/embrace_objective = new
			embrace_objective.owner = owner
			objectives += embrace_objective
		if(CLAN_MALKAVIAN)
			my_clan = CLAN_MALKAVIAN
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
			to_chat(owner, span_hypnophrase("Welcome to the Malkavian..."))
			to_chat(owner, span_userdanger("* Bloodsucker Malkavian: The voices will not go away. It is endless. You are trapped.\n\
			* If you get a Favorite Vassal, they will suffer a near fate as you, pick wisely."))
			bloodsucker.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
			bloodsucker.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
			ADD_TRAIT(bloodsucker, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)

	owner.announce_objectives()
