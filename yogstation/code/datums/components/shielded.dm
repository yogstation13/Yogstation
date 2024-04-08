/datum/component/shielded

	///file to get the shield icon from
	var/shield_icon 
	///specific icon used for the shield
	var/shield_icon_state 


	///current number of shield charges
	var/current_shield_charges
	///maximum number of charges the shield can have
	var/max_shield_charges
	///How long it takes for a shield charge to recharge
	var/shield_recharge

	///clothing slot the item is stored in
	var/target_slot

	///the visual overlay of the shield
	var/mutable_appearance/cached_mutable_appearance

	///Boolean, if the mutable appearance is currently being shown
	var/is_shielded = FALSE

	var/mob/living/current_owner

/datum/component/shielded/Initialize(shielded_icon, shielded_icon_state, max_shield, shielded_recharge, slot)
	if(!shielded_icon)	
		CRASH("Invalid shield icon passed")
	if(!shielded_icon_state)
		CRASH("Invalid shield icon state passed")
	if(!isnum(max_shield))
		CRASH("Invalid max shield charges passed, expected number, found [max_shield]")
	if(!isnum(shielded_recharge))
		CRASH("Invalid shield recharge passed, expected number, found [shielded_recharge]")

	shield_icon = shielded_icon 
	shield_icon_state = shielded_icon_state
	max_shield_charges = max_shield
	current_shield_charges = max_shield_charges
	shield_recharge = shielded_recharge
	target_slot = slot
	cached_mutable_appearance = mutable_appearance(shield_icon, shield_icon_state)

	RegisterSignal(parent,COMSIG_ITEM_HIT_REACT,PROC_REF(on_hit_react))
	RegisterSignal(parent,COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent,COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_LIVING_UPDA)

/datum/component/shielded/proc/apply_shield()
	if(is_shielded)
		return
	
	is_shielded = TRUE
	
	if(!current_owner)
		return

	if(is_charged)
		current_owner.add_overlay(cached_mutable_appearance)

/datum/component/shielded/proc/remove_shield()
	if(!is_shielded)
		return

	is_shielded = FALSE

	if(!current_owner)
		return
	
	if(is_charged)
		current_owner.cut_overlay(cached_mutable_appearance)
	
/datum/component/shielded/proc/drain_charge()
	if(!is_charged)
		return 
	is_charged = FALSE
	if(!current_owner)
		return 
	current_owner.cut_overlay(cached_mutable_appearance)
	addtimer(CALLBACK(src,PROC_REF(recharge)), shield_recharge)

/datum/component/shielded/proc/recharge()
	if(is_charged)
		return 
	is_charged = TRUE
	if(!current_owner)
		return
	current_owner.add_overlay(cached_mutable_appearance)

/datum/component/shielded/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!is_shielded || !is_charged)
		return
	drain_charge()
	return COMPONENT_HIT_REACTION_BLOCK

/datum/component/shielded/proc/on_equipped(datum/source, mob/equipper, slot)
	current_owner = equipper
	if(target_slot && target_slot != slot)
		remove_shield()
		return
	apply_shield()

/datum/component/shielded/proc/on_dropped(datum/source,mob/dropper)
	remove_shield()
	current_owner =  null
