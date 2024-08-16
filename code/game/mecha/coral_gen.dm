/obj/item/mecha_parts/mecha_equipment/coral_generator
	name = "IA-C01G AORTA"
	desc = "A highly classified emergent technology, burns raw redspace crystal to emit a red glow, greatly increasing the mech's movement speed, at the cost of greater energy usage."
	icon_state = "coral_engine" 
	selectable = FALSE // your mech IS the weapon
	var/minimum_damage = 10
	var/structure_damage_mult = 4
	var/list/hit_list = list()
	equip_actions = list(/datum/action/innate/mecha/coral_overload_mode)

/obj/item/mecha_parts/mecha_equipment/coral_generator/can_attach(obj/mecha/new_mecha)
	if(locate(type) in new_mecha.equipment)
		return FALSE // no stacking multiple
	return ..()

/datum/action/innate/mecha/coral_overload_mode
	name = "Coral Engine Overload"
	button_icon_state = "mech_coral_overload_off"

/datum/action/innate/mecha/coral_overload_mode/Activate(forced_state = null)
	if(chassis?.equipment_disabled) // If a EMP or something has messed a mech up return instead of activating -- Moogle
		return
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.coral_leg_overload_mode = forced_state
	else
		chassis.coral_leg_overload_mode = !chassis.coral_leg_overload_mode
	button_icon_state = "mech_coral_overload_[chassis.coral_leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled coral engine overload.", LOG_MECHA)
	if(chassis.coral_leg_overload_mode)
		chassis.AddComponent(/datum/component/after_image, 0.5 SECONDS, 0.5, TRUE)
		chassis.coral_leg_overload_mode = 1
		chassis.step_in = min(1, round(chassis.step_in/2))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.occupant_message(span_danger("You enable coral engine overload."))
	else
		var/datum/component/after_image/chassis_after_image = chassis.GetComponent(/datum/component/after_image)
		if(chassis_after_image)
			qdel(chassis_after_image)
		chassis.coral_leg_overload_mode = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message(span_notice("You disable coral engine overload."))
	build_all_button_icons()
