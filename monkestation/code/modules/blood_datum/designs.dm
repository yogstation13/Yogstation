/datum/design/vitals_monitor
	name = "Vitals Monitor"
	desc = "A wall mounted computer that displays the vitals of a patient nearby. \
		Links to stasis beds, operating tables, and other machines that can hold patients \
		such as cryo cells, sleepers, and more."
	id = "vitals_monitor"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/wallframe/status_display/vitals
	category = list(RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/vitals_monitor/advanced
	name = "Advanced Vitals Monitor"
	desc = "An updated vitals display which performs a more detailed scan of the patient than the basic display."
	id = "vitals_monitor_advanced"
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/wallframe/status_display/vitals/advanced

/datum/design/board/vital_floor_scanner
	name = "Vitals Scanning Pad"
	desc = "The circuit board for a vitals scanning pad."
	id = "scanning_pad"
	build_path = /obj/item/circuitboard/machine/vital_floor_scanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/circuitboard/machine/vital_floor_scanner
	name = "\improper Vitals Scanning Pad"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/health_scanner_floor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/scanning_module = 1,
	)
