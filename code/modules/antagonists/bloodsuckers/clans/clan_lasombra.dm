/datum/bloodsucker_clan/lasombra
	name = CLAN_LASOMBRA
	description = "This Clan seems to adore living in the Shadows, worshipping it's secrets. \n\
		They take their research and vanity seriously, they are always very proud of themselves after even minor achievements. \n\
		They appear to be in search of a station with a veil weakness to be able to channel their shadow's abyssal powers. \n\
		Thanks to this, they have also evolved a dark liquid in their veins, which makes them able to manipulate shadows. \n\
		Their Favorite Vassal appears to have been imbued with abyssal essence and is able to blend in with the shadows."
	clan_objective = /datum/objective/lasombra_clan_objective
	join_icon_state = "lasombra"
	join_description = "Heal more on the dark, transform abilties into upgraded ones, become one with the darkness."
	control_type = BLOODSUCKER_CONTROL_SHADOWS

/datum/objective/lasombra_clan_objective
	name = "hierarchy"

/datum/objective/lasombra_clan_objective/New()
	target_amount = rand(1, 2)
	..()
	update_explanation_text()

/datum/objective/lasombra_clan_objective/update_explanation_text()
	. = ..()
	explanation_text = "Ascend [target_amount == 1 ? "at least 1 ability" : "2 abilities"] using a Resting Place altar."

/datum/objective/lasombra_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	if(bloodsuckerdatum.clanprogress >= target_amount)
		return TRUE
	return FALSE

/datum/bloodsucker_clan/lasombra/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	bloodsuckerdatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/lasombra)
	if(ishuman(bloodsuckerdatum.owner.current))
		var/mob/living/carbon/human/human_user = bloodsuckerdatum.owner.current
		human_user.eye_color = BLOODCULT_EYE
		human_user.update_body()
		human_user.updateappearance()
	ADD_TRAIT(bloodsuckerdatum.owner.current, CULT_EYES, BLOODSUCKER_TRAIT)
	bloodsuckerdatum.owner.current.faction |= "bloodhungry"
	bloodsuckerdatum.owner.current.update_body()
	var/obj/item/organ/heart/nightmare/nightmarish_heart = new
	nightmarish_heart.Insert(bloodsuckerdatum.owner.current)
	nightmarish_heart.Stop()
	for(var/obj/item/light_eater/blade in bloodsuckerdatum.owner.current.held_items)
		QDEL_NULL(blade)
	GLOB.reality_smash_track.AddMind(bloodsuckerdatum.owner)
	to_chat(bloodsuckerdatum.owner.current, span_notice("You have also learned how to channel the abyss's power into an iron knight's armor that can be build in the structure tab and activated as a trap for your lair."))
	bloodsuckerdatum.owner.teach_crafting_recipe(/datum/crafting_recipe/possessedarmor)
	bloodsuckerdatum.owner.teach_crafting_recipe(/datum/crafting_recipe/restingplace)

/datum/bloodsucker_clan/lasombra/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	vassaldatum.BuyPower(new /datum/action/cooldown/spell/pointed/seize/lesser)
	vassaldatum.BuyPower(new /datum/action/cooldown/spell/jaunt/shadow_walk)
	if(ishuman(vassaldatum.owner.current))
		var/mob/living/carbon/human/vassal = vassaldatum.owner.current
		vassal.eye_color = BLOODCULT_EYE
		vassal.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		ADD_TRAIT(vassal, CULT_EYES, BLOODSUCKER_TRAIT)	
		var/obj/item/organ/eyes/current_eyes = vassal.getorganslot(ORGAN_SLOT_EYES)
		if(current_eyes)
			current_eyes.color_cutoffs = list(25, 8, 5)
			current_eyes.lighting_cutoff = LIGHTING_CUTOFF_REAL_LOW

		vassal.update_body()
		vassal.update_sight()
		vassal.update_appearance()
