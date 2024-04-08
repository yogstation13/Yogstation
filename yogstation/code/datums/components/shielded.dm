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

	///Cooldown after getting hit for the shield to recharge
	COOLDOWN_DECLARE(recharge_cooldown)

	///clothing slot the item is stored in
	var/target_slot

	///the visual overlay of the shield
	var/mutable_appearance/cached_mutable_appearance

	///whether or not the shield visual is emissive
	var/emissive = FALSE

	///the emissive visual overlay of the shield
	var/mutable_appearance/cached_emissive_appearance

	///Boolean whether or not the shield is currently worn the user
	var/shield_active = TRUE

	var/mob/living/current_owner

/datum/component/shielded/Initialize(shielded_icon, shielded_icon_state, max_shield, shielded_recharge, slot, emissive_shield = FALSE)
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
	emissive = emissive_shield
	cached_mutable_appearance = mutable_appearance(shield_icon, shield_icon_state)
	cached_emissive_appearance = emissive_appearance(shield_icon, shield_icon_state, parent)

	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/datum/component/shielded/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/shielded/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(drain_charge())
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, current_owner)
		s.start()
		current_owner.visible_message(span_danger("[current_owner]'s shields deflect [attack_text] in a shower of sparks!"))
		return COMPONENT_HIT_REACTION_BLOCK

/datum/component/shielded/proc/drain_charge()
	if(!shield_active)
		return FALSE
	if(!current_owner)
		return FALSE 
	if(current_shield_charges <= 0)
		return FALSE
	
	current_shield_charges --

	current_owner.update_appearance(UPDATE_OVERLAYS)

	if(shield_recharge)
		COOLDOWN_START(src, recharge_cooldown, shield_recharge)
		START_PROCESSING(SSobj, src)
	return TRUE

/datum/component/shielded/process(delta_time)
	if(COOLDOWN_FINISHED(src, recharge_cooldown) && current_shield_charges < max_shield_charges)
		current_shield_charges = clamp(current_shield_charges + 1, 0, max_shield_charges)
		playsound(get_turf(parent), 'sound/magic/charge.ogg', 50, 1)
		if(current_shield_charges >= max_shield_charges)
			STOP_PROCESSING(SSobj, src)
		if(current_owner)	
			current_owner.update_appearance(UPDATE_OVERLAYS)

/datum/component/shielded/proc/on_equipped(datum/source, mob/equipper, slot)
	current_owner = equipper
	shield_active = (target_slot == slot)
	RegisterSignal(current_owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_shield_overlay))
	current_owner.update_appearance(UPDATE_OVERLAYS)

/datum/component/shielded/proc/on_dropped(datum/source,mob/dropper)
	shield_active = FALSE
	UnregisterSignal(current_owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	current_owner.update_appearance(UPDATE_OVERLAYS)
	current_owner =  null

/datum/component/shielded/proc/update_shield_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(shield_active && current_shield_charges >= 1)
		overlays += cached_mutable_appearance
		if(emissive)
			overlays += cached_emissive_appearance
