/datum/bloodsucker_clan/toreador
	name = CLAN_TOREADOR
	description = "The most charming Clan of them all, allowing them to very easily disguise among the crew. \n\
		More in touch with their morals, they suffer and benefit more strongly from humanity cost or gain of their actions. \n\
		Known as 'The most humane kind of vampire', they have an obsession with perfectionism and beauty \n\
		The Favorite Vassal gains the Mesmerize ability."
	clan_objective = /datum/objective/toreador_clan_objective
	join_icon_state = "toreador"
	join_description = "Powerful Mesmerize, build statues to boost your status and mood, gather a large audience for your performance."
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY
	control_type = BLOODSUCKER_CONTROL_METAL


/datum/objective/toreador_clan_objective
	name = "leader"
	martyr_compatible = TRUE

/datum/objective/toreador_clan_objective/New()
	target_amount = rand(2, 3)
	..()
	update_explanation_text()

/datum/objective/toreador_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(LAZYLEN(bloodsuckerdatum?.vassals) >= target_amount)
		return TRUE
	return FALSE


/datum/bloodsucker_clan/toreador/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE, PROC_REF(on_bloodsucker_broke_masquerade))
	if(bloodsuckerdatum.owner.current && ishuman(bloodsuckerdatum.owner.current) && !bloodsuckerdatum.owner.current.GetComponent(/datum/component/mood))
		bloodsuckerdatum.owner.current.AddComponent(/datum/component/mood) //You are not a emotionless beast! //trolled!
//		user.mind.teach_crafting_recipe(/datum/crafting_recipe/bloodybrush)
		bloodsuckerdatum.owner.teach_crafting_recipe(/datum/crafting_recipe/moldingstone)
		bloodsuckerdatum.owner.teach_crafting_recipe(/datum/crafting_recipe/chisel)

		for(var/datum/action/cooldown/bloodsucker/masquerade/masquarade_spell in bloodsuckerdatum.powers)
			if(!istype(masquarade_spell))
				continue
			masquarade_spell.bloodcost = 0
			masquarade_spell.constant_bloodcost = 0

/datum/bloodsucker_clan/toreador/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE)
	return ..()

/datum/bloodsucker_clan/toreador/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	vassaldatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/mesmerize)

/datum/bloodsucker_clan/toreador/proc/on_bloodsucker_broke_masquerade(datum/antagonist/bloodsucker/masquerade_breaker)
	SIGNAL_HANDLER
	to_chat(bloodsuckerdatum.owner.current, span_userdanger("[masquerade_breaker.owner.current] has broken the Masquerade! Ensure [masquerade_breaker.owner.current.p_they()] [masquerade_breaker.owner.current.p_are()] eliminated at all costs!"))
	var/datum/objective/assassinate/masquerade_objective = new()
	masquerade_objective.target = masquerade_breaker.owner.current
	masquerade_objective.objective_name = "Clan Objective"
	masquerade_objective.explanation_text = "Ensure [masquerade_breaker.owner.current], who has broken the Masquerade, succumbs to Final Death."
	bloodsuckerdatum.objectives += masquerade_objective
	bloodsuckerdatum.owner.announce_objectives()
