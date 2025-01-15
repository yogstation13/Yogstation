/obj/item/card/emag
	var/microwaved = FALSE
	var/microwaved_uses_left = -1

/obj/item/card/emag/microwave_act(obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	if (microwaved)
		microwave_source.can_eject = FALSE
		INVOKE_ASYNC(src, PROC_REF(microwave_explode), microwave_source, microwaver)
		return ..() | COMPONENT_MICROWAVE_DONTEJECT | COMPONENT_MICROWAVE_DONTDIRTY | COMPONENT_MICROWAVE_DONTOPEN
	desc += " Some of the components look a little crispy."
	icon_state = "[initial(icon_state)]_burnt"

	microwaved_uses_left = 5
	microwaved = TRUE
	return ..() | COMPONENT_MICROWAVE_SUCCESS | COMPONENT_MICROWAVE_DONTDIRTY

/obj/item/card/emag/proc/microwave_explode(obj/machinery/microwave/microwave_source, mob/microwaver)
	microwave_source.spark()
	sleep(0.6 SECONDS)
	// explode the microwave,
	explosion(microwave_source, heavy_impact_range = 0, light_impact_range = 2, flame_range = 1, smoke = TRUE)
	microwave_source.broken = 2
	if(!QDELETED(src))
		qdel(src)
	microwave_source.update_appearance()

/obj/item/card/emag/examine_more(mob/user)
	. = ..()
	. += span_notice("I wonder what happens if you microwave it... surely that's not a good idea.")
