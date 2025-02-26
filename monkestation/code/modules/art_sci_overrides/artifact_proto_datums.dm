/datum/design/artifact_summon_wand
	name = "Artifact Wand"
	desc = "A wand used to create or modify artifacts."
	id = "artifact_wand"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold =SHEET_MATERIAL_AMOUNT, /datum/material/plasma =SHEET_MATERIAL_AMOUNT * 4, /datum/material/uranium =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/artifact_summon_wand
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/disk/artifact
	name = "Artifact Disk"
	desc = "A disk used to store artifact data."
	id = "disk_artifact"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT/2)
	build_path = /obj/item/disk/artifact
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	lathe_time_factor = 0.1
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
