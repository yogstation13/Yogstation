//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/armor
	name = "armor booster module (Bad Code)"
	desc = "Boosts exosuit armor against manatee. Make a bug report if you see this."
	range = NONE
	selectable = FALSE
	equip_ready = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)
	/// Reduces the effect of cooling.
	var/cooling_multiplier = 0.8

/obj/item/mecha_parts/mecha_equipment/armor/can_attach(obj/mecha/M)
	for(var/obj/item/equip as anything in M.equipment)
		if(istype(equip, type)) // absolutely NO stacking armor to become invincible
			return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/attach(obj/mecha/new_chassis)
	. = ..()
	if(equip_ready)
		new_chassis.armor = new_chassis.armor.attachArmor(armor)

/obj/item/mecha_parts/mecha_equipment/armor/detach(atom/moveto)
	if(equip_ready)
		chassis.armor = chassis.armor.detachArmor(armor)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/set_ready_state(state)
	if(equip_ready != state)
		if(state)
			chassis.armor = chassis.armor.attachArmor(armor)
		else
			chassis.armor = chassis.armor.detachArmor(armor)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/melee //what is that noise? A BAWWW from TK mutants.
	name = "armor booster module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks."
	icon_state = "mecha_abooster_ccw"
	armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)

/obj/item/mecha_parts/mecha_equipment/armor/ranged
	name = "armor booster module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks."
	icon_state = "mecha_abooster_proj"
	armor = list(MELEE = 0, BULLET = 15, LASER = 15, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)
