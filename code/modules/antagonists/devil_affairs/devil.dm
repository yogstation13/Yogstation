/datum/antagonist/devil
	name = "Devil"
	roundend_category = "infernal affairs agents"
	job_rank = ROLE_INFERNAL_AFFAIRS_DEVIL
	greentext_achieve = /datum/achievement/greentext/devil

	var/static/list/devil_powers = typecacheof(list(
		/datum/action/cooldown/spell/pointed/summon_contract,
		/datum/action/cooldown/spell/pointed/collect_soul,
		/datum/action/devil_transfer_body,
		/datum/action/cooldown/spell/conjure_item/summon_pitchfork,
		/datum/action/cooldown/spell/jaunt/infernal_jaunt,
		/datum/action/cooldown/spell/conjure_item/violin,
		/datum/action/cooldown/spell/summon_dancefloor,
		/datum/action/cooldown/spell/pointed/projectile/fireball/hellish,
		/datum/action/cooldown/spell/shapeshift/devil,
	))
	///The amount of souls the devil has so far.
	var/souls = 0

/datum/antagonist/devil/on_gain()
	. = ..()
	SSinfernal_affairs.devils += src
	RegisterSignal(SSinfernal_affairs, COMSIG_ON_SOUL_HARVESTED, PROC_REF(on_soul_harvest))

/datum/antagonist/devil/on_removal()
	UnregisterSignal(SSinfernal_affairs, COMSIG_ON_SOUL_HARVESTED)
	SSinfernal_affairs.devils -= src
	return ..()

/datum/antagonist/devil/proc/on_soul_harvest(atom/source, datum/antagonist/infernal_affairs/harvested_agent)
	SIGNAL_HANDLER
	if(harvested_agent.owner.current.stat != DEAD)
		return
	ADD_TRAIT(harvested_agent.owner, TRAIT_HELLBOUND, DEVIL_TRAIT)
	souls++
	SSinfernal_affairs.update_objective_datums()

/datum/action/cooldown/spell/pointed/summon_contract
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

/datum/action/cooldown/spell/pointed/collect_soul
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
