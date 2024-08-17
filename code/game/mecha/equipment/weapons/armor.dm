//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/armor
	name = "armor booster module (Bad Code)"
	desc = "Boosts exosuit armor against manatee. Make a bug report if you see this."
	range = NONE
	selectable = FALSE
	equip_ready = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)
	/// Reduces the effect of cooling.
	var/cooling_multiplier = 0.9

/obj/item/mecha_parts/mecha_equipment/armor/can_attach(obj/mecha/M)
	for(var/obj/item/equip as anything in M.equipment)
		if(istype(equip, type)) // absolutely NO stacking armor to become invincible
			return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/attach(obj/mecha/new_chassis)
	. = ..()
	if(equip_ready)
		new_chassis.armor.attachArmor(armor)

/obj/item/mecha_parts/mecha_equipment/armor/detach(atom/moveto)
	if(equip_ready)
		chassis.armor.detachArmor(armor)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/set_ready_state(state)
	if(equip_ready != state)
		if(state)
			chassis.armor.attachArmor(armor)
		else
			chassis.armor.detachArmor(armor)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/melee //what is that noise? A BAWWW from TK mutants.
	name = "armor booster module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)
	cooling_multiplier = 0.9

/obj/item/mecha_parts/mecha_equipment/armor/ranged
	name = "armor booster module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	armor = list(MELEE = 0, BULLET = 15, LASER = 15, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)

/obj/item/mecha_parts/mecha_equipment/armor/energy // unused for now, might add it to the uplink later
	name = "armor booster modules (Energy Weaponry)"
	desc = "Boosts exosuit armor against energy weapons. Generates large amounts of heat."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 30, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 50)

/obj/item/mecha_parts/mecha_equipment/armor/emp/attach(obj/mecha/new_chassis)
	. = ..()
	new_chassis.heat_modifier *= 1.2 // increases heating on top of the cooling reduction
	RegisterSignal(new_chassis, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_react))

/obj/item/mecha_parts/mecha_equipment/armor/emp/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_ATOM_EMP_ACT)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/emp/proc/emp_react(severity)
	SIGNAL_HANDLER
	return EMP_PROTECT_CONTENTS // protects things inside the mech

/obj/item/mecha_parts/mecha_equipment/armor/reactive // also unused, has no sprite for now
	name = "armor booster module (Reactive)"
	desc = "Boosts exosuit armor against all attacks. Requires time to recharge after taking too much damage. Less effective against energy weapons."
	equip_ready = TRUE
	equip_cooldown = 5 SECONDS
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 75)
	/// Sustained damage over time.
	var/sustained_damage = 0
	/// Limit of how much damage it can take before the armor is disabled.
	var/damage_limit = 25
	/// How much damage to convert into heat and energy.
	var/damage_conversion = 0.6

/obj/item/mecha_parts/mecha_equipment/armor/reactive/attach(obj/mecha/new_chassis)
	. = ..()
	RegisterSignal(new_chassis, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(armor_react))

/obj/item/mecha_parts/mecha_equipment/armor/reactive/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_ATOM_TAKE_DAMAGE)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/reactive/on_process(delta_time)
	if(sustained_damage)
		sustained_damage = max(0, sustained_damage - damage_limit * (delta_time / equip_cooldown))

/obj/item/mecha_parts/mecha_equipment/armor/reactive/proc/armor_react(atom/source, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(!damage_amount)
		return NONE
	if(damage_type != BRUTE && damage_type != BURN)
		return NONE
	if(equip_ready)
		sustained_damage += damage_amount
		chassis.use_power(damage_amount * damage_conversion)
		chassis.adjust_overheat(damage_amount * damage_conversion)
	if(sustained_damage >= damage_limit)
		start_cooldown()
