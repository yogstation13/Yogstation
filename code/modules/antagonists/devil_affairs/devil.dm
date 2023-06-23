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
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/devil_transfer_body
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/conjure_item/summon_pitchfork
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/jaunt/infernal_jaunt
	name = "Infernal Jaunt"
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/conjure_item/violin
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/**
 * Ascended Powers
 */
/datum/action/cooldown/spell/summon_dancefloor
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/pointed/projectile/fireball/hellish
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/shapeshift/devil
	name = "Devil Form"
	desc = "Take on the true shape of a devil."
	invocation = "P'ease't d'y fo' ' w'lk!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	possible_shapes = list(/mob/living/simple_animal/hostile/devil)


/**
 * 
 * FROM THE HACKMD (delete this before merging):
 * 
 * Summon Contract: This spawns a contract that will allow an individual to become a Devil Affair Agent, inserting them into the loop in exchange for an Uplink. This can be used on Security and Command personnel, but will not work on Lawyers, the Head of Personnel, and the Curator.
 * Collect Soul: A spell used on dead Devil Affair Agents, will take the soul out of their body, making them unrevivable. This will advance the Devil’s level, and allow the Agent who had them as a target to advance in their own assassination goals.
 * 1 soul - They will gain the ability to transfer over to a new body on death (More details in ‘Death’ section).
 * 2 soul - Gets their Golden Violin
 * 3 soul - Gets to spawn in their Pitchfork, a dual wielded weapon that sets players on fire and has a high block chance, but low damage. Meant primarily as a defensive tool.
 * 4 souls - Gets their Ethereal Jaunt //intentionally skips one
 * 8 souls - Ascends, granting them Devil form (Simple mob (or Basic mob if they are ported by then)) & Fireball
 */
