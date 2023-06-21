/datum/antagonist/infernal_affairs
	name = "Infernal Affairs Agent"
	roundend_category = "infernal affairs agents"
	job_rank = ROLE_INFERNAL_AFFAIRS
	preview_outfit = /datum/outfit/devil_affair_agent
	///Reference to the Uplink, so we can mess with it when required.
	var/datum/component/uplink/uplink_holder
	///The active objective this agent has to currently complete.
	var/datum/objective/assassinate/internal/active_objective

/datum/antagonist/infernal_affairs/on_gain(mob/living/mob_override)
	. = ..()
	uplink_holder = owner.equip_traitor(employer = "The Devil", uplink_owner = src)

/datum/antagonist/infernal_affairs/on_removal()
	. = ..()
	QDEL_NULL(uplink_holder)

/datum/outfit/devil_affair_agent
	name = "Devil Affairs Agent (Preview only)"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	head = /obj/item/clothing/head/devil_horns
	glasses = /obj/item/clothing/glasses/sunglasses
	r_hand = /obj/item/melee/transforming/energy/sword

/datum/outfit/devil_affair_agent/post_equip(mob/living/carbon/human/owner, visualsOnly)
	var/obj/item/melee/transforming/energy/sword/sword = locate() in owner.held_items
	sword.transform_weapon(owner, TRUE)
//	owner.update_inv_hands()

/obj/item/clothing/head/devil_horns
	desc = "The one the only Devil."
	icon_state = "devil_horns"
