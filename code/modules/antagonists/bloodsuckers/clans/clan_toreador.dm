/datum/bloodsucker_clan/toreador
	name = CLAN_TOREADOR
	description = "The most charming Clan of them all, allowing them to very easily disguise among the crew. \n\
		More in touch with their morals, they suffer and benefit more strongly from humanity cost or gain of their actions. \n\
		Known as 'The most humane kind of vampire', they have an obsession with perfectionism and beauty \n\
		The Favorite Vassal gains the Mesmerize ability."
	join_icon_state = "toreador"
	join_description = "Powerful Mesmerize, build statues to boost your status and mood, gather a large audience for your performance."
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY
	control_type = BLOODSUCKER_CONTROL_METAL

/datum/bloodsucker_clan/toreador/New(mob/living/carbon/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	if(user && ishuman(user) && !user.GetComponent(/datum/component/mood))
		user.AddComponent(/datum/component/mood) //You are not a emotionless beast! //trolled!
//		user.mind.teach_crafting_recipe(/datum/crafting_recipe/bloodybrush)
		user.mind.teach_crafting_recipe(/datum/crafting_recipe/moldingstone)
		user.mind.teach_crafting_recipe(/datum/crafting_recipe/chisel)

		for(var/datum/action/bloodsucker/masquerade/masquarade_spell in bloodsuckerdatum.powers)
			if(!istype(masquarade_spell))
				continue
			masquarade_spell.bloodcost = 0
			masquarade_spell.constant_bloodcost = 0
	var/datum/objective/bloodsucker/leader/toreador_objective = new
	toreador_objective.owner = user.mind
	bloodsuckerdatum.objectives += toreador_objective

/datum/bloodsucker_clan/toreador/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/bloodsucker)
	vassaldatum.BuyPower(new /datum/action/bloodsucker/targeted/mesmerize)
