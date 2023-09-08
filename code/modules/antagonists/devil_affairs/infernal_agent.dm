/datum/antagonist/infernal_affairs
	name = "Infernal Affairs Agent"
	roundend_category = "infernal affairs agents"
	antagpanel_category = "Devil Affairs"
	antag_hud_name = "sintouched"
	job_rank = ROLE_INFERNAL_AFFAIRS
	preview_outfit = /datum/outfit/devil_affair_agent

	///Reference to the Uplink, so we can mess with it when required.
	var/datum/component/uplink/uplink_holder
	///The active objective this agent has to currently complete.
	var/datum/objective/assassinate/internal/active_objective

	var/list/purchased_uplink_items = list()

/datum/antagonist/infernal_affairs/on_gain(mob/living/mob_override)
	. = ..()
	SSinfernal_affairs.agent_datums += src
	uplink_holder = owner.equip_traitor(employer = "The Devil", uplink_owner = src)
	if(owner.assigned_role != "Lawyer")
		uplink_holder.telecrystals = 10
	RegisterSignal(uplink_holder, COMSIG_ON_UPLINK_PURCHASE, PROC_REF(on_uplink_purchase))

/datum/antagonist/infernal_affairs/on_removal()
	. = ..()
	SSinfernal_affairs.agent_datums -= src
	UnregisterSignal(uplink_holder, COMSIG_ON_UPLINK_PURCHASE)
	QDEL_NULL(uplink_holder)

/datum/antagonist/infernal_affairs/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	//IAAs can only see devils (handled by devils), not eachother, but devils can see them.
	add_team_hud(current_mob, antag_to_check = /datum/antagonist/devil)
	RegisterSignal(mob_override, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/antagonist/infernal_affairs/remove_innate_effects(mob/living/mob_override)
	UnregisterSignal(mob_override, COMSIG_LIVING_DEATH)
	return ..()

///Handles affair agents when they die.
///If there are devils, update objectives to let them know they should hand the body in.
///If there aren't, go straight to harvesting (without the rewards).
/datum/antagonist/infernal_affairs/proc/on_death(atom/source, gibbed)
	SIGNAL_HANDLER
	if(length(SSinfernal_affairs.devils))
		SSinfernal_affairs.update_objective_datums()
		return
	INVOKE_ASYNC(src, PROC_REF(soul_harvested))

/**
 * ## on_uplink_purchase
 * 
 * Called when an uplink item is purchased.
 * We will keep track of their items to destroy them when the Agent dies.
 */
/datum/antagonist/infernal_affairs/proc/on_uplink_purchase(datum/component/uplink/source, atom/purchased_item, mob/living/purchaser)
	SIGNAL_HANDLER
	if(!isitem(purchased_item))
		return
	purchased_uplink_items += purchased_item.get_all_contents()

/**
 * ##soul_harvested
 * 
 * Handles making their mind unrevivable and the deletion of all their items,
 * on top of all misc effects like updating objectives and giving rewards.
 */
/datum/antagonist/infernal_affairs/proc/soul_harvested(datum/antagonist/infernal_affairs/killer)
	SSinfernal_affairs.agent_datums -= src
	ADD_TRAIT(owner, TRAIT_HELLBOUND, DEVIL_TRAIT)
	QDEL_LIST(purchased_uplink_items)

	//grant the soul to ALL devils, though without admin intervention there should only be one.
	for(var/datum/antagonist/devil/devil as anything in SSinfernal_affairs.devils)
		if(devil.owner.current)
			devil.update_souls_owned(1)

	if(killer && killer.owner.assigned_role != "Lawyer")
		killer.uplink_holder.telecrystals += rand(3,5)
	
	SSinfernal_affairs.update_objective_datums()

/datum/outfit/devil_affair_agent
	name = "Devil Affairs Agent (Preview only)"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	head = /obj/item/clothing/head/devil_horns
	glasses = /obj/item/clothing/glasses/sunglasses
	r_hand = /obj/item/melee/transforming/energy/sword

/datum/outfit/devil_affair_agent/post_equip(mob/living/carbon/human/owner, visualsOnly)
	var/obj/item/melee/transforming/energy/sword/sword = locate() in owner.held_items
	sword.transform_weapon(owner, TRUE)

/obj/item/clothing/head/devil_horns
	desc = "The one the only Devil."
	icon_state = "devil_horns"

/**
 * ##calling card
 * 
 * This item is required to be on someone to know if rewards should be given out.
 */
/obj/item/paper/calling_card
	name = "calling card"
	color = "#ff5050"
	foldable = FALSE
	info = {"<b>**Death to Allentown.**</b><br><br>"}

	///A weakref to the antag datum who signed the paper, so simply holding a paper for YOUR target doesn't make you eligible.
	var/datum/weakref/signed_by_ref

/obj/item/paper/calling_card/Initialize(mapload, datum/antagonist/infernal_affairs/agent_datum)
	. = ..()
	if(!agent_datum)
		stack_trace("calling card made but does not have an agent datum. This will cause errors as it is expected!")
		return INITIALIZE_HINT_QDEL
	signed_by_ref = WEAKREF(agent_datum)

/obj/item/paper/calling_card/Destroy()
	signed_by_ref = null
	return ..()
