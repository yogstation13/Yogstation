//////////////////////////////////
////////  Mecha wreckage   ///////
//////////////////////////////////
/obj/structure/mecha_wreckage/loaded_ripley
	name = "intact Ripley wreckage"
	icon_state = "ripley-broken"

/obj/structure/mecha_wreckage/loaded_ripley/Initialize()
	. = ..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg,
								/obj/item/circuitboard/mecha/ripley/peripherals,
								/obj/item/circuitboard/mecha/ripley/main)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part