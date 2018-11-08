//////////////////////////////////
////////  Mecha wreckage   ///////
//////////////////////////////////
/obj/structure/mecha_wreckage/loaded_ripley
	name = "intact Ripley wreckage"
	icon_state = "ripley-broken"

/obj/structure/mecha_wreckage/loaded_ripley/Initialize()
	. = ..()
	welder_salvage = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	crowbar_salvage = list(/obj/item/circuitboard/mecha/ripley/peripherals,
							/obj/item/circuitboard/mecha/ripley/main)
