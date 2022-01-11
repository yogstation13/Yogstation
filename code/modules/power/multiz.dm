/obj/structure/cable/multiz //This bridges powernets betwen Z levels
	name = "multi z layer cable hub"
	desc = "A flexible, superconducting insulated multi Z layer hub for heavy-duty multi Z power transfer."
	//icon = 'icons/obj/power.dmi'
	//icon_state = "cablerelay-on"
	//cable_layer = CABLE_LAYER_1|CABLE_LAYER_2|CABLE_LAYER_3
	//machinery_layer = null
	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-multiz"\
	)

/obj/structure/cable/multiz/get_connections(powernetless_only = 0)
	. = ..()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/multiz/up = locate(/obj/structure/cable/multiz) in (SSmapping.get_turf_below(T))
	if(up)
		. += up

	var/obj/structure/cable/multiz/down = locate(/obj/structure/cable/multiz) in (SSmapping.get_turf_above(T))
	if(down)
		. += down

/obj/structure/cable/multiz/examine(mob/user)
	. += ..()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/multiz/up = locate(/obj/structure/cable/multiz) in (SSmapping.get_turf_below(T))
	var/obj/structure/cable/multiz/down = locate(/obj/structure/cable/multiz) in (SSmapping.get_turf_above(T))
	. += span_notice("[down ? "Detected" : "Undetected"] hub UP.")
	. += span_notice("[up ? "Detected" : "Undetected"] hub DOWN.")

