/obj/spacepod/prebuilt
	icon = 'yogstation/goon/icons/obj/spacepods/2x2.dmi'
	icon_state = "pod_civ"
	var/cell_type = /obj/item/stock_parts/cell/high/plus
	var/armor_type = /obj/item/pod_parts/armor
	var/internal_tank_type = /obj/machinery/portable_atmospherics/canister/air
	var/equipment_types = list()
	construction_state = SPACEPOD_ARMOR_WELDED

/obj/spacepod/prebuilt/Initialize()
	..()
	add_armor(new armor_type(src))
	if(cell_type)
		cell = new cell_type(src)
	if(internal_tank_type)
		internal_tank = new internal_tank_type(src)
	for(var/equip in equipment_types)
		var/obj/item/spacepod_equipment/SE = new equip(src)
		SE.on_install(src)

/obj/spacepod/prebuilt/sec
	name = "security space pod"
	icon_state = "pod_mil"
	locked = TRUE
	armor_type = /obj/item/pod_parts/armor/security
	equipment_types = list(/obj/item/spacepod_equipment/weaponry/disabler,
		/obj/item/spacepod_equipment/lock/keyed/sec,
		/obj/item/spacepod_equipment/tracker,
		/obj/item/spacepod_equipment/cargo/chair)
