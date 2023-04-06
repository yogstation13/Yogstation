/datum/bloodsucker_clan/lasombra
	name = CLAN_LASOMBRA
	description = "This Clan seems to adore living in the Shadows, worshipping it's secrets. \n\
		They take their research and vanity seriously, they are always very proud of themselves after even minor achievements. \n\
		They appear to be in search of a station with a veil weakness to be able to channel their shadow's abyssal powers. \n\
		Thanks to this, they have also evolved a dark liquid in their veins, which makes them able to manipulate shadows. \n\
		Their Favorite Vassal appears to have been imbued with abyssal essence and is able to blend in with the shadows."
	join_icon_state = "lasombra"
	join_description = "Heal more on the dark, transform abilties into upgraded ones, become one with the darkness."

/datum/bloodsucker_clan/lasombra/New(mob/living/carbon/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/lasombra)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.eye_color = BLOODCULT_EYE
		human_user.updateappearance()
	ADD_TRAIT(user, CULT_EYES, BLOODSUCKER_TRAIT)
	user.faction |= "bloodhungry"
	user.update_body()
	var/obj/item/organ/heart/nightmare/nightmarish_heart = new
	nightmarish_heart.Insert(user)
	nightmarish_heart.Stop()
	for(var/obj/item/light_eater/blade in user.held_items)
		QDEL_NULL(blade)
	var/datum/objective/bloodsucker/hierarchy/lasombra_objective = new
	lasombra_objective.owner = user.mind
	bloodsuckerdatum.objectives += lasombra_objective
	GLOB.reality_smash_track.AddMind(user.mind)
	to_chat(user, span_notice("You have also learned how to channel the abyss's power into an iron knight's armor that can be build in the structure tab and activated as a trap for your lair."))
	user.mind.teach_crafting_recipe(/datum/crafting_recipe/possessedarmor)
	user.mind.teach_crafting_recipe(/datum/crafting_recipe/restingplace)

/datum/bloodsucker_clan/lasombra/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/bloodsucker)
	if(ishuman(vassaldatum.owner.current))
		var/mob/living/carbon/human/vassal = vassaldatum.owner.current
		vassal.see_in_dark = 8
		vassal.eye_color = BLOODCULT_EYE
		vassal.updateappearance()
	var/list/powers = list(new /obj/effect/proc_holder/spell/targeted/lesser_glare, new /obj/effect/proc_holder/spell/targeted/shadowwalk)
	for(var/obj/effect/proc_holder/spell/targeted/power in powers)
		vassaldatum.owner.AddSpell(power)
