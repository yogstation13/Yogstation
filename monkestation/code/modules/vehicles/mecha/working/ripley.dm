/obj/vehicle/sealed/mecha/working/ripley/mk2/engineering
	equip_by_category = list(
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/rcd,
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters, /obj/item/mecha_parts/mecha_equipment/ejector, /obj/item/mecha_parts/mecha_equipment/extinguisher),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	armor_type = /datum/armor/working_ripley/engineering
	movedelay = 1.5 //Move speed, lower is faster.
	lights_power = 7
	fast_pressure_step_in = 1.75
	slow_pressure_step_in = 3
	step_energy_drain = 6
	operation_req_access = list(ACCESS_MECH_ENGINE)
	internals_req_access = list(ACCESS_CENT_GENERAL)

/datum/armor/working_ripley/engineering
	melee = 40
	bullet = 20
	laser = 20
	energy = 20
	bomb = 60
	fire = 100
	acid = 100
