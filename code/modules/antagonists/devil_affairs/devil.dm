/datum/antagonist/devil
	name = "Devil"
	roundend_category = "infernal affairs agents"
	antagpanel_category = "Devil Affairs"
	job_rank = ROLE_INFERNAL_AFFAIRS_DEVIL
	greentext_achieve = /datum/achievement/greentext/devil

	///The amount of souls the devil has so far.
	var/souls = 0
	///List of Powers we currently have unlocked.
	var/list/datum/action/devil_powers = list()

/datum/antagonist/devil/on_gain()
	. = ..()
	SSinfernal_affairs.devils += src
	obtain_power(/datum/action/cooldown/spell/pointed/summon_contract)
	obtain_power(/datum/action/cooldown/spell/pointed/collect_soul)

/datum/antagonist/devil/on_removal()
	clear_power(/datum/action/cooldown/spell/pointed/summon_contract)
	clear_power(/datum/action/cooldown/spell/pointed/collect_soul)
	SSinfernal_affairs.devils -= src
	return ..()

/**
 * ##update_souls_owned
 * 
 * Used to edit the amount of souls a Devil has. This can be a negative number to take away.
 * Will give Powers when getting to the proper level, or attempts to take them away if they go under
 * That way this works for both adding and removing.
 */
/datum/antagonist/devil/proc/update_souls_owned(souls_adding)
	souls += souls_adding

	switch(souls)
		if(0)
			clear_power(/datum/action/devil_transfer_body)
		if(1)
			obtain_power(/datum/action/devil_transfer_body)
			clear_power(/datum/action/cooldown/spell/conjure_item/violin)
		if(2)
			obtain_power(/datum/action/cooldown/spell/conjure_item/violin)
			clear_power(/datum/action/cooldown/spell/conjure_item/summon_pitchfork)
		if(3)
			obtain_power(/datum/action/cooldown/spell/conjure_item/summon_pitchfork)
			clear_power(/datum/action/cooldown/spell/jaunt/infernal_jaunt)
		if(4)
			obtain_power(/datum/action/cooldown/spell/jaunt/infernal_jaunt)
		if(7)
			clear_power(/datum/action/cooldown/spell/summon_dancefloor)
			clear_power(/datum/action/cooldown/spell/pointed/projectile/fireball/hellish)
			clear_power(/datum/action/cooldown/spell/shapeshift/devil)
		if(8)
			obtain_power(/datum/action/cooldown/spell/summon_dancefloor)
			obtain_power(/datum/action/cooldown/spell/pointed/projectile/fireball/hellish)
			obtain_power(/datum/action/cooldown/spell/shapeshift/devil)

/datum/antagonist/devil/proc/obtain_power(datum/action/new_power)
	new_power = new new_power
	devil_powers[new_power.type] = new_power
	new_power.Grant(owner.current)
	return TRUE

///Called when a Bloodsucker loses a power: (power)
/datum/antagonist/devil/proc/clear_power(datum/action/removed_power)
	if(devil_powers[removed_power])
		QDEL_NULL(devil_powers[removed_power])

/datum/action/cooldown/spell/pointed/summon_contract
	name = "Summon devil contract"
	desc = "Summon a contract that, when signed, will \
		add someone to the Agent's death loop."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/devil_transfer_body
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/jaunt/infernal_jaunt
	name = "Infernal Jaunt"
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
