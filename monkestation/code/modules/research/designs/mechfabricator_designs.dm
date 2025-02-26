/datum/design/borg_upgrade_uwu
	name = "Cyborg UwU-speak \"Upgrade\""
	id = "borg_upgrade_cringe"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/uwu
	materials = list(/datum/material/gold = 2000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	construction_time = 12 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL
	)

//IPC Parts//

/datum/design/ipc_part_head
	name = "IPC Replacement Head"
	id = "ipc_head"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500)
	build_path = /obj/item/bodypart/head/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_chest
	name = "IPC Replacement Chest"
	id = "ipc_chest"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/bodypart/chest/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_arm_left
	name = "IPC Replacement Left Arm"
	id = "ipc_arm_left"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/arm/left/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_arm_right
	name = "IPC Replacement Right Arm"
	id = "ipc_arm_right"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/arm/right/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_leg_left
	name = "IPC Replacement Left Leg"
	id = "ipc_leg_left"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/leg/left/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_leg_right
	name = "IPC Replacement Right Leg"
	id = "ipc_leg_right"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/leg/right/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/power_cord
	name = "Power Cord Implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	id = "power_cord"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/power_cord
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

// Maint modules
/datum/design/module/mod_springlock
	name = "Springlock Module"
	id = "mod_springlock"
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/titanium =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/mod/module/springlock
	category = list(
		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE  // The Animatronics were made to entertain afterall...

/datum/design/module/mod_rave
	name = "Rave Module"
	id = "mod_rave"
	materials = list(/datum/material/gold =SMALL_MATERIAL_AMOUNT*5, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/mod/module/visor/rave

/datum/design/module/mod_tanner
	name = "Tanning Module"
	id = "mod_tanner"
	materials = list(/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/diamond =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/mod/module/tanner

/datum/design/module/mod_balloon
	name = "Balloon Blower Module"
	id = "mod_balloon"
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/plastic = SMALL_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/mod/module/balloon
	category = list(
		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE  // Lore descibes being a mime module

/datum/design/module/mod_paper_dispenser
	name = "Paper Dispenser Module"
	id = "mod_paper_dispenser"
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plastic =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/mod/module/paper_dispenser

/datum/design/module/stamp
	name = "Stamp Module"
	id = "mod_stamp"
	materials = list(/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/plastic =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/mod/module/stamp

/datum/design/module/atrocinator
	name = "Atrocinator Module"
	id = "mod_atrocinator"
	materials = list(/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/bluespace =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/mod/module/atrocinator

/datum/design/module/joint_torsion
	name = "Joint Torsion Ratchet Module"
	id = "mod_joint_torsion"
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold = SMALL_MATERIAL_AMOUNT*2.5, /datum/material/titanium = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/mod/module/joint_torsion
	category = list(
		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUITS_MISC
	)

/datum/design/module/mirage
	name = "Mirage Grenade Dispenser Module"
	id = "mod_mirage_grenade"
	materials = list(
		/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace =HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/mod/module/dispenser/mirage
	category = list(
		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/borg_upgrade_piercinghypospray
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL,
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_PEACEKEEPER,
	)
