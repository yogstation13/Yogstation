#define FABRICATOR_SUBCATEGORY_MATERIALS "/Materials"

/datum/design/manipulator_filter
	name = "Manipulator Filter"
	desc = "This can be inserted into a manipulator to give it filters."
	id = "manipulator_filter"
	build_path = /obj/item/manipulator_filter
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE | COLONY_FABRICATOR
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO
	)
	materials = list(/datum/material/iron = 2000)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/manipulator_filter_cargo
	name = "Manipulator Filter (Department)"
	desc = "This can be inserted into a manipulator to give it filters."
	id = "manipulator_filter_cargo"
	build_path = /obj/item/manipulator_filter/cargo
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE | COLONY_FABRICATOR
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO
	)
	materials = list(/datum/material/iron = 2000)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/manipulator_filter_internal
	name = "Manipulator Filter (Internal)"
	desc = "This can be inserted into a manipulator to give it filters."
	id = "manipulator_filter_internal"
	build_path = /obj/item/manipulator_filter/internal_filter
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE | COLONY_FABRICATOR
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO
	)
	materials = list(/datum/material/iron = 2000)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/big_manipulator
	name = "Big Manipulator Board"
	desc = "The circuit board for a big manipulator."
	id = "big_manipulator"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE | COLONY_FABRICATOR
	build_path = /obj/item/circuitboard/machine/big_manipulator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/assembler
	name = "Assembler Board"
	desc = "The circuit board for an assembler."
	id = "assembler"
	build_path = /obj/item/circuitboard/machine/assembler
	build_type = COLONY_FABRICATOR | IMPRINTER | AWAY_IMPRINTER
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/dissolution_chamber
	name = "Dissolution Chamber"
	id = "dissolution_chamber"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/dissolution_chamber
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/chemical_washer
	name = "Chemical Washer"
	id = "chemical_washer"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/chemical_washer
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/chemical_injector
	name = "Chemical Injector"
	id = "chemical_injector"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/chemical_injector
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/crystalizer
	name = "Crystalizer"
	id = "crystalizer"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/crystalizer
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/crusher
	name = "Crusher"
	id = "crusher"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/crusher
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/enricher
	name = "Enrichment Chamber"
	id = "enricher"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/enricher
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/purification_chamber
	name = "Purification Chamber"
	id = "purification_chamber"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/purification_chamber
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/brine_chamber
	name = "Brine Chamber Controller"
	id = "brine_chamber"
	build_type = COLONY_FABRICATOR | AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/ore_processing/brine_chamber
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 30 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

// Autolathe-able circuitboards for starting with boulder processing machines.
/datum/design/board/smelter
	name = "Boulder Smelter"
	desc = "A circuitboard for a boulder smelter. Lowtech enough to be printed from the lathe."
	id = "b_smelter"
	build_type = AUTOLATHE | COLONY_FABRICATOR
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/smelter
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/refinery
	name = "Boulder Refinery"
	desc = "A circuitboard for a boulder refinery. Lowtech enough to be printed from the lathe."
	id = "b_refinery"
	build_type = AUTOLATHE | COLONY_FABRICATOR
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/refinery
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING


/datum/design/board/brm
	name = "Boulder Retrieval Matrix"
	id = "brm"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/brm
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

#undef FABRICATOR_SUBCATEGORY_MATERIALS
