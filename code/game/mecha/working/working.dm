/obj/mecha/working
	internal_damage_threshold = 60
	var/fast_pressure_step_in = 1.5 //step_in while in low pressure conditions
	var/slow_pressure_step_in = 2.0 //step_in while in normal pressure conditions

/obj/mecha/working/Move()
	. = ..()
	if(.)
		collect_ore()
	update_pressure()

/obj/mecha/working/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

/**
  * Handles collecting ore.
  *
  * Checks for a hydraulic clamp or ore box manager and if it finds an ore box inside them puts ore in the ore box.
  */
/obj/mecha/working/proc/collect_ore()
	if((locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in equipment) || (locate(/obj/item/mecha_parts/mecha_equipment/orebox_manager) in equipment))
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in contents
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, src))
				if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc)) //we can reach it and it's in front of us? grab it!
					ore.forceMove(ore_box)
