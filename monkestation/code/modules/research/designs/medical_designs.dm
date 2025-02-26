/datum/design/extrapolator
	name = "virus extrapolator"
	desc = "A scanning device, used to extract genetic material of potential pathogens"
	id = "extrapolator"
	build_path = /obj/item/extrapolator
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/linked_surgery
	name = "surgical serverlink brain implant"
	desc = "A brain implant with a bluespace technology that lets you perform an advanced surgery through your station research server."
	id = "linked_surgery"
	build_path = /obj/item/organ/internal/cyberimp/brain/linked_surgery
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 1000, /datum/material/bluespace = 250)
	construction_time = 6 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_UTILITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/surgery/healing/filter_upgrade
	name = "Filter Blood Upgrade"
	desc = "Newfound knowledge allows us to remove the effect of toxins on the body whenever filtering someone's blood."
	surgery = /datum/surgery/blood_filter/upgraded
	id = "surgery_filter_upgrade"

/datum/design/surgery/healing/filter_upgrade_2
	name = "Filter Blood Upgrade"
	surgery = /datum/surgery/blood_filter/femto
	id = "surgery_filter_upgrade_femto"

/datum/design/surgical_glove
	name = "Surgical Latex Glove"
	desc = "Advanced latex gloves that allow the user to operate 25% quicker"
	id =  "surgical_gloves"
	build_path = /obj/item/clothing/gloves/latex/surgical
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/silver = 20000, /datum/material/gold = 1500)
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/surgery/robot_healing // Apparently this helps the code not scream looking at other examples?
	name = "Repair Robotic Limbs"
	desc = "A surgical procedure that provides highly effective repairs and maintenance to robotic limbs."
	surgery = /datum/surgery/robot_healing
	id = "surgery_heal_robot_base"
	research_icon_state = "surgery_chest"

/datum/design/surgery/robot_healing/upgraded
	name = "Repair Robotic Limbs (Physical) Upgrade"
	desc = "A surgical procedure that provides highly effective repairs and maintenance to robotic limbs. Is somewhat more efficient when the patient is severely damaged."
	surgery = /datum/surgery/robot_healing/upgraded
	id = "surgery_heal_robot_upgrade"
	research_icon_state = "surgery_chest"

/datum/design/surgery/robot_healing/upgraded_2
	name = "Repair Robotic Limbs (Physical) Upgrade"
	desc = "A surgical procedure that quickly provides highly effective repairs and maintenance to robotic limbs. Is moderately more efficient when the patient is severely damaged."
	surgery = /datum/surgery/robot_healing/experimental
	id = "surgery_heal_robot_upgrade_femto"
	research_icon_state = "surgery_chest"

/datum/design/cyberimp_sprinter
	name = "Vacuole ligament system"
	desc = "Mechicanical servos in ones leg that increases their natural stride. Popular amongst parkour enthusiasts. You need to implant this in both of your legs to make it work."
	id = "ci-sprinter"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 1000, /datum/material/silver =SMALL_MATERIAL_AMOUNT*5, /datum/material/gold =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/organ/internal/cyberimp/leg/sprinter
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_UTILITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/glasses
	name = "Prescription glasses"
	desc = "Glasses that can fix vision."
	id = "pglasses"
	build_type = PROTOLATHE | AWAY_LATHE | COLONY_FABRICATOR
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/clothing/glasses/regular
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/pathology_goggles
	name = "Viral Analyzer Goggles"
	desc = "A pair of goggles fitted with an analyzer for viral particles and reagents."
	id = "pathology_goggles"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/clothing/glasses/pathology
	category = list(RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/nv_pathology_goggles
	name = "Night Vision Viral Analyzer Goggles"
	desc = "A pair of night vision goggles fitted with an analyzer for viral particles and reagents."
	id = "nv_pathology_goggles"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium = 350)
	build_path = /obj/item/clothing/glasses/night/pathology
	category = list(RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/surgery/dna_recovery
	name = "DNA Recovery"
	desc = "A surgical procedure which involves using rezadone to salvage a single strand of DNA from the patient, allowing them to be cloned."
	id = "surgery_dna_recovery"
	surgery = /datum/surgery/advanced/dna_recovery
	research_icon_state = "surgery_head"
